import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.controls.Button;
import Shared.GlobalFunc;

import skyui.components.SearchWidget;
import skyui.components.TabBar;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.TabularList;
import skyui.components.list.SortedListHeader;
import skyui.filter.ItemTypeFilter;
import skyui.filter.NameFilter;
import skyui.filter.SortFilter;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.util.DialogManager;
import skyui.util.Debug;

import skyui.defines.Input;


class CraftingLists extends MovieClip
{
	#include "../version.as"
	
  /* CONSTANTS */
	
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;
	
	// Menu subtypes
	static var MENU_ALCHEMY         = 0;
	static var MENU_ENCHANTING      = 1;
	static var MENU_FORGING         = 2;
	
	static var MENU_ARMOR_SMITHING  = 3; // WEAPON
	static var MENU_WEAPON_SMITHING = 4; // ARMOR
	
	static var MENU_COOKING    = 5; // FOOD
	static var MENU_SMELTING   = 6; // MISC
	static var MENU_TANNING    = 7; // MISC
	
	
  /* STAGE ELEMENTS */
  
	public var panelContainer: MovieClip;
	public var zoomButtonHolder: MovieClip;


  /* PRIVATE VARIABLES */

	private var _typeFilter: ItemTypeFilter;
	private var _nameFilter: NameFilter;
	private var _sortFilter: SortFilter;
	
	private var _platform: Number;
	
	private var _currCategoryIndex: Number;
	private var _savedSelectionIndex: Number = -1;
	
	private var _searchKey: Number = -1;
	private var _switchTabKey: Number = -1;
	private var _sortOrderKey: Number = -1;
	private var _sortOrderKeyHeld: Boolean = false;
	
	private var _bTabbed = false;
	private var _leftTabText: String;
	private var _rightTabText: String;

	private var _columnSelectDialog: MovieClip;
	private var _columnSelectInterval: Number;
	
	private var _categoryData: Array;
	

  /* PROPERTIES */

	public var itemList: TabularList;

//	public var filterList: FilterList;
	
	public var tabBar: TabBar;
	
	public var searchWidget: SearchWidget;
	
	public var categoryLabel: MovieClip;
	
	public var columnSelectButton: Button;
	
	private var _currentState: Number;
	
	public function get currentState()
	{
		return _currentState;
	}

	public function set currentState(a_newState: Number)
	{
		if (a_newState == SHOW_PANEL)
			FocusHandler.instance.setFocus(itemList,0);

		_currentState = a_newState;
	}
	
	private var _tabBarIconArt: Array;
	
	public function set tabBarIconArt(a_iconArt: Array)
	{
		_tabBarIconArt = a_iconArt;
		
		if (tabBar)
			tabBar.setIcons(_tabBarIconArt[0], _tabBarIconArt[1]);
	}
	
	public function get tabBarIconArt(): Array
	{
		return _tabBarIconArt;
	}
	
	public function setSubtype(a_name: String): Void
	{
		panelContainer.gotoAndStop(a_name);
	}


  /* INITIALIZATION */

	public function CraftingLists()
	{
		super();
		
		_categoryData = [];

		GlobalFunctions.addArrayFunctions();

		EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new NameFilter();
		_sortFilter = new SortFilter();
		
//		categoryList = panelContainer.categoryList;
		categoryLabel = panelContainer.categoryLabel;
		itemList = panelContainer.itemList;
		searchWidget = panelContainer.searchWidget;
		columnSelectButton = panelContainer.columnSelectButton;

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");
	}
	
	private function onLoad(): Void
	{
//		categoryList.listEnumeration = new BasicEnumeration(categoryList.entryList);

		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		itemList.listEnumeration = listEnumeration;
		// data processors are initialized by the top-level menu since they differ in each case
		
		itemList.listState.maxTextLength = 80;

		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");

//		categoryList.addEventListener("itemPress", this, "onCategoriesItemPress");
//		categoryList.addEventListener("itemPressAux", this, "onCategoriesItemPress");
//		categoryList.addEventListener("selectionChange", this, "onCategoriesListSelectionChange");

		itemList.disableInput = false;

		itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		itemList.addEventListener("sortChange", this, "onSortChange");

		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		
		columnSelectButton.addEventListener("press", this, "onColumnSelectButtonPress");
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	// @mixin by Shared.GlobalFunc
	public var Lock: Function;
	
	public function InitExtensions(): Void
	{
		skse.Log("Called init extensions");
		// Delay updates until config is ready
//		categoryList.suspended = true;
		itemList.suspended = true;
	}
	
	public function showPanel(a_bPlayBladeSound: Boolean): Void
	{
		// Release itemlist for updating
//		categoryList.suspended = false;
		itemList.suspended = false;
		
		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

//		dispatchEvent({type:"categoryChange", index:categoryList.selectedIndex});

		if (a_bPlayBladeSound != false)
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}

	public function hidePanel(): Void
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	
	public function enableTabBar(): Void
	{
		_bTabbed = true;
		panelContainer.gotoAndPlay("tabbed");
		itemList.listHeight = 480;
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;

//		categoryList.setPlatform(a_platform,a_bPS3Switch);
		itemList.setPlatform(a_platform,a_bPS3Switch);
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_currentState != SHOW_PANEL)
			return false;

		if (_platform != 0) {
			if (details.skseKeycode == _sortOrderKey) {
				if (details.value == "keyDown") {
					_sortOrderKeyHeld = true;

					if (_columnSelectDialog)
						DialogManager.close();
					else
						_columnSelectInterval = setInterval(this, "onColumnSelectButtonPress", 1000, {type: "timeout"});

					return true;
				} else if (details.value == "keyUp") {
					_sortOrderKeyHeld = false;

					if (_columnSelectInterval == undefined)
						// keyPress handled: Key was released after the interval expired, don't process any further
						return true;

					// keyPress not handled: Clear intervals and change value to keyDown to be processed later
					clearInterval(_columnSelectInterval);
					delete(_columnSelectInterval);
					// Continue processing the event as a normal keyDown event
					details.value = "keyDown";
				} else if (_sortOrderKeyHeld && details.value == "keyHold") {
					// Fix for opening journal menu while key is depressed
					// For some reason this is the only time we receive a keyHold event
					_sortOrderKeyHeld = false;

					if (_columnSelectDialog)
						DialogManager.close();

					return true;
				}
			}

			if (_sortOrderKeyHeld) // Disable extra input while interval is active
				return true;
		}

		if (GlobalFunc.IsKeyPressed(details)) {
			// Search hotkey (default space)
			if (details.skseKeycode == _searchKey) {
				searchWidget.startInput();
				return true;
			}
			
			// Toggle tab (default ALT)
			if (tabBar != undefined && details.skseKeycode == _switchTabKey) {
				tabBar.tabToggle();
				return true;
			}
		}
		
//		if (categoryList.handleInput(details, pathToFocus))
//			return true;
		
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	public function getContentBounds():Array
	{
		var lb = panelContainer.ListBackground;
		return [lb._x, lb._y, lb._width, lb._height];
	}
	
	public function showItemsList(): Void
	{
//		_currCategoryIndex = categoryList.selectedIndex;
		
//		categoryLabel.textField.SetText(categoryList.selectedEntry.text);

		// Start with no selection
		itemList.selectedIndex = -1;
		itemList.scrollPosition = 0;

//		if (categoryList.selectedEntry != undefined) {
			// Set filter type
//			_typeFilter.changeFilterFlag(categoryList.selectedEntry.flag);
			
			// Not set yet before the config is loaded
//			itemList.layout.changeFilterFlag(categoryList.selectedEntry.flag);
//		}
		
		itemList.requestUpdate();
		
		dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});

		itemList.disableInput = false;
	}
	
	private function detectMenuSubtype(): Void
	{
//		if (menuType = "alchemy") {
//		}
	}

	// Called to initially set the category list.
	// @API 
	public function SetCategoriesList(): Void
	{
		detectMenuSubtype();
		skse.Log("SetCategoriesList");

		skse.Log("Category count: " + arguments.length);
		
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

//		categoryList.clearList();

		for (var i=0, index = 0; i < arguments.length; i = i + len, index++) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			//categoryList.entryList.push(entry);
			skse.Log(entry.text + " " + entry.flag.toString(16));
			_categoryData.push(entry);
		}
		
/*		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

//		categoryList.clearList();

		for (var i = 0, index = 0; i < arguments.length; i = i + len, index++) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			categoryList.entryList.push(entry);

			if (entry.flag == 0)
				categoryList.dividerIndex = index;
		}

		categoryList.InvalidateData();*/
	}
	
	function EntryMatchesFilter(a_entry: Object, a_flag: Boolean): Boolean
	{
		return a_entry != undefined &&
			(a_entry.filterFlag == undefined || (a_entry.filterFlag & a_flag) != 0);
	}

	function EntryMatchesPartitionedFilter(a_entry: Object, a_flag: Boolean): Boolean
	{
		if (a_entry == undefined)
			return false;
			
		if (a_flag == 0xFFFFFFFF)
			return true;
			
		var flag: Number = a_entry.filterFlag;
		var byte0: Number = (flag & 0x000000FF);
		var byte1: Number = (flag & 0x0000FF00) >>> 8;
		var byte2: Number = (flag & 0x00FF0000) >>> 16;
		var byte3: Number = (flag & 0xFF000000) >>> 24;
		
		return byte0 == a_flag || byte1 == a_flag || byte2 == a_flag || byte3 == a_flag;
	}

	// Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	// @API
	public function InvalidateListData(): Void
	{
		skse.Log("InvalidateListData");
		
		for (var i=0; i < _categoryData.length; i++) {
			var catEntry = _categoryData[i];
			
			skse.Log(catEntry.text + ": ");
			
			for (var j=0; j < itemList.entryList.length; j++) {
				var itemEntry = itemList.entryList[j];
				if (EntryMatchesPartitionedFilter(itemEntry, catEntry.flag))
					skse.Log("      " + itemEntry.text + " ");
			}
		}
		
//		for (var i = 0; i < itemList.entryList.length; i++) {
//			skse.Log(itemList.entryList[i].text + " " + itemList.entryList[i].filterFlag.toString(16));
//		}
		
//		var flag = categoryList.selectedEntry.flag;

//		for (var i = 0; i < categoryList.entryList.length; i++)
//			categoryList.entryList[i].filterFlag = categoryList.entryList[i].bDontHide ? 1 : 0;

/*		itemList.InvalidateData();

		// Set filter flag = 1 for non-empty categories with bDontHideOffset=false
		for (var i = 0; i < itemList.entryList.length; i++) {
			for (var j = 0; j < categoryList.entryList.length; ++j) {
				if (categoryList.entryList[j].filterFlag != 0)
					continue;

				if (itemList.entryList[i].filterFlag & categoryList.entryList[j].flag)
					categoryList.entryList[j].filterFlag = 1;
			}
		}

		categoryList.UpdateList();

		if (flag != categoryList.selectedEntry.flag) {
			// Triggers an update if filter flag changed
			_typeFilter.itemFilter = categoryList.selectedEntry.flag;
			dispatchEvent({type:"categoryChange", index:categoryList.selectedIndex});
		}
		
		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		if (itemList.selectedIndex == -1)
			dispatchEvent({type:"showItemsList", index: -1});
		else
			dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});*/
	}
	
	
  /* PRIVATE FUNCTIONS */
  
  	private function onConfigLoad(event: Object): Void
	{
		var config = event.config;
		_searchKey = config["Input"].controls.pc.search;
		
		if (_platform == 0)
			_switchTabKey = config["Input"].controls.pc.switchTab;
		else {
			_switchTabKey = config["Input"].controls.gamepad.switchTab;
			_sortOrderKey = config["Input"].controls.gamepad.sortOrder;
		}
	}
  
	private function onFilterChange(): Void
	{
		itemList.requestInvalidate();
	}
	
	private function onColumnSelectButtonPress(event: Object): Void
	{
		if (event.type == "timeout") {
			clearInterval(_columnSelectInterval);
			delete(_columnSelectInterval);
		}

		if (_columnSelectDialog) {
			DialogManager.close();
			return;
		}
		
		_savedSelectionIndex = itemList.selectedIndex;
		itemList.selectedIndex = -1;
		
//		categoryList.disableSelection = categoryList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		searchWidget.isDisabled = true;
			
		_columnSelectDialog = DialogManager.open(panelContainer, "ColumnSelectDialog", {_x: 554, _y: 35, layout: itemList.layout});
		_columnSelectDialog.addEventListener("dialogClosed", this, "onColumnSelectDialogClosed");
	}
	
	private function onColumnSelectDialogClosed(event: Object): Void
	{
//		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		searchWidget.isDisabled = false;
		
		itemList.selectedIndex = _savedSelectionIndex;
	}
	
	private function onConfigUpdate(event: Object): Void
	{
		itemList.layout.refresh();
	}

	private function onCategoriesItemPress(): Void
	{
		showItemsList();
	}

	private function onCategoriesListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"categoryChange", index:event.index});
		
		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onItemsListSelectionChange(event: Object): Void
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	private function onSortChange(event: Object): Void
	{
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	private function onSearchInputStart(event: Object): Void
	{
//		categoryList.disableSelection = categoryList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
//		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}
}