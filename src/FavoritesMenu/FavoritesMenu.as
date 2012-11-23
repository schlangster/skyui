import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;

import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

import skyui.components.list.ScrollingList;
import skyui.components.list.BasicEnumeration;

class FavoritesMenu extends MovieClip
{
	public var bPCControlsReady: Boolean = true;
	
	public var itemList: ScrollingList;
	
	public var background: MovieClip;
	
	var dbgIntvl;
	
	private var _typeFilter: ItemTypeFilter;
	private var _nameFilter: ItemNameFilter;
	private var _sortFilter: ItemSorter;

	public function FavoritesMenu()
	{
		super();

		dbgIntvl = setInterval(this, "TestMenu", 1000);
		
		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSorter();
	}

	public function InitExtensions(): Void
	{
		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		itemList.listEnumeration = listEnumeration;

		GlobalFunc.SetLockFunction();
		_parent.Lock("BL");
		
		GameDelegate.addCallBack("PopulateItems", this, "populateItemList");
		GameDelegate.addCallBack("SetSelectedItem", this, "setSelectedItem");
		GameDelegate.addCallBack("StartFadeOut", this, "startFadeOut");
		
		itemList.addEventListener("itemPress", this, "onItemSelect");
		FocusHandler.instance.setFocus(itemList, 0);
		
		_parent.gotoAndPlay("startFadeIn");
	}
	
	// @API
	public function get ItemList(): MovieClip
	{
		return itemList;
	}
	
	function TestMenu(): Void
	{
		clearInterval(dbgIntvl);
		
		InitExtensions();

		itemList.clearList();
		for (var i=0; i<100; i++) {
			itemList.entryList.push({text: "test", equipState: 0});
		}
		itemList.InvalidateData();
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB) {
				startFadeOut();
			}
		}
		return true;
	}

	public function get selectedIndex(): Number
	{
		return itemList.selectedEntry.index;
	}

	public function setSelectedItem(aiIndex: Number): Void
	{
		for (var i: Number = 0; i < itemList.entryList.length; i++) {
			if (itemList.entryList[i].index == aiIndex) {
				itemList.selectedIndex = i;
//				itemList.RestoreScrollPosition(i);
				itemList.UpdateList();
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
	}
	
	function AppendHotkeyText(atfText: TextField, aiHotkey: Number, astrItemName: String): Void
	{
		if (aiHotkey >= 0 && aiHotkey <= 7) {
			atfText.SetText(aiHotkey + 1 + ". " + astrItemName);
			return;
		}
		atfText.SetText("$HK" + aiHotkey);
		atfText.SetText(atfText.text + ". " + astrItemName);
	}

}
