import gfx.io.GameDelegate;

import skyui.components.list.BasicList;
import skyui.components.list.IDataFetcher;


class skyui.InventoryDataFetcher implements IDataFetcher
{	
	public function InventoryDataFetcher(a_list: BasicList)
	{
		// Hack to inject functions for itemcard info retrieval		
		Object(a_list)._itemInfo = null;

		Object(a_list).requestItemInfo = function(a_index: Number): Void
		{
			var oldIndex = this._selectedIndex;
			this._selectedIndex = a_index;
			GameDelegate.call("RequestItemCardInfo", [], this, "updateItemInfo");
			this._selectedIndex = oldIndex;
		};

		Object(a_list).updateItemInfo = function(a_updateObj: Object): Void
		{
			this._itemInfo = a_updateObj;
		};
	}
	
  	// @override skyui.IDataFetcher
	public function processEntries(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			Object(a_list).requestItemInfo(i);
			processEntry(entryList[i], a_list["_itemInfo"]);
		}
	}
	
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		switch (a_itemInfo.type) {
			case InventoryDefines.ICT_ARMOR :
				if (a_itemInfo.armor) {
					a_entryObject.infoArmor = a_itemInfo.armor;
					a_entryObject.infoArmorValid = 1;
				} else {
					a_entryObject.infoArmor = "-";
					a_entryObject.infoArmorValid = 0;
				}

				a_entryObject.infoDamage = "-";
				a_entryObject.infoDamageValid = 0;
				a_entryObject.infoIsEnchanted = (a_itemInfo.effects != "");
				break;
				
			case InventoryDefines.ICT_WEAPON :
				if (a_itemInfo.damage) {
					a_entryObject.infoDamage = a_itemInfo.damage;
					a_entryObject.infoDamageValid = 1;
				} else {
					a_entryObject.infoDamage = "-";
					a_entryObject.infoDamageValid = 0;
				}
				
				a_entryObject.infoArmor =  "-";
				a_entryObject.infoArmorValid =  0;
				a_entryObject.infoIsEnchanted = (a_itemInfo.effects != "");
				break;
				
			case InventoryDefines.ICT_POTION :
				// if potion item has spellCost then it is a scroll
				if (a_itemInfo.skillName)
					a_itemInfo.type = InventoryDefines.ICT_BOOK;
				else if (a_itemInfo.spellCost)
					a_itemInfo.type = InventoryDefines.ICT_SPELL;
				// Fall through
				
			default:
				a_entryObject.infoArmor =  "-";
				a_entryObject.infoArmorValid =  0;
				a_entryObject.infoDamage = "-";
				a_entryObject.infoDamageValid = 0;
				a_entryObject.infoIsEnchanted = false;
		}

		a_entryObject.infoValue = Math.round(a_itemInfo.value);
		a_entryObject.infoWeight = Math.round(a_itemInfo.weight * 10) / 10;
		a_entryObject.infoType = a_itemInfo.type;
		a_entryObject.infoPotionType = a_itemInfo.potionType;
		a_entryObject.infoWeightValue = a_itemInfo.weight != 0 ? Math.round(a_itemInfo.value / a_itemInfo.weight) : "-";
		
		if (a_itemInfo.weight != 0) {
			a_entryObject.infoWeightValue = Math.round(a_itemInfo.value / a_itemInfo.weight);
			a_entryObject.infoWeightValueValid = 1;
		} else {
			a_entryObject.infoWeightValue = "-";
			a_entryObject.infoWeightValueValid = 0;
		}
		
		a_entryObject.infoIsPoisoned = (a_itemInfo.poisoned > 0);
		a_entryObject.infoIsStolen = (a_itemInfo.stolen > 0);
		a_entryObject.infoIsEquipped = (a_entryObject.equipState > 0);
	}
}