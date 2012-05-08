import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.controls.Button;
import Shared.GlobalFunc;

import skyui.components.SearchWidget;
import skyui.components.TabBar;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.TabularList;
import skyui.components.list.SortedListHeader;
import skyui.filter.ItemTypeFilter;
import skyui.filter.ItemNameFilter;
import skyui.filter.ItemSorter;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.CategoryList;
import skyui.CategoryEntryBuilder;
import skyui.InventoryEntryBuilder;


class InventoryLists extends MovieClip
{
  /* CONSTANTS */
	
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;
	
	
  /* STAGE ELEMENTS */
  
	public var panelContainer: MovieClip;
	public var zoomButtonHolder: MovieClip;


  /* PRIVATE VARIABLES */

	private var _config: Object;

	private var _searchWidget: SearchWidget;
	
	private var _categoryLabel: MovieClip;

	private var _typeFilter: ItemTypeFilter;
	
	private var _nameFilter: ItemNameFilter;
	
	private var _sortFilter: ItemSorter;
	
	private var _platform: Number;
	
	private var _currCategoryIndex: Number;
	
	private var _customizeButton: Button;
	
	private var _customizePanel: MovieClip;

	private var _searchKey: Number;
	private var _tabToggleKey: Number;
	private var _allString: String;
	
	private var _savedSelectionIndex: Number = -1;


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

		GlobalFunctions.addArrayFunctions();

		EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList", this, "setCategoriesList");
		GameDelegate.addCallBack("InvalidateListData", this, "invalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSorter();

		_searchKey = undefined;
		_tabToggleKey = undefined;
		
		_categoryList = panelContainer.categoryList;
		_categoryLabel = panelContainer.categoryLabel;
		_itemList = panelContainer.itemList;
		_searchWidget = panelContainer.searchWidget;
		_tabBar = panelContainer.tabBar;
		_customizeButton = panelContainer.customizeButton;
		_customizePanel = panelContainer.customizePanel;

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
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

	// Apparently it's not safe to use stage elements in the constructor (as it doesn't work).
	// That's why they are initialized in onLoad.
	public function onLoad()
	{
		_categoryList.entryClipBuilder = new CategoryEntryBuilder(_categoryList);
		_categoryList.listEnumeration = new BasicEnumeration(_categoryList.entryList);
		_categoryList.entryFormatter = new AlphaEntryFormatter(_categoryList);

		_itemList.entryClipBuilder = new InventoryEntryBuilder(_itemList);
		var listEnumeration = new FilteredEnumeration(_itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		_itemList.listEnumeration = listEnumeration;
		// entry formatter and data fetcher are initialized by the top-level menu since they differ in each case

		_typeFilter.addEventListener("filterChange", _itemList, "onFilterChange");
		_nameFilter.addEventListener("filterChange", _itemList, "onFilterChange");
		_sortFilter.addEventListener("filterChange", _itemList, "onFilterChange");

		_categoryList.addEventListener("itemPress", this, "onCategoriesItemPress");
		_categoryList.addEventListener("listPress", this, "onCategoriesListPress");
		_categoryList.addEventListener("listMovedUp", this, "onCategoriesListMoveUp");
		_categoryList.addEventListener("listMovedDown", this, "onCategoriesListMoveDown");
		_categoryList.addEventListener("selectionChange", this, "onCategoriesListMouseSelectionChange");

		_itemList.disableInput = false;

		_itemList.addEventListener("listMovedUp", this, "onItemsListMoveUp");
		_itemList.addEventListener("listMovedDown", this, "onItemsListMoveDown");
		_itemList.addEventListener("selectionChange", this, "onItemsListMouseSelectionChange");
		_itemList.addEventListener("sortChange", this, "onSortChange");

		_searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		_searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		_searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		
		_customizeButton.addEventListener("press", this, "onCustomizeButtonPress");
		
		if (_tabBar != undefined)
			_tabBar.addEventListener("tabPress", this, "onTabPress");
	}
	
	var _visvis = false;
	
	public function onCustomizeButtonPress(event): Void
	{
		_visvis = !_visvis;
		_customizePanel._visible = _visvis;
		if (_visvis) {
			_savedSelectionIndex = _itemList.selectedIndex;
			_itemList.selectedIndex = -1;
		} else {
			_itemList.selectedIndex = _savedSelectionIndex;
		}
			
		_categoryList.disableSelection = _visvis;
		_categoryList.disableInput = _visvis;
		_itemList.disableSelection = _visvis;
		_itemList.disableInput = _visvis;
		_searchWidget.disabled = _visvis;

	}

	public function onConfigLoad(event)
	{
		_config = event.config;
		_searchKey = _config.Input.hotkey.search;
		_tabToggleKey = _config.Input.hotkey.tabToggle;
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean)
	{
		_platform = a_platform;

		_categoryList.platform = a_platform;
		_itemList.platform = a_platform;
	}

	// GFx
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

	public function restoreCategoryIndex()
	{
		_categoryList.selectedIndex = _currCategoryIndex;
	}

	public function showCategoriesList(a_bPlayBladeSound: Boolean)
	{
		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

		dispatchEvent({type:"categoryChange", index:_categoryList.selectedIndex});

		if (a_bPlayBladeSound != false)
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}

	public function hideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	
	public function showItemsList()
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
	function hideItemsList(): Void
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

	public function onCategoriesItemPress(): Void
	{
		showItemsList();
	}

	public function onCategoriesListPress(): Void
	{
	}
	
	public function onTabPress(event): Void
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

	public function onCategoriesListMoveUp(event)
	{
		doCategorySelectionChange(event);
	}

	public function onCategoriesListMoveDown(event)
	{
		doCategorySelectionChange(event);
	}

	public function onCategoriesListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0)
			doCategorySelectionChange(event);
	}

	public function onItemsListMoveUp(event)
	{
		this.doItemsSelectionChange(event);
	}

	public function onItemsListMoveDown(event)
	{
		this.doItemsSelectionChange(event);
	}

	public function onItemsListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0)
			doItemsSelectionChange(event);
	}

	public function doCategorySelectionChange(event)
	{
		dispatchEvent({type:"categoryChange", index:event.index});
		
		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	public function doItemsSelectionChange(event)
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	public function onSortChange(event)
	{
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	public function onSearchInputStart(event)
	{
		_categoryList.disableSelection = _categoryList.disableInput = true;
		_itemList.disableSelection = _itemList.disableInput = true
		_nameFilter.filterText = "";
	}

	public function onSearchInputChange(event)
	{
		_nameFilter.filterText = event.data;
	}

	public function onSearchInputEnd(event)
	{
		_categoryList.disableSelection = _categoryList.disableInput = false;
		_itemList.disableSelection = _itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}

	// API - Called to initially set the category list
	function setCategoriesList()
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
	function invalidateListData()
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