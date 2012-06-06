class OptionsList extends Shared.BSScrollingList
{
	var EntriesA: Array;
	var GetClipByIndex: Function;
	var bAllowValueOverwrite: Boolean;

	function OptionsList()
	{
		super();
		bAllowValueOverwrite = false;
	}

	function GetEntryHeight(aiEntryIndex: Number): Number
	{
		var entry: MovieClip = GetClipByIndex(0);
		return entry._height;
	}

	function onValueChange(aiItemIndex: Number, aiNewValue: Number): Void
	{
		if (aiItemIndex != undefined) {
			EntriesA[aiItemIndex].value = aiNewValue;
		}
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		if (aEntryClip != undefined) {
			aEntryClip.selected = aEntryObject == selectedEntry;
			if (bAllowValueOverwrite || aEntryClip.ID != aEntryObject.ID) {
				aEntryClip.movieType = aEntryObject.movieType;
				if (aEntryObject.options != undefined) {
					aEntryClip.SetOptionStepperOptions(aEntryObject.options);
				}
				aEntryClip.ID = aEntryObject.ID;
				aEntryClip.value = aEntryObject.value;
				aEntryClip.text = aEntryObject.text;
			}
		}
	}

}
