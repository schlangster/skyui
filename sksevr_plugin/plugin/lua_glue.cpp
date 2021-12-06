#include "lua_glue.h"
#include <assert.h>
#include <filesystem>
#include "FormDB.h"

namespace lua {
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

   lua_State* lua_new_skyui_state() {
      // Setup new lua instance
      lua_State* state = lua_new_with_libs();

      auto dll_dir = dll_path().parent_path();
      auto package_path = dll_dir / "SkyUI-VR/?.lua";
      lua_prepend_package_path(state, package_path.generic_u8string().c_str());

      // Execute our lua file to setup global functions and variables in the vm
      // FIXME!!! This will probably not work for non-ascii paths.
      auto mainEntryPath = dll_dir / "SkyUI-VR/MainEntry.lua";
      if (luaL_dofile(state, mainEntryPath.generic_u8string().c_str()) != 0) {
         _ERROR("Could not load lua file '%s': %s", mainEntryPath.generic_u8string().c_str(), lua_tostring(state, lua_gettop(state)));
         lua_pop(state, 1);
      }

      return state;
   }

   void lua_pop_to_level(lua_State* L, int targetLevel) {
      int curLevel = lua_gettop(L);
      assert(targetLevel <= curLevel);

      int popCount = curLevel - targetLevel;
      if (curLevel > 0)
         lua_pop(L, curLevel - targetLevel);

      assert(lua_gettop(L) == targetLevel);
   }

   bool lua_table_is_array(lua_State* L, int tableIdx) {
      assert(lua_istable(L, tableIdx));
      int top = lua_gettop(L);

      lua_pushvalue(L, tableIdx);
      // stack starts with: -1 => table

      lua_pushnil(L);
      // stack now contains: -1 => nil; -2 => table

      // Walk through the table...
      // We'll consider the table an "array" if all keys are numbers and are consecutive integers
      bool isArray = true;
      int index = 1;
      while (lua_next(L, -2)) {
         // stack now contains: -1 => value; -2 => key; -3 => table
         if (0 == lua_isnumber(L, -2) || lua_tonumber(L, -2) != (lua_Number)index) {
            isArray = false;
            break;
         }
         index++;

         // Pop the value before continuing with lua_next()
         lua_pop(L, 1);
      }

      // Restore the stack to the level where we entered
      lua::lua_pop_to_level(L, top);

      return isArray;
   }

   void lua_print_value(lua_State* L, int index) {
      switch (lua_type(L, index)) {
      case LUA_TNONE:
         printf("LUA_TNONE");
         break;

      case LUA_TNIL:
         printf("LUA_TNIL");
         break;

      case LUA_TBOOLEAN:
         printf("LUA_TBOOLEAN: %s", lua_toboolean(L, index) ? "true" : "false");
         break;

      case LUA_TNUMBER:
         printf("LUA_TNUMBER: %f", lua_tonumber(L, index));
         break;

      case LUA_TSTRING:
         printf("LUA_TSTRING: %s", lua_tostring(L, index));
         break;

      case LUA_TTABLE:
         printf("LUA_TTABLE: 0x%llx", (uint64_t)lua_topointer(L, index));
         break;

      case LUA_TLIGHTUSERDATA:
         printf("LUA_TLIGHTUSERDATA: 0x%llx", (uint64_t)lua_topointer(L, index));
         break;

      case LUA_TFUNCTION:
         printf("LUA_TFUNCTION: 0x%llx", (uint64_t)lua_topointer(L, index));
         break;

      case LUA_TUSERDATA:
         printf("LUA_TUSERDATA: 0x%llx", (uint64_t)lua_topointer(L, index));
         break;

      case LUA_TTHREAD:
         printf("LUA_TTHREAD: 0x%llx", (uint64_t)lua_topointer(L, index));
         break;
      }
   }

   void lua_print_value_recursive(lua_State* L, int index) {
      int top = lua_gettop(L);

      const char* func_name = "print_value_recursive";
      lua_getglobal(L, func_name);       // Grab the lua function
      lua_pushvalue(L, index);

      // Call and print any errors
      if (lua_pcall(L, 1, 0, 0) != 0) {
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
      }

      lua::lua_pop_to_level(L, top);
   }

   bool lua_table_get_by_path(lua_State* L, int tableIdx, const char* path) {
      const char* func_name = "table_get_by_path";
      lua_getglobal(L, func_name);       // Grab the lua function
      lua_pushvalue(L, tableIdx);
      lua_pushstring(L, path);
      lua_pushnil(L);

      // Call and print any errors
      if (lua_pcall(L, 3, 1, 0) != 0) {
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
         return false;
      }
      return true;
   }

   bool lua_settings_get_by_path_with_defaults(lua_State* L, int tableIdx, const char* path, const char* defaultsFilename) {
      const char* func_name = "settings_get_by_path_with_defaults";
      lua_getglobal(L, func_name);       // Grab the lua function
      lua_pushvalue(L, tableIdx);
      lua_pushstring(L, path);
      lua_pushstring(L, defaultsFilename);
      lua_pushnil(L);

      // Call and print any errors
      if (lua_pcall(L, 4, 1, 0) != 0) {
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
         return false;
      }
      return true;
   }

   bool lua_table_get_bool_by_path(lua_State* L, int tableIdx, const char* path, bool default) {
      bool ok = lua_table_get_by_path(L, tableIdx, path);
      if (!ok)
         return default;

      bool val = lua_toboolean(L, -1);
      lua_pop(L, 1);
      return val;
   }

   double lua_table_get_double_by_path(lua_State* L, int tableIdx, const char* path, double default) {
      bool ok = lua_table_get_by_path(L, tableIdx, path);
      if (!ok)
         return default;

      double val = lua_tonumber(L, -1);
      lua_pop(L, 1);
      return val;
   }

   std::string lua_table_get_string_by_path(lua_State* L, int tableIdx, const char* path, std::string default) {
      bool ok = lua_table_get_by_path(L, tableIdx, path);
      if (!ok)
         return default;

      std::string val = lua_tostring(L, -1);
      lua_pop(L, 1);
      return val;
   }
}
