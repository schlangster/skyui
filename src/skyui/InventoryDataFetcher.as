class skyui.InventoryDataFetcher implements skyui.IDataFetcher
{
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		switch (a_itemInfo.type) {
			case InventoryDefines.ICT_ARMOR :
				a_entryObject.infoArmor = a_itemInfo.armor;
				break;
			case InventoryDefines.ICT_WEAPON :
				a_entryObject.infoDamage = a_itemInfo.damage;
				break;
			case InventoryDefines.ICT_POTION :
				// if potion item has spellCost then it is a scroll
				if (a_itemInfo.skillName) {
					a_itemInfo.type = InventoryDefines.ICT_BOOK;
				} else if (a_itemInfo.spellCost) {
					a_itemInfo.type = InventoryDefines.ICT_SPELL;
				}
				break;
			case InventoryDefines.ICT_SPELL :
			case InventoryDefines.ICT_SHOUT :
				a_entryObject.infoSpellCost = a_itemInfo.spellCost.toString();
				break;
			case InventoryDefines.ICT_SOUL_GEMS :
				a_entryObject.infoSoulLVL = a_itemInfo.soulLVL;
				break;
		}

		a_entryObject.infoValue = Math.round(a_itemInfo.value);
		a_entryObject.infoWeight = int(a_itemInfo.weight * 100) / 100;
		a_entryObject.infoType = a_itemInfo.type;
		a_entryObject.infoPotionType = a_itemInfo.potionType;
		a_entryObject.infoWeightValue = a_itemInfo.weight != 0 ? Math.round(a_itemInfo.value / a_itemInfo.weight) : 0;
		a_entryObject.infoIsPoisoned = (a_itemInfo.poisoned > 0);
		a_entryObject.infoIsStolen = (a_itemInfo.stolen > 0);
		a_entryObject.infoIsEnchanted = (a_itemInfo.charge != undefined);
		a_entryObject.infoIsEquipped = (a_entryObject.equipState > 0);
	}
}