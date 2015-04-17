import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.controls.Button;
import Shared.GlobalFunc;
import mx.utils.Delegate;

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
import skyui.defines.Inventory;


class CraftingLists extends MovieClip
{
	#include "../version.as"
	
  /* CONSTANTS */
	
	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;
	
	static var SHORT_LIST_OFFSET = 210;

	
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
	private var _sortOrderKey: Number = -1;
	private var _sortOrderKeyHeld: Boolean = false;

	private var _columnSelectDialog: MovieClip;
	private var _columnSelectInterval: Number;
	
	private var _subtypeName: String;
	
	private var _bFocusItemList: Boolean = true;
	

  /* PROPERTIES */

	public var itemList: TabularList;

	// @API
	public var CategoriesList: IconTabList;
	
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


  /* INITIALIZATION */

	public function CraftingLists()
	{
		super();
		
		GlobalFunctions.addArrayFunctions();

		EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new NameFilter();
		_sortFilter = new SortFilter();
		
		categoryLabel = panelContainer.categoryLabel;
		CategoriesList = panelContainer.categoriesList; // Note: Re-assigned later if alchemy
		itemList = panelContainer.itemList;
		searchWidget = panelContainer.searchWidget;
		columnSelectButton = panelContainer.columnSelectButton;

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");

		// Hide by default, maybe show later
		panelContainer.effectsList._visible = false;
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
	
	public function InitExtensions(a_subtypeName: String): Void
	{
		_subtypeName = a_subtypeName;
		
		// Alchemy uses a different layout
		if (_subtypeName == "Alchemy") {
			panelContainer.gotoAndStop("no_categories");
			
			// Hide top icon category bar, use effects list instead
			CategoriesList._visible = false;
			CategoriesList = panelContainer.effectsList;
			CategoriesList._visible = true;
			

			itemList.gotoAndStop("short");
			itemList.leftBorder = SHORT_LIST_OFFSET;
			itemList.listHeight = 560;

		// Support for custom categorization
		} else if (_subtypeName == "ConstructibleObject") {			
			itemList.addDataProcessor(new CustomConstructDataSetter());
			
		// Smithing doesn't need top icon categories
		} else if (_subtypeName == "Smithing") {			
			panelContainer.gotoAndStop("no_categories");
			CategoriesList._visible = false;
			itemList.listHeight = 560;
		}
		
		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		itemList.listEnumeration = listEnumeration;
		
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");		
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");
		
		CategoriesList.listEnumeration = new BasicEnumeration(CategoriesList.entryList);
		
		itemList.listState.maxTextLength = 80;

		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");

		CategoriesList.addEventListener("itemPress", this, "onCategoriesItemPress");
		CategoriesList.addEventListener("itemPressAux", this, "onCategoriesItemPress");
		CategoriesList.addEventListener("selectionChange", this, "onCategoriesListSelectionChange");

		itemList.disableInput = false;

		itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		itemList.addEventListener("sortChange", this, "onSortChange");
		itemList.addEventListener("itemPress", this, "onItemPress");

		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		
		columnSelectButton.addEventListener("press", this, "onColumnSelectButtonPress");
		
		itemList.onInvalidate = Delegate.create(this, onItemListInvalidate);		

		CategoriesList.onUnsuspend = function()
		{
			// this == CategoriesList
			this.onItemPress(0, 0); // Select first category
			delete this.onUnsuspend;
		};
		
		// Delay updates until config is ready
		CategoriesList.suspended = true;
		itemList.suspended = true;
	}
	
	public function showPanel(a_bPlayBladeSound: Boolean): Void
	{
		// Release itemlist for updating
		CategoriesList.suspended = false;
		itemList.suspended = false;
		
		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

		dispatchEvent({type:"categoryChange", index: CategoriesList.selectedIndex});

		if (a_bPlayBladeSound != false)
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}

	public function hidePanel(): Void
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");
		
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;

		CategoriesList.setPlatform(a_platform,a_bPS3Switch);
		itemList.setPlatform(a_platform,a_bPS3Switch);
	}
	
	public function setPartitionedFilterMode(a_bPartitioned: Boolean): Void
	{
		_typeFilter.setPartitionedFilterMode(a_bPartitioned);
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
		}
		
		if (_subtypeName == "Alchemy") {
			if (handleAlchemyNavigation(details, pathToFocus))
				return true;
		} else {
			if (CategoriesList.handleInput(details, pathToFocus))
				return true;
		}
		
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	private function handleAlchemyNavigation(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.LEFT) {
				if (!_bFocusItemList)
					return true;

				_savedSelectionIndex = itemList.selectedIndex;
				itemList.selectedIndex = -1;

				// Moving from Item list to Category List
				_bFocusItemList = false;
				return true;
				
			} else if (details.navEquivalent == NavigationCode.RIGHT) {
				if (_bFocusItemList)
					return true;

				if (_savedSelectionIndex == -1) {
					itemList.selectDefaultIndex(true)
				} else {
					itemList.selectedIndex = _savedSelectionIndex;
				}

				// Moving from Category list to Item List
				_bFocusItemList = true;
				return true;
			}
			
			// Ok thats a bit weird but whatever...:
			// Itemlist always has focus, but if this flag is false, categories list gets to run first.
			// Since both use the same nav scheme, category list wins.
			if (!_bFocusItemList) {
				if (CategoriesList.handleInput(details, pathToFocus)) {
					// Clear saved index
					_savedSelectionIndex = -1;
					
					return true;
				}
			}
		}
		
		return false;
	}

	public function getContentBounds():Array
	{
		var lb = panelContainer.ListBackground;
		return [lb._x, lb._y, lb._width, lb._height];
	}
	
	public function showItemsList(): Void
	{
		_currCategoryIndex = CategoriesList.selectedIndex;
		
		categoryLabel.textField.SetText(CategoriesList.selectedEntry.text.toUpperCase());

		// Start with no selection
		itemList.selectedIndex = -1;
		itemList.scrollPosition = 0;

		if (CategoriesList.selectedEntry != undefined) {
			var catFlag = CategoriesList.selectedEntry.flag;
			
			// Set filter type
			_typeFilter.changeFilterFlag(catFlag);
			
			// Not set yet before the config is loaded
			itemList.layout.changeFilterFlag(catFlag);
		}
		
		itemList.requestUpdate();
		
		dispatchEvent({type: "showItemsList", index: itemList.selectedIndex});
		
//		dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});

		itemList.disableInput = false;
	}

	// Called to initially set the category list.
	// @API 
	public function SetCategoriesList(): Void
	{		
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

		CategoriesList.clearList();

		for (var i=0, index = 0; i < arguments.length; i = i + len, index++) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			
			if (entry.flag == 0) {
				entry.divider = true;
			}
			
			entry.enabled = false;
			
//			Debug.dump("category" + i, entry);
			
			CategoriesList.entryList.push(entry);
		}
		
		// We have enough information to init the art now.
		// But the list has not been invalidated, so no clips have been loaded yet.
		preprocessCategoriesList();

		CategoriesList.selectedIndex = 0;
		CategoriesList.InvalidateData();
	}

	// Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	// @API
	public function InvalidateListData(): Void
	{
		itemList.InvalidateData();
	}
	
	
  /* PRIVATE FUNCTIONS */
  
  	private function onHideCategoriesList(event: Object): Void
	{
		itemList.listHeight = 579;
	}
  
  	private function onConfigLoad(event: Object): Void
	{
		var config = event.config;
		_searchKey = config["Input"].controls.pc.search;
		
		if (_platform != 0) {
			_sortOrderKey = config["Input"].controls.gamepad.sortOrder;
		}
	}
	
 	private function onItemListInvalidate(): Void
	{
		// Set enabled == false for empty categories
		if (_subtypeName != "Alchemy") {
			for (var i=0; i<CategoriesList.entryList.length; i++) {
				for (var j=0; j<itemList.entryList.length; j++) {
					if (_typeFilter.isMatch(itemList.entryList[j], CategoriesList.entryList[i].flag)) {
						CategoriesList.entryList[i].enabled = true;
						break;
					}
				}
			}
		}

		// Grey out any categories that are not enabled
		CategoriesList.UpdateList();
		
		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data    
		if (itemList.selectedIndex == -1)
			dispatchEvent({type:"showItemsList", index: -1});
		else
			dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});
	}
	
	private function preprocessCategoriesList(): Void
	{		
		// EnchantConstruct - Set icon art, but leave default categories as they are.
		if (_subtypeName == "EnchantConstruct") {
			CategoriesList.iconArt = [ "ench_disentchant", "separator", "ench_item", "ench_effect", "ench_soul" ];

		// Smithing - Set icon art, but leave default categories as they are.
		} else if (_subtypeName == "Smithing") {
			CategoriesList.iconArt = [ "smithing" ];
			
		// ConstructibleObject - Use a custom categorization scheme.
		} else if (_subtypeName == "ConstructibleObject") {
			CategoriesList.iconArt = [ "construct_all", "weapon", "ammo", "armor", "jewelry", "food", "misc" ];
			
			replaceConstructObjectCategories();

		// Alchemy - Use a custom categorization scheme.
		} else if (_subtypeName == "Alchemy") {			
			fixupAlchemyCategories();
		}
	}	
	
	private function replaceConstructObjectCategories(): Void
	{
		CategoriesList.clearList();
		
		CategoriesList.entryList.push(
			{text: "$ALL", flag: Inventory.FILTERFLAG_CUST_CRAFT_ALL, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: "$WEAPONS", flag: Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: "$AMMO", flag: Inventory.FILTERFLAG_CUST_CRAFT_AMMO, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: Translator.translate("$Armor"), flag: Inventory.FILTERFLAG_CUST_CRAFT_ARMOR, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: Translator.translate("$Jewelry"), flag: Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: Translator.translate("$Food"), flag: Inventory.FILTERFLAG_CUST_CRAFT_FOOD, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
		CategoriesList.entryList.push(
			{text: Translator.translate("$Misc"), flag: Inventory.FILTERFLAG_CUST_CRAFT_MISC, bDontHide: 1, savedItemIndex: 0, filterFlag: 1, enabled: false});
	}
	
	private function fixupAlchemyCategories(): Void
	{
		// Ingredients category is always enabled
		CategoriesList.entryList[0].enabled = true;
		CategoriesList.entryList[0].iconLabel = "ingredients";
		
		// Old flag is type. New flag is index (was flag before skse ext.)
		for (var i=1; i<CategoriesList.entryList.length; i++) {
			var cat = CategoriesList.entryList[i];
			
			if (cat.flag & Inventory.FILTERFLAG_CUST_ALCH_GOOD)
				cat.iconLabel = "beneficial";
			else if (cat.flag & Inventory.FILTERFLAG_CUST_ALCH_BAD)
				cat.iconLabel = "harmful";
			else if (cat.flag & Inventory.FILTERFLAG_CUST_ALCH_OTHER)
				cat.iconLabel = "other";

			// Thats the index that was previously used as flag and sent by the game (without SKSE).
			cat.flag = i;
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
		
		CategoriesList.disableSelection = CategoriesList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		searchWidget.isDisabled = true;
			
		_columnSelectDialog = DialogManager.open(panelContainer, "ColumnSelectDialog", {_x: 554, _y: 35, layout: itemList.layout});
		_columnSelectDialog.addEventListener("dialogClosed", this, "onColumnSelectDialogClosed");
	}
	
	private function onColumnSelectDialogClosed(event: Object): Void
	{
		CategoriesList.disableSelection = CategoriesList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		searchWidget.isDisabled = false;
		
		itemList.selectedIndex = _savedSelectionIndex;
	}
	
	private function onConfigUpdate(event: Object): Void
	{
		itemList.layout.refresh();
	}
	
	private function onItemPress(): Void
	{
		_bFocusItemList = true;
		// CraftingMenu has a handler that does the actual work.
		// This is just for focus.
	}

	private function onCategoriesItemPress(): Void
	{
		_bFocusItemList = false;
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
		CategoriesList.disableSelection = CategoriesList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		CategoriesList.disableSelection = CategoriesList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}
}