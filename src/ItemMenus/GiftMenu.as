﻿import gfx.io.GameDelegate;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.util.Debug;
import skyui.VRInput;


class GiftMenu extends ItemMenu
{
	#include "../version.as"

  /* PRIVATE VARIABLES */

	private var _bGivingGifts: Boolean = true;

	private var _categoryListIconArt: Array;

	private var vrActionConditions = undefined;

  /* INITIALIZATION */

	public function GiftMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions(): Void
	{
		super.InitExtensions();
		GameDelegate.addCallBack("SetMenuInfo", this, "SetMenuInfo");

		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
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

	// @API
	public function ShowItemsList(): Void
	{
		// Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
		//inventoryLists.showItemsList();
	}

	// @API
	public function SetMenuInfo(a_bGivingGifts: Boolean, a_bUseFavorPoints: Boolean): Void
	{
		_bGivingGifts = a_bGivingGifts;

		if (!a_bUseFavorPoints)
			bottomBar.hidePlayerInfo();
	}

	// @override ItemMenu
	public function UpdatePlayerInfo(a_favorPoints: Number): Void
	{
		bottomBar.setGiftInfo(a_favorPoints);
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onShowItemsList(event: Object): Void
	{
		setupVRInput();
		if(!vrActionConditions) {
			vrActionConditions = VRInput.instance.getActionConditions("GiftMenu");
			if(VRInput.instance.logDetails)
				Debug.dump("vrActionConditions", vrActionConditions);
		}

		// Force select of first category because RestoreIndices isn't called for GiftMenu
		// TODO: Do this in the correct place, i.e. InventoryLists.SetCategoriesList();
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.selectedIndex = 0;
		categoryList.entryList[0].text = "$ALL";
		categoryList.InvalidateData();

		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	private function onItemHighlightChange(event: Object): Void
	{
		super.onItemHighlightChange(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity")
			GameDelegate.call("QuantitySliderOpen", [event.opening]);
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		var activateControls = skyui.util.Input.pickControls(_platform,
				{PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"trigger",MoveArt:"PS3_MOVE",OculusArt:"trigger",WindowsMRArt:"trigger"});

		if (a_bSelected) {
			navPanel.addButton({text: (_bGivingGifts ? "$Give" : "$Take"), controls: activateControls});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: {namedKey: "Action_Up"}});
				navPanel.addButton({text: "$Order", controls: {namedKey: "Action_Double_Up"}});
			}
		}

		navPanel.addButton({
			text: "$Search",
			controls: skyui.util.Input.pickControls(_platform,
																								{PCArt: "Space", ViveArt: "radial_Either_Down",
																								 MoveArt: "PS3_X", OculusArt: "OCC THUMB_REST", WindowsMRArt: "OCC THUMB_REST",
																								 KnucklesArt: "OCC THUMB_REST"})});

		navPanel.updateButtons(true);
	}


	public function handleVRInput(event): Boolean {
		//Debug.dump("GiftMenu::handleVRInput", event);
		if (!bFadedIn)
			return;

		var action = VRInput.instance.triggeredAction(vrActionConditions, event);
		if(action == "search") {
						inventoryLists.searchWidget.startInput();
						return true;
					}
		return false;
	}
}
