/* ControllerStateHook
 *
 * Does 2 things:
 * - Hooks into Controller State update calls made by the engine via SkyrimVRTools
 * - Pushes controller states to scaleform for processing
 *
 * Similar code has already been in SkyrimVRTools for sometime. However, since we have a
 * more generic way to get controller updates from it now, having scaleform related
 * functionality here allows more control over the native code without having to worry
 * about coordinating release. Users will have a more straightforward time installing and
 * running skyui as well.
 */

#include "skse64/InternalVR.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/Hooks_Scaleform.h"
#include "skse64/ScaleformCallbacks.h"

#include "VRHookAPI.h"
#include <list>
#include <assert.h>


namespace ControllerStateHook {
   namespace vr = vr_1_0_12;

   void DispatchControllerState(vr::ETrackedControllerRole controllerHand, const vr::VRControllerState_t* controllerState);

   OpenVRHookManagerAPI* hookMgr = nullptr;

   // When we receive ControllerState updates, send it over to Scaleform as needed.
   bool ControllerStateCB(vr::TrackedDeviceIndex_t unControllerDeviceIndex, const vr::VRControllerState_t* pControllerState, uint32_t unControllerStateSize, vr::VRControllerState_t* pOutputControllerState) {
      vr::IVRSystem* system = hookMgr->GetVRSystem();
      assert(system);

      vr::ETrackedControllerRole hand = vr::TrackedControllerRole_Invalid;

      if (unControllerDeviceIndex == system->GetTrackedDeviceIndexForControllerRole(vr::ETrackedControllerRole::TrackedControllerRole_LeftHand)) {
         hand = vr::TrackedControllerRole_LeftHand;
      }
      else if (unControllerDeviceIndex == system->GetTrackedDeviceIndexForControllerRole(vr::ETrackedControllerRole::TrackedControllerRole_RightHand)) {
         hand = vr::TrackedControllerRole_RightHand;
      }

      DispatchControllerState(hand, pControllerState);
      return true;
   }

   void Init() {
      // Ask for SkyrimVRTools to send us ConstrollerStates whenever they are requested.
      hookMgr = RequestOpenVRHookManagerObject();
      if (!hookMgr)
         return;

      hookMgr->RegisterControllerStateCB(ControllerStateCB);
   }

   bool equalGFxValue(const GFxValue& lhs, const GFxValue& rhs)
   {
      if (rhs.type == lhs.type) {
         switch (rhs.GetType()) {
         case GFxValue::kType_Null:
            return true;
         case GFxValue::kType_Bool:
            return lhs.GetBool() == rhs.GetBool();
         case GFxValue::kType_Number:
            return lhs.GetNumber() == rhs.GetNumber();
         case GFxValue::kType_String:
            return 0 == strcmp(lhs.GetString(), rhs.GetString());
         case GFxValue::kType_WideString:
            return 0 == wcscmp(lhs.GetWideString(), rhs.GetWideString());
         case GFxValue::kType_Object:
            return lhs.data.obj == rhs.data.obj;
         case GFxValue::kType_Array:
            // Not implemented =(
            return false;
         case GFxValue::kType_DisplayObject:
            return lhs.data.obj == rhs.data.obj;
         default:
            return false;
         }
      }
      return false;
   }

   struct ScaleformCallback {
      GFxMovieView* movieView;
      GFxValue		object;
      const char* methodName;

      bool operator==(const ScaleformCallback& rhs)
      {
         return equalGFxValue(this->object, rhs.object) && (0 == strcmp(this->methodName, rhs.methodName));
      }
   };

   typedef std::list <ScaleformCallback> ScaleformCallbackList;
   static ScaleformCallbackList g_scaleformInputHandlers;

   void DispatchControllerState(vr::ETrackedControllerRole controllerHand, const vr::VRControllerState_t* controllerState) {
      for (ScaleformCallbackList::iterator iter = g_scaleformInputHandlers.begin(); iter != g_scaleformInputHandlers.end(); ++iter)
      {
         GFxMovieView* movieView = (*iter).movieView;
         GFxValue* object = &(*iter).object;
         const char* methodName = (*iter).methodName;

         GFxValue result, args[7];
         args[0].SetNumber(controllerHand);
         args[1].SetNumber(controllerState->unPacketNum);
         args[2].SetNumber(controllerState->ulButtonPressed & 0xFFFFFFFF);
         args[3].SetNumber(controllerState->ulButtonPressed >> 32);
         args[4].SetNumber(controllerState->ulButtonTouched && 0xFFFFFFFF);
         args[5].SetNumber(controllerState->ulButtonTouched >> 32);

         GFxValue axisData;
         movieView->CreateArray(&args[6]);

         for (int i = 0; i < vr::k_unControllerStateAxisCount; i++) {
            GFxValue x, y;
            x.SetNumber(controllerState->rAxis[i].x);
            y.SetNumber(controllerState->rAxis[i].y);

            args[6].PushBack(&x);
            args[6].PushBack(&y);
         }

         object->Invoke(methodName, &result, args, 7);
      }
   }

   class VRInputScaleform_RegisterInputHandler : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         //_MESSAGE("RegisterInputHandler dll fn called!");

         ASSERT(args->numArgs == 2);
         ASSERT(args->args[0].GetType() == GFxValue::kType_DisplayObject);
         ASSERT(args->args[1].GetType() == GFxValue::kType_String);

         ScaleformCallback callback;
         callback.movieView = args->movie;
         callback.object = args->args[0];
         callback.methodName = args->args[1].GetString();

         // If the same callback has already been registered, do not add it again.
         // This will cause the callback to triggered twice when input events are sent.
         for (ScaleformCallbackList::iterator iter = g_scaleformInputHandlers.begin(); iter != g_scaleformInputHandlers.end(); ++iter)
         {
            if (*iter == callback) {
               //_MESSAGE("Duplicate callback found, aborting register...");
               return;
            }
         }

         //_MESSAGE("Registering: %s", callback.methodName);
         g_scaleformInputHandlers.push_back(callback);
      }
   };

   class VRInputScaleform_UnregisterInputHandler : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         //_MESSAGE("VRInputScaleform_UnregisterInputHandler dll fn called!");
         ASSERT(args->numArgs == 2);
         ASSERT(args->args[0].GetType() == GFxValue::kType_DisplayObject);
         ASSERT(args->args[1].GetType() == GFxValue::kType_String);

         ScaleformCallback callback;
         callback.object = args->args[0];
         callback.methodName = args->args[1].GetString();

         g_scaleformInputHandlers.remove(callback);
         //_MESSAGE("Unregistering: %s | remaining: %d", callback.methodName, g_scaleformInputHandlers.size());
      }
   };

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin) {
      //_MESSAGE("Registering scaleform functions");

      RegisterFunction<VRInputScaleform_RegisterInputHandler>(plugin, view, "RegisterInputHandler");
      RegisterFunction<VRInputScaleform_UnregisterInputHandler>(plugin, view, "UnregisterInputHandler");

      return true;
   }
}

