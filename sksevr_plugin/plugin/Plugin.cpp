#include <filesystem>
#include <assert.h>

#include "Plugin.h"
#include "skse64/GameForms.h"
#include "skse64/ScaleformValue.h"
#include "skse64/ScaleformCallbacks.h"
#include "skse64/ScaleformAPI.h"
#include "skse64/Hooks_Scaleform.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/GameExtraData.h"
#include "skse64/ScaleformExtendedData.h"

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

int lua_prepend_package_path(lua_State* L, const char* path) {
   int stack_before = lua_gettop(L);
   auto new_path = std::string(path);

   lua_getglobal(L, "package");
   lua_getfield(L, -1, "path");                 // get field "path" from table at top of stack (-1)
   const char* cur_path = lua_tostring(L, -1);  // grab path string from top of stack
   lua_pop(L, 1);                               // Pop the result we just used

   new_path.append(";");
   new_path.append(cur_path);

   lua_pushstring(L, new_path.c_str()); // push the new one
   lua_setfield(L, -2, "path");         // set the field "path" in table at -2 with value at top of stack
   lua_pop(L, 1);                       // get rid of package table from top of stack

   assert(stack_before == lua_gettop(L));
   return 0;
}


namespace SkyUIVR {

   std::filesystem::path dll_path() {
      HMODULE hm = nullptr;
      if (GetModuleHandleEx(
         GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
         (LPCSTR)&dll_path, &hm) == 0)
      {
         int ret = GetLastError();
         _ERROR("GetModuleHandle failed, error = %d\n", ret);
         return L"";
      }

      wchar_t path[MAX_PATH];
      if (GetModuleFileNameW(hm, path, _countof(path)) == 0) {
         int ret = GetLastError();
         _ERROR("GetModuleFileName failed, error = %d\n", ret);
         return L"";
      }

      return std::filesystem::path(path);
   }

   void Form_SetInt(UInt32 formID, const char* fieldName, SInt32 val) {
      const char* func_name = "Form_SetVal";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);
      lua_pushinteger(g_lua, val);

      // Call and print any errors
      if (lua_pcall(g_lua, 3, 1, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));

      // Pop the return value
      // The lua function actually returns the updated table.
      // Since there isn't a great way to interact with it in C/C++,
      // we're just going to discard it.
      lua_pop(g_lua, 1);
   }

   void Form_SetInt(TESForm* form, BSFixedString fieldName, SInt32 val){
      Form_SetInt(form->formID, fieldName.c_str(), val);
   }

   void Papyrus_Form_SetInt(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, SInt32 val) {
      Form_SetInt(form->formID, fieldName.c_str(), val);
   }

   SInt32 Form_GetInt(UInt32 formID, const char* fieldName, SInt32 default) {
      const char* func_name = "Form_GetVal";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);
      lua_pushinteger(g_lua, default);

      // Call and print any errors
      if (lua_pcall(g_lua, 3, 1, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));

      if (!lua_isnumber(g_lua, -1))
         _ERROR("function `%s` did not return a number", func_name);

      // Get the fetch result
      SInt32 val = lua_tointeger(g_lua, -1);

      lua_pop(g_lua, 1); // Cleanup the result from the stack

      return val;
   }

   SInt32 Form_GetInt(TESForm* form, BSFixedString fieldName, SInt32 default){
      return Form_GetInt(form->formID, fieldName.c_str(), default);
   }

   SInt32 Papyrus_Form_GetInt(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, SInt32 default){
      return Form_GetInt(form->formID, fieldName.c_str(), default);
   }

   void Form_SetBool(UInt32 formID, const char* fieldName, bool val) {
      const char* func_name = "Form_SetVal";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);
      lua_pushboolean(g_lua, val);

      if (lua_pcall(g_lua, 3, 1, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));

      lua_pop(g_lua, 1);
   }

   void Form_SetBool(TESForm* form, BSFixedString fieldName, bool val){
      Form_SetBool(form->formID, fieldName.c_str(), val);
   }

   void Papyrus_Form_SetBool(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, bool val){
      //_MESSAGE("[PIH]Papyrus -> DLL: SetBool, %x, %s, %s", form->formID, fieldName.c_str(), val ? "true" : "false");
      Form_SetBool(form->formID, fieldName.c_str(), val);
   }

   bool Form_GetBool(UInt32 formID, const char* fieldName, bool default) {
      const char* func_name = "Form_GetVal";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);
      lua_pushboolean(g_lua, default);

      // Call and print any errors
      if (lua_pcall(g_lua, 3, 1, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));

      if (!lua_isboolean(g_lua, -1))
         _ERROR("function `%s` did not return a boolean", func_name);

      // Get the fetch result
      bool val = lua_toboolean(g_lua, -1);

      lua_pop(g_lua, 1); // Cleanup the result from the stack

      return val;
   }

   bool Form_GetBool(TESForm* form, BSFixedString fieldName, bool default){
      //_MESSAGE("[PIH]Papyrus -> DLL: GetBool, %x, %s, %s", form->formID, fieldName.c_str(), default ? "true" : "false");
      bool val = Form_GetBool(form->formID, fieldName.c_str(), default);
      //_MESSAGE("[PIH]Papyrus -> DLL: GetBool, %x, %s, %s -> %s", form->formID, fieldName.c_str(), default ? "true" : "false", val ? "true" : "false");
      return val;
   }

   bool Papyrus_Form_GetBool(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, bool default){
      return Form_GetBool(form->formID, fieldName.c_str(), default);
   }

   void Form_RemoveField(UInt32 formID, const char* fieldName){
      const char* func_name = "Form_RemoveField";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);

      // Call and print any errors
      if(lua_pcall(g_lua, 2, 0, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
   }

   void Form_RemoveField(TESForm* form, BSFixedString fieldName){
      Form_RemoveField(form->formID, fieldName.c_str());
   }

   void Papyrus_Form_RemoveField(StaticFunctionTag*, TESForm* form, BSFixedString fieldName){
      Form_RemoveField(form->formID, fieldName.c_str());
   }

   void Form_RemoveAllFields(UInt32 formID){
      const char* func_name = "Form_RemoveAllFields";
      lua_getglobal(g_lua, func_name);
      lua_pushinteger(g_lua, formID);

      // Call and print any errors
      if(lua_pcall(g_lua, 1, 0, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
   }

   void Form_RemoveAllFields(TESForm* form){
      Form_RemoveAllFields(form->formID);
   }

   void Papyrus_Form_RemoveAllFields(StaticFunctionTag*, TESForm* form){
      Form_RemoveAllFields(form->formID);
   }

   bool RegisterPapyrusFuncs(VMClassRegistry* registry) {
      _MESSAGE("Registering Papyrus Functions");
      registry->RegisterFunction(new NativeFunction3 <StaticFunctionTag, void, TESForm*, BSFixedString, SInt32>("SetInt", "SKI_PlayerInventoryHook", Papyrus_Form_SetInt, registry));
      registry->RegisterFunction(new NativeFunction3 <StaticFunctionTag, SInt32, TESForm*, BSFixedString, SInt32>("GetInt", "SKI_PlayerInventoryHook", Papyrus_Form_GetInt, registry));
      registry->RegisterFunction(new NativeFunction3 <StaticFunctionTag, void, TESForm*, BSFixedString, bool>("SetBool", "SKI_PlayerInventoryHook", Papyrus_Form_SetBool, registry));
      registry->RegisterFunction(new NativeFunction3 <StaticFunctionTag, bool, TESForm*, BSFixedString, bool>("GetBool", "SKI_PlayerInventoryHook", Papyrus_Form_GetBool, registry));
      registry->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, TESForm*, BSFixedString>("RemoveField", "SKI_PlayerInventoryHook", Papyrus_Form_RemoveField, registry));
      registry->RegisterFunction(new NativeFunction1 <StaticFunctionTag, void, TESForm*>("RemoveAllFields", "SKI_PlayerInventoryHook", Papyrus_Form_RemoveAllFields, registry));
      return true;
   }

   bool InitGlobalLuaVM() {
      if (g_lua)
         return false;

      //DebugBreak();

      // Setup new lua instance
      g_lua = lua_new_with_libs();

      auto dll_dir = dll_path().parent_path();
      auto package_path = dll_dir / "SkyUI/?.lua";
      lua_prepend_package_path(g_lua, package_path.generic_u8string().c_str());

      // Execute our lua file to setup global functions and variables in the vm
      // FIXME!!! This will probably not work for non-ascii paths.
      auto mainEntryPath = dll_dir / "SkyUI/MainEntry.lua";
      if (luaL_dofile(g_lua, mainEntryPath.generic_u8string().c_str()) != 0) {
         _ERROR("Could not load lua file '%s': %s", mainEntryPath.generic_u8string().c_str(), lua_tostring(g_lua, lua_gettop(g_lua)));
         lua_pop(g_lua, 1);
      }

      if (g_lua)
         return true;
      else
         return false;
   }

   class Scaleform_RemoveField : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         //_MESSAGE("In Scaleform_RemoveField");
         ASSERT(args->numArgs == 2);
         ASSERT(args->args[0].GetType() == GFxValue::kType_Number);
         ASSERT(args->args[1].GetType() == GFxValue::kType_String);

         //_MESSAGE("Scaleform -> Dll: RemoveField, %d, %s", UInt32(args->args[0].GetNumber()), args->args[1].GetString());
         Form_RemoveField(UInt32(args->args[0].GetNumber()), args->args[1].GetString());
      }
   };

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin) {
      RegisterFunction<Scaleform_RemoveField>(plugin, view, "FormDB_RemoveField");
      return true;
   }

   void InventoryMarkNew(GFxMovieView* view, GFxValue* object, InventoryEntryData* item) {
      bool new_item = Form_GetBool(item->type->formID, "skyui/newItem", false);
      if(new_item) {
         //_MESSAGE("Marking [%x] with 'newItem'", item->type->formID);
         RegisterBool(object, "newItem", new_item);
      }
   }

   void RegisterScaleformHooks(SKSEScaleformInterface* infc) {
      infc->Register("skyui", RegisterScaleformFuncs);
      infc->RegisterForInventory(InventoryMarkNew);
   }
}
