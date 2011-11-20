import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

class InventoryLists extends MovieClip
{
	static var NO_PANELS = 0;
    static var ONE_PANEL = 1;
    static var TWO_PANELS = 2;
    static var TRANSITIONING_TO_NO_PANELS = 3;
    static var TRANSITIONING_TO_ONE_PANEL = 4;
    static var TRANSITIONING_TO_TWO_PANELS = 5;
	
    var CategoriesListHolder;
	var _CategoriesList;
	var ItemsListHolder;
	var _ItemsList;
	var strHideItemsCode;
	var strShowItemsCode;
	var iPlatform;
	var iCurrentState:Number;
	var iCurrCategoryIndex:Number;
	
	var dispatchEvent:Function;
	
	
    function InventoryLists()
    {
        super();
        _CategoriesList = CategoriesListHolder.List_mc;
        _ItemsList = ItemsListHolder.List_mc;
        EventDispatcher.initialize(this);
        gotoAndStop("NoPanels");
        GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
        GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");
        strHideItemsCode = NavigationCode.LEFT;
        strShowItemsCode = NavigationCode.RIGHT;
    }
	
    function onLoad()
    {
        _CategoriesList.addEventListener("itemPress", this, "onCategoriesItemPress");
        _CategoriesList.addEventListener("listPress", this, "onCategoriesListPress");
        _CategoriesList.addEventListener("listMovedUp", this, "onCategoriesListMoveUp");
        _CategoriesList.addEventListener("listMovedDown", this, "onCategoriesListMoveDown");
        _CategoriesList.addEventListener("selectionChange", this, "onCategoriesListMouseSelectionChange");
        _CategoriesList.numTopHalfEntries = 7;
        _CategoriesList.filterer.itemFilter = 1;
        _ItemsList.maxTextLength = 35;
        _ItemsList.disableInput = true;
        _ItemsList.addEventListener("listMovedUp", this, "onItemsListMoveUp");
        _ItemsList.addEventListener("listMovedDown", this, "onItemsListMoveDown");
        _ItemsList.addEventListener("selectionChange", this, "onItemsListMouseSelectionChange");
    }
	
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        iPlatform = aiPlatform;
        _CategoriesList.SetPlatform(aiPlatform, abPS3Switch);
        _ItemsList.SetPlatform(aiPlatform, abPS3Switch);
		
        if (iPlatform == 0)
        {
            CategoriesListHolder.ListBackground.gotoAndStop("Mouse");
            ItemsListHolder.ListBackground.gotoAndStop("Mouse");
        }
        else
        {
            CategoriesListHolder.ListBackground.gotoAndStop("Gamepad");
            ItemsListHolder.ListBackground.gotoAndStop("Gamepad");
        }
    }
	
    function handleInput(details, pathToFocus)
    {
        var _loc2 = false;
        if (iCurrentState == ONE_PANEL || iCurrentState == TWO_PANELS)
        {
            if (Shared.GlobalFunc.IsKeyPressed(details))
            {
                if (details.navEquivalent == strHideItemsCode && iCurrentState == TWO_PANELS)
                {
                    HideItemsList();
                    _loc2 = true;
                }
                else if (details.navEquivalent == strShowItemsCode && iCurrentState == ONE_PANEL)
                {
                    ShowItemsList();
                    _loc2 = true;
                }
            }
            if (!_loc2)
            {
                _loc2 = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
            }
        }
        return (_loc2);
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
        return iCurrentState;
    }
	
    function set currentState(aiNewState)
    {
        switch (aiNewState)
        {
            case NO_PANELS:
            {
                iCurrentState = aiNewState;
                break;
            } 
            case ONE_PANEL:
            {
                iCurrentState = aiNewState;
                FocusHandler.instance.setFocus(_CategoriesList, 0);
                break;
            } 
            case TWO_PANELS:
            {
                iCurrentState = aiNewState;
                FocusHandler.instance.setFocus(_ItemsList, 0);
                break;
            } 
        }
    }
	
    function RestoreCategoryIndex()
    {
        _CategoriesList.selectedIndex = iCurrCategoryIndex;
    }
	
    function ShowCategoriesList(abPlayBladeSound)
    {
        iCurrentState = TRANSITIONING_TO_ONE_PANEL;
        dispatchEvent({type: "categoryChange", index: _CategoriesList.selectedIndex});
        gotoAndPlay("Panel1Show");
		
        if (abPlayBladeSound != false)
        {
            GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
        }
    }
	
    function HideCategoriesList()
    {
        iCurrentState = TRANSITIONING_TO_NO_PANELS;
        gotoAndPlay("Panel1Hide");
        GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
    }
	
    function ShowItemsList(abPlayBladeSound, abPlayAnim)
    {
        if (abPlayAnim != false)
        {
            iCurrentState = TRANSITIONING_TO_TWO_PANELS;
        }
		
        if (_CategoriesList.selectedEntry != undefined)
        {
            iCurrCategoryIndex = _CategoriesList.selectedIndex;
            _ItemsList.filterer.itemFilter = _CategoriesList.selectedEntry.flag;
            _ItemsList.RestoreScrollPosition(_CategoriesList.selectedEntry.savedItemIndex, true);
        }
		
        _ItemsList.UpdateList();
        dispatchEvent({type: "showItemsList", index: _ItemsList.selectedIndex});
		
        if (abPlayAnim != false)
        {
            gotoAndPlay("Panel2Show");
        }
        if (abPlayBladeSound != false)
        {
            GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
        }
        _ItemsList.disableInput = false;
    }
	
    function HideItemsList()
    {
        iCurrentState = TRANSITIONING_TO_ONE_PANEL;
        dispatchEvent({type: "hideItemsList", index: _ItemsList.selectedIndex});
        _ItemsList.selectedIndex = -1;
        gotoAndPlay("Panel2Hide");
        GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
        _ItemsList.disableInput = true;
    }
	
    function onCategoriesItemPress()
    {
        if (iCurrentState == ONE_PANEL)
        {
            ShowItemsList();
        }
        else if (iCurrentState == TWO_PANELS)
        {
            ShowItemsList(true, false);
        }
    }
	
    function onCategoriesListPress()
    {
        if (iCurrentState == TWO_PANELS && !_ItemsList.disableSelection && !_ItemsList.disableInput)
        {
            HideItemsList();
            _CategoriesList.UpdateList();
        }
    }
	
    function onCategoriesListMoveUp(event)
    {
        doCategorySelectionChange(event);
        if (event.scrollChanged == true)
        {
            _CategoriesList._parent.gotoAndPlay("moveUp");
        }
    }
	
    function onCategoriesListMoveDown(event)
    {
        doCategorySelectionChange(event);
        if (event.scrollChanged == true)
        {
            _CategoriesList._parent.gotoAndPlay("moveDown");
        }
    }
	
    function onCategoriesListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0)
        {
            doCategorySelectionChange(event);
        }
    }
	
    function onItemsListMoveUp(event)
    {
        this.doItemsSelectionChange(event);
        if (event.scrollChanged == true)
        {
            _ItemsList._parent.gotoAndPlay("moveUp");
        }
    }
	
    function onItemsListMoveDown(event)
    {
        this.doItemsSelectionChange(event);
        if (event.scrollChanged == true)
        {
            _ItemsList._parent.gotoAndPlay("moveDown");
        }
    }
	
    function onItemsListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0)
        {
            doItemsSelectionChange(event);
        }
    }
	
    function doCategorySelectionChange(event)
    {
        dispatchEvent({type: "categoryChange", index: event.index});
		
        if (event.index != -1)
        {
            GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        }
    }
	
    function doItemsSelectionChange(event)
    {
        _CategoriesList.selectedEntry.savedItemIndex = _ItemsList.scrollPosition;
        dispatchEvent({type: "itemHighlightChange", index: event.index});
		
        if (event.index != -1)
        {
            GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        }
    }
	
    function SetCategoriesList()
    {
        var _loc12 = 0;
        var _loc13 = 1;
        var _loc5 = 2;
        var _loc11 = 3;
        _CategoriesList.entryList.splice(0, _CategoriesList.entryList.length);
		
        for (var _loc3 = 0; _loc3 < arguments.length; _loc3 = _loc3 + _loc11)
        {
            var _loc4 = {text: arguments[_loc3 + _loc12], flag: arguments[_loc3 + _loc13], bDontHide: arguments[_loc3 + _loc5], savedItemIndex: 0, filterFlag: arguments[_loc3 + _loc5] == true ? (1) : (0)};
            if (_loc4.flag == 0)
            {
                _loc4.divider = true;
            }
            _CategoriesList.entryList.push(_loc4);
        }
        _CategoriesList.InvalidateData();
        _ItemsList.filterer.itemFilterer = _CategoriesList.selectedEntry.flag;
    }
	
    function InvalidateListData()
    {
        var _loc6 = _CategoriesList.centeredEntry;
        var _loc7 = _CategoriesList.selectedEntry.flag;
		
        for (var _loc3 = 0; _loc3 < _CategoriesList.entryList.length; ++_loc3)
        {
            _CategoriesList.entryList[_loc3].filterFlag = _CategoriesList.entryList[_loc3].bDontHide ? (1) : (0);
        }
		
        _ItemsList.InvalidateData();
        for (var _loc3 = 0; _loc3 < _ItemsList.entryList.length; ++_loc3)
        {
            var _loc5 = _ItemsList.entryList[_loc3].filterFlag;
            for (var _loc2 = 0; _loc2 < _CategoriesList.entryList.length; ++_loc2)
            {
                if (_CategoriesList.entryList[_loc2].filterFlag != 0)
                {
                    continue;
                }
				
                if (_ItemsList.entryList[_loc3].filterFlag & _CategoriesList.entryList[_loc2].flag)
                {
                    _CategoriesList.entryList[_loc2].filterFlag = 1;
                }
            }
        }
		
        _CategoriesList.onFilterChange();
		
        var index = 0;
        for (var i = 0; i < _CategoriesList.entryList.length; ++i)
        {
            if (_CategoriesList.entryList[i].filterFlag == 1)
            {
                if (_loc6.flag == _CategoriesList.entryList[i].flag)
                {
                    _CategoriesList.RestoreScrollPosition(index, false);
                }
                ++index;
            }
        }
		
        _CategoriesList.UpdateList();
		
        if (_CategoriesList.centeredEntry == undefined)
        {
            _CategoriesList.scrollPosition = _CategoriesList.scrollPosition - 1;
        }
		
        if (_loc7 != _CategoriesList.selectedEntry.flag)
        {
            _ItemsList.filterer.itemFilter = _CategoriesList.selectedEntry.flag;
            _ItemsList.UpdateList();
            dispatchEvent({type: "categoryChange", index: _CategoriesList.selectedIndex});
        }
		
        if (iCurrentState != TWO_PANELS && iCurrentState != TRANSITIONING_TO_TWO_PANELS)
        {
            _ItemsList.selectedIndex = -1;
        }
        else if (iCurrentState == TWO_PANELS)
        {
            dispatchEvent({type: "itemHighlightChange", index: _ItemsList.selectedIndex});
        }
        else
        {
            dispatchEvent({type: "showItemsList", index: _ItemsList.selectedIndex});
        }
    }
}
