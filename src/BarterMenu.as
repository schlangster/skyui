import gfx.io.GameDelegate;

import skyui.InventoryColumnFormatter;
import skyui.BarterDataFetcher;


class BarterMenu extends ItemMenu
{
	private var _playerInfoObj:Object;
	private var _buyMult:Number;
	private var _sellMult:Number;
	private var _confirmAmount:Number;
	private var _selectedCategory:Number;
	private var _playerGold:Number;
	private var _vendorGold:Number;

	var CategoryListIconArt:Array;

	var ColumnFormatter:InventoryColumnFormatter;
	var DataFetcher:BarterDataFetcher;


	function BarterMenu()
	{
		super();
		_buyMult = 1;
		_sellMult = 1;
		_vendorGold = 0;
		_playerGold = 0;
		_confirmAmount = 0;

		CategoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];

		ColumnFormatter = new InventoryColumnFormatter();
		ColumnFormatter.maxTextLength = 80;

		DataFetcher = new BarterDataFetcher();
	}

	function InitExtensions()
	{
		super.InitExtensions();
		GameDelegate.addCallBack("SetBarterMultipliers",this,"SetBarterMultipliers");
		
		ItemCard_mc.addEventListener("messageConfirm",this,"onTransactionConfirm");
		ItemCard_mc.addEventListener("sliderChange",this,"onQuantitySliderChange");
		BottomBar_mc.SetButtonArt({PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"},1);
		BottomBar_mc.Button1.addEventListener("click",this,"onExitButtonPress");
		BottomBar_mc.Button1.disabled = false;

		InventoryLists_mc.CategoriesList.setIconArt(CategoryListIconArt);

		InventoryLists_mc.ItemsList.entryClassName = "ItemsListEntryInv";
		InventoryLists_mc.ItemsList.columnFormatter = ColumnFormatter;
		InventoryLists_mc.ItemsList.dataFetcher = DataFetcher;
		InventoryLists_mc.ItemsList.setConfigSection("ItemList");
	}

	function onExitButtonPress()
	{
		GameDelegate.call("CloseMenu",[]);
	}

	function SetBarterMultipliers(a_buyMult:Number, a_sellMult:Number)
	{
		_buyMult = a_buyMult;
		_sellMult = a_sellMult;
		// set initial multiplier for datafetcher
		InventoryLists_mc.ItemsList.dataFetcher.barterMult = _buyMult;
		BottomBar_mc.SetButtonsText("","$Exit");
	}

	function onShowItemsList(event)
	{
		_selectedCategory = InventoryLists_mc.CategoriesList.selectedIndex;
		
		if (IsViewingVendorItems()) {
			// adjust item values to buy multiplier
			InventoryLists_mc.ItemsList.dataFetcher._barterMult = _buyMult;
			// invalidate data to apply new values
//			InventoryLists_mc.ItemsList.InvalidateData();
		} else {
			// adjust item values to sell multiplier
			InventoryLists_mc.ItemsList.dataFetcher._barterMult = _sellMult;
			// invalidate data to apply new values
//			InventoryLists_mc.ItemsList.InvalidateData();
		}

		super.onShowItemsList(event);
	}
	
	function onItemHighlightChange(event)
	{
		if (event.index != -1) {
			if (IsViewingVendorItems()) {
				BottomBar_mc.SetButtonsText("$Buy","$Exit");
			} else {
				BottomBar_mc.SetButtonsText("$Sell","$Exit");
			}
		}

		super.onItemHighlightChange(event);
	}

	function onHideItemsList(event)
	{
		super.onHideItemsList(event);
		BottomBar_mc.SetButtonsText("","$Exit");
	}

	function IsViewingVendorItems()
	{
		var dividerIndex = InventoryLists_mc.CategoriesList.dividerIndex;
		return dividerIndex != undefined && _selectedCategory < dividerIndex;
	}

	function onQuantityMenuSelect(event)
	{
		var price = event.amount * ItemCard_mc.itemInfo.value;
		if (price > _vendorGold && !IsViewingVendorItems()) {
			_confirmAmount = event.amount;
			GameDelegate.call("GetRawDealWarningString",[price],this,"ShowRawDealWarning");
			return;
		}
		doTransaction(event.amount);
	}

	function ShowRawDealWarning(a_warning:String)
	{
		ItemCard_mc.ShowConfirmMessage(a_warning);
	}

	function onTransactionConfirm()
	{
		doTransaction(_confirmAmount);
		_confirmAmount = 0;
	}

	function doTransaction(a_amount:Number)
	{
		GameDelegate.call("ItemSelect",[a_amount, ItemCard_mc.itemInfo.value, IsViewingVendorItems()]);
	}

	function UpdateItemCardInfo(a_updateObj:Object)
	{
		if (IsViewingVendorItems()) {
			a_updateObj.value = a_updateObj.value * _buyMult;
			a_updateObj.value = Math.max(a_updateObj.value, 1);
		} else {
			a_updateObj.value = a_updateObj.value * _sellMult;
		}
		a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
		ItemCard_mc.itemInfo = a_updateObj;
		BottomBar_mc.SetBarterPerItemInfo(a_updateObj,_playerInfoObj);
	}

	function UpdatePlayerInfo(a_playerGold:Number, a_vendorGold:Number, a_vendorName:String, a_updateObj:Object)
	{
		_vendorGold = a_vendorGold;
		_playerGold = a_playerGold;
		BottomBar_mc.SetBarterInfo(a_playerGold,a_vendorGold,undefined,a_vendorName);
		_playerInfoObj = a_updateObj;
	}

	function onQuantitySliderChange(event)
	{
		var price = ItemCard_mc.itemInfo.value * event.value;
		if (IsViewingVendorItems()) {
			price = price * -1;
		}
		BottomBar_mc.SetBarterInfo(_playerGold,_vendorGold,price);
	}

	function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			if (event.opening) {
				onQuantitySliderChange({value:ItemCard_mc.itemInfo.count});
				return;
			}
			BottomBar_mc.SetBarterInfo(_playerGold,_vendorGold);
		}
	}

}