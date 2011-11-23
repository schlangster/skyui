import gfx.io.GameDelegate;

class ItemMenu extends MovieClip
{

	private var _bFadedIn;
	private var _platform;

	// Children
	var InventoryLists_mc:InventoryLists;
	var ItemCardFadeHolder_mc:MovieClip;
	var ItemCard_mc:MovieClip;
	var BottomBar_mc:MovieClip;
	var ItemsListInputCatcher:MovieClip;
	var RestoreCategoryRect:MovieClip;
	var ExitMenuRect:MovieClip;
	var MouseRotationRect:MovieClip;

	function ItemMenu()
	{
		super();

		_bFadedIn = true;
		Mouse.addListener(this);
	}

	function InitExtensions(a_bPlayBladeSound:Boolean)
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

		positionElements();
		InventoryLists_mc.ShowCategoriesList(a_bPlayBladeSound);

		ItemCard_mc._visible = false;
		BottomBar_mc.HideButtons();

		ItemsListInputCatcher.onMouseDown = function()
		{
			if (_parent._bFadedIn == true && Mouse.getTopMostEntity() == this) {
				_parent.onItemsListInputCatcherClick();
			}
		};

		RestoreCategoryRect.onRollOver = function()
		{
			if (_parent._bFadedIn == true && _parent.InventoryLists_mc.currentState == InventoryLists.TWO_PANELS) {
				_parent.InventoryLists_mc.RestoreCategoryIndex();
			}
		};
		ExitMenuRect.onMouseDown = function()
		{
			if (_parent._bFadedIn == true && Mouse.getTopMostEntity() == this) {
				_parent.onExitMenuRectClick();
			}
		};
	}

	function positionElements()
	{
		Shared.GlobalFunc.SetLockFunction();
		MovieClip(InventoryLists_mc).Lock("L");
		InventoryLists_mc._x = InventoryLists_mc._x - 20;
		
		var _loc4 = Stage.visibleRect.x + Stage.safeRect.x;
		var _loc3 = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		BottomBar_mc.PositionElements(_loc4,_loc3);
		ItemCard_mc._parent._x = (_loc3 + InventoryLists_mc._x + InventoryLists_mc._width) / 2 - ItemCard_mc._parent._width / 2 - 85;
		(MovieClip)(ExitMenuRect).Lock("TL");
		
		ExitMenuRect._x = ExitMenuRect._x - Stage.safeRect.x;
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
		
		RestoreCategoryRect._x = ExitMenuRect._x + InventoryLists_mc.CategoriesList._parent._width;
		ItemsListInputCatcher._x = RestoreCategoryRect._x + RestoreCategoryRect._width;
		ItemsListInputCatcher._width = _root._width - ItemsListInputCatcher._x;

		if (MouseRotationRect != undefined) {
			(MovieClip)(MouseRotationRect).Lock("T");
			MouseRotationRect._x = ItemCard_mc._parent._x;
			MouseRotationRect._width = ItemCard_mc._parent._width;
			MouseRotationRect._height = 0.550000 * Stage.visibleRect.height;
		}
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		_platform = a_platform;
		InventoryLists_mc.setPlatform(a_platform,a_bPS3Switch);
		ItemCard_mc.SetPlatform(a_platform,a_bPS3Switch);
		BottomBar_mc.SetPlatform(a_platform,a_bPS3Switch);
	}

	function GetInventoryItemList()
	{
		return InventoryLists_mc.ItemsList;
	}

	function handleInput(details, pathToFocus)
	{
		if (_bFadedIn) {
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
		for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined; _loc2 = _loc2._parent) {
			if (_loc2 == MouseRotationRect && ShouldProcessItemsListInput(false) || !_bFadedIn && delta == -1) {
				GameDelegate.call("ZoomItemModel",[delta]);
				continue;
			}
			
			if (_loc2 == ItemsListInputCatcher && ShouldProcessItemsListInput(false)) {
				if (delta == 1) {
					InventoryLists_mc.ItemsList.moveSelectionUp();
					continue;
				}
				
				if (delta == -1) {
					InventoryLists_mc.ItemsList.moveSelectionDown();
				}
			}
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
		} else {
			onHideItemsList();
		}
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
		} else {
			GameDelegate.call("DisabledItemSelect",[]);
		}
	}

	function onQuantityMenuSelect(event)
	{
		GameDelegate.call("ItemSelect",[event.amount]);
	}

	function UpdatePlayerInfo(a_updateObj:Object)
	{
		BottomBar_mc.UpdatePlayerInfo(a_updateObj,ItemCard_mc.itemInfo);
	}

	function UpdateItemCardInfo(a_updateObj:Object)
	{
		ItemCard_mc.itemInfo = a_updateObj;
		BottomBar_mc.UpdatePerItemInfo(a_updateObj);
	}

	function onItemCardSubMenuAction(event)
	{
		if (event.opening == true) {
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			InventoryLists_mc.ItemsList.disableSelection = false;
			InventoryLists_mc.ItemsList.disableInput = false;
			InventoryLists_mc.CategoriesList.disableSelection = false;
			InventoryLists_mc.CategoriesList.disableInput = false;
		}
	}

	function ShouldProcessItemsListInput(a_bCheckIfOverRect)
	{
		var _loc4 = _bFadedIn == true && InventoryLists_mc.currentState == InventoryLists.TWO_PANELS && InventoryLists_mc.ItemsList.numUnfilteredItems > 0 && !InventoryLists_mc.ItemsList.disableSelection && !InventoryLists_mc.ItemsList.disableInput;

		if (_loc4 && _platform == 0 && a_bCheckIfOverRect) {
			var _loc2 = Mouse.getTopMostEntity();
			var _loc3 = false;
			while (!_loc3 && _loc2 && _loc2 != undefined)
			{
				if (_loc2 == ItemsListInputCatcher || _loc2 == InventoryLists_mc.ItemsList) {
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
		if (_bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			_bFadedIn = false;
			InventoryLists_mc.ItemsList.disableSelection = true;
			InventoryLists_mc.ItemsList.disableInput = true;
			InventoryLists_mc.CategoriesList.disableSelection = true;
			InventoryLists_mc.CategoriesList.disableInput = true;
		} else {
			_parent.gotoAndPlay("fadeIn");
		}
	}

	function SetFadedIn()
	{
		_bFadedIn = true;
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
		for (var i = 0; i < InventoryLists_mc.CategoriesList.entryList.length; ++i) {
			indices.push(InventoryLists_mc.CategoriesList.entryList[i].savedItemIndex);
		}
		GameDelegate.call("SaveIndices",[indices]);
	}
}