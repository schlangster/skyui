#include "skse64/PluginAPI.h"             // super
#include "skse64_common/skse_version.h"   // What version of SKSE is running?
#include <shlobj.h>                       // CSIDL_MYCODUMENTS

#include "FormDB.h"
#include "Keyboard.h"
#include "ControllerStateHook.h"
#include "Settings.h"

// SKSE patches
#include "ScaleformExtendedDataFix.h"
#include "PapyrusUIFix.h"
#include "skse64/Hooks_UI.h"

PluginHandle g_pluginHandle = kPluginHandle_Invalid;
SKSEPapyrusInterface* g_papyrus = nullptr;
SKSEScaleformInterface* g_scaleform = nullptr;
SKSETaskInterface* g_SkseTaskInterface = nullptr;
SKSEObjectInterface* g_SkseObjectInterface = nullptr;

void WaitForDebugger(bool should_break = false) {
   while (!IsDebuggerPresent())
      Sleep(100);
   if (should_break)
      DebugBreak();
}

extern "C" {
   // Called by SKSE to learn about this plugin and check that it's safe to load it
   bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info) {
      gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim VR\\SKSE\\SkyUI-VR.log");
      gLog.SetPrintLevel(IDebugLog::kLevel_Error);
      gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);

      _MESSAGE("SkyUI-VR loading");

      // populate info structure
      info->infoVersion = PluginInfo::kInfoVersion;
      info->name = "SkyUI";
      info->version = 1;

      // store plugin handle so we can identify ourselves later
      g_pluginHandle = skse->GetPluginHandle();

      if (skse->isEditor) {
         _MESSAGE("loaded in editor, marking as incompatible");
         return false;
      } else if (skse->runtimeVersion != RUNTIME_VR_VERSION_1_4_15) {
         _MESSAGE("unsupported runtime version %08X", skse->runtimeVersion);
         return false;
      }

      // ### do not do anything else in this callback
      // ### only fill out PluginInfo and return true/false

      // supported runtime version
      return true;
   }

   // Called by SKSE to load this plugin
   bool SKSEPlugin_Load(const SKSEInterface * skse) {
      _MESSAGE("SkyUI-VR loaded");

      //WaitForDebugger();

      // Initialize lua
      // We're storing all our data in lua
      FormDB::InitGlobalLuaVM();

      // Setup pointers to various SKSE interfaces
      // Parts of the program may need to access these sparatically.
      g_SkseTaskInterface = (SKSETaskInterface*)skse->QueryInterface(kInterface_Task);
      g_SkseObjectInterface = (SKSEObjectInterface*)skse->QueryInterface(kInterface_Object);

      // Register additional Papyrus functions
      g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);
      g_papyrus->Register(FormDB::RegisterPapyrusFuncs);             // Expose FormDB lua functions to Papyrus
      g_papyrus->Register(PapyrusUIFix::RegisterPapyrusFuncs);       // Fix Papyrus=>SKSE=>Scaleform SInt32 conversion bug

      // Register Inventory item hooks
      g_scaleform = (SKSEScaleformInterface*)skse->QueryInterface(kInterface_Scaleform);
      FormDB::RegisterScaleformInventoryHooks(g_scaleform);
      ExtendDataFix::RegisterScaleformInventoryHooks(g_scaleform);

      // Register additional Scaleform functions
      g_scaleform->Register("skyui", [](GFxMovieView* view, GFxValue* plugin) {
         FormDB::RegisterScaleformFuncs(view, plugin);               // Expose FormDB lua functions to Scaleform
         ControllerStateHook::RegisterScaleformFuncs(view, plugin);
         Keyboard::RegisterScaleformFuncs(view, plugin);
         Settings::RegisterScaleformFuncs(view, plugin);
         return true;
      });

      // Start receiving constroller state updates
      ControllerStateHook::Init();


      

      _MESSAGE("Plugin loaded");

      return true;
   }
};
