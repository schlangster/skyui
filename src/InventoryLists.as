import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import Shared.GlobalFunc;

import skyui.CategoryList;
import skyui.TabularList;
import skyui.ItemTypeFilter;
import skyui.ItemNameFilter;
import skyui.ItemSorter;
import skyui.SortedListHeader;
import skyui.SearchWidget;
import skyui.TabBar;
import skyui.ConfigLoader;
import skyui.Util;
import skyui.Translator;


class InventoryLists extends MovieClip
{
  /* CONSTANTS */
	
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;
	
	
  /* STAGE ELEMENTS */
  
	var panelContainer: MovieClip;
	var zoomButtonHolder: MovieClip;


  /* PRIVATE VARIABLES */

	private var _config: Object;

	private var _searchWidget: SearchWidget;
	
	private var _categoryLabel: MovieClip;

	private var _typeFilter: ItemTypeFilter;
	
	private var _nameFilter: ItemNameFilter;
	
	private var _sortFilter: ItemSorter;
	
	private var _platform: Number;
	
	private var _currCategoryIndex: Number;

	private var _searchKey: Number;
	private var _tabToggleKey: Number;
	private var _allString: String;


  /* PROPERTIES */

	private var _itemList: TabularList;
	
	function get itemList(): TabularList
	{
		return _itemList;
	}
	
	private var _categoryList: CategoryList;
	
	function get categoryList(): CategoryList
	{
		return _categoryList;
	}
	
	private var _tabBar: TabBar;
	
	function get tabBar(): TabBar
	{
		return _tabBar;
	}
	
	private var _currentState: Number;
	
	public function get currentState()
	{
		return _currentState;
	}

	public function set currentState(a_newState)
	{
		if (a_newState == SHOW_PANEL) {
			FocusHandler.instance.setFocus(_itemList,0);
		}

		_currentState = a_newState;
	}


  /* CONSTRUCTORS */

	function InventoryLists()
	{
		super();

		Util.addArrayFunctions();

		_categoryList = panelContainer.categoryList;
		_categoryLabel = panelContainer.categoryLabel;
		_itemList = panelContainer.itemList;
		_searchWidget = panelContainer.searchWidget;
		_tabBar = panelContainer.tabBar;

		EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSorter();

		_searchKey = undefined;
		_tabToggleKey = undefined;

		ConfigLoader.registerCallback(this, "onConfigLoad");
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
	// @mixin by gfx.events.EventDispatcher
	public var addEventListener: Function;
	
	// @mixin by gfx.events.EventDispatcher
	public var Lock: Function;

	public function onLoad()
	{		
		_itemList.addFilter(_typeFilter);
		_itemList.addFilter(_nameFilter);
		_itemList.addFilter(_sortFilter);

		_typeFilter.addEventListener("filterChange",_itemList,"onFilterChange");
		_nameFilter.addEventListener("filterChange",_itemList,"onFilterChange");
		_sortFilter.addEventListener("filterChange",_itemList,"onFilterChange");

		_categoryList.addEventListener("itemPress",this,"onCategoriesItemPress");
		_categoryList.addEventListener("listPress",this,"onCategoriesListPress");
		_categoryList.addEventListener("listMovedUp",this,"onCategoriesListMoveUp");
		_categoryList.addEventListener("listMovedDown",this,"onCategoriesListMoveDown");
		_categoryList.addEventListener("selectionChange",this,"onCategoriesListMouseSelectionChange");

		_itemList.disableInput = false;

		_itemList.addEventListener("listMovedUp",this,"onItemsListMoveUp");
		_itemList.addEventListener("listMovedDown",this,"onItemsListMoveDown");
		_itemList.addEventListener("selectionChange",this,"onItemsListMouseSelectionChange");
		_itemList.addEventListener("sortChange",this,"onSortChange");

		_searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
		_searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
		_searchWidget.addEventListener("inputChange",this,"onSearchInputChange");
		
		if (_tabBar != undefined)
			_tabBar.addEventListener("tabPress",this,"onTabPress");
	}

	public function onConfigLoad(event)
	{
		_config = event.config;
		_searchKey = _config.Input.hotkey.search;
		_tabToggleKey = _config.Input.hotkey.tabToggle;
	}

	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean)
	{
		_platform = a_platform;

		_categoryList.platform = a_platform;
		_itemList.platform = a_platform;
	}

	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;

		if (_currentState == SHOW_PANEL) {
			if (GlobalFunc.IsKeyPressed(details)) {
				
				if (details.navEquivalent == NavigationCode.LEFT) {
					_categoryList.moveSelectionLeft();
					bCaught = true;

				} else if (details.navEquivalent == NavigationCode.RIGHT) {
					_categoryList.moveSelectionRight();
					bCaught = true;

				// Search hotkey (default space)
				} else if (details.code == _searchKey) {
					bCaught = true;
					_searchWidget.startInput();
					
				// Toggle tab (default ALT)
				} else if (_tabBar != undefined && (details.code == _tabToggleKey || (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8))) {
					
					bCaught = true;
					_tabBar.tabToggle();
				}
			}
			if (!bCaught)
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return bCaught;
	}

	public function getContentBounds():Array
	{
		var lb = panelContainer.ListBackground;
		return [lb._x, lb._y, lb._width, lb._height];
	}

	function RestoreCategoryIndex()
	{
		_categoryList.selectedIndex = _currCategoryIndex;
	}

	function ShowCategoriesList(a_bPlayBladeSound: Boolean)
	{
		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

		dispatchEvent({type:"categoryChange", index:_categoryList.selectedIndex});

		if (a_bPlayBladeSound != false)
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}

	function HideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	
	function showItemsList()
	{
		_currCategoryIndex = _categoryList.selectedIndex;
		
		_categoryLabel.textField.SetText(_categoryList.selectedEntry.text);

		// Start with no selection
		_itemList.selectedIndex = -1;
		_itemList.scrollPosition = 0;

		if (_categoryList.selectedEntry != undefined) {
			// Set filter type
			_typeFilter.changeFilterFlag(_categoryList.selectedEntry.flag);
			_itemList.layout.changeFilterFlag(_categoryList.selectedEntry.flag);
		} else {
			_itemList.UpdateList();
		}
		
		dispatchEvent({type:"itemHighlightChange", index:_itemList.selectedIndex});

		_itemList.disableInput = false;
	}

	// Not needed anymore, items list always visible
	function hideItemsList()
	{
		/*
		_currentState = TRANSITIONING_TO_ONE_PANEL;
		dispatchEvent({type:"hideItemsList", index:_itemList.selectedIndex});
		_itemList.selectedIndex = -1;
		gotoAndPlay("Panel2Hide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		_itemList.disableInput = true;
		*/
	}

	function onCategoriesItemPress()
	{
		showItemsList();
	}

	function onCategoriesListPress()
	{
	}
	
	function onTabPress(event)
	{
		if (_categoryList.disableSelection || _categoryList.disableInput || _itemList.disableSelection || _itemList.disableInput)
			return;
		
		if (event.index == TabBar.LEFT_TAB) {
			_tabBar.activeTab = TabBar.LEFT_TAB;
			_categoryList.activeSegment = CategoryList.LEFT_SEGMENT;
		} else if (event.index == TabBar.RIGHT_TAB) {
			_tabBar.activeTab = TabBar.RIGHT_TAB;
			_categoryList.activeSegment = CategoryList.RIGHT_SEGMENT;
		}
		
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		showItemsList();
	}

	function onCategoriesListMoveUp(event)
	{
		doCategorySelectionChange(event);
	}

	function onCategoriesListMoveDown(event)
	{
		doCategorySelectionChange(event);
	}

	function onCategoriesListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0)
			doCategorySelectionChange(event);
	}

	function onItemsListMoveUp(event)
	{
		this.doItemsSelectionChange(event);
	}

	function onItemsListMoveDown(event)
	{
		this.doItemsSelectionChange(event);
	}

	function onItemsListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0)
			doItemsSelectionChange(event);
	}

	function doCategorySelectionChange(event)
	{
		dispatchEvent({type:"categoryChange", index:event.index});
		
		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	function doItemsSelectionChange(event)
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	function onSortChange(event)
	{
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	function onSearchInputStart(event)
	{
		_categoryList.disableSelection = true;
		_itemList.disableInput = true;
		_nameFilter.filterText = "";
	}

	function onSearchInputChange(event)
	{
		_nameFilter.filterText = event.data;
	}

	function onSearchInputEnd(event)
	{
		_categoryList.disableSelection = false;
		_itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}

	// API - Called to initially set the category list
	function SetCategoriesList()
	{
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

		_categoryList.clearList();

		for (var i = 0, index = 0; i < arguments.length; i = i + len, index++) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			_categoryList.entryList.push(entry);

			if (entry.flag == 0) {
				_categoryList.dividerIndex = index;
			}
		}
		
		// Initialize tabbar labels and replace text of segment heads (name -> ALL)
		if (_tabBar != undefined) {
			if (_categoryList.dividerIndex != -1) {
				_tabBar.setLabelText(_categoryList.entryList[0].text, _categoryList.entryList[_categoryList.dividerIndex + 1].text);
				_categoryList.entryList[0].text = _categoryList.entryList[_categoryList.dividerIndex + 1].text = Translator.translate("$ALL");
			}
			
			// Restore 0 as default index for tabbed lists
			_categoryList.selectedIndex = 0;
		}

		_categoryList.InvalidateData();
	}

	// API - Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	function InvalidateListData()
	{
		var flag = _categoryList.selectedEntry.flag;

		for (var i = 0; i < _categoryList.entryList.length; i++) {
			_categoryList.entryList[i].filterFlag = _categoryList.entryList[i].bDontHide ? 1 : 0;
		}

		// Set filter flag = 1 for non-empty categories with bDontHideOffset=false
		_itemList.InvalidateData();
		for (var i = 0; i < _itemList.entryList.length; i++) {
			for (var j = 0; j < _categoryList.entryList.length; ++j) {
				if (_categoryList.entryList[j].filterFlag != 0) {
					continue;
				}

				if (_itemList.entryList[i].filterFlag & _categoryList.entryList[j].flag) {
					_categoryList.entryList[j].filterFlag = 1;
				}
			}
		}

		_categoryList.UpdateList();

		if (flag != _categoryList.selectedEntry.flag) {
			// Triggers an update if filter flag changed
			_typeFilter.itemFilter = _categoryList.selectedEntry.flag;
			dispatchEvent({type:"categoryChange", index:_categoryList.selectedIndex});
		}
		
		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		if (_itemList.selectedIndex == -1) {
			dispatchEvent({type:"showItemsList", index: -1});
		} else {
			dispatchEvent({type:"itemHighlightChange", index:_itemList.selectedIndex});
		}
	}
}