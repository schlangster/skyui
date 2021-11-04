#include "skse64/PluginAPI.h"
#include "skse64/ScaleformValue.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/ScaleformCallbacks.h"
#include "skse64/ScaleformAPI.h"
#include "skse64/Hooks_UI.h"
#include "common/ICriticalSection.h"
#include "skse64/InternalVR.h"
#include "skse64/GameVR.h"
#include "skse64/Hooks_Threads.h"
#include "skse64/InternalVR.h"

#include <new>
#include <list>
#include <thread>
#include <future>
#include <assert.h>


namespace Keyboard {
   namespace vr = vr_1_0_12;

   auto vrContext = vr::COpenVRContext();
   vr::VROverlayHandle_t keyboardOverlayHandle = 0;
   std::thread* keyboardHandlerThread = nullptr;

   void WaitForKeyboardInput(GFxValue desc, GFxValue currentText, GFxValue thisValue, GFxValue func) {
      // In the case where the user is clicking on the search box directly,
      // wait a short while before activating the keyboard.
      // If we don't do this, the keyboard might become active before the trigger can be released.
      // Steamvr may immediately dismiss the keyboard if the keyboard becomes active, because the
      // controller is pointing away from the keyboard and the trigger is still depressed.
      // This gives the user a bit of time to release the trigger.
      // This isn't perfect. A better solution may be to wait for both controller's trigger to become
      // fully released first.
      Sleep(100);

      const int charMax = 255;

      // Bring up the keyboard
      vr::EVROverlayError err;
      err = vrContext.VROverlay()->ShowKeyboardForOverlay(keyboardOverlayHandle, vr::k_EGamepadTextInputModeNormal, vr::k_EGamepadTextInputLineModeSingleLine, desc.GetString(), charMax, currentText.GetString(), false, 0);
      if (err != vr::EVROverlayError::VROverlayError_None)
         return;

      vr::VREvent_t eventData;
      while (true)
      {
         // Consume all overlay events
         if (vrContext.VROverlay()->PollNextOverlayEvent(keyboardOverlayHandle, &eventData, sizeof(vr::VREvent_t)))
         {
            // Look for event where the keyboard is dismissed
            if (eventData.eventType == vr::VREvent_KeyboardClosed || eventData.eventType == vr::VREvent_KeyboardDone)
            {
               // Grab the entered text in its entirety.
               char buffer[charMax+1];
               vrContext.VROverlay()->GetKeyboardText(buffer, charMax);

               // Invoke the callback to send the result back to the Scaleform UI.
               GFxValue vals[3];
               vals[0] = thisValue;
               auto objectInterface = func.objectInterface;
               if (objectInterface) {
                  auto movieRoot = objectInterface->root;
                  if (movieRoot) {
                     movieRoot->CreateString(&vals[1], buffer);
                  }
               }
               vals[2].SetNumber(0);
               func.Invoke("call", nullptr, vals, 3);

               //vrContext.VROverlay()->DestroyOverlay(handle);
               break;
            }
         }
         Sleep(50);
      }

      keyboardHandlerThread->detach();
      delete keyboardHandlerThread;
      keyboardHandlerThread = nullptr;
   }


   class Scaleform_ShowVirtualKeyboard : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 6);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key
         ASSERT(args->args[1].GetType() == GFxValue::kType_String); // Title
         ASSERT(args->args[2].GetType() == GFxValue::kType_String); // Desc
         ASSERT(args->args[3].GetType() == GFxValue::kType_String); // Text
         ASSERT(args->args[4].GetType() == GFxValue::kType_Object || args->args[4].GetType() == GFxValue::kType_DisplayObject); // This
         ASSERT(args->args[5].GetType() == GFxValue::kType_Object); // Function

         // Lazily initialize the keyboard overlay
         vr::EVROverlayError err;
         if (keyboardOverlayHandle == 0) {
            err = vrContext.VROverlay()->CreateOverlay(args->args[0].GetString(), args->args[1].GetString(), &keyboardOverlayHandle);
            if (err != vr::EVROverlayError::VROverlayError_None)
               return;
         }

         // Start a thread to wait for keyboard input.
         assert(keyboardHandlerThread == nullptr);
         keyboardHandlerThread = new std::thread(WaitForKeyboardInput, args->args[2], args->args[3], args->args[4], args->args[5]);

         // Tell the caller things have been initiated.
         args->result->SetBool(true);
      }
   };


   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin) {

      RegisterFunction<Scaleform_ShowVirtualKeyboard>(plugin, view, "ShowVirtualKeyboard");

      return true;
   }

   void RegisterScaleformHooks(SKSEScaleformInterface* infc) {
      _MESSAGE("Registering keyboard scaleform funcs");
      infc->Register("skyui", [](GFxMovieView* view, GFxValue* plugin){
         RegisterFunction<Scaleform_ShowVirtualKeyboard>(plugin, view, "ShowVirtualKeyboard");
         return true;
      });
   }
}
