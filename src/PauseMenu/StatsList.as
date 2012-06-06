import gfx.controls.ScrollBar;

class StatsList extends Shared.BSScrollingList
{
	var scrollbar: ScrollBar;

	function StatsList()
	{
		super();
		scrollbar.focusTarget = this;
	}

	function SetEntryText(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		super.SetEntryText(aEntryClip, aEntryObject);
		aEntryClip.valueText.textAutoSize = "shrink";
		if (aEntryObject.text != undefined) {
			aEntryClip.valueText.SetText(aEntryObject.value.toString());
			return;
		}
		aEntryClip.valueText.SetText(" ");
	}

}
