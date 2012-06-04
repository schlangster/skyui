dynamic class StatsList extends Shared.BSScrollingList
{
	var scrollbar;

	function StatsList()
	{
		super();
		this.scrollbar.focusTarget = this;
	}

	function SetEntryText(aEntryClip, aEntryObject)
	{
		super.SetEntryText(aEntryClip, aEntryObject);
		aEntryClip.valueText.textAutoSize = "shrink";
		if (aEntryObject.text != undefined) 
		{
			aEntryClip.valueText.SetText(aEntryObject.value.toString());
			return;
		}
		aEntryClip.valueText.SetText(" ");
	}

}
