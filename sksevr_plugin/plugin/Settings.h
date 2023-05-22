#pragma once

#include "skse64/PluginAPI.h"

namespace Settings {
   bool loadLuaConfig(const char* settingFilePath = nullptr);

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin);

   bool        GetBool  (lua_State* L, const char* path, bool default);
   double      GetDouble(lua_State* L, const char* path, double default);
   std::string GetString(lua_State* L, const char* path, std::string default);
}
