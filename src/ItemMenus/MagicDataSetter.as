import skyui.defines.Actor;
import skyui.defines.Inventory;

class MagicDataSetter extends ItemcardDataExtender
{
  /* PRIVATE VARIABLES */

  	private var _defaultDisabledColor: Number;

  /* INITIALIZATION */

	public function MagicDataSetter(a_configAppearance: Object)
	{
		super();

		_defaultDisabledColor = (a_configAppearance.colors.text.disabled != undefined) ? a_configAppearance.colors.text.disabled : 0x000000;
	}
	
  	// @override ItemcardDataExtender
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;
		a_entryObject.type = a_itemInfo.type;
		a_entryObject.spellCost = a_itemInfo.spellCost;
		a_entryObject.castTime = a_itemInfo.castTime;
		a_entryObject.timeRemaining = a_itemInfo.timeRemaining;

		a_entryObject.actorValue = (a_entryObject.actorValue != Actor.AV_NONE) ? a_entryObject.actorValue : undefined;
		a_entryObject.resistance = (a_entryObject.resistance != Actor.AV_NONE) ? a_entryObject.resistance : undefined;
		a_entryObject.school = (a_entryObject.school != Actor.AV_NONE) ? a_entryObject.school : undefined;
		a_entryObject.source = (a_entryObject.cardName != undefined) ? a_entryObject.cardName : "-";

		a_entryObject.word0 = a_itemInfo.word0;
		a_entryObject.word1 = a_itemInfo.word1;
		a_entryObject.word2 = a_itemInfo.word2;
		a_entryObject.word0Unlocked = a_itemInfo.unlocked0;
		a_entryObject.word1Unlocked = a_itemInfo.unlocked1;
		a_entryObject.word2Unlocked = a_itemInfo.unlocked2;
		a_entryObject.word0Display = a_entryObject.word1Display = a_entryObject.word2Display = "-";
		a_entryObject.word0Recharge = a_entryObject.word1Recharge = a_entryObject.word2Recharge = "-";
		a_entryObject.word0Color = a_entryObject.word1Color = a_entryObject.word2Color = undefined;

		a_entryObject.durationDisplay = (a_entryObject.duration > 0) ? String(Math.round(a_entryObject.duration * 10) / 10) : "-";
		a_entryObject.magnitudeDisplay = (a_entryObject.magnitude > 0) ? String(Math.round(a_entryObject.magnitude * 10) / 10) : "-";
		a_entryObject.schoolDisplay = (a_itemInfo.magicSchoolName != undefined) ? a_itemInfo.magicSchoolName : "-";
		a_entryObject.spellCostDisplay = "-";
		a_entryObject.skillLevelDisplay = (a_itemInfo.castLevel != undefined) ? a_itemInfo.castLevel : "-";
		a_entryObject.timeRemainingDisplay = "-";

		switch (a_entryObject.type) {
			case Inventory.ICT_SHOUT:
				processShout(a_entryObject);
				break;
			
			case Inventory.ICT_ACTIVE_EFFECT:
				processActiveEffect(a_entryObject);
				break;

			case Inventory.ICT_SPELL:
				processSpell(a_entryObject);
				break;

			case Inventory.ICT_SPELL_DEFAULT: //Power
			default:
				processPower(a_entryObject);
				break;
		}
	}

  /* PRIVATE FUNCTIONS */

	private function processShout(a_entryObject: Object): Void
	{
		var recharge: Array = a_entryObject.spellCost.split(" , ");

		for (var i = 0; i < 3; i++)  {
			if (a_entryObject["word" + i] != undefined) {
				a_entryObject["word" + i + "Display"] = a_entryObject["word" + i];
				if (recharge[i] != undefined) {
					a_entryObject["word" + i + "Display"] += " (" + recharge[i] + ")";
					a_entryObject["word" + i + "Recharge"] = Number(recharge[i]);
				}
			}

			if (a_entryObject["word" + i + "Unlocked"] == undefined || a_entryObject["word" + i + "Unlocked"] == false)
				a_entryObject["word" + i + "Color"] = _defaultDisabledColor;
		}
	}

	private function processActiveEffect(a_entryObject: Object): Void
	{
		if (a_entryObject.timeRemaining != undefined && a_entryObject.timeRemaining > 0) {

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

	private function processSpell(a_entryObject: Object): Void
	{
		processSpellCost(a_entryObject);
	}

	private function processPower(a_entryObject: Object): Void
	{
		// Powers should have no skillLevel
		a_entryObject.skillLevel = undefined;
		a_entryObject.skillLevelDisplay = "-";

		processSpellCost(a_entryObject);
	}


	private function processSpellCost(a_entryObject: Object): Void
	{
		if (a_entryObject.spellCost != 0 && a_entryObject.castTime == 0) {
			a_entryObject.spellCostDisplay = String(Math.round(a_entryObject.spellCost * 10) / 10) + "/s";
		} else if (a_entryObject.spellCost != 0) {
			a_entryObject.spellCostDisplay = String(Math.round(a_entryObject.spellCost * 10) / 10);
		}
	}
}