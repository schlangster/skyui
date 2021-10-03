#include "skse/PluginAPI.h"    // super
#include "skse/skse_version.h" // What version of SKSE is running?
#include <shlobj.h>            // CSIDL_MYCODUMENTS

#include "Plugin.h"


static PluginHandle g_pluginHandle = kPluginHandle_Invalid;
static SKSEPapyrusInterface * g_papyrus = NULL;


extern "C" {
   // Called by SKSE to learn about this plugin and check that it's safe to load it
   bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info) {
      gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim\\SKSE\\PluginScript.log");
      gLog.SetPrintLevel(IDebugLog::kLevel_Error);
      gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);

      _MESSAGE("PluginScript loading");

      // populate info structure
      info->infoVersion = PluginInfo::kInfoVersion;
      info->name = "ExportPlugin";
      info->version = 1;

      // store plugin handle so we can identify ourselves later
      g_pluginHandle = skse->GetPluginHandle();

      if (skse->isEditor) {
         _MESSAGE("loaded in editor, marking as incompatible");
         return false;
      } else if (skse->runtimeVersion != RUNTIME_VERSION_1_9_32_0) {
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
      _MESSAGE("PluginScript loaded");

      g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);

      // Check if the function registration was a success...
      bool btest = g_papyrus->Register(PluginNamespace::RegisterFuncs);

      if (btest) {
         _MESSAGE("Register Succeeded");
      }

      return true;
   }
};
