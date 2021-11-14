#pragma once

#include "skse64/PluginAPI.h"

namespace Settings {
   typedef std::map<std::string, std::string> SettingsMap;
   extern SettingsMap* g_settingsMap;

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin);
   bool GetBool(SettingsMap& m, const char* varname, bool& val);
   bool GetInt(SettingsMap& m, const char* varname, int& val);
   bool GetFloat(SettingsMap& m, const char* varname, float& val);
}
