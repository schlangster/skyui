import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import dui.HorizontalList;
import dui.FilteredList;
import dui.ItemTypeFilter;
import dui.ItemNameFilter;
import dui.ItemSortingFilter;

class InventoryLists extends MovieClip
{
	static var NO_PANELS = 0;
	static var ONE_PANEL = 1;
	static var TWO_PANELS = 2;

	static var TRANSITIONING_TO_NO_PANELS = 3;
	static var TRANSITIONING_TO_ONE_PANEL = 4;
	static var TRANSITIONING_TO_TWO_PANELS = 5;

	private var _CategoriesList:HorizontalList;
	private var _ItemsList:FilteredList;
	private var _hideItemsCode:String;
	private var _showItemsCode:String;
	private var _platform:Number;
	private var _currentState:Number;
	private var _currCategoryIndex:Number;
	
	private var _typeFilter:ItemTypeFilter;
	private var _nameFilter:ItemNameFilter;
	private var _sortFilter:ItemSortingFilter;

	// Children
	var CategoriesListHolder:MovieClip;
	var ItemsListHolder:MovieClip;
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	

	function InventoryLists()
	{
		super();
		
		_CategoriesList = CategoriesListHolder.List_mc;
		_ItemsList = ItemsListHolder.List_mc;

		EventDispatcher.initialize(this);
		gotoAndStop("NoPanels");

		GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
		GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");

		_typeFilter = new ItemTypeFilter();
		_nameFilter = new ItemNameFilter();
		_sortFilter = new ItemSortingFilter();

		_hideItemsCode = NavigationCode.LEFT;
		_showItemsCode = NavigationCode.RIGHT;
	}

	function onLoad()
	{
		_ItemsList.addFilter(_typeFilter);
		_ItemsList.addFilter(_nameFilter);
		_ItemsList.addFilter(_sortFilter);

		_typeFilter.addEventListener("filterChange",_ItemsList,"onFilterChange");

		_CategoriesList.addEventListener("itemPress",this,"onCategoriesItemPress");
		_CategoriesList.addEventListener("listPress",this,"onCategoriesListPress");
		_CategoriesList.addEventListener("listMovedUp",this,"onCategoriesListMoveUp");
		_CategoriesList.addEventListener("listMovedDown",this,"onCategoriesListMoveDown");
		_CategoriesList.addEventListener("selectionChange",this,"onCategoriesListMouseSelectionChange");

		_ItemsList.maxTextLength = 35;
		_ItemsList.disableInput = true;

		_ItemsList.addEventListener("listMovedUp",this,"onItemsListMoveUp");
		_ItemsList.addEventListener("listMovedDown",this,"onItemsListMoveDown");
		_ItemsList.addEventListener("selectionChange",this,"onItemsListMouseSelectionChange");
	}

	function setPlatform(a_platform, a_bPS3Switch)
	{
		_platform = a_platform;
		
		_CategoriesList.setPlatform(a_platform,a_bPS3Switch);
		_ItemsList.setPlatform(a_platform,a_bPS3Switch);

		if (_platform == 0) {
			CategoriesListHolder.ListBackground.gotoAndStop("Mouse");
			ItemsListHolder.ListBackground.gotoAndStop("Mouse");
		} else {
			CategoriesListHolder.ListBackground.gotoAndStop("Gamepad");
			ItemsListHolder.ListBackground.gotoAndStop("Gamepad");
		}
	}

	function handleInput(details, pathToFocus)
	{
		var _loc2 = false;

		if (_currentState == ONE_PANEL || _currentState == TWO_PANELS) {
			if (Shared.GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == _hideItemsCode && _currentState == TWO_PANELS) {
					hideItemsList();
					_loc2 = true;
				} else if (details.navEquivalent == _showItemsCode && _currentState == ONE_PANEL) {
					showItemsList();
					_loc2 = true;
				}
			}
			if (!_loc2) {
				_loc2 = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		return _loc2;
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
		switch (a_newState) {
			case NO_PANELS :
				_currentState = a_newState;
				break;
			case ONE_PANEL :
				_currentState = a_newState;
				FocusHandler.instance.setFocus(_CategoriesList,0);
				break;
			case TWO_PANELS :
				_currentState = a_newState;
				FocusHandler.instance.setFocus(_ItemsList,0);
				break;
		}
	}

	function RestoreCategoryIndex()
	{
		_CategoriesList.selectedIndex = _currCategoryIndex;
	}

	function ShowCategoriesList(a_bPlayBladeSound)
	{
		_currentState = TRANSITIONING_TO_ONE_PANEL;
		dispatchEvent({type:"categoryChange", index:_CategoriesList.selectedIndex});
		gotoAndPlay("Panel1Show");

		if (a_bPlayBladeSound != false) {
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		}
	}

	function HideCategoriesList()
	{
		_currentState = TRANSITIONING_TO_NO_PANELS;
		gotoAndPlay("Panel1Hide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}

	function showItemsList(a_bPlayBladeSound, abPlayAnim)
	{
		if (abPlayAnim != false) {
			_currentState = TRANSITIONING_TO_TWO_PANELS;
		}

		if (_CategoriesList.selectedEntry != undefined) {
			_currCategoryIndex = _CategoriesList.selectedIndex;
			_typeFilter.itemFilter = _CategoriesList.selectedEntry.flag;
		}

		_ItemsList.UpdateList();
		dispatchEvent({type:"showItemsList", index:_ItemsList.selectedIndex});

		if (abPlayAnim != false) {
			gotoAndPlay("Panel2Show");
		}
		if (a_bPlayBladeSound != false) {
			GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		}
		_ItemsList.disableInput = false;
	}

	function hideItemsList()
	{
		_currentState = TRANSITIONING_TO_ONE_PANEL;
		dispatchEvent({type:"hideItemsList", index:_ItemsList.selectedIndex});
		_ItemsList.selectedIndex = -1;
		gotoAndPlay("Panel2Hide");
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		_ItemsList.disableInput = true;
	}

	function onCategoriesItemPress()
	{
		if (_currentState == ONE_PANEL) {
			showItemsList();
		} else if (_currentState == TWO_PANELS) {
			showItemsList(true,false);
		}
	}

	function onCategoriesListPress()
	{
		if (_currentState == TWO_PANELS && !_ItemsList.disableSelection && !_ItemsList.disableInput) {
			hideItemsList();
			_CategoriesList.UpdateList();
		}
	}

	function onCategoriesListMoveUp(event)
	{
		doCategorySelectionChange(event);
		if (event.scrollChanged == true) {
			_CategoriesList._parent.gotoAndPlay("moveUp");
		}
	}

	function onCategoriesListMoveDown(event)
	{
		doCategorySelectionChange(event);
		if (event.scrollChanged == true) {
			_CategoriesList._parent.gotoAndPlay("moveDown");
		}
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
		if (event.scrollChanged == true) {
			_ItemsList._parent.gotoAndPlay("moveUp");
		}
	}

	function onItemsListMoveDown(event)
	{
		this.doItemsSelectionChange(event);
		if (event.scrollChanged == true) {
			_ItemsList._parent.gotoAndPlay("moveDown");
		}
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