class skyui.MagicDataFetcher implements skyui.IDataFetcher
{
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		switch (a_itemInfo.type) {
			// Spell
			case InventoryDefines.ICT_SPELL :
				a_entryObject.infoSpellCost = a_itemInfo["spellCost"];
				
				if (a_itemInfo["spellCost"] == 0) {
					a_entryObject.infoSpellCostStr = "-";
				} else if (a_itemInfo["castTime"] == 0) {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost + "/s";
				} else {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost;
				}
				
				a_entryObject.infoSchoolName = a_itemInfo["magicSchoolName"];
				break;
			
			// Power
			case InventoryDefines.ICT_SPELL_DEFAULT :
			default :
				a_entryObject.infoSpellCost = a_itemInfo["spellCost"];

				if (a_itemInfo["spellCost"] == 0) {
					a_entryObject.infoSpellCostStr = "-";
				} else if (a_itemInfo["castTime"] == 0) {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost + "/s";
				} else {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost;
				}
				
				a_entryObject.infoSchoolName = "-";
				break;
				
			// Shout
			case InventoryDefines.ICT_SHOUT :
				a_entryObject.infoSpellCost = 0;
				a_entryObject.infoSpellCostStr = "-";
				a_entryObject.infoCastTime = "-";
				a_entryObject.infoSchoolName = "-";
				
				a_entryObject.infoRecharge = a_itemInfo["spellCost"];
				break;
			
			// Active Effect
			case InventoryDefines.ICT_ACTIVE_EFFECT :
				a_entryObject.infoItem = a_itemInfo["name"];
				a_entryObject.infoTimeRemaining = Math.round(a_itemInfo["timeRemaining"]);
				
				if (! a_entryObject.infoTimeRemaining) {
					a_entryObject.infoTimeRemainingStr = "-";
				} else {
					var s = parseInt(a_entryObject.infoTimeRemaining);
					var m = 0;
					var h = 0;
					var d = 0;
					
					if (s >= 60) {
						m = Math.floor(s / 60);
						s = s % 60;
					}
					if  (m >= 60) {
						h = Math.floor(m / 60);
						m = m % 60;
					}
					if  (h >= 60) {
						d = Math.floor(h / 24);
						h = h % 24;
					}
					
					a_entryObject.infoTimeRemainingStr = (d != 0 ? (d + "d ") : "") +
														 (h != 0 ? (h + "h ") : "") +
														 (m != 0 ? (m + "m ") : "") +
														 (s != 0 ? (s + "s ") : "");
				}

				break;
		}
		
		a_entryObject.infoType = a_itemInfo["type"];
	}
}