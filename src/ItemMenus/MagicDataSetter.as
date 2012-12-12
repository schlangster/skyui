import skyui.defines.Inventory;

class MagicDataSetter extends ItemcardDataExtender
{
  /* PRIVATE VARIABLES */

  	private var _defaultDisabledColor: Number;

  /* INITIALIZATION */

	public function MagicDataSetter(a_configItemList: Object, a_configAppearance: Object)
	{
		super();

		_defaultDisabledColor = a_configAppearance.colors.text.disabled;
	}
	
  	// @override ItemcardDataExtender
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;
		a_entryObject.type = a_itemInfo.type;
		a_entryObject.spellCost = a_itemInfo.spellCost;
		a_entryObject.castTime = a_itemInfo.castTime;

		a_entryObject.schoolDisplay = "-";
		a_entryObject.spellCostDisplay = "-";
		a_entryObject.skillLevelDisplay  = "-";
		a_entryObject.word1 = a_entryObject.word2 = a_entryObject.word3 = "-";
		a_entryObject.recharge1 = a_entryObject.recharge2 = a_entryObject.recharge3 = undefined;
		a_entryObject.wordColor1 = a_entryObject.wordColor2 = a_entryObject.wordColor3 = undefined;
		a_entryObject.timeRemaining = undefined;
		a_entryObject.timeRemainingDisplay = "-";

		switch (a_entryObject.type) {
			// Shout
			case Inventory.ICT_SHOUT:
				processShout(a_entryObject, a_itemInfo);
				break;
			
			// Active Effect
			case Inventory.ICT_ACTIVE_EFFECT:
				processActiveEffect(a_entryObject, a_itemInfo);
				break;

			case Inventory.ICT_SPELL:
				processSpell(a_entryObject, a_itemInfo);
				break;

			//Power
			case Inventory.ICT_SPELL_DEFAULT:
			default:
				processPower(a_entryObject, a_itemInfo);
				break;
		}
	}

  /* PRIVATE FUNCTIONS */

	private function processShout(a_entryObject: Object, a_itemInfo: Object): Void
	{
		// Shouts should have no spellCost or skillLevel
		a_entryObject.spellCost = undefined;
		a_entryObject.skillLevel = undefined;
		
		var recharge: Array = a_itemInfo.spellCost.split(" , ");
		
		if (a_itemInfo.word0 != undefined) {
			a_entryObject.word1 = a_itemInfo.word0;
			if (recharge[0] != undefined) {
				a_entryObject.word1 += " (" + recharge[0] + ")";
				a_entryObject.recharge1 = Number(recharge[0]);
			}
			if (a_itemInfo.unlocked0 == undefined || a_itemInfo.unlocked0 == false)
				a_entryObject.wordColor1 = _defaultDisabledColor;
		}
		
		if (a_itemInfo.word1 != undefined) {
			a_entryObject.word2 = a_itemInfo.word1;
			if (recharge[1] != undefined) {
				a_entryObject.word2 += " (" + recharge[1] + ")";
				a_entryObject.recharge2 = Number(recharge[1]);
			}
			if (a_itemInfo.unlocked1 == undefined || a_itemInfo.unlocked1 == false)
				a_entryObject.wordColor2 = _defaultDisabledColor;
		}
		
		if (a_itemInfo.word2 != undefined) {
			a_entryObject.word3 = a_itemInfo.word2;
			if (recharge[2] != undefined) {
				a_entryObject.word3 += " (" + recharge[2] + ")";
				a_entryObject.recharge3 = Number(recharge[2]);
			}
			if (a_itemInfo.unlocked2 == undefined || a_itemInfo.unlocked2 == false)
				a_entryObject.wordColor3 = _defaultDisabledColor;
		}
	}
	private function processActiveEffect(a_entryObject: Object, a_itemInfo: Object): Void
	{
		//cardName = a_entryObject.source = a_itemInfo.name;
		if (a_itemInfo.timeRemaining != undefined && a_itemInfo.timeRemaining > 0) {
			a_entryObject.timeRemaining = a_itemInfo.timeRemaining;

			var s: Number = Math.round(a_entryObject.timeRemaining);
			var m: Number = 0;
			var h: Number = 0;
			var d: Number = 0;
			
			if (s >= 60) {
				m = Math.floor(s / 60);
				s = s % 60;
			}
			if  (m >= 60) {
				h = Math.floor(m / 60);
				m = m % 60;
			}
			if  (h >= 24) {
				d = Math.floor(h / 24);
				h = h % 24;
			}
			
			a_entryObject.timeRemainingDisplay = (d != 0 ? (d + "d ") : "") +
												 (h != 0 || d ? (h + "h ") : "") +
												 (m != 0 || d || h ? (m + "m ") : "") +
												 (s + "s");
		}
	}
	private function processSpell(a_entryObject: Object, a_itemInfo: Object): Void
	{
		a_entryObject.schoolDisplay = a_itemInfo.magicSchoolName;
		a_entryObject.skillLevelDisplay = a_itemInfo.castLevel;

		processSpellCost(a_entryObject, a_itemInfo);
	}

	private function processPower(a_entryObject: Object, a_itemInfo: Object): Void
	{
		// Powers should have no skillLevel
		a_entryObject.skillLevel = undefined;

		processSpellCost(a_entryObject, a_itemInfo);
	}


	private function processSpellCost(a_entryObject: Object, a_itemInfo: Object): Void
	{
		if (a_entryObject.spellCost != 0 && a_entryObject.castTime == 0) {
			a_entryObject.spellCostDisplay = a_entryObject.spellCost + "/s";
		} else if (a_entryObject.spellCost != 0) {
			a_entryObject.spellCostDisplay = a_entryObject.spellCost;
		}
	}
}