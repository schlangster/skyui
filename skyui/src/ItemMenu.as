import gfx.io.GameDelegate;

dynamic class ItemMenu extends MovieClip
{
	var BottomBar_mc:MovieClip;
	var ExitMenuRect:MovieClip;
	var InventoryLists_mc:MovieClip;
	var ItemCardFadeHolder_mc:MovieClip;
	var ItemCard_mc:MovieClip;
	var ItemsListInputCatcher:MovieClip;
	var MouseRotationRect:MovieClip;
	var RestoreCategoryRect:MovieClip;

	var bFadedIn;
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
		GameDelegate.addCallBack("UpdatePlayerInfo",this,"UpdatePlayerInfo");
		GameDelegate.addCallBack("UpdateItemCardInfo",this,"UpdateItemCardInfo");
		GameDelegate.addCallBack("ToggleMenuFade",this,"ToggleMenuFade");
		GameDelegate.addCallBack("RestoreIndices",this,"RestoreIndices");
		InventoryLists_mc.addEventListener("categoryChange",this,"onCategoryChange");
		InventoryLists_mc.addEventListener("itemHighlightChange",this,"onItemHighlightChange");
		InventoryLists_mc.addEventListener("showItemsList",this,"onShowItemsList");
		InventoryLists_mc.addEventListener("hideItemsList",this,"onHideItemsList");
		InventoryLists_mc.ItemsList.addEventListener("itemPress",this,"onItemSelect");
		ItemCard_mc.addEventListener("quantitySelect",this,"onQuantityMenuSelect");
		ItemCard_mc.addEventListener("subMenuAction",this,"onItemCardSubMenuAction");
		PositionElements();
		InventoryLists_mc.ShowCategoriesList(abPlayBladeSound);
		ItemCard_mc._visible = false;
		BottomBar_mc.HideButtons();
		
		ItemsListInputCatcher.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this) {
				_parent.onItemsListInputCatcherClick();
			}
		};
		
		RestoreCategoryRect.onRollOver = function()
		{
			if (_parent.bFadedIn == true && _parent.InventoryLists_mc.currentState == InventoryLists.TWO_PANELS) {
				_parent.InventoryLists_mc.RestoreCategoryIndex();
			}
		};
		
		ExitMenuRect.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this) {
				_parent.onExitMenuRectClick();
			}
		};
	}

	function PositionElements()
	{
		GlobalFunc.SetLockFunction();
		MovieClip(InventoryLists_mc).Lock("L");
		InventoryLists_mc._x = InventoryLists_mc._x - 20;
		var __reg4 = Stage.visibleRect.x + Stage.safeRect.x;
		var __reg3 = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		BottomBar_mc.PositionElements(__reg4,__reg3);
		ItemCard_mc._parent._x = (__reg3 + InventoryLists_mc._x + InventoryLists_mc._width) / 2 - ItemCard_mc._parent._width / 2 - 85;
		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - Stage.safeRect.x;
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
		RestoreCategoryRect._x = ExitMenuRect._x + InventoryLists_mc.CategoriesList._parent._width;
		ItemsListInputCatcher._x = RestoreCategoryRect._x + RestoreCategoryRect._width;
		ItemsListInputCatcher._width = _root._width - ItemsListInputCatcher._x;
		if (MouseRotationRect != undefined) {
			MovieClip(MouseRotationRect).Lock("T");
			MouseRotationRect._x = ItemCard_mc._parent._x;
			MouseRotationRect._width = ItemCard_mc._parent._width;
			MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
		}
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		iPlatform = aiPlatform;
		InventoryLists_mc.SetPlatform(aiPlatform,abPS3Switch);
		ItemCard_mc.SetPlatform(aiPlatform,abPS3Switch);
		BottomBar_mc.SetPlatform(aiPlatform,abPS3Switch);
	}

	function GetInventoryItemList()
	{
		return InventoryLists_mc.ItemsList;
	}

	function handleInput(details, pathToFocus)
	{
		if (bFadedIn) {
			if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
				if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB) {
					GameDelegate.call("CloseMenu",[]);
				}
			}
		}
		return true;
	}

	function onMouseWheel(delta)
	{
		var __reg2 = Mouse.getTopMostEntity();
		for (; ; ) {
			if (!(__reg2 && __reg2 != undefined)) {
				return;
			}
			if ((__reg2 == MouseRotationRect && ShouldProcessItemsListInput(false)) || (!bFadedIn && delta == -1)) {
				GameDelegate.call("ZoomItemModel",[delta]);
			} else if (__reg2 == ItemsListInputCatcher && ShouldProcessItemsListInput(false)) {
				if (delta == 1) {
					InventoryLists_mc.ItemsList.moveSelectionUp();
				} else if (delta == -1) {
					InventoryLists_mc.ItemsList.moveSelectionDown();
				}
			}
			__reg2 = __reg2._parent;
		}
	}

	function onExitMenuRectClick()
	{
		GameDelegate.call("CloseMenu",[]);
	}

	function onCategoryChange(event)
	{
	}

	function onItemHighlightChange(event)
	{
		if (event.index != -1) {
			GameDelegate.call("UpdateItem3D",[true]);
			GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
			return;
		}
		onHideItemsList();
	}

	function onShowItemsList(event)
	{
		if (event.index != -1) {
			GameDelegate.call("UpdateItem3D",[true]);
			GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
			ItemCard_mc.FadeInCard();
			BottomBar_mc.ShowButtons();
		}
	}

	function onHideItemsList(event)
	{
		GameDelegate.call("UpdateItem3D",[false]);
		ItemCard_mc.FadeOutCard();
		BottomBar_mc.HideButtons();
	}

	function onItemSelect(event)
	{
		if (event.entry.enabled) {
			if (event.entry.count > InventoryDefines.QUANTITY_MENU_COUNT_LIMIT) {
				ItemCard_mc.ShowQuantityMenu(event.entry.count);
			} else {
				onQuantityMenuSelect({amount:1});
			}
			return;
		}
		GameDelegate.call("DisabledItemSelect",[]);
	}

	function onQuantityMenuSelect(event)
	{
		GameDelegate.call("ItemSelect",[event.amount]);
	}

	function UpdatePlayerInfo(aUpdateObj)
	{
		BottomBar_mc.UpdatePlayerInfo(aUpdateObj,ItemCard_mc.itemInfo);
	}

	function UpdateItemCardInfo(aUpdateObj)
	{
		ItemCard_mc.itemInfo = aUpdateObj;
		BottomBar_mc.UpdatePerItemInfo(aUpdateObj);
	}

	function onItemCardSubMenuAction(event)
	{
		if (event.opening == true) {
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
			return;
		}
		if (event.opening == false) {
			InventoryLists_mc.ItemsList.disableSelection = false;
			InventoryLists_mc.ItemsList.disableInput = false;
			InventoryLists_mc.CategoriesList.disableSelection = false;
			InventoryLists_mc.CategoriesList.disableInput = false;
		}
	}

	function ShouldProcessItemsListInput(abCheckIfOverRect)
	{
		var __reg4 = bFadedIn == true && InventoryLists_mc.currentState == InventoryLists.TWO_PANELS && InventoryLists_mc.ItemsList.numUnfilteredItems > 0 && !InventoryLists_mc.ItemsList.disableSelection && !InventoryLists_mc.ItemsList.disableInput;
		if (__reg4 && iPlatform == 0 && abCheckIfOverRect) {
			var __reg2 = Mouse.getTopMostEntity();
			var __reg3 = false;
			while (!__reg3 && __reg2 && __reg2 != undefined)
			{
				if (__reg2 == ItemsListInputCatcher || __reg2 == InventoryLists_mc.ItemsList) {
					__reg3 = true;
				}
				__reg2 = __reg2._parent;
			}
			__reg4 = __reg4 && __reg3;
		}
		return __reg4;
	}

	function onMouseRotationStart()
	{
		GameDelegate.call("StartMouseRotation",[]);
		InventoryLists_mc.CategoriesList.disableSelection = true;
		InventoryLists_mc.ItemsList.disableSelection = true;
	}

	function onMouseRotationStop()
	{
		GameDelegate.call("StopMouseRotation",[]);
		InventoryLists_mc.CategoriesList.disableSelection = false;
		InventoryLists_mc.ItemsList.disableSelection = false;
	}

	function onItemsListInputCatcherClick()
	{
		if (ShouldProcessItemsListInput(false)) {
			onItemSelect({entry:InventoryLists_mc.ItemsList.selectedEntry, keyboardOrMouse:0});
		}
	}

	function onMouseRotationFastClick()
	{
		onItemsListInputCatcherClick();
	}

	function ToggleMenuFade()
	{
		if (bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
			return;
		}
		_parent.gotoAndPlay("fadeIn");
	}

	function SetFadedIn()
	{
		bFadedIn = true;
		InventoryLists_mc.ItemsList.disableSelection = false;
		InventoryLists_mc.ItemsList.disableInput = false;
		InventoryLists_mc.CategoriesList.disableSelection = false;
		InventoryLists_mc.CategoriesList.disableInput = false;
	}

	function RestoreIndices()
	{
		InventoryLists_mc.CategoriesList.RestoreScrollPosition(arguments[0],true);
		
		for (var i = 1; i < arguments.length; i++) {
			InventoryLists_mc.CategoriesList.entryList[i - 1].savedItemIndex = arguments[i];
		}
		InventoryLists_mc.CategoriesList.UpdateList();
	}

	function SaveIndices()
	{
		var indices = new Array();
		indices.push(InventoryLists_mc.CategoriesList.scrollPosition);
		var __reg2 = 0;
		for (var i=0; i < InventoryLists_mc.CategoriesList.entryList.length; i++) {
			indices.push(InventoryLists_mc.CategoriesList.entryList[i].savedItemIndex);
		}
		GameDelegate.call("SaveIndices",[indices]);
	}

}