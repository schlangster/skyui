import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;


class InventoryMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */
  
	private var _bMenuClosing:Boolean;

	private var _equipButtonArt: Object;
	private var _altButtonArt: Object;
	private var _chargeButtonArt: Object;
	private var _prevButtonArt: Object;
	private var _itemCardListButtonArt: Array;
	private var _categoryListIconArt: Array;

	// ?
	var bPCControlsReady = true;


	public function InventoryMenu()
	{
		super();
		
		_bMenuClosing = false;
		
		_equipButtonArt = {PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"};
		_altButtonArt = {PCArt:"E", XBoxArt:"360_A", PS3Art:"PS3_A"};
		_chargeButtonArt = {PCArt:"T", XBoxArt:"360_RB", PS3Art:"PS3_RT"};
		_itemCardListButtonArt = [{PCArt:"Enter", XBoxArt:"360_A", PS3Art:"PS3_A"},
								 {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_prevButtonArt = undefined;
		
		_categoryListIconArt = ["cat_favorites", "inv_all", "inv_weapons", "inv_armor",
							   "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients",
							   "inv_books", "inv_keys", "inv_misc"];
		
		GameDelegate.addCallBack("AttemptEquip", this, "attemptEquip");
		GameDelegate.addCallBack("DropItem", this, "dropItem");
		GameDelegate.addCallBack("AttemptChargeItem", this, "attemptChargeItem");
		GameDelegate.addCallBack("ItemRotating", this, "itemRotating");
	}

	// @override ItemMenu
	public function initExtensions(): Void
	{
		super.initExtensions();

		GlobalFunc.AddReverseFunctions();
		
		inventoryLists.zoomButtonHolder.gotoAndStop(1);
		bottomBar.SetButtonArt(_chargeButtonArt, 3);
	
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
		
		var itemList: TabularList = inventoryLists.itemList;		
		var entryFormatter = new InventoryEntryFormatter(itemList);
		entryFormatter.maxTextLength = 80;
		itemList.entryFormatter = entryFormatter;
		itemList.dataFetcher = new InventoryDataFetcher(itemList);
		itemList.layout = ListLayoutManager.instance.getLayoutByName("ItemListLayout");

		itemCard.addEventListener("itemPress", this, "onItemCardListPress");
	}


	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		if (_bFadedIn && !pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
			if (GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.TAB) {
					startMenuFade();
					GameDelegate.call("CloseTweenMenu", []);
				}
			} else if (!inventoryLists.itemList.disableInput) {
				if (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8 && _platform != 0)
					openMagicMenu();
			}
		}
		
		return true;
	}

	// @override ItemMenu
	public function onExitMenuRectClick(): Void
	{
		startMenuFade();
		GameDelegate.call("ShowTweenMenu", []);
	}

	public function startMenuFade(): Void
	{
		inventoryLists.hideCategoriesList();
		toggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}

	public function onFadeCompletion(): Void
	{
		if (_bMenuClosing)
			GameDelegate.call("CloseMenu", []);
	}

	public function onShowItemsList(event: Object): Void
	{
		super.onShowItemsList(event);
		
		if (event.index != -1)
			updateBottomBarButtons();
	}

	public function onItemHighlightChange(event: Object): Void
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1)
			updateBottomBarButtons();
			
	}

	// @override ItemMenu
	public function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
		bottomBar.UpdatePerItemInfo({type:InventoryDefines.ICT_NONE});
	}

	// @override ItemMenu
	public function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled && event.keyboardOrMouse != 0)
			GameDelegate.call("ItemSelect", []);
	}

	// @API
	public function attemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList != undefined ? a_bCheckOverList : true;
		if (shouldProcessItemsListInput(bCheckOverList) && confirmSelectedEntry())
			GameDelegate.call("ItemSelect", [a_slot]);
	}

	// @API
	public function dropItem(): Void
	{
		if (shouldProcessItemsListInput(false) && inventoryLists.itemList.selectedEntry != undefined) {
			if (inventoryLists.itemList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
				onQuantityMenuSelect({amount:1});
			else
				itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
		}
	}

	// @API
	public function attemptChargeItem(): Void
	{
		if (inventoryLists.itemList.selectedIndex == -1)
			return;
		
		if (shouldProcessItemsListInput(false) && itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100)
			GameDelegate.call("ShowSoulGemList", []);
	}

	// @override ItemMenu
	public function onQuantityMenuSelect(event: Object): Void
	{
		GameDelegate.call("ItemDrop", [event.amount]);
		
		// Bug Fix: ItemCard does not update when attempting to drop quest items through the quantity menu
		//   so let's request an update even though it may be redundant.
		GameDelegate.call("RequestItemCardInfo", [], this, "updateItemCardInfo");
	}


	public function onMouseRotationFastClick(aiMouseButton: Number): Void
	{
		GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "attemptEquip");
	}

	public function onItemCardListPress(event: Object): Void
	{
		GameDelegate.call("ItemCardListCallback", [event.index]);
	}

	// @override ItemMenu
	public function onItemCardSubMenuAction(event: Object)
	{
		super.onItemCardSubMenuAction(event);
		GameDelegate.call("QuantitySliderOpen", [event.opening]);
		
		if (event.menu == "list") {
			if (event.opening == true) {
				_prevButtonArt = bottomBar.GetButtonsArt();
				bottomBar.SetButtonsText("$Select", "$Cancel");
				bottomBar.SetButtonsArt(_itemCardListButtonArt);
			} else {
				bottomBar.SetButtonsArt(_prevButtonArt);
				_prevButtonArt = undefined;
				GameDelegate.call("RequestItemCardInfo", [], this, "updateItemCardInfo");
				updateBottomBarButtons();
			}
		}
	}

	// @override ItemMenu
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		inventoryLists.zoomButtonHolder.gotoAndStop(1);
		inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
		inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform, a_bPS3Switch);
		
		super.setPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function itemRotating(): Void
	{
		inventoryLists.zoomButtonHolder.PlayForward(inventoryLists.zoomButtonHolder._currentframe);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	// currently only used for controller users when pressing the BACK button
	private function openMagicMenu(): Void
	{
		saveIndices();
		GameDelegate.call("CloseMenu",[]);
		GameDelegate.call("CloseTweenMenu",[]);
		skse.OpenMenu("Magic Menu");
	}
	
	private function updateBottomBarButtons(): Void
	{
		bottomBar.SetButtonArt(_altButtonArt, 0);
		
		switch (itemCard.itemInfo.type) {
			case InventoryDefines.ICT_ARMOR :
				bottomBar.SetButtonText("$Equip", 0);
				break;

			case InventoryDefines.ICT_BOOK :
				bottomBar.SetButtonText("$Read", 0);
				break;

			case InventoryDefines.ICT_POTION :
				bottomBar.SetButtonText("$Use", 0);
				break;

			case InventoryDefines.ICT_FOOD :
			case InventoryDefines.ICT_INGREDIENT :
				bottomBar.SetButtonText("$Eat", 0);
				break;

			default :
				bottomBar.SetButtonArt(_equipButtonArt, 0);
				bottomBar.SetButtonText("$Equip", 0);
		}


		bottomBar.SetButtonText("$Drop", 1);
		
		if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
			bottomBar.SetButtonText("$Unfavorite", 2);
		else
			bottomBar.SetButtonText("$Favorite", 2);

		if (itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100)
			bottomBar.SetButtonText("$Charge", 3);
		else
			bottomBar.SetButtonText("", 3);
	}
}