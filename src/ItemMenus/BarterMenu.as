import gfx.io.GameDelegate;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;


class BarterMenu extends ItemMenu
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */
  
	private var _buyMult: Number = 1;
	private var _sellMult: Number = 1;
	private var _confirmAmount: Number = 0;
	private var _playerGold: Number = 0;
	private var _vendorGold: Number = 0;

	private var _categoryListIconArt: Array;
	private var _tabBarIconArt: Array;
	
	
  /* PROPERTIES */
	
	// @override ItemMenu
	public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

	public function BarterMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		_tabBarIconArt = ["buy", "sell"];
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function InitExtensions(): Void
	{
		super.InitExtensions();
		GameDelegate.addCallBack("SetBarterMultipliers", this, "SetBarterMultipliers");
		
		itemCard.addEventListener("messageConfirm",this,"onTransactionConfirm");
		itemCard.addEventListener("sliderChange",this,"onQuantitySliderChange");
		
		inventoryLists.tabBarIconArt = _tabBarIconArt;
		
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);

		var itemList: TabularList = inventoryLists.itemList;		
		itemList.addDataProcessor(new BarterDataSetter(_buyMult, _sellMult));
		itemList.addDataProcessor(new InventoryIconSetter(a_config["Appearance"]));
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
	}

	private function onExitButtonPress(): Void
	{
		GameDelegate.call("CloseMenu",[]);
	}

	// @API
	public function SetBarterMultipliers(a_buyMult: Number, a_sellMult: Number): Void
	{
		_buyMult = a_buyMult;
		_sellMult = a_sellMult;
	}

	// @API
	public function ShowRawDealWarning(a_warning: String): Void
	{
		itemCard.ShowConfirmMessage(a_warning);
	}
	
	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj: Object): Void
	{
		if (isViewingVendorItems()) {
			a_updateObj.value = a_updateObj.value * _buyMult;
			a_updateObj.value = Math.max(a_updateObj.value, 1);
		} else {
			a_updateObj.value = a_updateObj.value * _sellMult;
		}
		a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
		itemCard.itemInfo = a_updateObj;
		bottomBar.updateBarterPerItemInfo(a_updateObj);
	}

	// @override ItemMenu
	public function UpdatePlayerInfo(a_playerGold: Number, a_vendorGold: Number, a_vendorName: String, a_playerUpdateObj: Object): Void
	{
		_vendorGold = a_vendorGold;
		_playerGold = a_playerGold;
		bottomBar.updateBarterInfo(a_playerUpdateObj, itemCard.itemInfo, a_playerGold, a_vendorGold, a_vendorName);
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	// @override ItemMenu
	private function onShowItemsList(event: Object): Void
	{
		inventoryLists.showItemsList();

		//super.onShowItemsList(event);
	}

	// @override ItemMenu
	private function onItemHighlightChange(event: Object): Void
	{
		if (event.index != -1)
			updateBottomBar(true);

		super.onItemHighlightChange(event);
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);

		bottomBar.updateBarterPerItemInfo({type:Inventory.ICT_NONE});
		
		updateBottomBar(false);
	}
	
	private function onQuantitySliderChange(event: Object): Void
	{
		var price = itemCard.itemInfo.value * event.value;
		if (isViewingVendorItems()) {
			price = price * -1;
		}
		bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold, itemCard.itemInfo, price);
	}
	
	// @override ItemMenu
	private function onQuantityMenuSelect(event: Object): Void
	{
		var price = event.amount * itemCard.itemInfo.value;
		if (price > _vendorGold && !isViewingVendorItems()) {
			_confirmAmount = event.amount;

			GameDelegate.call("GetRawDealWarningString", [price], this, "ShowRawDealWarning");

			bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold, itemCard.itemInfo, price);
			return;
		}
		doTransaction(event.amount);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			if (event.opening) {
				onQuantitySliderChange({value:itemCard.itemInfo.count});
				return;
			}
			bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold);
		}
	}
	
	private function onTransactionConfirm(): Void
	{
		doTransaction(_confirmAmount);
		_confirmAmount = 0;
	}
	
	private function doTransaction(a_amount: Number): Void
	{
		GameDelegate.call("ItemSelect",[a_amount, itemCard.itemInfo.value, isViewingVendorItems()]);
		// Update barter multipliers
		// Update itemList => dataProcessor => BarterDataSetter updateBarterMultipliers
		// Update itemCardInfo GameDelegate.call("RequestItemCardInfo",[], this, "UpdateItemCardInfo");
	}
	
	private function isViewingVendorItems(): Boolean
	{
		return inventoryLists.categoryList.activeSegment == 0;
	}
	
	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();
		
		if (a_bSelected) {
			navPanel.addButton({text: (isViewingVendorItems() ? "$Buy" : "$Sell"), controls: Input.Activate});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Switch Tab", controls: _switchControls});
		}
		
		navPanel.updateButtons(true);
	}

}