dynamic class OptionsList extends Shared.BSScrollingList
{
	var EntriesA;
	var GetClipByIndex;
	var bAllowValueOverwrite;

	function OptionsList()
	{
		super();
		this.bAllowValueOverwrite = false;
	}

	function GetEntryHeight(aiEntryIndex)
	{
		var __reg2 = this.GetClipByIndex(0);
		return __reg2._height;
	}

	function onValueChange(aiItemIndex, aiNewValue)
	{
		if (aiItemIndex != undefined) 
		{
			this.EntriesA[aiItemIndex].value = aiNewValue;
		}
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryClip != undefined) 
		{
			aEntryClip.selected = aEntryObject == this.selectedEntry;
			if (this.bAllowValueOverwrite || aEntryClip.ID != aEntryObject.ID) 
			{
				aEntryClip.movieType = aEntryObject.movieType;
				if (aEntryObject.options != undefined) 
				{
					aEntryClip.SetOptionStepperOptions(aEntryObject.options);
				}
				aEntryClip.ID = aEntryObject.ID;
				aEntryClip.value = aEntryObject.value;
				aEntryClip.text = aEntryObject.text;
			}
		}
	}

}
