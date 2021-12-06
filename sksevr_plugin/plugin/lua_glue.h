#pragma once
#include <filesystem>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
}

namespace lua {
   std::filesystem::path dll_path();
   lua_State* lua_new_skyui_state();

   bool lua_table_get_by_path(lua_State* L, int tableIdx, const char* path);
   void lua_pop_to_level(lua_State* L, int targetLevel);
   bool lua_table_is_array(lua_State* L, int tableIdx);
   void lua_print_value(lua_State* L, int index);
   void lua_print_value_recursive(lua_State* L, int index);

   bool lua_table_get_bool_by_path(lua_State* L, int tableIdx, const char* path, bool default);
   double lua_table_get_double_by_path(lua_State* L, int tableIdx, const char* path, double default);
   std::string lua_table_get_string_by_path(lua_State* L, int tableIdx, const char* path, std::string default);

   bool lua_settings_get_by_path_with_defaults(lua_State* L, int tableIdx, const char* path, const char* defaultsFilename);
}
