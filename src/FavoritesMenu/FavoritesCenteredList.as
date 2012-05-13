dynamic class FavoritesCenteredList extends Shared.CenteredScrollingList
{
	var EntriesA;
	var iNumTopHalfEntries;
	var iPlatform;
	var moveSelectionDown;
	var moveSelectionUp;

	function FavoritesCenteredList()
	{
		super();
	}

	function SetEntryText(aEntryClip, aEntryObject)
	{
		var __reg6 = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

		if (aEntryObject.text == undefined) {
			aEntryClip.textField.SetText(" ");
		} else {
			if (aEntryObject.hotkey != undefined && aEntryObject.hotkey != -1) {
				aEntryClip.textField.SetText(aEntryObject.hotkey + 1 + ". " + aEntryObject.text);
			} else {
				aEntryClip.textField.SetText(aEntryObject.text);
			}
			var __reg4 = 35;
			if (aEntryClip.textField.text.length > __reg4) {
				aEntryClip.textField.SetText(aEntryClip.textField.text.substr(0, __reg4 - 3) + "...");
			}
		}
		
		aEntryClip.textField.textAutoSize = "shrink";
		
		if (aEntryObject == undefined) {
			aEntryClip.EquipIcon.gotoAndStop("None");
		} else {
			aEntryClip.EquipIcon.gotoAndStop(__reg6[aEntryObject.equipState]);
		}
		
		if (iPlatform == 0) {
			aEntryClip._alpha = aEntryObject == selectedEntry ? 100 : 60;
			return;
		}
		
		var __reg5 = 8;
		if (aEntryClip.clipIndex < iNumTopHalfEntries) {
			aEntryClip._alpha = 60 - __reg5 * (iNumTopHalfEntries - aEntryClip.clipIndex);
			return;
		}
		if (aEntryClip.clipIndex > iNumTopHalfEntries) {
			aEntryClip._alpha = 60 - __reg5 * (aEntryClip.clipIndex - iNumTopHalfEntries);
			return;
		}
		aEntryClip._alpha = 100;
	}

	function InvalidateData()
	{
		EntriesA.sort(doABCSort);
		super.InvalidateData();
	}

	function doABCSort(a_obj1, a_obj2)
	{
		if (a_obj1.text < a_obj2.text) {
			return -1;
		} else if (a_obj1.text > a_obj2.text) {
			return 1;
		} else {
			return 0;
		}
	}

	function onMouseWheel(delta)
	{
		if (delta == 1) {
			moveSelectionUp();
		} else if (delta == -1) {
			moveSelectionDown();
		}
	}

}