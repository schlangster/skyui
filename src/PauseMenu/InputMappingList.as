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
		var buttonArt: InputMappingArt	= aEntryClip.buttonArt;
		var label: MovieClip			= aEntryClip.textField;

		buttonArt._alpha = aEntryObject == selectedEntry ? 100 : 30;
		label._alpha = aEntryObject == selectedEntry ? 100 : 30;
		label.textAutoSize = "shrink";

		buttonArt.setButtonName(aEntryObject.buttonName);
		label.SetText("$" + aEntryObject.text);
	}
}
