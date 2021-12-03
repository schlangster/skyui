#include <filesystem>
#include <assert.h>

#include "FormDB.h"
#include "skse64/GameForms.h"
#include "skse64/ScaleformValue.h"
#include "skse64/ScaleformCallbacks.h"
#include "skse64/ScaleformAPI.h"
#include "skse64/Hooks_Scaleform.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/GameExtraData.h"
#include "skse64/ScaleformExtendedData.h"
#include "skse64/GameRTTI.h"

#include "Keyboard.h"

lua_State* g_lua = nullptr;

namespace FormDB {


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

   void Form_SetInt(TESForm* form, BSFixedString fieldName, SInt32 val) {
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

   SInt32 Form_GetInt(TESForm* form, BSFixedString fieldName, SInt32 default) {
      return Form_GetInt(form->formID, fieldName.c_str(), default);
   }

   SInt32 Papyrus_Form_GetInt(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, SInt32 default) {
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

   void Form_SetBool(TESForm* form, BSFixedString fieldName, bool val) {
      Form_SetBool(form->formID, fieldName.c_str(), val);
   }

   void Papyrus_Form_SetBool(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, bool val) {
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

   bool Form_GetBool(TESForm* form, BSFixedString fieldName, bool default) {
      //_MESSAGE("[PIH]Papyrus -> DLL: GetBool, %x, %s, %s", form->formID, fieldName.c_str(), default ? "true" : "false");
      bool val = Form_GetBool(form->formID, fieldName.c_str(), default);
      //_MESSAGE("[PIH]Papyrus -> DLL: GetBool, %x, %s, %s -> %s", form->formID, fieldName.c_str(), default ? "true" : "false", val ? "true" : "false");
      return val;
   }

   bool Papyrus_Form_GetBool(StaticFunctionTag*, TESForm* form, BSFixedString fieldName, bool default) {
      return Form_GetBool(form->formID, fieldName.c_str(), default);
   }

   void Form_RemoveField(UInt32 formID, const char* fieldName) {
      const char* func_name = "Form_RemoveField";
      lua_getglobal(g_lua, func_name);       // Grab the lua function
      lua_pushinteger(g_lua, formID);        // Push the params
      lua_pushstring(g_lua, fieldName);

      // Call and print any errors
      if (lua_pcall(g_lua, 2, 0, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
   }

   void Form_RemoveField(TESForm* form, BSFixedString fieldName) {
      Form_RemoveField(form->formID, fieldName.c_str());
   }

   void Papyrus_Form_RemoveField(StaticFunctionTag*, TESForm* form, BSFixedString fieldName) {
      Form_RemoveField(form->formID, fieldName.c_str());
   }

   void Form_RemoveAllFields(UInt32 formID) {
      const char* func_name = "Form_RemoveAllFields";
      lua_getglobal(g_lua, func_name);
      lua_pushinteger(g_lua, formID);

      // Call and print any errors
      if (lua_pcall(g_lua, 1, 0, 0) != 0)
         _ERROR("Error running `%s`: %s", func_name, lua_tostring(g_lua, -1));
   }

   void Form_RemoveAllFields(TESForm* form) {
      Form_RemoveAllFields(form->formID);
   }

   void Papyrus_Form_RemoveAllFields(StaticFunctionTag*, TESForm* form) {
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

      // Setup new lua instance
      g_lua = lua::lua_new_skyui_state();

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
      Keyboard::RegisterScaleformFuncs(view, plugin);
      return true;
   }

   void InventoryMarkNew(GFxMovieView* view, GFxValue* object, InventoryEntryData* item) {
      bool new_item = Form_GetBool(item->type->formID, "skyui/newItem", false);
      // Skip marking gold as new
      if (item->type->formID == 0x0000000f)
         return;
      if (new_item) {
         //_MESSAGE("Marking [%x] with 'newItem'", item->type->formID);
         RegisterBool(object, "newItem", new_item);
      }
   }

   void RegisterScaleformInventoryHooks(SKSEScaleformInterface* infc) {
      infc->RegisterForInventory(InventoryMarkNew);
   }
}

