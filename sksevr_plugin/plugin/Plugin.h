#include "skse64/PapyrusNativeFunctions.h"
#include "skse64/PluginAPI.h"

namespace SkyUIVR {
   void   Form_SetInt(TESForm* form, BSFixedString fieldName, SInt32 val);
   SInt32 Form_GetInt(TESForm* form, BSFixedString fieldName, SInt32 default);
   void   Form_RemoveField(TESForm* form, BSFixedString fieldName);
   void   Form_RemoveAllFields(TESForm* form, BSFixedString fieldName);

   bool RegisterPapyrusFuncs(VMClassRegistry* registry);
   bool InitGlobalLuaVM();

   void RegisterScaleformHooks(SKSEScaleformInterface* infc);
}
