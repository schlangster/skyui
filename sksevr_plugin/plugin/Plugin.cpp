#include "Plugin.h"
#include "skse64/GameForms.h"

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
}

static lua_State* g_lua = nullptr;

lua_State* lua_new_with_libs() {
   lua_State* L = luaL_newstate();
   if (L) {
      luaL_openlibs(L);
   }

   return L;
}

lua_State* get_formdb(lua_State* L) {
   lua_getglobal(L, "formdb");
}

// lua: FormDB = {}
bool lua_init_FormDB(lua_State* L) {
  lua_newtable(L);
  lua_setglobal(L, "FormDB");
}

namespace SkyUIVR {
   void Form_SetInt(TESForm* form, BSFixedString fieldName, SInt32 val) {
      lua_getglobal(g_lua, "FormDB");
      lua_pushinteger(L, val);
      lua_settable(L, );
   }

   SInt32 Form_GetInt(TESForm* form, BSFixedString fieldName, SInt32 default) {
      return default;
   }

   void Form_RemoveField(TESForm* form, BSFixedString fieldName){

   }

   void Form_RemoveAllFields(TESForm* form, BSFixedString fieldName) {

   }

   bool RegisterFuncs(VMClassRegistry* registry) {
      registry->RegisterFunction(new NativeFunction2 <TESForm, void, BSFixedString, SInt32>("SetInt", "SKI_PlayerInventory", Form_SetInt, registry));
      registry->RegisterFunction(new NativeFunction2 <TESForm, SInt32, BSFixedString, SInt32>("GetInt", "SKI_PlayerInventory", Form_GetInt, registry));
      registry->RegisterFunction(new NativeFunction1 <TESForm, void, BSFixedString>("RemoveField", "SKI_PlayerInventory", Form_RemoveField, registry));
      registry->RegisterFunction(new NativeFunction1 <TESForm, void, BSFixedString>("RemoveField", "SKI_PlayerInventory", Form_RemoveAllFields, registry));
      return true;
   }

   bool InitGlobalLuaVM() {
      if (g_lua)
         return false;

      g_lua = lua_new_with_libs();
      lua_pushinteger(L, val);
      lua_settable(L, );

      if (g_lua)
         return true;
      else
         return false;
   }
}
