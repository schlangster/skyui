import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

class FavoritesMenu extends MovieClip
{
	var bPCControlsReady: Boolean = true;
	var ItemList: MovieClip;
	var LeftPanel: MovieClip;
	var List_mc: MovieClip;

	function FavoritesMenu()
	{
		super();
		ItemList = List_mc;
	}

	function InitExtensions(): Void
	{
		GlobalFunc.SetLockFunction();
		_parent.Lock("BL");
		GameDelegate.addCallBack("PopulateItems", this, "populateItemList");
		GameDelegate.addCallBack("SetSelectedItem", this, "setSelectedItem");
		GameDelegate.addCallBack("StartFadeOut", this, "startFadeOut");
		ItemList.addEventListener("listMovedUp", this, "onListMoveUp");
		ItemList.addEventListener("listMovedDown", this, "onListMoveDown");
		ItemList.addEventListener("itemPress", this, "onItemSelect");
		FocusHandler.instance.setFocus(ItemList, 0);
		_parent.gotoAndPlay("startFadeIn");
		
		skse.ASInvoke("HUD Menu", "_root.HUDMovieBaseInstance.ShowElements", "TweenModes", true)
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB) {
				startFadeOut();
			}
		}
		return true;
	}

	function get selectedIndex(): Number
	{
		return ItemList.selectedEntry.index;
	}

	function get itemList(): MovieClip
	{
		return ItemList;
	}

	function setSelectedItem(aiIndex: Number): Void
	{
		for (var i: Number = 0; i < ItemList.entryList.length; i++) {
			if (ItemList.entryList[i].index == aiIndex) {
				ItemList.selectedIndex = i;
				ItemList.RestoreScrollPosition(i);
				ItemList.UpdateList();
				return;
			}
		}
	}

	function onListMoveUp(event: Object): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			gotoAndPlay("moveUp");
		}
	}

	function onListMoveDown(event: Object): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			gotoAndPlay("moveDown");
		}
	}

	function onItemSelect(event: Object): Void
	{
		if (event.keyboardOrMouse != 0) {
			GameDelegate.call("ItemSelect", []);
		}
	}

	function startFadeOut(): Void
	{
		_parent.gotoAndPlay("startFadeOut");
	}

	function onFadeOutCompletion(): Void
	{
		GameDelegate.call("FadeDone", [selectedIndex]);
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		ItemList.SetPlatform(aiPlatform, abPS3Switch);
		LeftPanel._x = aiPlatform == 0 ? -90 : -78.2;
		LeftPanel.gotoAndStop(aiPlatform == 0 ? "Mouse" : "Gamepad");
	}

}
