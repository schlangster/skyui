class MagicDataFetcher implements skyui.IDataFetcher
{
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		switch (a_itemInfo.type) {
			// Spell
			case InventoryDefines.ICT_SPELL :
				a_entryObject.infoSpellCost = a_itemInfo["spellCost"];
				
				if (a_itemInfo["spellCost"] == 0) {
					a_entryObject.infoSpellCostStr = "-";
					a_entryObject.infoSpellCostValid = 0;
				} else if (a_itemInfo["castTime"] == 0) {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost + "/s";
					a_entryObject.infoSpellCostValid = 1;
				} else {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost;
					a_entryObject.infoSpellCostValid = 1;
				}
				
				a_entryObject.infoSchoolName = a_itemInfo["magicSchoolName"];
				a_entryObject.infoSchoolNameValid = 1;
				a_entryObject.infoSkillLevel = a_itemInfo["castLevel"].toString();
				a_entryObject.infoSkillLevelValid = 1;
				break;
			
			// Power
			case InventoryDefines.ICT_SPELL_DEFAULT :
			default :
				a_entryObject.infoSpellCost = a_itemInfo["spellCost"];

				if (a_itemInfo["spellCost"] == 0) {
					a_entryObject.infoSpellCostStr = "-";
					a_entryObject.infoSpellCostValid = 0;
				} else if (a_itemInfo["castTime"] == 0) {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost + "/s";
					a_entryObject.infoSpellCostValid = 1;
				} else {
					a_entryObject.infoSpellCostStr = a_entryObject.infoSpellCost;
					a_entryObject.infoSpellCostValid = 1;
				}
				
				a_entryObject.infoSchoolName = "-";
				a_entryObject.infoSchoolNameValid = 0;
				a_entryObject.infoSkillLevel = "-";
				a_entryObject.infoSkillLevelValid = 0;
				break;
				
			// Shout
			case InventoryDefines.ICT_SHOUT :
				a_entryObject.infoSpellCost = 0;
				a_entryObject.infoSpellCostStr = "-";
				a_entryObject.infoSpellCostValid = 0;
				a_entryObject.infoSchoolName = "-";
				a_entryObject.infoSchoolNameValid = 0;
				a_entryObject.infoSkillLevel = "-";
				a_entryObject.infoSkillLevelValid = 0;


				
				var recharge = a_itemInfo["spellCost"].split(" , ");
				
				if (a_itemInfo["word0"]) {
					a_entryObject.infoWord1 = a_itemInfo["word0"] + " (" + recharge[0] + ")";
					a_entryObject.infoRecharge1 = recharge[0];
					a_entryObject.infoWord1Valid = 1;
				} else {
					a_entryObject.infoWord1 = "-";
					a_entryObject.infoRecharge1 = "-";
					a_entryObject.infoWord1Valid = 0;
				}
				
				if (a_itemInfo["word1"]) {
					a_entryObject.infoWord2 = a_itemInfo["word1"] + " (" + recharge[1] + ")";;
					a_entryObject.infoRecharge2 = recharge[1];
					a_entryObject.infoWord2Valid = 1;
				} else {
					a_entryObject.infoWord2 = "-";
					a_entryObject.infoRecharge2 = "-";
					a_entryObject.infoWord2Valid = 0;
				}
				
				if (a_itemInfo["word2"]) {
					a_entryObject.infoWord3 = a_itemInfo["word2"] + " (" + recharge[2] + ")";;
					a_entryObject.infoRecharge3 = recharge[2];
					a_entryObject.infoWord3Valid = 1;
				} else {
					a_entryObject.infoWord3 = "-";
					a_entryObject.infoRecharge3 = "-";
					a_entryObject.infoWord3Valid = 0;
				}
				
				break;
			
			// Active Effect
			case InventoryDefines.ICT_ACTIVE_EFFECT :
				a_entryObject.infoItem = a_itemInfo["name"];
				a_entryObject.infoTimeRemaining = Math.round(a_itemInfo["timeRemaining"]);
				
				if (! a_entryObject.infoTimeRemaining || a_entryObject.infoTimeRemaining <= 0) {
					a_entryObject.infoTimeRemainingStr = "-";
					a_entryObject.infoTimeRemainingValid = 0;
				} else {
					a_entryObject.infoTimeRemainingValid = 1;
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