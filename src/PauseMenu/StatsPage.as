import gfx.managers.FocusHandler;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;

class StatsPage extends MovieClip
{
	var CategoryList: MovieClip;
	var CategoryList_mc: MovieClip;
	var StatsList_mc: MovieClip;
	var _StatsList: MovieClip;
	var bUpdated: Boolean;
	var iPlatform: Number;
	var Divider: MovieClip;

	function StatsPage()
	{
		super();
		CategoryList = CategoryList_mc.List_mc;
		_StatsList = StatsList_mc;
		bUpdated = false;
	}

	function OnShow(): Void
	{
		bUpdated = false;
		var STAT_ENTRYLISTINDEX = 2;
		var STAT_STRIDE = 4;
		var cursor = 0;
		while(cursor < arguments.length)
		{
			CategoryList.entryList[arguments[cursor + STAT_ENTRYLISTINDEX]].stats.length = 0;
			cursor = cursor + STAT_STRIDE;
		}
		CategoryList.entryList.length = 0;
		CategoryList.InvalidateData();
		onLoad();
	}

	function onLoad(): Void
	{
		CategoryList.entryList.push({text: "$GENERAL", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$QUEST", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$COMBAT", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$MAGIC", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$CRAFTING", stats: new Array(), savedHighlight: 0});
		CategoryList.entryList.push({text: "$CRIME", stats: new Array(), savedHighlight: 0});
		CategoryList.InvalidateData();
		CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		CategoryList.disableInput = true; // Bugfix for vanilla
		_StatsList.disableSelection = false;
	}

	function startPage(): Void
	{
		CategoryList.disableInput = false; // Bugfix for vanilla
		FocusHandler.instance.setFocus(CategoryList, 0);
		if (bUpdated) {
			return;
		}
		GameDelegate.call("updateStats", [], this, "PopulateStatsList");
		bUpdated = true;
	}

	function endPage(): Void
	{
		CategoryList.disableInput = true; // Bugfix for vanilla
	}

	function PopulateStatsList(): Void
	{
		var STAT_TEXT = 0;
		var STAT_VALUE = 1;
		var STAT_ENTRYLISTINDEX = 2;
		var STAT_UNKNOWN = 3;
		var STAT_STRIDE = 4;

		for (var i: Number = 0; i < arguments.length; i += STAT_STRIDE) {
			var stat: Object = {text: "$" + arguments[i + STAT_TEXT], value: arguments[i + STAT_VALUE]};
			CategoryList.entryList[arguments[i + STAT_ENTRYLISTINDEX]].stats.push(stat);
		}
		onCategoryHighlight();
	}

	function onCategoryHighlight(): Void
	{
		var stats: Array = CategoryList.selectedEntry.stats;
		_StatsList.ClearList();
		_StatsList.scrollPosition = 0;

		for(var i: Number = 0; i < stats.length; i++) {
			_StatsList.entryList.push(stats[i]);
		}
		_StatsList.InvalidateData();
	}

	function onCategoryListMoveUp(event: Object): Void
	{
		onCategoryHighlight();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	function onCategoryListMoveDown(event: Object): Void
	{
		onCategoryHighlight();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	function onCategoryListMouseSelectionChange(event: Object): Void
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			onCategoryHighlight();
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function onRightStickInput(afX: Number, afY: Number): Void
	{
		if (afY < 0) {
			_StatsList.moveSelectionDown();
			return;
		}
		_StatsList.moveSelectionUp();
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		CategoryList.SetPlatform(aiPlatform, abPS3Switch);
		_StatsList.SetPlatform(aiPlatform, abPS3Switch);
		iPlatform = aiPlatform;
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bhandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if (_StatsList.entryList.length > 0) {
				if (details.navEquivalent == NavigationCode.LEFT && FocusHandler.instance.getFocus(0) != CategoryList) {
					switchFocusToCategoryList();
					bhandledInput = true;
				} else if (details.navEquivalent == NavigationCode.RIGHT && FocusHandler.instance.getFocus(0) != _StatsList) {
					switchFocusToStatsList();
					bhandledInput = true;

				} else if (details.navEquivalent == NavigationCode.DOWN && FocusHandler.instance.getFocus(0) == _StatsList) {
					// Scroll down if the user has the stat list select and hits "down"
					_StatsList.scrollPosition = _StatsList.scrollPosition + 1;
				} else if (details.navEquivalent == NavigationCode.UP && FocusHandler.instance.getFocus(0) == _StatsList) {
					// Scroll up if the user has the stat list select and hits "up"
					_StatsList.scrollPosition = _StatsList.scrollPosition - 1;
				}
			}
		}

		// Let other widgets try handling the event
		if (!bhandledInput && pathToFocus != undefined && pathToFocus.length > 0) {
			bhandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return bhandledInput;
	}

	private function switchFocusToStatsList(): Void
	{
		FocusHandler.instance.setFocus(_StatsList, 0);
		Divider.gotoAndStop("Left");
	}

	private function switchFocusToCategoryList(): Void
	{
		FocusHandler.instance.setFocus(CategoryList, 0);
		Divider.gotoAndStop("Right");
	}

}
