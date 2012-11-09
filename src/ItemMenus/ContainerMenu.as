import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.util.Translator;
import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;


class ContainerMenu extends ItemMenu
{
	#include "../version.as"
	
  /* CONSTANTS */
  
	private static var NULL_HAND: Number = -1;
	private static var RIGHT_HAND: Number = 0;
	private static var LEFT_HAND: Number = 1;


  /* PRIVATE VARIABLES */

	private var _bEquipMode: Boolean = false;
	private var _equipHand: Number;
	
	private var _equipModeControls: Array;
	
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
		
		_equipModeControls = [{keyCode: 42}];
		
		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		
		_tabBarIconArt = ["take", "give"];
	}


  /* PUBLIC FUNCTIONS */
  
	public function InitExtensions(): Void
	{
		super.InitExtensions();
		
		inventoryLists.tabBarIconArt = _tabBarIconArt;

		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		GameDelegate.addCallBack("XButtonPress", this, "onXButtonPress");
		itemCardFadeHolder.StealTextInstance._visible = false;
	}

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);
		
		var itemList: TabularList = inventoryLists.itemList;		
		itemList.addDataProcessor(new InventoryDataExtender());
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
	}

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
				_bEquipMode = details.value != "keyUp";
				updateBottomBar(true);
			}
		}

		return true;
	}

	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj: Object): Void
	{
		super.UpdateItemCardInfo(a_updateObj);

		updateBottomBar(true);

		if (a_updateObj.pickpocketChance != undefined) {
			itemCardFadeHolder.StealTextInstance._visible = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (isViewingContainer() ? Translator.translate("$ TO STEAL") : Translator.translate("$ TO PLACE"));
		} else {
			itemCardFadeHolder.StealTextInstance._visible = false;
		}
	}

	// @API
	public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;
		
		if (!shouldProcessItemsListInput(bCheckOverList) || !confirmSelectedEntry())
			return;
			
		if (_platform == 0) {
			if (_bEquipMode)
				startItemEquip(a_slot);
			else
				startItemTransfer();
		} else {
			startItemEquip(a_slot);
		}
	}

	// @API
	public function onXButtonPress(): Void
	{
		// If we are zoomed into an item, do nothing
		if (!bFadedIn)
			return;
		
		if (isViewingContainer() && !bNPCMode)
			GameDelegate.call("TakeAllItems",[]);
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.SetPlatform(a_platform,a_bPS3Switch);
		
		_bEquipMode = a_platform != 0;
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onItemSelect(event: Object): Void
	{
		if (event.keyboardOrMouse != 0) {
			if (_platform == 0 && _bEquipMode)
				startItemEquip(ContainerMenu.NULL_HAND);
			else
				startItemTransfer();
		}
	}

	private function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);

		if (event.menu == "quantity")
			GameDelegate.call("QuantitySliderOpen", [event.opening]);
	}
  
	// @override ItemMenu
	private function onItemHighlightChange(event: Object): Void
	{
		super.onItemHighlightChange(event);
		updateBottomBar(true);
	}

	// @override ItemMenu
	private function onShowItemsList(event: Object): Void
	{
		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
		updateBottomBar(false);
	}

	private function onMouseRotationFastClick(a_mouseButton:Number): Void
	{
		GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
	}

	private function onQuantityMenuSelect(event: Object): Void
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
	
	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();
		
		if (a_bSelected && inventoryLists.itemList.selectedIndex != -1 && inventoryLists.currentState == InventoryLists.SHOW_PANEL) {
			if (isViewingContainer()) {
				if (_platform != 0) {
					navPanel.addButton({text: "$Take", controls: InputDefines.Activate});
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type, true));
				} else {
					if (_bEquipMode)
						navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
					else
						navPanel.addButton({text: "$Take", controls: InputDefines.Activate});
				}
				if (!bNPCMode)
					navPanel.addButton({text: "$Take All", controls: InputDefines.XButton});
			} else {
				if (_platform != 0) {
					navPanel.addButton({text: bNPCMode ? "$Give" : "$Store", controls: InputDefines.Activate});
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type, true));
				} else {
					if (_bEquipMode)
						navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
					else
						navPanel.addButton({text: bNPCMode ? "$Give" : "$Store", controls: InputDefines.Activate});
				}

				navPanel.addButton({text: itemCard.itemInfo.favorite ? "$Unfavorite" : "$Favorite", controls: InputDefines.YButton});
			}
			if (!_bEquipMode)
				navPanel.addButton({text: "$Equip Mode", controls: _equipModeControls});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: InputDefines.SortColumn});
				navPanel.addButton({text: "$Order", controls: InputDefines.SortOrder});
			}
			navPanel.addButton({text: "$Switch Tab", controls: _switchControls});
			
			if (isViewingContainer() && !bNPCMode)
				navPanel.addButton({text: "$Take All", controls: InputDefines.XButton});			

		}
		
		navPanel.updateButtons(true);
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