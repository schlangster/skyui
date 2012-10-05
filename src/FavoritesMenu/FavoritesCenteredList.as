class FavoritesCenteredList extends Shared.CenteredScrollingList
{
	var EntriesA: Array;
	var iNumTopHalfEntries: Number;
	var iPlatform: Number;

	function FavoritesCenteredList()
	{
		super();
	}

	function SetEntryText(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		var equippedStates: Array = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];
		if (aEntryObject.text == undefined) {
			aEntryClip.textField.SetText(" ");
		} else {
			if (aEntryObject.hotkey != undefined && aEntryObject.hotkey != -1) {
				AppendHotkeyText(aEntryClip.textField, aEntryObject.hotkey, aEntryObject.text);
			} else {
				aEntryClip.textField.SetText(aEntryObject.text);
			}
			var maxTextLength: Number = 35;
			if (aEntryClip.textField.text.length > maxTextLength) {
				aEntryClip.textField.SetText(aEntryClip.textField.text.substr(0, maxTextLength - 3) + "...");
			}
		}
		aEntryClip.textField.textAutoSize = "shrink";
		if (aEntryObject == undefined) {
			aEntryClip.EquipIcon.gotoAndStop("None");
		} else {
			aEntryClip.EquipIcon.gotoAndStop(equippedStates[aEntryObject.equipState]);
		}
		if (iPlatform == 0) {
			aEntryClip._alpha = aEntryObject == selectedEntry ? 100 : 60;
			return;
		}
		var alphaMultiplier: Number = 8;
		if (aEntryClip.clipIndex < iNumTopHalfEntries) {
			aEntryClip._alpha = 60 - alphaMultiplier * (iNumTopHalfEntries - aEntryClip.clipIndex);
			return;
		}
		if (aEntryClip.clipIndex > iNumTopHalfEntries) {
			aEntryClip._alpha = 60 - alphaMultiplier * (aEntryClip.clipIndex - iNumTopHalfEntries);
			return;
		}
		aEntryClip._alpha = 100;
	}
	
	function AppendHotkeyText(atfText: TextField, aiHotkey: Number, astrItemName: String): Void
	{
		if (aiHotkey >= 0 && aiHotkey <= 7) {
			atfText.SetText(aiHotkey + 1 + ". " + astrItemName);
			return;
		}
		atfText.SetText("$HK" + aiHotkey);
		atfText.SetText(atfText.text + ". " + astrItemName);
	}

	function InvalidateData()
	{
		EntriesA.sort(doABCSort);
		super.InvalidateData();
	}

	function doABCSort(aObj1: Object, aObj2: Object): Number
	{
		if (aObj1.text < aObj2.text) {
			return -1;
		}
		if (aObj1.text > aObj2.text) {
			return 1;
		}
		return 0;
	}

	function onMouseWheel(delta: Number): Void
	{
		if (delta == 1) {
			moveSelectionUp();
			return;
		}
		if (delta == -1) {
			moveSelectionDown();
		}
	}

}
