class InputMappingList extends Shared.BSScrollingList
{
	var GetClipByIndex;

	function InputMappingList()
	{
		super();
	}

	function GetEntryHeight(aiEntryIndex: Number): Number
	{
		var entry: MovieClip = GetClipByIndex(0);
		return entry._height;
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		aEntryClip.textField.textAutoSize = "shrink";
		aEntryClip.textField.SetText("$" + aEntryObject.text);
		aEntryClip.textField._alpha = aEntryObject == selectedEntry ? 100 : 30;
		if (aEntryClip.ButtonArt != undefined) {
			aEntryClip.ButtonArt.removeMovieClip();
		}
		var buttonArt_mc: MovieClip = aEntryClip.attachMovie(aEntryObject.buttonName, "ButtonArt", aEntryClip.getNextHighestDepth());
		var buttonPlacing_mc: MovieClip = aEntryClip.buttonPlacing;
		if (buttonArt_mc == undefined) {
			buttonArt_mc = aEntryClip.attachMovie("UnknownKey", "ButtonArt", aEntryClip.getNextHighestDepth());
			if (aEntryObject.buttonID == undefined) {
				buttonArt_mc.textField.SetText("???");
			} else {
				buttonArt_mc.textField.SetText(GetHexString(aEntryObject.buttonID));
			}
			buttonPlacing_mc = aEntryClip.buttonPlacing;
		}
		if (buttonArt_mc != undefined) {
			var iar: Number = buttonArt_mc._width / buttonArt_mc._height;
			buttonArt_mc._height = buttonPlacing_mc._height;
			buttonArt_mc._width = iar * buttonPlacing_mc._height;
			buttonArt_mc._y = buttonPlacing_mc._y;
			buttonArt_mc._x = buttonPlacing_mc._x + (buttonPlacing_mc._width - buttonArt_mc._width) / 2;
			buttonArt_mc._alpha = aEntryObject == selectedEntry ? 100 : 30;
			buttonPlacing_mc._visible = false;
			return;
		}
		buttonPlacing_mc._visible = true;
	}

	function GetHexString(aiNumber: Number): String
	{
		var shex: String = "";
		var idec: Number = aiNumber;
		var ahexarr: Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
		while (idec > 0) {
			var ibit: Number = idec % 16;
			shex = ahexarr[ibit] + shex;
			idec = Math.floor(idec / 16);
		}
		shex = "0x" + shex;
		return shex;
	}

}
