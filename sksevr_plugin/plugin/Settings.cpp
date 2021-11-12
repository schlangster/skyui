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

namespace Settings {
   typedef std::map<std::string, std::string> SettingsMap;
   SettingsMap* g_settingsMap = nullptr;

   inline std::vector<std::string> split(const std::string& s, char delimiter)
   {
      std::vector<std::string> tokens;
      std::string token;
      std::istringstream tokenStream(s);
      while (std::getline(tokenStream, token, delimiter))
      {
         tokens.push_back(std::move(token));
      }
      return tokens;
   }

   void removeComments(std::string& str)
   {
      auto pos = str.find("#");
      if (pos != std::string::npos)
      {
         str.erase(pos);
      }
   }

   inline void ltrim(std::string& s) {
      s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
         return !std::isspace(ch);
      }));
   }

   inline void rtrim(std::string& s) {
      s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
         return !std::isspace(ch);
      }).base(), s.end());
   }

   inline bool to_bool(std::string& s, bool& val) {
      std::transform(s.begin(), s.end(), s.begin(), ::tolower);
      if (s == "true" || s == "yes" || s == "1")
         val = true;
      else
         val = false;
      return true;
   }

   inline bool to_int(std::string& s, int& val) {
      try {
         int r = std::stoi(s);
         val = r;
         return true;
      }
      catch (std::exception&) {
         return false;
      }
   }

   inline bool to_float(std::string& s, float& val) {
      try {
         float r = std::stof(s);
         val = r;
         return true;
      }
      catch (std::exception&) {
         return false;
      }
   }

   inline bool to_double(std::string& s, double& val) {
      try {
         double r = std::stod(s);
         val = r;
         return true;
      }
      catch (std::exception&) {
         return false;
      }
   }

   bool GetBool(SettingsMap& m, const char* varname, bool& val) {
      auto it = m.find(varname);
      if (it == m.end())
         return false;
      return to_bool(it->second, val);
   }

   bool GetInt(SettingsMap& m, const char* varname, int& val) {
      auto it = m.find(varname);
      if (it == m.end())
         return false;
      return to_int(it->second, val);
   }

   bool GetFloat(SettingsMap& m, const char* varname, float& val) {
      auto it = m.find(varname);
      if (it == m.end())
         return false;
      return to_float(it->second, val);
   }

   bool GetDouble(SettingsMap& m, const char* varname, double& val) {
      auto it = m.find(varname);
      if (it == m.end())
         return false;
      return to_double(it->second, val);
   }

   bool GetString(SettingsMap& m, const char* varname, std::string** val) {
      auto it = m.find(varname);
      if (it == m.end())
         return false;
      *val = &it->second;
      return true;
   }

   SettingsMap* loadConfig(const char* settingFilePath = nullptr)
   {
      std::string path;
      auto result = new SettingsMap();

      // Figure out which file we're trying to open.
      if (settingFilePath) {
         path = settingFilePath;
      }
      else {
         path = GetRuntimeDirectory() + "Data\\SKSE\\Plugins\\Skyui-VR.ini";
      }

      // Open the file
      std::ifstream file(path);
      if (!file.is_open())
         return std::move(result);

      // Process each line in the file
      std::string line;
      while (std::getline(file, line))
      {
         removeComments(line);
         ltrim(line);
         rtrim(line);
         if (line.length() == 0)
            continue;

         // Skip all section markers
         if (line[0] == '[')
         {
            continue;
         }

         // If we can successfully split the line with '=',
         // put the first and second item into a map.
         auto tokens = split(line, '=');
         if (tokens.size() > 1)
         {
            result->insert(make_pair(tokens[0], tokens[1]));
         }
      }

      return std::move(result);
   }

   void lazyInit() {
      if (g_settingsMap == nullptr) {
         g_settingsMap = loadConfig();
      }
   }

   class Scaleform_IniGetBool : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key

         lazyInit();
         bool val;
         bool success = GetBool(*g_settingsMap, args->args[0].GetString(), val);

         if (!success)
            args->result->SetNull();
         else
            args->result->SetBool(val);
      }
   };

   class Scaleform_IniGetNumber : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key

         lazyInit();
         double val;
         bool success = GetDouble(*g_settingsMap, args->args[0].GetString(), val);

         if (!success)
            args->result->SetNull();
         else
            args->result->SetNumber(val);
      }
   };

   class Scaleform_IniGetString : public GFxFunctionHandler
   {
   public:
      virtual void	Invoke(Args* args)
      {
         ASSERT(args->numArgs >= 1);
         ASSERT(args->args[0].GetType() == GFxValue::kType_String); // Key

         lazyInit();
         std::string* val;

         bool success = GetString(*g_settingsMap, args->args[0].GetString(), &val);
         assert(val);

         if (!success)
            args->result->SetNull();
         else
            args->result->SetString(val->c_str());
      }
   };

   bool RegisterScaleformFuncs(GFxMovieView* view, GFxValue* plugin) {
      RegisterFunction<Scaleform_IniGetBool>(plugin, view, "IniGetBool");
      RegisterFunction<Scaleform_IniGetNumber>(plugin, view, "IniGetNumber");
      RegisterFunction<Scaleform_IniGetString>(plugin, view, "IniGetString");
      return true;
   }
}
