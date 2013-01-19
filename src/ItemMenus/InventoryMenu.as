import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Inventory;
import skyui.defines.Input;


class InventoryMenu extends ItemMenu
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */
  
	private var _bMenuClosing: Boolean = false;
	private var _bSwitchMenus: Boolean = false;

	private var _categoryListIconArt: Array;
	
	
  /* PROPERTIES */
  
	// @GFx
	public var bPCControlsReady: Boolean = true;


  /* INITIALIZATION */

	public function InventoryMenu()
	{
		super();
		
		_categoryListIconArt = ["cat_favorites", "inv_all", "inv_weapons", "inv_armor",
							   "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients",
							   "inv_books", "inv_keys", "inv_misc"];
		
		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		GameDelegate.addCallBack("DropItem", this, "DropItem");
		GameDelegate.addCallBack("AttemptChargeItem", this, "AttemptChargeItem");
		GameDelegate.addCallBack("ItemRotating", this, "ItemRotating");
	}


  /* PUBLIC FUNCTIONS */
  
	// @override ItemMenu
	public function InitExtensions(): Void
	{		
		super.InitExtensions();

		GlobalFunc.AddReverseFunctions();
		
		inventoryLists.zoomButtonHolder.gotoAndStop(1);
	
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		itemCard.addEventListener("itemPress", this, "onItemCardListPress");
	}

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);
		
		var itemList: TabularList = inventoryLists.itemList;
		itemList.addDataProcessor(new InventoryDataSetter());
		itemList.addDataProcessor(new InventoryIconSetter(a_config["Appearance"]));
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!bFadedIn)
			return true;
		
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.SHIFT_TAB ) {
				startMenuFade();
				GameDelegate.call("CloseTweenMenu", []);
			} else if (!inventoryLists.itemList.disableInput) {
				// Gamepad back || ALT (default) || 'P'
				if (details.skseKeycode == _switchTabKey || details.control == "Quick Magic")
					openMagicMenu(true);
			}
		}
		
		return true;
	}

	// @API
	public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList != undefined ? a_bCheckOverList : true;
		if (shouldProcessItemsListInput(bCheckOverList) && confirmSelectedEntry()) {
			GameDelegate.call("ItemSelect", [a_slot]);
			checkBook(inventoryLists.itemList.selectedEntry);
		}
	}

	// @API
	public function DropItem(): Void
	{
		if (shouldProcessItemsListInput(false) && inventoryLists.itemList.selectedEntry != undefined) {
			if (_quantityMinCount < 1 || (inventoryLists.itemList.selectedEntry.count < _quantityMinCount))
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
  
	// @override ItemMenu
	private function onExitMenuRectClick(): Void
	{
		startMenuFade();
		GameDelegate.call("ShowTweenMenu", []);
	}

	private function onFadeCompletion(): Void
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
	private function onShowItemsList(event: Object): Void
	{
		super.onShowItemsList(event);
		
		if (event.index != -1)
			updateBottomBar(true);
	}

	private function onItemHighlightChange(event: Object): Void
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1)
			updateBottomBar(true);
			
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:Inventory.ICT_NONE});
		
		updateBottomBar(false);
	}

	// @override ItemMenu
	private function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled && event.keyboardOrMouse != 0) {
			GameDelegate.call("ItemSelect", []);
			checkBook(event.entry);
		}
	}

	// @override ItemMenu
	private function onQuantityMenuSelect(event: Object): Void
	{
		GameDelegate.call("ItemDrop", [event.amount]);
		
		// Bug Fix: ItemCard does not update when attempting to drop quest items through the quantity menu
		//   so let's request an update even though it may be redundant.
		GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
	}


	private function onMouseRotationFastClick(aiMouseButton: Number): Void
	{
		GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "AttemptEquip");
	}

	private function onItemCardListPress(event: Object): Void
	{
		GameDelegate.call("ItemCardListCallback", [event.index]);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);
		GameDelegate.call("QuantitySliderOpen", [event.opening]);
		
		if (event.menu == "list") {
			if (event.opening == true) {
				navPanel.clearButtons();
				navPanel.addButton({text: "$Select", controls: _acceptControls});
				navPanel.addButton({text: "$Cancel", controls: _cancelControls});
				navPanel.updateButtons(true);
			} else {
				GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
				updateBottomBar(true);
			}
		}
	}
	
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
	
	private function startMenuFade(): Void
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}
	
	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();
		
		if (a_bSelected) {
			navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
			navPanel.addButton({text: "$Drop", controls: Input.XButton});
			
			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: Input.YButton});
			else
				navPanel.addButton({text: "$Favorite", controls: Input.YButton});
	
			if (itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100)
				navPanel.addButton({text: "$Charge", controls: Input.ChargeItem});
				
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Magic", controls: _switchControls});
		}
		
		navPanel.updateButtons(true);
	}
}