class skyui.MagicDataFetcher implements skyui.IDataFetcher
{
	static var MAGIC_TYPES = ["Alteration", "Illusion", "Destruction", "Conjuration", "Restoration"];
	static var SHOUT_TYPES = ["Ice", "Fire", "Force", "Whirlwind"];
	
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		switch (a_itemInfo.type) {
			case InventoryDefines.ICT_SPELL_DEFAULT :
				a_entryObject.infoSpellCost = "-";
				a_entryObject.infoCastTime = "-";
				a_entryObject.infoType = a_itemInfo["type"];
				break;
			case InventoryDefines.ICT_SPELL :
				a_entryObject.infoSpellCost = a_itemInfo["spellCost"];
//				a_entryObject.infoType = MAGIC_TYPES.indexOf(a_itemInfo["magicSchoolName"]);
				a_entryObject.infoCastTime = a_itemInfo["castTime"];
				break;
			case InventoryDefines.ICT_SHOUT :
				a_entryObject.infoSpellCost = "-";
				a_entryObject.infoRecharge = a_itemInfo["spellCost"];
				a_entryObject.infoCastTime = "-";
				a_entryObject.infoShoutType = SHOUT_TYPES.indexOf(a_itemInfo["word0"]);
				break;
			case InventoryDefines.ICT_ACTIVE_EFFECT :
			default :
				a_entryObject.infoSpellCost = "-";
				a_entryObject.infoCastTime = "-";
				a_entryObject.infoTimeRemaining = a_itemInfo["timeRemaining"];
				a_entryObject.infoNegativeEffect = a_itemInfo["negativeEffect"];
				a_entryObject.infoItem = a_itemInfo["name"];
				break;
		}
		
		a_entryObject.infoType = a_itemInfo["type"];
		a_entryObject.infoSchoolName = a_itemInfo["magicSchoolName"];
		a_entryObject.infoSchoolLevel = a_itemInfo["magicSchoolLevel"];
		a_entryObject.infoSchoolPct = a_itemInfo["magicSchoolPct"];
	}
}