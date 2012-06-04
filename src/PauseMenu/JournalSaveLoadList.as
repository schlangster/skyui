dynamic class JournalSaveLoadList extends Shared.BSScrollingList
{
	var ListScrollbar;
	var iMaxScrollPosition;

	function JournalSaveLoadList()
	{
		super();
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		super.SetEntry(aEntryClip, aEntryObject);
		if (aEntryObject.fileNum == undefined) 
		{
			aEntryClip.SaveNumber.SetText(" ");
		}
		else if (aEntryObject.fileNum < 10) 
		{
			aEntryClip.SaveNumber.SetText("00" + aEntryObject.fileNum);
		}
		else if (aEntryObject.fileNum < 100) 
		{
			aEntryClip.SaveNumber.SetText("0" + aEntryObject.fileNum);
		}
		else 
		{
			aEntryClip.SaveNumber.SetText(aEntryObject.fileNum);
		}
		if (this.ListScrollbar != undefined) 
		{
			aEntryClip._x = this.iMaxScrollPosition <= 0 ? 0 : 25;
		}
	}

	function moveSelectionUp()
	{
		super.moveSelectionUp();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	function moveSelectionDown()
	{
		super.moveSelectionDown();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

}
