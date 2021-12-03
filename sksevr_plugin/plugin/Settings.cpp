#include <fstream>
#include <sstream>
#include <algorithm>
#include <map>
#include <vector>
#include <functional>
#include <cctype>
#include <assert.h>

#include "skse64/ScaleformValue.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/ScaleformCallbacks.h"
#include "skse64_common/Utilities.h"

#include "lua_glue.h"
#include "FormDB.h"

namespace Settings {

   bool GetBool(lua_State* L, const char* path, bool default) {
      return lua::lua_table_get_bool_by_path(L, LUA_GLOBALSINDEX, path, default);
   }

   double GetDouble(lua_State* L, const char* path, double default) {
      return lua::lua_table_get_double_by_path(L, LUA_GLOBALSINDEX, path, default);
   }

   std::string GetString(lua_State* L, const char* path, std::string default) {
      return lua::lua_table_get_string_by_path(L, LUA_GLOBALSINDEX, path, default);
   }

   bool load_settings_file(lua_State* L, const char* path) {
      const char* func_name = "load_settings_file";
      lua_getglobal(L, func_name);       // Grab the lua function
      lua_pushstring(L, path);

      // Call and print any errors
      if (lua_pcall(L, 1, 1, 0) != 0) {
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
         return false;
      }

      return true;
   }

   bool loadLuaConfig(const char* settingFilePath = nullptr)
   {
      std::string path;

      // Figure out which file we're trying to open.
      if (settingFilePath) {
         path = settingFilePath;
      }
      else {
         path = GetRuntimeDirectory() + "Data\\SKSE\\Plugins\\SkyUI-VR.settings.lua";
      }

      int top = lua_gettop(g_lua);

      bool ok = load_settings_file(g_lua, path.c_str());
      if (!ok)
         return false;

      lua_getfield(g_lua, -1, "Settings");
      lua_setglobal(g_lua, "Settings");
      lua::lua_pop_to_level(g_lua, top);
      return true;
   }

   bool deepCopyValue(lua_State* L, int index, GFxMovieView* movie, GFxValue* val);

   bool deepCopyTable(lua_State* L, int index, GFxMovieView* movie, GFxValue* object) {
      int top = lua_gettop(L);

      // stack now contains: -1 => table 
      bool isArray = lua::lua_table_is_array(L, index);

      if (isArray) {
         movie->CreateArray(object);

         lua_pushnil(L);
         // stack now contains: -1 => nil; -2 => table

         for(int i = 0; lua_next(L, -2); i++) {
            // stack now contains: -1 => value; -2 => key; -3 => table
            GFxValue val;

            //lua::lua_print_value(L, -1);
            //printf("\n");

            // Copy the lua value from the top of the stack into a Scaleform Value
            deepCopyValue(L, -1, movie, &val);

            // Add the Scaleform value to the Scaleform array
            object->PushBack(&val);

            // pop value, leaving the key
            lua_pop(L, 1);
            // stack now contains: -1 => key; -2 => table
         }
      }
      else {
         movie->CreateObject(object);

         lua_pushnil(L);
         // stack now contains: -1 => nil; -2 => table

         while (lua_next(L, -2))
         {
            // stack now contains: -1 => value; -2 => key; -3 => table
            const char* key = lua_tostring(L, -2);
            const char* value = lua_tostring(L, -1);

            //lua::lua_print_value(L, -2);
            //printf(" => ");
            //lua::lua_print_value(L, -1);
            //printf("\n");

            GFxValue val;
            deepCopyValue(L, -1, movie, &val);
            object->SetMember(key, &val);

            // pop value, leaving the key
            lua_pop(L, 1);
            // stack now contains: -1 => key; -2 => table
         }
      }

      // stack now contains: -1 => table
      // (when lua_next returns 0 it pops the key but does not push anything.)

      // Restore stack to the same state as when we entered the function
      lua::lua_pop_to_level(L, top);

      return true;
   }


   bool deepCopyValue(lua_State* L, int index, GFxMovieView* movie, GFxValue* val) {
      switch (lua_type(L, index)) {
      case LUA_TNONE:
         val->SetUndefined();
         break;

      case LUA_TNIL:
         val->SetNull();
         break;

      case LUA_TBOOLEAN:
         val->SetBool(lua_toboolean(L, index));
         break;

      case LUA_TNUMBER:
         val->SetBool(lua_tonumber(L, index));
         break;

      case LUA_TSTRING:
         val->SetString(lua_tostring(L, index));
         break;

      case LUA_TTABLE:
         deepCopyTable(L, index, movie, val);
         break;

      case LUA_TLIGHTUSERDATA:
         printf("Cannot copy light user data");
         break;
      case LUA_TFUNCTION:
         printf("Cannot copy function");
         break;
      case LUA_TUSERDATA:
         printf("Cannot copy userdata");
         break;
      case LUA_TTHREAD:
         printf("Cannot copy thread");
         break;
      }

      return true;
   }

   class Scaleform_IniGet : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key
         ASSERT(g_lua);

         int top = lua_gettop(g_lua);
         bool ok = lua::lua_table_get_by_path(g_lua, LUA_GLOBALSINDEX, args->args[0].GetString());

         if (ok)
            deepCopyValue(g_lua, -1, args->movie, args->result);
         else
            args->result->SetNull();

         lua::lua_pop_to_level(g_lua, top);
      }
   };

   class Scaleform_IniGetBool : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key
         ASSERT(g_lua);

         lua::lua_print_value_recursive(g_lua, LUA_GLOBALSINDEX);

         int top = lua_gettop(g_lua);
         bool ok = lua::lua_table_get_by_path(g_lua, LUA_GLOBALSINDEX, args->args[0].GetString());

         if (ok && lua_isboolean(g_lua, -1))
            deepCopyValue(g_lua, -1, args->movie, args->result);
         else
            args->result->SetUndefined();

         lua::lua_pop_to_level(g_lua, top);
      }
   };

   class Scaleform_IniGetNumber : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key
         ASSERT(g_lua);
         
         int top = lua_gettop(g_lua);
         bool ok = lua::lua_table_get_by_path(g_lua, LUA_GLOBALSINDEX, args->args[0].GetString());

         if (ok && lua_isnumber(g_lua, -1))
            deepCopyValue(g_lua, -1, args->movie, args->result);
         else
            args->result->SetUndefined();

         lua::lua_pop_to_level(g_lua, top);
      }
   };

   class Scaleform_IniGetString : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key
         ASSERT(g_lua);

         int top = lua_gettop(g_lua);
         bool ok = lua::lua_table_get_by_path(g_lua, LUA_GLOBALSINDEX, args->args[0].GetString());

         if (ok && lua_isstring(g_lua, -1))
            deepCopyValue(g_lua, -1, args->movie, args->result);
         else
            args->result->SetUndefined();

         lua::lua_pop_to_level(g_lua, top);
      }
   };

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin) {
      RegisterFunction<Scaleform_IniGet>(plugin, view, "IniGet");
      RegisterFunction<Scaleform_IniGetBool>(plugin, view, "IniGetBool");
      RegisterFunction<Scaleform_IniGetNumber>(plugin, view, "IniGetNumber");
      RegisterFunction<Scaleform_IniGetString>(plugin, view, "IniGetString");
      return true;
   }
}
