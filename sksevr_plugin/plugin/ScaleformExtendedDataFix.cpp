
#include "ScaleformExtendedDataFix.h"
#include "skse64/ScaleformValue.h"
#include "skse64/ScaleformExtendedData.h"
#include "skse64/GameRTTI.h"
#include "skse64/GameExtraData.h"

namespace ExtendDataFix {

   // As of SKSEVR 2.0.12, the layout of TESAmmo is slightly off, causing the "flags" field to be
   // read & passed to skyui incorrectly.
   // The end result is skyui seems to always categorize bolts and arrow as "type: bolt".
   void AttachAmmoFlags(GFxMovieView* view, GFxValue* pFxVal, InventoryEntryData* item) {
      TESForm* pForm = item->type;
      if (!pForm || !pFxVal || !pFxVal->IsObject())
         return;

      switch (pForm->GetFormType())
      {
         case kFormType_Ammo:
         {
            TESAmmo* pAmmo = DYNAMIC_CAST(pForm, TESForm, TESAmmo);
            if (pAmmo)
            {
               RegisterNumber(pFxVal, "flags", pAmmo->settings.flags);
            }
         }
         break;

         default:
            break;
      }
   }

   void RegisterScaleformInventoryHooks(SKSEScaleformInterface* infc) {
      infc->RegisterForInventory(AttachAmmoFlags);
   }
}
