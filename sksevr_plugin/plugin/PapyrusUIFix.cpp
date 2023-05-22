#include "PapyrusUIFix.h"

#include "skse64/GameMenus.h"
#include "skse64/ScaleformCallbacks.h"
#include "skse64/ScaleformMovie.h"
#include "skse64/PapyrusNativeFunctions.h"

#include "skse64/PapyrusUI.h"
#include "skse64/Hooks_UI.h"
#include "skse64/Serialization.h"

#include "Globals.h"

namespace PapyrusUIFix
{
   template <typename T> void SetGFxValue(GFxValue* val, T arg);
   template <> void SetGFxValue<bool>(GFxValue* val, bool arg) { val->SetBool(arg); }
   template <> void SetGFxValue<float>(GFxValue* val, float arg) { val->SetNumber(arg); }

   // Disabled so we don't accidentally use this
   //template <> void SetGFxValue<UInt32>(GFxValue* val, UInt32 arg) { val->SetNumber(arg); } 

   template <> void SetGFxValue<SInt32>(GFxValue* val, SInt32 arg) { val->SetNumber(arg); }
   template <> void SetGFxValue<BSFixedString>(GFxValue* val, BSFixedString arg)
   {
      // lifetime of this string will not be managed by the scaleform runtime
      val->SetString(arg.data);
   }

   class UIInvokeDelegate : public UIDelegate_v1, public ISKSEObject
   {
   public:
      UIInvokeDelegate(const char* nameBuf, const char* targetBuf) :
         menuName_(nameBuf),
         target_(targetBuf)
      {}

      explicit UIInvokeDelegate(SerializationTag tag) {

      }

      virtual const char* ClassName() const { return "SkyUI-UIInvokeDelegate"; }
      virtual UInt32		ClassVersion() const { return 1; }

      virtual void Run() override
      {
         MenuManager* mm = MenuManager::GetSingleton();
         if (!mm)
            return;

         BSFixedString t(menuName_.c_str());
         GFxMovieView* view = mm->GetMovieView(&t);
         if (!view)
            return;

         GFxValue* value = NULL;
         if (args.size() > 0)
            value = &args[0];

         view->Invoke(target_.c_str(), NULL, value, args.size());
      }
      virtual void Dispose() override
      {
         delete this;
      }

      virtual bool Save(SKSESerializationInterface* intfc)
      {
         using namespace Serialization;

         if (!WriteData(intfc, &menuName_))
            return false;

         if (!WriteData(intfc, &target_))
            return false;

         if (!WriteData(intfc, &type_))
            return false;

         if (!WriteData(intfc, &handle_))
            return false;

         return true;
      }

      virtual bool Load(SKSESerializationInterface* intfc, UInt32 version)
      {
         using namespace Serialization;

         if (!ReadData(intfc, &menuName_))
            return false;

         if (!ReadData(intfc, &target_))
            return false;

         if (!ReadData(intfc, &type_))
            return false;

         if (!ReadData(intfc, &handle_))
            return false;

         UInt64 fixedHandle;
         if (intfc->ResolveHandle(handle_, &fixedHandle))
            handle_ = fixedHandle;

         return true;
      }


      std::vector<GFxValue>	args;

   private:
      std::string		menuName_;
      std::string		target_;

      UInt32			type_;
      UInt64			handle_;
   };

   template <typename T>
   void SetT(StaticFunctionTag* thisInput, BSFixedString menuName, BSFixedString targetStr, T value)
   {
      if (!menuName.data || !targetStr.data)
         return;

      MenuManager* mm = MenuManager::GetSingleton();
      if (!mm)
         return;

      GFxMovieView* view = mm->GetMovieView(&menuName);
      if (!view)
         return;

      GFxValue fxValue;
      PapyrusUIFix::SetGFxValue<T>(&fxValue, value);

      view->SetVariable(targetStr.data, &fxValue, 1);
   }

   template <typename T>
   void InvokeArgT(StaticFunctionTag* thisInput, BSFixedString menuName, BSFixedString targetStr, T arg)
   {
      if (!menuName.data || !targetStr.data)
         return;

      if (!g_SkseTaskInterface)
         return;

      UIInvokeDelegate* cmd = new UIInvokeDelegate(menuName.data, targetStr.data);

      cmd->args.resize(1);
      PapyrusUIFix::SetGFxValue<T>(&cmd->args[0], arg);

      g_SkseTaskInterface->AddUITask(cmd);
   }

   template <typename T>
   void InvokeArrayT(StaticFunctionTag* thisInput, BSFixedString menuName, BSFixedString targetStr, VMArray<T> args)
   {
      if (!menuName.data || !targetStr.data)
         return;

      if (!g_SkseTaskInterface)
         return;

      UInt32 argCount = args.Length();

      UIInvokeDelegate* cmd = new UIInvokeDelegate(menuName.data, targetStr.data);

      cmd->args.resize(argCount);
      for (UInt32 i = 0; i < argCount; i++)
      {
         T arg;
         args.Get(&arg, i);
         PapyrusUIFix::SetGFxValue<T>(&cmd->args[i], arg);
      }

      g_SkseTaskInterface->AddUITask(cmd);
   }

   bool RegisterPapyrusFuncs(VMClassRegistry* registry) {
      SKSEObjectRegistry& objectRegistry = g_SkseObjectInterface->GetObjectRegistry();
      objectRegistry.RegisterClass<UIInvokeDelegate>();

      registry->RegisterFunction(
         new NativeFunction3 <StaticFunctionTag, void, BSFixedString, BSFixedString, SInt32>("SetInt", "UI", SetT<SInt32>, registry));

      registry->RegisterFunction(
         new NativeFunction3 <StaticFunctionTag, void, BSFixedString, BSFixedString, SInt32>("InvokeInt", "UI", InvokeArgT<SInt32>, registry));

      registry->RegisterFunction(
         new NativeFunction3 <StaticFunctionTag, void, BSFixedString, BSFixedString, VMArray<SInt32>>("InvokeIntA", "UI", InvokeArrayT<SInt32>, registry));

      return true;
   }
}
