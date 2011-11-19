import gfx.io.GameDelegate;

class ItemMenu extends MovieClip
{
    var InventoryLists_mc;
	var ItemCardFadeHolder_mc;
	var ItemCard_mc;
	var BottomBar_mc;
	var bFadedIn;
	var ItemsListInputCatcher;
	var RestoreCategoryRect;
	var ExitMenuRect;
	var MouseRotationRect;
	var iPlatform;
	
    function ItemMenu()
    {
        super();
        InventoryLists_mc = InventoryLists_mc;
        ItemCard_mc = ItemCardFadeHolder_mc.ItemCard_mc;
        BottomBar_mc = BottomBar_mc;
        bFadedIn = true;
        Mouse.addListener(this);
    }
	
    function InitExtensions(abPlayBladeSound)
    {
        GameDelegate.addCallBack("UpdatePlayerInfo", this, "UpdatePlayerInfo");
        GameDelegate.addCallBack("UpdateItemCardInfo", this, "UpdateItemCardInfo");
        GameDelegate.addCallBack("ToggleMenuFade", this, "ToggleMenuFade");
        GameDelegate.addCallBack("RestoreIndices", this, "RestoreIndices");
        InventoryLists_mc.addEventListener("categoryChange", this, "onCategoryChange");
        InventoryLists_mc.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
        InventoryLists_mc.addEventListener("showItemsList", this, "onShowItemsList");
        InventoryLists_mc.addEventListener("hideItemsList", this, "onHideItemsList");
        InventoryLists_mc.ItemsList.addEventListener("itemPress", this, "onItemSelect");
        ItemCard_mc.addEventListener("quantitySelect", this, "onQuantityMenuSelect");
        ItemCard_mc.addEventListener("subMenuAction", this, "onItemCardSubMenuAction");
        
		PositionElements();
        InventoryLists_mc.ShowCategoriesList(abPlayBladeSound);
        ItemCard_mc._visible = false;
        BottomBar_mc.HideButtons();
        
		ItemsListInputCatcher.onMouseDown = function ()
        {
            if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
            {
                _parent.onItemsListInputCatcherClick();
            }
        };
		
        RestoreCategoryRect.onRollOver = function ()
        {
            if (_parent.bFadedIn == true && _parent.InventoryLists_mc.currentState == InventoryLists.TWO_PANELS)
            {
                _parent.InventoryLists_mc.RestoreCategoryIndex();
            }
        };
        ExitMenuRect.onMouseDown = function ()
        {
            if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
            {
                _parent.onExitMenuRectClick();
            }
        };
    }
	
    function PositionElements()
    {
        Shared.GlobalFunc.SetLockFunction();
        (MovieClip)(InventoryLists_mc).Lock("L");
        InventoryLists_mc._x = InventoryLists_mc._x - 20;
        var _loc4 = Stage.visibleRect.x + Stage.safeRect.x;
        var _loc3 = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
        BottomBar_mc.PositionElements(_loc4, _loc3);
        ItemCard_mc._parent._x = (_loc3 + InventoryLists_mc._x + InventoryLists_mc._width) / 2 - ItemCard_mc._parent._width / 2 - 85;
        (MovieClip)(ExitMenuRect).Lock("TL");
        ExitMenuRect._x = ExitMenuRect._x - Stage.safeRect.x;
        ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
        RestoreCategoryRect._x = ExitMenuRect._x + InventoryLists_mc.CategoriesList._parent._width;
        ItemsListInputCatcher._x = RestoreCategoryRect._x + RestoreCategoryRect._width;
        ItemsListInputCatcher._width = _root._width - ItemsListInputCatcher._x;
        if (MouseRotationRect != undefined)
        {
            (MovieClip)(MouseRotationRect).Lock("T");
            MouseRotationRect._x = ItemCard_mc._parent._x;
            MouseRotationRect._width = ItemCard_mc._parent._width;
            MouseRotationRect._height = 0.550000 * Stage.visibleRect.height;
        }
    }
	
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        iPlatform = aiPlatform;
        InventoryLists_mc.SetPlatform(aiPlatform, abPS3Switch);
        ItemCard_mc.SetPlatform(aiPlatform, abPS3Switch);
        BottomBar_mc.SetPlatform(aiPlatform, abPS3Switch);
    }
	
    function GetInventoryItemList()
    {
        //return (InventoryLists_mc.ItemsList());
    }
	
    function handleInput(details, pathToFocus)
    {
        if (bFadedIn)
        {
            if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
            {
                if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB)
                {
                    gfx.io.GameDelegate.call("CloseMenu", []);
                }
            }
        }
		
        return (true);
    }
	
    function onMouseWheel(delta)
    {
        for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined; _loc2 = _loc2._parent)
        {
            if (_loc2 == MouseRotationRect && this.ShouldProcessItemsListInput(false) || !bFadedIn && delta == -1)
            {
                gfx.io.GameDelegate.call("ZoomItemModel", [delta]);
                continue;
            } // end if
            if (_loc2 == ItemsListInputCatcher && this.ShouldProcessItemsListInput(false))
            {
                if (delta == 1)
                {
                    InventoryLists_mc.ItemsList.moveSelectionUp();
                    continue;
                } // end if
                if (delta == -1)
                {
                    InventoryLists_mc.ItemsList.moveSelectionDown();
                } // end if
            } // end if
        } // end of for
    }
	
    function onExitMenuRectClick()
    {
        GameDelegate.call("CloseMenu", []);
    }
	
    function onCategoryChange(event)
    {
    }
	
    function onItemHighlightChange(event)
    {
        if (event.index != -1)
        {
            GameDelegate.call("UpdateItem3D", [true]);
            GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
        }
        else
        {
            onHideItemsList();
        }
    }
	
    function onShowItemsList(event)
    {
        if (event.index != -1)
        {
            gfx.io.GameDelegate.call("UpdateItem3D", [true]);
            gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
            ItemCard_mc.FadeInCard();
            BottomBar_mc.ShowButtons();
        } // end if
    }
	
    function onHideItemsList(event)
    {
        gfx.io.GameDelegate.call("UpdateItem3D", [false]);
        ItemCard_mc.FadeOutCard();
        BottomBar_mc.HideButtons();
    }
	
    function onItemSelect(event)
    {
        if (event.entry.enabled)
        {
            if (event.entry.count > InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
            {
                ItemCard_mc.ShowQuantityMenu(event.entry.count);
            }
            else
            {
                this.onQuantityMenuSelect({amount: 1});
            } // end else if
        }
        else
        {
            gfx.io.GameDelegate.call("DisabledItemSelect", []);
        } // end else if
    }
	
    function onQuantityMenuSelect(event)
    {
        gfx.io.GameDelegate.call("ItemSelect", [event.amount]);
    }
	
    function UpdatePlayerInfo(aUpdateObj)
    {
        BottomBar_mc.UpdatePlayerInfo(aUpdateObj, ItemCard_mc.itemInfo);
    }
	
    function UpdateItemCardInfo(aUpdateObj)
    {
        ItemCard_mc.itemInfo = aUpdateObj;
        BottomBar_mc.UpdatePerItemInfo(aUpdateObj);
    }
	
    function onItemCardSubMenuAction(event)
    {
        if (event.opening == true)
        {
            InventoryLists_mc.ItemsList.disableSelection = true;
            InventoryLists_mc.ItemsList.disableInput = true;
            InventoryLists_mc.CategoriesList.disableSelection = true;
            InventoryLists_mc.CategoriesList.disableInput = true;
        }
        else if (event.opening == false)
        {
            InventoryLists_mc.ItemsList.disableSelection = false;
            InventoryLists_mc.ItemsList.disableInput = false;
            InventoryLists_mc.CategoriesList.disableSelection = false;
            InventoryLists_mc.CategoriesList.disableInput = false;
        } // end else if
    }
	
    function ShouldProcessItemsListInput(abCheckIfOverRect)
    {
        var _loc4 = bFadedIn == true && InventoryLists_mc.currentState == InventoryLists.TWO_PANELS && InventoryLists_mc.ItemsList.numUnfilteredItems > 0 && !InventoryLists_mc.ItemsList.disableSelection && !InventoryLists_mc.ItemsList.disableInput;
        if (_loc4 && iPlatform == 0 && abCheckIfOverRect)
        {
            var _loc2 = Mouse.getTopMostEntity();
            var _loc3 = false;
            while (!_loc3 && _loc2 && _loc2 != undefined)
            {
                if (_loc2 == ItemsListInputCatcher || _loc2 == InventoryLists_mc.ItemsList)
                {
                    _loc3 = true;
                }
                _loc2 = _loc2._parent;
            }
            _loc4 = _loc4 && _loc3;
        }
        return (_loc4);
    }
	
    function onMouseRotationStart()
    {
        GameDelegate.call("StartMouseRotation", []);
        InventoryLists_mc.CategoriesList.disableSelection = true;
        InventoryLists_mc.ItemsList.disableSelection = true;
    }
	
    function onMouseRotationStop()
    {
        GameDelegate.call("StopMouseRotation", []);
        InventoryLists_mc.CategoriesList.disableSelection = false;
        InventoryLists_mc.ItemsList.disableSelection = false;
    }
	
    function onItemsListInputCatcherClick()
    {
        if (ShouldProcessItemsListInput(false))
        {
            onItemSelect({entry: InventoryLists_mc.ItemsList.selectedEntry, keyboardOrMouse: 0});
        }
    }
	
    function onMouseRotationFastClick()
    {
        onItemsListInputCatcherClick();
    }
	
    function ToggleMenuFade()
    {
        if (bFadedIn)
        {
            _parent.gotoAndPlay("fadeOut");
            bFadedIn = false;
            InventoryLists_mc.ItemsList.disableSelection = true;
            InventoryLists_mc.ItemsList.disableInput = true;
            InventoryLists_mc.CategoriesList.disableSelection = true;
            InventoryLists_mc.CategoriesList.disableInput = true;
        }
        else
        {
            _parent.gotoAndPlay("fadeIn");
        }
    }
	
    function SetFadedIn()
    {
        bFadedIn = true;
		InventoryLists_mc.ItemsList.disableSelection = false;
        InventoryLists_mc.ItemsList.disableInput = false;
		InventoryLists_mc.CategoriesList.disableSelection = false;
		InventoryLists_mc.CategoriesList.disableInput = false;
    } // End of the function
	
    function RestoreIndices()
    {
        InventoryLists_mc.CategoriesList.RestoreScrollPosition(arguments[0], true);
        for (var _loc3 = 1; _loc3 < arguments.length; ++_loc3)
        {
            InventoryLists_mc.CategoriesList.entryList[_loc3 - 1].savedItemIndex = arguments[_loc3];
        }
        InventoryLists_mc.CategoriesList.UpdateList();
    }
	
    function SaveIndices()
    {
        var _loc3 = new Array();
        _loc3.push(InventoryLists_mc.CategoriesList.scrollPosition);
        for (var _loc2 = 0; _loc2 < InventoryLists_mc.CategoriesList.entryList.length; ++_loc2)
        {
            _loc3.push(InventoryLists_mc.CategoriesList.entryList[_loc2].savedItemIndex);
        }
        GameDelegate.call("SaveIndices", [_loc3]);
    }
}
