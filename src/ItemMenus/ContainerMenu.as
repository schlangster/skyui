import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.util.Translator;
import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.props.PropertyDataExtender;


class ContainerMenu extends ItemMenu
{
  /* CONSTANTS */
  
	private static var NULL_HAND: Number = -1;
	private static var RIGHT_HAND: Number = 0;
	private static var LEFT_HAND: Number = 1;


  /* PRIVATE VARIABLES */

	private var _bShowEquipButtonHelp: Boolean = false;
	private var _equipHand: Number;
	private var _equipHelpArt: Object;
	private var _defaultEquipArt: Object;

	private var _containerButtonArt: Object;
	private var _inventoryButtonArt: Object;
	private var _categoryListIconArt: Array;
	private var _tabBarIconArt: Array;
	
	
  /* PROPERTIES */
	
	// @API
	public var bNPCMode: Boolean = false;
	
	// @override ItemMenu
	public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

	public function ContainerMenu()
	{
		super();
		
		_containerButtonArt = [{PCArt: "M1M2", XBoxArt: "360_LTRT", PS3Art: "PS3_LBRB"},
							  {PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"},
							  {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"},
							  {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_inventoryButtonArt = [{PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"},
							   {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"},
							   {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"},
							   {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];

		_defaultEquipArt = {PCArt:"E", XBoxArt:"360_A", PS3Art:"PS3_A"};
		
		_equipHelpArt = {PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"};
		
		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		
		_tabBarIconArt = ["take", "give"];
	}
	
	public function InitExtensions(): Void
	{
		super.InitExtensions();
		
		inventoryLists.tabBarIconArt = _tabBarIconArt;

		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		var itemList: TabularList = inventoryLists.itemList;		
		var entryFormatter = new InventoryEntryFormatter(itemList);
		entryFormatter.maxTextLength = 80;
		itemList.entryFormatter = entryFormatter;
		itemList.addDataProcessor(new InventoryDataExtender());
		itemList.addDataProcessor(new PropertyDataExtender('itemProperties', 'itemIcons', 'itemCompoundProperties', 'translateProperties'));
		itemList.layout = ListLayoutManager.instance.getLayoutByName("ItemListLayout");

		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		GameDelegate.addCallBack("XButtonPress", this, "onXButtonPress");
		itemCardFadeHolder.StealTextInstance._visible = false;
		updateButtons();
	}


  /* PUBLIC FUNCTIONS */

	// @API
	public function ShowItemsList(): Void
	{
		// Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
		//inventoryLists.showItemsList();
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		super.handleInput(details,pathToFocus);

		if (shouldProcessItemsListInput(false)) {
			if (_platform == 0 && details.code == 16 && inventoryLists.itemList.selectedIndex != -1) {
				_bShowEquipButtonHelp = details.value != "keyUp";
				updateButtons();
			}
		}

		return true;
	}

	// @API
	public function onXButtonPress(): Void
	{
		// If we are zoomed into an item, do nothing
		if (!bFadedIn)
			return;
		
		if (isViewingContainer() && !bNPCMode) {
			GameDelegate.call("TakeAllItems",[]);
			return;
		}

		if (isViewingContainer())
			return;

		startItemTransfer();
	}

	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj: Object): Void
	{
		super.UpdateItemCardInfo(a_updateObj);

		updateButtons();

		if (a_updateObj.pickpocketChance != undefined) {
			itemCardFadeHolder.StealTextInstance._visible = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (isViewingContainer() ? Translator.translate("$ TO STEAL") : Translator.translate("$ TO PLACE"));
		} else {
			itemCardFadeHolder.StealTextInstance._visible = false;
		}
	}

	// @override ItemMenu
	public function onItemHighlightChange(event: Object): Void
	{
		updateButtons();
		super.onItemHighlightChange(event);
	}

	// @override ItemMenu
	public function onShowItemsList(event: Object): Void
	{
		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	public function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
		updateButtons();
	}

	public function onMouseRotationFastClick(a_mouseButton:Number): Void
	{
		GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
	}

	public function onQuantityMenuSelect(event: Object): Void
	{
		if (_equipHand != undefined) {
			GameDelegate.call("EquipItem",[_equipHand, event.amount]);
			_equipHand = undefined;
			return;
		}

		if (inventoryLists.itemList.selectedEntry.enabled) {
			GameDelegate.call("ItemTransfer",[event.amount, isViewingContainer()]);
			return;
		}

		GameDelegate.call("DisabledItemSelect",[]);
	}

	// @API
	public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;

		if (shouldProcessItemsListInput(bCheckOverList) && confirmSelectedEntry()) {
			if (_platform == 0) {
				if (!isViewingContainer() || _bShowEquipButtonHelp)
					startItemEquip(a_slot);
				else
					startItemTransfer();
			} else {
				startItemEquip(a_slot);
			}
		}
	}

	public function onItemSelect(event: Object): Void
	{
		if (event.keyboardOrMouse != 0) {
			if (!isViewingContainer())
				startItemEquip(ContainerMenu.NULL_HAND);
			else
				startItemTransfer();
		}
	}

	public function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);

		if (event.menu == "quantity")
			GameDelegate.call("QuantitySliderOpen", [event.opening]);
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.SetPlatform(a_platform,a_bPS3Switch);

		_platform = a_platform;
		_bShowEquipButtonHelp = a_platform != 0;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function hideButtons(): Void
	{
		if (isViewingContainer()) {
			bottomBar.SetButtonText("",0);
			bottomBar.SetButtonText("",1);
			bottomBar.SetButtonText(bNPCMode ? "" : "$Take All",2);
			bottomBar.SetButtonText("$Exit",3);
		} else {
			bottomBar.SetButtonText("",0);
			bottomBar.SetButtonText("",1);
			bottomBar.SetButtonText("",2);
			bottomBar.SetButtonText("$Exit",3);
		}
	}

	private function updateButtons(): Void
	{
		
		if (isViewingContainer())
			bottomBar.SetButtonsArt(_containerButtonArt);
		else
			bottomBar.SetButtonsArt(_inventoryButtonArt);
		
		if (inventoryLists.itemList.selectedIndex == -1 || inventoryLists.currentState != InventoryLists.SHOW_PANEL) {
			hideButtons();
			return;
		}

		if (isViewingContainer()) {
			if (_bShowEquipButtonHelp) {
				bottomBar.SetButtonText(InventoryDefines.GetEquipText(itemCard.itemInfo.type),0);
				bottomBar.SetButtonText("$Take",1);
				bottomBar.SetButtonText(bNPCMode ? "" : "$Take All",2);
			} else {
				bottomBar.SetButtonText("",0);
				bottomBar.SetButtonText("$Take",1);
				bottomBar.SetButtonText(bNPCMode ? "" : "$Take All",2);
			}
			bottomBar.SetButtonText("$Exit",3);
		} else {
			bottomBar.SetButtonArt(_bShowEquipButtonHelp ? _equipHelpArt : _defaultEquipArt,0);
			bottomBar.SetButtonText(InventoryDefines.GetEquipText(itemCard.itemInfo.type),0);
			bottomBar.SetButtonText(bNPCMode ? "$Give" : "$Store",1);
			bottomBar.SetButtonText(itemCard.itemInfo.favorite ? "$Unfavorite" : "$Favorite",2);
			bottomBar.SetButtonText("$Exit",3);
		}
	}

	private function startItemTransfer(): Void
	{
		if (inventoryLists.itemList.selectedEntry.enabled) {
			if (itemCard.itemInfo.weight == 0 && isViewingContainer()) {
				onQuantityMenuSelect({amount:inventoryLists.itemList.selectedEntry.count});
				return;
			}

			if (inventoryLists.itemList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT) {
				onQuantityMenuSelect({amount:1});
				return;
			}

			itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
		}
	}

	private function startItemEquip(a_equipHand: Number): Void
	{
		if (isViewingContainer()) {
			_equipHand = a_equipHand;
			startItemTransfer();
			return;
		}

		GameDelegate.call("EquipItem",[a_equipHand]);
	}
	
	private function isViewingContainer(): Boolean
	{
		return (inventoryLists.categoryList.activeSegment == 0);
	}

}