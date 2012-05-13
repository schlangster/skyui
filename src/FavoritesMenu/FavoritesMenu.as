import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import gfx.managers.FocusHandler;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;


class FavoritesMenu extends MovieClip
{
	var _ItemsList;
	var LeftPanel;

	// Children
	var itemsList:MovieClip;
	
	// ?
	var bPCControlsReady:Boolean = true;


	function FavoritesMenu()
	{
		super();
		_ItemsList = itemsList;
	}

	function InitExtensions()
	{
		GlobalFunc.SetLockFunction();
		_parent.Lock("BL");
		GameDelegate.addCallBack("PopulateItems",this,"populate_ItemsList");
		GameDelegate.addCallBack("SetSelectedItem",this,"setSelectedItem");
		GameDelegate.addCallBack("StartFadeOut",this,"startFadeOut");

		_ItemsList.addEventListener("listMovedUp",this,"onListMoveUp");
		_ItemsList.addEventListener("listMovedDown",this,"onListMoveDown");
		_ItemsList.addEventListener("itemPress",this,"onItemSelect");

		FocusHandler.instance.setFocus(_ItemsList,0);
		_parent.gotoAndPlay("startFadeIn");
		
		
	}
	
	var icon2:MovieClip;
	
	function onLoad()
	{
		_root.createEmptyMovieClip("icon2", this.getNextHighestDepth());
		_root.icon2.loadMovie("skyui_icons_cat_celtic.swf");
		_root.icon2._x = 50;
		_root.icon2._y = 50;
		_root.icon2._width = 5;
		_root.icon2._height = 5;
	}

	function handleInput(details:InputDetails, pathToFocus:Array):Boolean
	{
		if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
			if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB) {
				startFadeOut();
			}
		}
		return true;
	}

	function get selectedIndex()
	{
		return _ItemsList.selectedEntry.index;
	}

	function get ItemsList()
	{
		return _ItemsList;
	}

	function setSelectedItem(a_index)
	{
		for (var i=0; i<_ItemsList.entryList.length; i++) {
			if (_ItemsList.entryList[i].index == a_index) {
				_ItemsList.selectedIndex = i;
				_ItemsList.RestoreScrollPosition(i);
				_ItemsList.UpdateList();
				return;
			}
		}
	}

	function onListMoveUp(event)
	{
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		
		if (event.scrollChanged == true) {
			gotoAndPlay("moveUp");
		}
	}

	function onListMoveDown(event)
	{
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		
		if (event.scrollChanged == true) {
			gotoAndPlay("moveDown");
		}
	}

	function onItemSelect(event)
	{
		if (event.keyboardOrMouse != 0) {
			GameDelegate.call("ItemSelect",[]);
		}
	}

	function startFadeOut()
	{
		_parent.gotoAndPlay("startFadeOut");
	}

	function onFadeOutCompletion()
	{
		GameDelegate.call("FadeDone",[selectedIndex]);
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		_ItemsList.SetPlatform(a_platform, a_bPS3Switch);
		LeftPanel._x = a_platform == 0 ? -90 : -78.2;
		LeftPanel.gotoAndStop(a_platform == 0 ? "Mouse" : "Gamepad");
	}
}