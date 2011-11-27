import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import Shared.GlobalFunc;

import skyui.HorizontalList;
import skyui.FilteredList;
import skyui.ItemTypeFilter;
import skyui.ItemNameFilter;

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
	private var _ItemsList:FilteredList;
	
	private var _prevCategoryCode:String;
	private var _nextCategoryCode:String;
	private var _prevItemCode:String;
	private var _nextItemCode:String;
	
	private var _platform:Number;
	private var _currentState:Number;

	private var _currCategoryIndex:Number;
	private var _defaultCategoryIndex:Number;
	
	private var _typeFilter:ItemTypeFilter;
	private var _nameFilter:ItemNameFilter;

	// Children
	var panelContainer:MovieClip;
	var ItemsListHolder:MovieClip;
	
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

		EventDispatcher.initialize(this);
		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();

		_prevCategoryCode = NavigationCode.LEFT;
		_nextCategoryCode = NavigationCode.RIGHT;
		_prevItemCode = NavigationCode.UP;
		_nextItemCode = NavigationCode.DOWN;
		
		_defaultCategoryIndex = 1; // ALL
	}

	function onLoad()
	{
		_ItemsList.addFilter(_typeFilter);
		_ItemsList.addFilter(_nameFilter);

		_typeFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");

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
				} else if (details.navEquivalent == _prevItemCode) {
					_ItemsList.moveSelectionUp();
					bCaught = true;					
				} else if (details.navEquivalent == _nextItemCode) {
					_ItemsList.moveSelectionDown();
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
			FocusHandler.instance.setFocus(this,0);
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
		
		_CategoriesList.selectedIndex = _defaultCategoryIndex;
		dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});

		if (a_bPlayBladeSound != false) {
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		}
		
		showItemsList();
	}

	function HideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_NO_PANELS;
		gotoAndPlay("PanelHide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	function showItemsList()
	{
		if (_CategoriesList.selectedEntry == undefined) {
			_CategoriesList.selectedIndex = _defaultCategoryIndex;
		}

		_currCategoryIndex = _CategoriesList.selectedIndex;
		_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
		_CategoryLabel.textField.SetText(_CategoriesList.selectedEntry.text);

		_ItemsList.UpdateList();
		dispatchEvent({type:"showItemsList", index:_ItemsList.selectedIndex});
		
		_ItemsList.disableInput = false;
	}

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
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1) {
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}

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

		_CategoriesList.InvalidateData();
		_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
	}

	function InvalidateListData()
	{
		var _loc7 = _CategoriesList.selectedEntry.flag;

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

//		_CategoriesList.onFilterChange();

		_CategoriesList.UpdateList();

		if (_loc7 != _CategoriesList.selectedEntry.flag) {
			_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
			_ItemsList.UpdateList();
			dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});
		}

		if (_currentState != TWO_PANELS && _currentState != TRANSITIONING_TO_TWO_PANELS) {
			_ItemsList.selectedIndex = -1;
		} else if (_currentState == TWO_PANELS) {
			dispatchEvent({type:"itemHighlightChange", index:_ItemsList.selectedIndex});
		} else {
			dispatchEvent({type:"showItemsList", index:_ItemsList.selectedIndex});
		}
	}
}