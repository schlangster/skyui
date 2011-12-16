class FavoritesCenteredList extends Shared.CenteredScrollingList
{
	var iPlatform:Number; 
	var iNumTopHalfEntries:Number;
	var EntriesA:Array;
	 
	function FavoritesCenteredList()
	{
		super();
	}
	function SetEntryText(aEntryClip, aEntryObject)
	{
		var _equipState = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];
		if (aEntryObject.text != undefined)
		{
			if (aEntryObject.hotkey != undefined && aEntryObject.hotkey != -1)
			{
				aEntryClip.textField.SetText(aEntryObject.hotkey + 1 + ". " + aEntryObject.text);
			}
			else
			{
				aEntryClip.textField.SetText(aEntryObject.text);
			}
			var _maxTextLength = 35;
			if (aEntryClip.textField.text.length > _maxTextLength)
			{
				aEntryClip.textField.SetText(aEntryClip.textField.text.substr(0, _maxTextLength - 3) + "...");
			} 
		}
		else
		{
			aEntryClip.textField.SetText(" ");
		}
		aEntryClip.textField.textAutoSize = "shrink";
		if (aEntryObject != undefined)
		{
			aEntryClip.EquipIcon.gotoAndStop(_equipState[aEntryObject.equipState]);
		}
		else
		{
			aEntryClip.EquipIcon.gotoAndStop("None");
		}
		if (iPlatform == 0)
		{
			aEntryClip._alpha = aEntryObject == selectedEntry ? (100) : (60);
		}
		else
		{
			var _loc5 = 8;
			if (aEntryClip.clipIndex < iNumTopHalfEntries)
			{
				aEntryClip._alpha = 60 - _loc5 * (iNumTopHalfEntries - aEntryClip.clipIndex);
			}
			else if (aEntryClip.clipIndex > iNumTopHalfEntries)
			{
				aEntryClip._alpha = 60 - _loc5 * (aEntryClip.clipIndex - iNumTopHalfEntries);
			}
			else
			{
				aEntryClip._alpha = 100;
			} 
		} 
	} 
	function InvalidateData()
	{
		EntriesA.sort(doABCSort);
		super.InvalidateData();
	} 
	function doABCSort(aObj1, aObj2)
	{
		if (aObj1.text < aObj2.text)
		{
			return (-1);
		} 
		if (aObj1.text > aObj2.text)
		{
			return (1);
		}
		return (0);
	} 
	function onMouseWheel(delta)
	{
		if (delta == 1)
		{
			moveSelectionUp();
		}
		else if (delta == -1)
		{
			moveSelectionDown();
		} 
	} 
} 
