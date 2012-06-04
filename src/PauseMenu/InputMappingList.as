dynamic class InputMappingList extends Shared.BSScrollingList
{
	var GetClipByIndex;

	function InputMappingList()
	{
		super();
	}

	function GetEntryHeight(aiEntryIndex)
	{
		var __reg2 = this.GetClipByIndex(0);
		return __reg2._height;
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		aEntryClip.textField.textAutoSize = "shrink";
		aEntryClip.textField.SetText("$" + aEntryObject.text);
		aEntryClip.textField._alpha = aEntryObject == this.selectedEntry ? 100 : 30;
		if (aEntryClip.ButtonArt != undefined) 
		{
			aEntryClip.ButtonArt.removeMovieClip();
		}
		var __reg2 = aEntryClip.attachMovie(aEntryObject.buttonName, "ButtonArt", aEntryClip.getNextHighestDepth());
		var __reg4 = aEntryClip.buttonPlacing;
		if (__reg2 == undefined) 
		{
			__reg2 = aEntryClip.attachMovie("UnknownKey", "ButtonArt", aEntryClip.getNextHighestDepth());
			if (aEntryObject.buttonID == undefined) 
			{
				__reg2.textField.SetText("???");
			}
			else 
			{
				__reg2.textField.SetText(this.GetHexString(aEntryObject.buttonID));
			}
			__reg4 = aEntryClip.buttonPlacing;
		}
		if (__reg2 != undefined) 
		{
			var __reg6 = __reg2._width / __reg2._height;
			__reg2._height = __reg4._height;
			__reg2._width = __reg6 * __reg4._height;
			__reg2._y = __reg4._y;
			__reg2._x = __reg4._x + (__reg4._width - __reg2._width) / 2;
			__reg2._alpha = aEntryObject == this.selectedEntry ? 100 : 30;
			__reg4._visible = false;
			return;
		}
		__reg4._visible = true;
	}

	function GetHexString(aiNumber)
	{
		var __reg3 = "";
		var __reg1 = aiNumber;
		var __reg4 = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
		while (__reg1 > 0) 
		{
			var __reg2 = __reg1 % 16;
			__reg3 = __reg4[__reg2] + __reg3;
			__reg1 = Math.floor(__reg1 / 16);
		}
		__reg3 = "0x" + __reg3;
		return __reg3;
	}

}
