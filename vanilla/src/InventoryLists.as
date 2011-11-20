class InventoryLists extends MovieClip
{
    var CategoriesListHolder, _CategoriesList, ItemsListHolder, _ItemsList, gotoAndStop, strHideItemsCode, strShowItemsCode, iPlatform, iCurrentState, __get__currentState, iCurrCategoryIndex, dispatchEvent, gotoAndPlay, __get__CategoriesList, __get__ItemsList, __set__currentState;
    function InventoryLists()
    {
        super();
        _CategoriesList = CategoriesListHolder.List_mc;
        _ItemsList = ItemsListHolder.List_mc;
        gfx.events.EventDispatcher.initialize(this);
        this.gotoAndStop("NoPanels");
        gfx.io.GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
        gfx.io.GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");
        strHideItemsCode = gfx.ui.NavigationCode.LEFT;
        strShowItemsCode = gfx.ui.NavigationCode.RIGHT;
    } // End of the function
    function onLoad()
    {
        _CategoriesList.addEventListener("itemPress", this, "onCategoriesItemPress");
        _CategoriesList.addEventListener("listPress", this, "onCategoriesListPress");
        _CategoriesList.addEventListener("listMovedUp", this, "onCategoriesListMoveUp");
        _CategoriesList.addEventListener("listMovedDown", this, "onCategoriesListMoveDown");
        _CategoriesList.addEventListener("selectionChange", this, "onCategoriesListMouseSelectionChange");
        _CategoriesList.__set__numTopHalfEntries(7);
        _CategoriesList.__get__filterer().__set__itemFilter(1);
        _ItemsList.__set__maxTextLength(35);
        _ItemsList.__set__disableInput(true);
        _ItemsList.addEventListener("listMovedUp", this, "onItemsListMoveUp");
        _ItemsList.addEventListener("listMovedDown", this, "onItemsListMoveDown");
        _ItemsList.addEventListener("selectionChange", this, "onItemsListMouseSelectionChange");
    } // End of the function
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
        } // end else if
    } // End of the function
    function handleInput(details, pathToFocus)
    {
        var _loc2 = false;
        if (iCurrentState == InventoryLists.ONE_PANEL || iCurrentState == InventoryLists.TWO_PANELS)
        {
            if (Shared.GlobalFunc.IsKeyPressed(details))
            {
                if (details.navEquivalent == strHideItemsCode && iCurrentState == InventoryLists.TWO_PANELS)
                {
                    this.HideItemsList();
                    _loc2 = true;
                }
                else if (details.navEquivalent == strShowItemsCode && iCurrentState == InventoryLists.ONE_PANEL)
                {
                    this.ShowItemsList();
                    _loc2 = true;
                } // end if
            } // end else if
            if (!_loc2)
            {
                _loc2 = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
            } // end if
        } // end if
        return (_loc2);
    } // End of the function
    function get CategoriesList()
    {
        return (_CategoriesList);
    } // End of the function
    function get ItemsList()
    {
        return (_ItemsList);
    } // End of the function
    function get currentState()
    {
        return (iCurrentState);
    } // End of the function
    function set currentState(aiNewState)
    {
        switch (aiNewState)
        {
            case InventoryLists.NO_PANELS:
            {
                iCurrentState = aiNewState;
                break;
            } 
            case InventoryLists.ONE_PANEL:
            {
                iCurrentState = aiNewState;
                gfx.managers.FocusHandler.instance.setFocus(_CategoriesList, 0);
                break;
            } 
            case InventoryLists.TWO_PANELS:
            {
                iCurrentState = aiNewState;
                gfx.managers.FocusHandler.instance.setFocus(_ItemsList, 0);
                break;
            } 
        } // End of switch
        //return (this.currentState());
        null;
    } // End of the function
    function RestoreCategoryIndex()
    {
        _CategoriesList.__set__selectedIndex(iCurrCategoryIndex);
    } // End of the function
    function ShowCategoriesList(abPlayBladeSound)
    {
        iCurrentState = InventoryLists.TRANSITIONING_TO_ONE_PANEL;
        this.dispatchEvent({type: "categoryChange", index: _CategoriesList.__get__selectedIndex()});
        this.gotoAndPlay("Panel1Show");
        if (abPlayBladeSound != false)
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
        } // end if
    } // End of the function
    function HideCategoriesList()
    {
        iCurrentState = InventoryLists.TRANSITIONING_TO_NO_PANELS;
        this.gotoAndPlay("Panel1Hide");
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
    } // End of the function
    function ShowItemsList(abPlayBladeSound, abPlayAnim)
    {
        if (abPlayAnim != false)
        {
            iCurrentState = InventoryLists.TRANSITIONING_TO_TWO_PANELS;
        } // end if
        if (_CategoriesList.__get__selectedEntry() != undefined)
        {
            iCurrCategoryIndex = _CategoriesList.selectedIndex;
            _ItemsList.__get__filterer().__set__itemFilter(_CategoriesList.__get__selectedEntry().flag);
            _ItemsList.RestoreScrollPosition(_CategoriesList.__get__selectedEntry().savedItemIndex, true);
        } // end if
        _ItemsList.UpdateList();
        this.dispatchEvent({type: "showItemsList", index: _ItemsList.__get__selectedIndex()});
        if (abPlayAnim != false)
        {
            this.gotoAndPlay("Panel2Show");
        } // end if
        if (abPlayBladeSound != false)
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
        } // end if
        _ItemsList.__set__disableInput(false);
    } // End of the function
    function HideItemsList()
    {
        iCurrentState = InventoryLists.TRANSITIONING_TO_ONE_PANEL;
        this.dispatchEvent({type: "hideItemsList", index: _ItemsList.__get__selectedIndex()});
        _ItemsList.__set__selectedIndex(-1);
        this.gotoAndPlay("Panel2Hide");
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
        _ItemsList.__set__disableInput(true);
    } // End of the function
    function onCategoriesItemPress()
    {
        if (iCurrentState == InventoryLists.ONE_PANEL)
        {
            this.ShowItemsList();
        }
        else if (iCurrentState == InventoryLists.TWO_PANELS)
        {
            this.ShowItemsList(true, false);
        } // end else if
    } // End of the function
    function onCategoriesListPress()
    {
        if (iCurrentState == InventoryLists.TWO_PANELS && !_ItemsList.__get__disableSelection() && !_ItemsList.__get__disableInput())
        {
            this.HideItemsList();
            _CategoriesList.UpdateList();
        } // end if
    } // End of the function
    function onCategoriesListMoveUp(event)
    {
        this.doCategorySelectionChange(event);
        if (event.scrollChanged == true)
        {
            _CategoriesList._parent.gotoAndPlay("moveUp");
        } // end if
    } // End of the function
    function onCategoriesListMoveDown(event)
    {
        this.doCategorySelectionChange(event);
        if (event.scrollChanged == true)
        {
            _CategoriesList._parent.gotoAndPlay("moveDown");
        } // end if
    } // End of the function
    function onCategoriesListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0)
        {
            this.doCategorySelectionChange(event);
        } // end if
    } // End of the function
    function onItemsListMoveUp(event)
    {
        this.doItemsSelectionChange(event);
        if (event.scrollChanged == true)
        {
            _ItemsList._parent.gotoAndPlay("moveUp");
        } // end if
    } // End of the function
    function onItemsListMoveDown(event)
    {
        this.doItemsSelectionChange(event);
        if (event.scrollChanged == true)
        {
            _ItemsList._parent.gotoAndPlay("moveDown");
        } // end if
    } // End of the function
    function onItemsListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0)
        {
            this.doItemsSelectionChange(event);
        } // end if
    } // End of the function
    function doCategorySelectionChange(event)
    {
        this.dispatchEvent({type: "categoryChange", index: event.index});
        if (event.index != -1)
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        } // end if
    } // End of the function
    function doItemsSelectionChange(event)
    {
        _CategoriesList.__get__selectedEntry().savedItemIndex = _ItemsList.scrollPosition;
        this.dispatchEvent({type: "itemHighlightChange", index: event.index});
        if (event.index != -1)
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        } // end if
    } // End of the function
    function SetCategoriesList()
    {
        var _loc12 = 0;
        var _loc13 = 1;
        var _loc5 = 2;
        var _loc11 = 3;
        _CategoriesList.__get__entryList().splice(0, _CategoriesList.__get__entryList().length);
        for (var _loc3 = 0; _loc3 < arguments.length; _loc3 = _loc3 + _loc11)
        {
            var _loc4 = {text: arguments[_loc3 + _loc12], flag: arguments[_loc3 + _loc13], bDontHide: arguments[_loc3 + _loc5], savedItemIndex: 0, filterFlag: arguments[_loc3 + _loc5] == true ? (1) : (0)};
            if (_loc4.flag == 0)
            {
                _loc4.divider = true;
            } // end if
            _CategoriesList.__get__entryList().push(_loc4);
        } // end of for
        _CategoriesList.InvalidateData();
        _ItemsList.__get__filterer().__set__itemFilter(_CategoriesList.__get__selectedEntry().flag);
    } // End of the function
    function InvalidateListData()
    {
        var _loc6 = _CategoriesList.__get__centeredEntry();
        var _loc7 = _CategoriesList.__get__selectedEntry().flag;
        for (var _loc3 = 0; _loc3 < _CategoriesList.__get__entryList().length; ++_loc3)
        {
            _CategoriesList.__get__entryList()[_loc3].filterFlag = _CategoriesList.__get__entryList()[_loc3].bDontHide ? (1) : (0);
        } // end of for
        _ItemsList.InvalidateData();
        for (var _loc3 = 0; _loc3 < _ItemsList.__get__entryList().length; ++_loc3)
        {
            var _loc5 = _ItemsList.__get__entryList()[_loc3].filterFlag;
            for (var _loc2 = 0; _loc2 < _CategoriesList.__get__entryList().length; ++_loc2)
            {
                if (_CategoriesList.__get__entryList()[_loc2].filterFlag != 0)
                {
                    continue;
                } // end if
                if (_ItemsList.__get__entryList()[_loc3].filterFlag & _CategoriesList.__get__entryList()[_loc2].flag)
                {
                    _CategoriesList.__get__entryList()[_loc2].filterFlag = 1;
                } // end if
            } // end of for
        } // end of for
        _CategoriesList.onFilterChange();
        var _loc4 = 0;
        for (var _loc3 = 0; _loc3 < _CategoriesList.__get__entryList().length; ++_loc3)
        {
            if (_CategoriesList.__get__entryList()[_loc3].filterFlag == 1)
            {
                if (_loc6.flag == _CategoriesList.__get__entryList()[_loc3].flag)
                {
                    _CategoriesList.RestoreScrollPosition(_loc4, false);
                } // end if
                ++_loc4;
            } // end if
        } // end of for
        _CategoriesList.UpdateList();
        if (_CategoriesList.__get__centeredEntry() == undefined)
        {
            _CategoriesList.__set__scrollPosition(_CategoriesList.__get__scrollPosition() - 1);
        } // end if
        if (_loc7 != _CategoriesList.__get__selectedEntry().flag)
        {
            _ItemsList.__get__filterer().__set__itemFilter(_CategoriesList.__get__selectedEntry().flag);
            _ItemsList.UpdateList();
            this.dispatchEvent({type: "categoryChange", index: _CategoriesList.__get__selectedIndex()});
        } // end if
        if (iCurrentState != InventoryLists.TWO_PANELS && iCurrentState != InventoryLists.TRANSITIONING_TO_TWO_PANELS)
        {
            _ItemsList.__set__selectedIndex(-1);
        }
        else if (iCurrentState == InventoryLists.TWO_PANELS)
        {
            this.dispatchEvent({type: "itemHighlightChange", index: _ItemsList.__get__selectedIndex()});
        }
        else
        {
            this.dispatchEvent({type: "showItemsList", index: _ItemsList.__get__selectedIndex()});
        } // end else if
    } // End of the function
    static var NO_PANELS = 0;
    static var ONE_PANEL = 1;
    static var TWO_PANELS = 2;
    static var TRANSITIONING_TO_NO_PANELS = 3;
    static var TRANSITIONING_TO_ONE_PANEL = 4;
    static var TRANSITIONING_TO_TWO_PANELS = 5;
} // End of Class
