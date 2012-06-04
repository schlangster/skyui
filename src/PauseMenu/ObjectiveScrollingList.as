dynamic class ObjectiveScrollingList extends Shared.BSScrollingList
{
	var SetEntryText;

	function ObjectiveScrollingList()
	{
		super();
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryObject.text == undefined) 
		{
			aEntryClip.gotoAndStop("None");
		}
		else 
		{
			var __reg2 = "";
			if (aEntryObject.active) 
			{
				__reg2 = __reg2 + "Active";
			}
			else if (aEntryObject.completed) 
			{
				__reg2 = __reg2 + "Completed";
			}
			else if (aEntryObject.failed) 
			{
				__reg2 = __reg2 + "Failed";
			}
			else 
			{
				__reg2 = __reg2 + "Normal";
			}
			if (aEntryObject == this.selectedEntry) 
			{
				__reg2 = __reg2 + "Selected";
			}
			aEntryClip.gotoAndStop(__reg2);
		}
		this.SetEntryText(aEntryClip, aEntryObject);
	}

}
