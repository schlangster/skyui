class ObjectiveScrollingList extends Shared.BSScrollingList
{
	var SetEntryText: Function;

	function ObjectiveScrollingList()
	{
		super();
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		if (aEntryObject.text == undefined) {
			aEntryClip.gotoAndStop("None");
		} else {
			var slabelName: String = "";
			if (aEntryObject.active) {
				slabelName = slabelName + "Active";
			} else if (aEntryObject.completed) {
				slabelName = slabelName + "Completed";
			} else if (aEntryObject.failed) {
				slabelName = slabelName + "Failed";
			} else  {
				slabelName = slabelName + "Normal";
			}
			if (aEntryObject == selectedEntry) {
				slabelName = slabelName + "Selected";
			}
			aEntryClip.gotoAndStop(slabelName);
		}
		SetEntryText(aEntryClip, aEntryObject);
	}

}
