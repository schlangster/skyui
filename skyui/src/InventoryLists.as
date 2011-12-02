import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import Shared.GlobalFunc;

import skyui.HorizontalList;
import skyui.InventoryItemList;
import skyui.ItemTypeFilter;
import skyui.ItemNameFilter;
import skyui.ItemSortingFilter;
import skyui.SortedListHeader;

class InventoryLists extends MovieClip
{
	// Pretend to the outside as if still using two panels for compatiblity.
	// The internal transitions are
	// NO_PANELS -> TRANSITIONING_TO_TWO_PANELS -> TWO_PANELS
	// TWO_PANELS -> TRANSITIONING_TO_NO_PANELS -> NO_PANELS
	// ONE_PANEL is skipped, only used to enable the menu closing with LEFT
	
	static var NO_PANELS = 0;
	static var ONE_PANEL = 1;
	static var TWO_PANELS = 2;
	static var TRANSITIONING_TO_NO_PANELS = 3;
	static var TRANSITIONING_TO_ONE_PANEL = 4;
	static var TRANSITIONING_TO_TWO_PANELS = 5;

	private var _CategoriesList:HorizontalList;
	private var _CategoryLabel:MovieClip;
	private var _ItemsList:InventoryItemList;
	private	var _itemsHeader:SortedListHeader;
	
	private var _prevCategoryCode:String;
	private var _nextCategoryCode:String;
	private var _prevItemCode:String;
	private var _nextItemCode:String;
	
	private var _platform:Number;
	private var _currentState:Number;
	
	private var _defaultCategoryIndex:Number;
	
	private var _typeFilter:ItemTypeFilter;
	private var _nameFilter:ItemNameFilter;
	private var _sortFilter:ItemSortingFilter;
	
	private var _currCategoryIndex:Number;
	private var _bFirstSelectionFlag:Boolean;

	// Children
	var panelContainer:MovieClip;
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	var debug;
	

	function InventoryLists()
	{		
		super();
		
		_CategoriesList = panelContainer.categoriesList;
		_CategoryLabel = panelContainer.CategoryLabel;
		_ItemsList = panelContainer.itemsList;
		_itemsHeader = panelContainer.itemsHeader;

		EventDispatcher.initialize(this);
		
		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSortingFilter();

		_prevCategoryCode = NavigationCode.LEFT;
		_nextCategoryCode = NavigationCode.RIGHT;
		
		_defaultCategoryIndex = 1; // ALL
	}

	function onLoad()
	{
		_ItemsList.addFilter(_typeFilter);
		_ItemsList.addFilter(_nameFilter);
		_ItemsList.addFilter(_sortFilter);

		_typeFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");
		_nameFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");
		_sortFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");
		
		_itemsHeader.addEventListener("sortChange",this,"onSortChange");

		_CategoriesList.addEventListener("itemPress",this,"onCategoriesItemPress");
		_CategoriesList.addEventListener("listPress",this,"onCategoriesListPress");
		_CategoriesList.addEventListener("listMovedUp",this,"onCategoriesListMoveUp");
		_CategoriesList.addEventListener("listMovedDown",this,"onCategoriesListMoveDown");
		_CategoriesList.addEventListener("selectionChange",this,"onCategoriesListMouseSelectionChange");

		_ItemsList.maxTextLength = 35;
		_ItemsList.disableInput = false;

		_ItemsList.addEventListener("listMovedUp",this,"onItemsListMoveUp");
		_ItemsList.addEventListener("listMovedDown",this,"onItemsListMoveDown");
		_ItemsList.addEventListener("selectionChange",this,"onItemsListMouseSelectionChange");
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		_platform = a_platform;
		
		_CategoriesList.setPlatform(a_platform,a_bPS3Switch);
		_ItemsList.setPlatform(a_platform,a_bPS3Switch);
	}

	function handleInput(details, pathToFocus)
	{
		var bCaught = false;

		if (_currentState == TWO_PANELS) {
			if (GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == _prevCategoryCode) {
					
					if (_CategoriesList.selectedIndex == 0) {
						// Required to trigger the closing when InventoryMenu catches this event
						currentState = ONE_PANEL;
					} else {
						_CategoriesList.moveSelectionLeft();
						bCaught = true;
					}
					
				} else if (details.navEquivalent == _nextCategoryCode) {
					_CategoriesList.moveSelectionRight();
					bCaught = true;
				}
			}
			if (!bCaught) {
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		return bCaught;
	}

	function get CategoriesList()
	{
		return _CategoriesList;
	}

	function get ItemsList()
	{
		return _ItemsList;
	}

	function get currentState()
	{
		return _currentState;
	}

	function set currentState(a_newState)
	{
		if (a_newState == TWO_PANELS) {
			FocusHandler.instance.setFocus(_ItemsList,0);
		}
		
		_currentState = a_newState;
	}

	function RestoreCategoryIndex()
	{
		_CategoriesList.selectedIndex = _currCategoryIndex;
	}

	function ShowCategoriesList(a_bPlayBladeSound:Boolean)
	{
		_currentState = TRANSITIONING_TO_TWO_PANELS;
		gotoAndPlay("PanelShow");
		
		dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});

		if (a_bPlayBladeSound != false) {
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		}
	}

	function HideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_NO_PANELS;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}


	/*	Default reactions:
			"showItemsList" with index == -1: Do nothing
			"showItemsList" with index != -1: Fade in item card and bottom bar icons, update 3d icon
			"itemHighlightChange" with index == -1: Fade out item card, hide bottom bar icons and 3d icon
			"itemHighlightChange" with index != -1: Update item card, update 3d model

		showItemsList() is called to trigger an update of the item list.
		it has to call itemHighlightChange with index -1 and set _bFirstSelectionFlag to true.
		onItemsListMouseSelectionChange() then dispatches
			"showItemsList" and sets _bFirstSelectionFlag=false, if _bFirstSelectionFlag was true
			"itemHighlightChange", if _bFirstSelectionFlag was false
	*/
	function showItemsList()
	{
		_currCategoryIndex = _CategoriesList.selectedIndex;

		_CategoryLabel.textField.SetText(_CategoriesList.selectedEntry.text);

		_bFirstSelectionFlag = true;
		
		// Let's do this more elegant at some point.. :)
		// Changing the sort filter might already trigger an update, so the final UpdateList is redudant
		
		if (_CategoriesList.selectedEntry != undefined) {
			// Set filter type before update
			_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
			
			// Header my change the sort type, if STAT column is no longer available for the current category
			_itemsHeader.statType = CategoriesList.selectedEntry.flag;
			_sortFilter.setSortBy(_itemsHeader.sortBy, _itemsHeader.ascending);
			
			_ItemsList.statType = _CategoriesList.selectedEntry.flag;
			_currCategoryIndex = _CategoriesList.selectedIndex;
			
            _ItemsList.RestoreScrollPosition(_CategoriesList.selectedEntry.savedItemIndex);
        }
		
		// Start with no selection
		_ItemsList.selectedIndex = -1;
		_ItemsList.UpdateList();
		
		dispatchEvent({type:"itemHighlightChange", index:_ItemsList.selectedIndex});
		
		_ItemsList.disableInput = false;
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}

	// Not needed anymore, items list always visible
	function hideItemsList()
	{
//		_currentState = TRANSITIONING_TO_ONE_PANEL;
//		dispatchEvent({type:"hideItemsList", index:_ItemsList.selectedIndex});
//		_ItemsList.selectedIndex = -1;
//		gotoAndPlay("Panel2Hide");
//		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
//		_ItemsList.disableInput = true;
	}

	function onCategoriesItemPress()
	{
		if (_currentState == TWO_PANELS) {
			showItemsList();
		}
	}

	function onCategoriesListPress()
	{
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
		if (event.keyboardOrMouse == 0) {
			doCategorySelectionChange(event);
		}
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
		if (event.keyboardOrMouse == 0) {
			doItemsSelectionChange(event);
		}
	}

	function doCategorySelectionChange(event)
	{
		dispatchEvent({type:"categoryChange", index:event.index});

		if (event.index != -1) {
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}

	function doItemsSelectionChange(event)
	{
		_CategoriesList.selectedEntry.savedItemIndex = _ItemsList.scrollPosition;
		
		if (_bFirstSelectionFlag) {
			_bFirstSelectionFlag = false;
			dispatchEvent({type:"showItemsList", index:event.index});
		} else {
			if (event.index == -1) {
				_bFirstSelectionFlag = true;
			}
			dispatchEvent({type:"itemHighlightChange", index:event.index});			
		}

		if (event.index != -1) {
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}
	
	function onSortChange(event)
	{
		_sortFilter.setSortBy(event.sortBy, event.ascending);
	}

	// API - Called to initially set the category list
	function SetCategoriesList()
	{
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

		_CategoriesList.clearList();

		for (var i = 0; i < arguments.length; i = i + len) {
			var entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:arguments[i + bDontHideOffset] == true ? (1) : (0)};
			_CategoriesList.entryList.push(entry);
		}

		// Start with selected default category (ALL)
		_CategoriesList.selectedIndex = _defaultCategoryIndex;
		_CategoriesList.InvalidateData();

//		_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;

		// <TODO> - do this in ItemMenu once we start changing it
		var itemCardContainer = _parent.ItemCard_mc._parent;
		itemCardContainer._x = Stage.visibleRect.x + Stage.visibleRect.width - itemCardContainer._width - 65;
		_parent.ItemsListInputCatcher._visible = false;
		_parent.RestoreCategoryRect._visible = false;
		// </TODO>
		

		showItemsList();
	}

	// API - Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	function InvalidateListData()
	{
		var flag = _CategoriesList.selectedEntry.flag;

		for (var i = 0; i < _CategoriesList.entryList.length; i++) {
			_CategoriesList.entryList[i].filterFlag = _CategoriesList.entryList[i].bDontHide ? 1 : 0;
		}

		_ItemsList.InvalidateData();
		for (var i = 0; i < _ItemsList.entryList.length; i++) {
			var _loc5 = _ItemsList.entryList[i].filterFlag;
			for (var j = 0; j < _CategoriesList.entryList.length; ++j) {
				if (_CategoriesList.entryList[j].filterFlag != 0) {
					continue;
				}

				if (_ItemsList.entryList[i].filterFlag & _CategoriesList.entryList[j].flag) {
					_CategoriesList.entryList[j].filterFlag = 1;
				}
			}
		}
		
		_CategoriesList.UpdateList();

		if (flag != _CategoriesList.selectedEntry.flag) {
			// Triggers an update if filter flag changed
			_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
			dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});
		}

// Probably not necessary anymore

//		if (_currentState != TWO_PANELS && _currentState != TRANSITIONING_TO_TWO_PANELS) {
//			_ItemsList.selectedIndex = -1;
//		} else {
//			dispatchEvent({type:"itemHighlightChange", index:_ItemsList.selectedIndex});
//	        dispatchEvent({type: "showItemsList", index:_ItemsList.selectedIndex});
//		}
	}
}