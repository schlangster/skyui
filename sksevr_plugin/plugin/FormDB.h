#include "skse64/PapyrusNativeFunctions.h"
#include "skse64/PluginAPI.h"

#include "lua_glue.h"

extern lua_State* g_lua;

namespace FormDB {
   void   Form_SetInt(TESForm* form, BSFixedString fieldName, SInt32 val);
   SInt32 Form_GetInt(TESForm* form, BSFixedString fieldName, SInt32 default);
   void   Form_RemoveField(TESForm* form, BSFixedString fieldName);
   void   Form_RemoveAllFields(TESForm* form, BSFixedString fieldName);

   bool RegisterPapyrusFuncs(VMClassRegistry* registry);
   bool InitGlobalLuaVM();

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin);
   void RegisterScaleformInventoryHooks(SKSEScaleformInterface* infc);
}
