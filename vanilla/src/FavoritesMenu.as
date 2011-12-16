import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class FavoritesMenu extends MovieClip
{
	var bPCControlsReady:Boolean = true;
	var List_mc:MovieClip;
	var ItemList:MovieClip;
	var LeftPanel:MovieClip;
	
	function FavoritesMenu()
	{
		super();
		ItemList = List_mc;
	} 
	function InitExtensions()
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
	} 
	function handleInput(details, pathToFocus)
	{
		if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
		{
			if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB)
			{
				this.startFadeOut();
			}
		} 
		return (true);
	} 
	function get selectedIndex()
	{
		return ItemList.selectedEntry.index;
	} 
	function get itemList()
	{
		return ItemList;
	}
	function setSelectedItem(aiIndex)
	{
		for (var i = 0; i < ItemList.entryList.length; ++i)
		{
			if (ItemList.entryList[i].index == aiIndex)
			{
				ItemList.selectedIndex(i);
				ItemList.RestoreScrollPosition(i);
				ItemList.UpdateList();
				break;
			} 
		} 
	} 
	function onListMoveUp(event)
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true)
		{
			this.gotoAndPlay("moveUp");
		}
	} 
	function onListMoveDown(event)
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true)
		{
			this.gotoAndPlay("moveDown");
		} 
	}
	function onItemSelect(event)
	{
		if (event.keyboardOrMouse != 0)
		{
			GameDelegate.call("ItemSelect", []);
		} 
	} 
	function startFadeOut()
	{
		_parent.gotoAndPlay("startFadeOut");
	}
	function onFadeOutCompletion()
	{
		GameDelegate.call("FadeDone", [this.selectedIndex()]);
	} 
	function SetPlatform(aiPlatform, abPS3Switch)
	{
		ItemList.SetPlatform(aiPlatform, abPS3Switch);
		LeftPanel._x = aiPlatform == 0 ? (-90) : (-78.2);
		LeftPanel.gotoAndStop(aiPlatform == 0 ? ("Mouse") : ("Gamepad"));
	} 
} 
