import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.controls.ButtonGroup;
import gfx.controls.Button;

import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import skyui.components.list.ScrollingList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.FilteredEnumeration;

import skyui.filter.ItemTypeFilter;
import skyui.filter.SortFilter;


class FavoritesMenu extends MovieClip
{
	var dbgIntvl;
	
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	
	private var _typeFilter: ItemTypeFilter;
	private var _sortFilter: SortFilter;
	
	private var _categoryButtons: Array;
	private var _categoryButtonGroup: ButtonGroup;
	private var _categoryIndex: Number = 0;
	
	private var _leftKeycode: Number;
	private var _rightKeycode: Number;
	
	// A workaround to prevent bla blablabla
	private var _useMouseNavigation: Boolean = false;
	
	
  /* STAGE ELEMENTS */
	
	public var itemList: ScrollingList;
	public var background: MovieClip;
	
	public var btnAll: Button;
	public var btnGear: Button;
	public var btnAid: Button;
	public var btnMagic: Button;
	
	public var categoryText: TextField;
	
	
  /* PROPERTIES */
	
	// @API
	public var bPCControlsReady: Boolean = true;


  /* INITIALIZATION */

	public function FavoritesMenu()
	{
		super();

		//dbgIntvl = setInterval(this, "TestMenu", 1000);
		
		_typeFilter = new ItemTypeFilter();
		_sortFilter = new SortFilter();
		
		_categoryButtonGroup = new ButtonGroup("CategoryButtonGroup");
		
		Mouse.addListener(this);
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function InitExtensions(): Void
	{
		skse.ExtendData(true);
		
		_leftKeycode = GlobalFunctions.getMappedKey("Left", Input.CONTEXT_MENUMODE, false);
		_rightKeycode = GlobalFunctions.getMappedKey("Right", Input.CONTEXT_MENUMODE, false);
		
		btnAll.group = _categoryButtonGroup;
		btnGear.group = _categoryButtonGroup;
		btnAid.group = _categoryButtonGroup;
		btnMagic.group = _categoryButtonGroup;
		
		_categoryButtonGroup.addEventListener("change", this, "onCategorySelect");
		
		itemList.addDataProcessor(new FilterDataExtender());
		itemList.addDataProcessor(new FavoritesIconSetter());

		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_sortFilter);
		
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");
		
		itemList.listEnumeration = listEnumeration;

		GlobalFunc.SetLockFunction();
		_parent.Lock("BL");
		
		GameDelegate.addCallBack("PopulateItems", this, "populateItemList");
		GameDelegate.addCallBack("SetSelectedItem", this, "setSelectedItem");
		GameDelegate.addCallBack("StartFadeOut", this, "startFadeOut");
		
		itemList.addEventListener("itemPress", this, "onItemPress");
		itemList.addEventListener("selectionChange", this, "onItemSelectionChange");
		FocusHandler.instance.setFocus(itemList, 0);
		
		_parent.gotoAndPlay("startFadeIn");
		
		_sortFilter.setSortBy(["text"], [], false);
		
		_categoryButtonGroup.setSelectedButton(btnAll);
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
			itemList.entryList.push({text: "test", equipState: 0, filterFlag: 1});
		}
		itemList.InvalidateData();
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				startFadeOut();
				return true;
				
			} else if(details.navEquivalent == NavigationCode.LEFT || details.skseKeycode == _leftKeycode) {
				if (_categoryIndex > 0) {
					_categoryIndex--;
					_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
				}
				return true;
				
			} else if (details.navEquivalent == NavigationCode.RIGHT || details.skseKeycode == _rightKeycode) {
				if (_categoryIndex < _categoryButtonGroup.length-1) {
					_categoryIndex++;
					_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
				}
				return true;
			}
		}
		
		return true;
	}

	// @API
	public function get selectedIndex(): Number
	{
		return confirmSelectedEntry() ? itemList.selectedEntry.index : -1;
	}

	// @API
	public function setSelectedItem(a_index: Number): Void
	{
		for (var i = 0; i < itemList.entryList.length; i++) {
			if (itemList.entryList[i].index == a_index) {
				itemList.selectedIndex = i;
//				itemList.RestoreScrollPosition(i);
				itemList.UpdateList();
				return;
			}
		}
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
	}
	

  /* PRIVATE FUNCTIONS */
  
	private function onFilterChange(a_event: Object): Void
	{
		itemList.requestInvalidate();
	}

	private function onItemPress(a_event: Object): Void
	{
		// Only handles keyboard input, mouse is done internally
		if (a_event.keyboardOrMouse != 0) {
			_useMouseNavigation = false;
			GameDelegate.call("ItemSelect", []);
		} else {
			_useMouseNavigation = true;
		}
	}
	
	private function onItemSelectionChange(a_event: Object): Void
	{
		_useMouseNavigation = a_event.keyboardOrMouse == 0;
	}
	
	private function onCategorySelect(a_event: Object): Void
	{
		var item = a_event.item;
		if (a_event.item == null)
			return;
		
		categoryText.SetText(item.category);
		_typeFilter.changeFilterFlag(item.filterFlag);
	}

	private function startFadeOut(): Void
	{
		_parent.gotoAndPlay("startFadeOut");
	}
	
	private function onFadeOutCompletion(): Void
	{
		GameDelegate.call("FadeDone", [itemList.selectedIndex]);
	}
	
	private function onMouseDown(): Void
	{
		_useMouseNavigation = true;
	}
	
	private function onMouseMove(): Void
	{
		_useMouseNavigation = true;
	}
	
	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry(): Boolean
	{
		// only confirm when using mouse
		if (_platform != 0 || !_useMouseNavigation)
			return true;
		
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e.itemIndex == itemList.selectedIndex)
				return true;
				
		return false;
	}
}
