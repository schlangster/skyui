import gfx.controls.ScrollBar;
import gfx.io.GameDelegate;

class JournalSaveLoadList extends Shared.BSScrollingList
{
	var ListScrollbar: ScrollBar;
	var iMaxScrollPosition: Number;

	function JournalSaveLoadList()
	{
		super();
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		super.SetEntry(aEntryClip, aEntryObject);
		if (aEntryObject.fileNum == undefined) {
			aEntryClip.SaveNumber.SetText(" ");
		} else if (aEntryObject.fileNum < 10) {
			aEntryClip.SaveNumber.SetText("00" + aEntryObject.fileNum);
		} else if (aEntryObject.fileNum < 100) {
			aEntryClip.SaveNumber.SetText("0" + aEntryObject.fileNum);
		} else {
			aEntryClip.SaveNumber.SetText(aEntryObject.fileNum);
		}
		if (ListScrollbar != undefined) {
			aEntryClip._x = iMaxScrollPosition <= 0 ? 0 : 25;
		}
	}

	function moveSelectionUp(): Void
	{
		super.moveSelectionUp();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	function moveSelectionDown(): Void
	{
		super.moveSelectionDown();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

}
