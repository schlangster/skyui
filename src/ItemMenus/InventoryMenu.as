import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.props.PropertyDataExtender;


class InventoryMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */
  
	private var _bMenuClosing: Boolean = false;
	private var _bSwitchMenus: Boolean = false;

	private var _equipButtonArt: Object;
	private var _altButtonArt: Object;
	private var _chargeButtonArt: Object;
	private var _prevButtonArt: Object;
	private var _itemCardListButtonArt: Array;
	private var _categoryListIconArt: Array;
	
	
  /* PROPERTIES */
  
	// @GFx
	// @Mysterious
	public var bPCControlsReady: Boolean = true;


  /* INITIALIZATION */

	public function InventoryMenu()
	{
		super();
		
		_equipButtonArt = {PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"};
		_altButtonArt = {PCArt:"E", XBoxArt:"360_A", PS3Art:"PS3_A"};
		_chargeButtonArt = {PCArt:"T", XBoxArt:"360_RB", PS3Art:"PS3_RT"};
		_itemCardListButtonArt = [{PCArt:"Enter", XBoxArt:"360_A", PS3Art:"PS3_A"}, {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_prevButtonArt = undefined;
		
		_categoryListIconArt = ["cat_favorites", "inv_all", "inv_weapons", "inv_armor",
							   "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients",
							   "inv_books", "inv_keys", "inv_misc"];
		
		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		GameDelegate.addCallBack("DropItem", this, "DropItem");
		GameDelegate.addCallBack("AttemptChargeItem", this, "AttemptChargeItem");
		GameDelegate.addCallBack("ItemRotating", this, "ItemRotating");
	}
	
	// @override ItemMenu
	public function InitExtensions(): Void
	{		
		super.InitExtensions();

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
		itemList.addDataProcessor(new InventoryDataExtender());
		itemList.addDataProcessor(new PropertyDataExtender("itemProperties", "itemIcons", "itemCompoundProperties", "translateProperties"));
		itemList.layout = ListLayoutManager.instance.getLayoutByName("ItemListLayout");

		itemCard.addEventListener("itemPress", this, "onItemCardListPress");
	}

  /* PUBLIC FUNCTIONS */

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!bFadedIn)
			return true;
		
		var nextClip = pathToFocus.shift();
			
		if (nextClip.handleInput(details, pathToFocus))
			return true;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				startMenuFade();
				GameDelegate.call("CloseTweenMenu", []);
			} else if (!inventoryLists.itemList.disableInput) {
				// Gamepad back || ALT (default) || 'P'
				var bGamepadBackPressed = (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8);
				if (bGamepadBackPressed || (_tabToggleKey && details.code == _tabToggleKey) || details.code == 80)
					openMagicMenu(true);
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

	private function startMenuFade(): Void
	{
		inventoryLists.hideCategoriesList();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}

	public function onFadeCompletion(): Void
	{
		if (!_bMenuClosing)
			return;

		GameDelegate.call("CloseMenu", []);
		if (_bSwitchMenus) {
			GameDelegate.call("CloseTweenMenu",[]);
			skse.OpenMenu("MagicMenu");
		}
	}

	// @override ItemMenu
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
	public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList != undefined ? a_bCheckOverList : true;
		if (shouldProcessItemsListInput(bCheckOverList) && confirmSelectedEntry())
			GameDelegate.call("ItemSelect", [a_slot]);
	}

	// @API
	public function DropItem(): Void
	{
		if (shouldProcessItemsListInput(false) && inventoryLists.itemList.selectedEntry != undefined) {
			if (inventoryLists.itemList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
				onQuantityMenuSelect({amount:1});
			else
				itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
		}
	}

	// @API
	public function AttemptChargeItem(): Void
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
		GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
	}


	public function onMouseRotationFastClick(aiMouseButton: Number): Void
	{
		GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "AttemptEquip");
	}

	public function onItemCardListPress(event: Object): Void
	{
		GameDelegate.call("ItemCardListCallback", [event.index]);
	}

	// @override ItemMenu
	public function onItemCardSubMenuAction(event: Object): Void
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
				GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
				updateBottomBarButtons();
			}
		}
	}

	// @override ItemMenu
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		inventoryLists.zoomButtonHolder.gotoAndStop(1);
		inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
		inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform, a_bPS3Switch);
		
		super.SetPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function ItemRotating(): Void
	{
		inventoryLists.zoomButtonHolder.PlayForward(inventoryLists.zoomButtonHolder._currentframe);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function openMagicMenu(a_bFade: Boolean): Void
	{
		if (a_bFade) {
			_bSwitchMenus = true;
			startMenuFade();
		} else {
			saveIndices();
			GameDelegate.call("CloseMenu",[]);
			GameDelegate.call("CloseTweenMenu",[]);
			skse.OpenMenu("MagicMenu");
		}
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