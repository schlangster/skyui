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
import skyui.util.Debug;
import skyui.VRInput;

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

	private var vrActionConditions = undefined;


	public function OnShow()
	{
		super.OnShow();
		if(!vrActionConditions) {
			vrActionConditions = VRInput.instance.getActionConditions("InventoryMenu");
			if(VRInput.instance.logDetails)
				Debug.dump("vrActionConditions", vrActionConditions);
		}

		_bMenuClosing = false;
		// TODO! Cleanup these lines ported from SkyrimVR
		//this.iLastItemType = InventoryDefines.ICT_NONE;
		//bottomBar._lastItemType = Inventory.ICT_NONE;
		//ResetItemCard();
		//itemCard.bFadedIn = false;
		//itemCard._visible = false;
		//inventoryLists.showItemsList();
		if(!this.bFadedIn)
		{
			inventoryLists.showPanel(false);
			itemCard.FadeInCard();
			ToggleMenuFade();
		}
		//bottomBar.GoToDefaultFrame();
		//bottomBar.buttonPanel.hideButtons();
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
	public function closeMenu(): Void
	{
		var list = inventoryLists.itemList.listEnumeration;
		for(var i = 0; i < list.size(); i++) {
			var item = list.at(i);
			if(item.newItem) {
				var skyui_funcs = skse["plugins"]["skyui"];
				if(skyui_funcs) {
					skyui_funcs.FormDB_RemoveField(item.formId, "skyui/newItem");
				}
			}
		}
		super.closeMenu();
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

		inventoryLists.itemList.listState.layout = layout;
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

	public function classname(): String{
		return "Class Inventorymenu";
	}

	public function handleVRInput(event): Boolean {
		//Debug.dump("InventoryMenu::handleVRInput", event);
		if (!bFadedIn)
			return;

		var action = VRInput.instance.triggeredAction(vrActionConditions, event);
		if(action == "search") {
						inventoryLists.searchWidget.startInput();
						return true;
					}

		return false;
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

		closeMenu();
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
		{
			updateBottomBar(true);
			GameDelegate.call("SetShowingItemsList",[1]);
		}
	}

	public function logAllItems() {
		var itemList = inventoryLists.itemList;
		var entryList: Array = itemList.entryList;
		for (var i: Number = 0; i < entryList.length; i++) {
			var obj = entryList[i];
			Debug.dump("inv item", obj);
		}
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
		GameDelegate.call("SetShowingItemsList",[0]);
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
			closeMenu();
			GameDelegate.call("CloseTweenMenu",[]);
			skse.OpenMenu("MagicMenu");
		}
	}

	private function startMenuFade(): Void
	{
		inventoryLists.hidePanel();
		itemCard.FadeOutCard();
		//onHideItemsList({});
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		if (a_bSelected) {
			// Setup the main action button
			var equipArt = {PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LTRT", ViveArt: "trigger_LR",
				MoveArt:"PS3_MOVE", OculusArt: "trigger_LR", WindowsMRArt: "trigger_LR"};
      var useItemArt = {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"trigger",MoveArt:"PS3_MOVE",OculusArt:"trigger",WindowsMRArt:"trigger"};

			var actionText = undefined;
			var actionArt = undefined;
			switch(itemCard.itemInfo.type)
			{
				case Inventory.ICT_BOOK:
					actionText = "$Read";
					actionArt = useItemArt;
					break;
				case Inventory.ICT_POTION:
					actionText = "$Use";
					actionArt = useItemArt;
					break;
				case Inventory.ICT_FOOD:
				case Inventory.ICT_INGREDIENT:
					actionText = "$Eat";
					actionArt = useItemArt;
					break;
				case Inventory.ICT_ARMOR:
				case Inventory.ICT_WEAPON:
					actionText = "$Equip";
					actionArt = equipArt;
					break;
			}

			if (actionArt != undefined)
				navPanel.addButton({text: actionText, controls: skyui.util.Input.pickControls(_platform, actionArt)});

			navPanel.addButton({
				text: "$Drop",
				controls: skyui.util.Input.pickControls(_platform,
						{PCArt:"R", XBoxArt: "360_X", PS3Art: "PS3_X", ViveArt: "radial_Either_Up",
						 MoveArt: "PS3_A", OculusArt: "OCC_X", WindowsMRArt: "radial_Either_Up"}) });

			// Add the Favorite/Unfavorite button
			var favoriteControl = skyui.util.Input.pickControls(_platform,
																													{PCArt:"F", XBoxArt:"360_Y", PS3Art:"PS3_Y", ViveArt:"radial_Either_Right",
																													 MoveArt:"PS3_Y", OculusArt:"OCC_B", WindowsMRArt:"radial_Either_Right"});
			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: favoriteControl});
			else
				navPanel.addButton({text: "$Favorite", controls: favoriteControl});

			if (itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100) {
				navPanel.addButton({
					text: "$Charge",
					controls: skyui.util.Input.pickControls(_platform,
																									{PCArt: "T", XBoxArt: "360_RB", PS3Art: "PS3_RB", ViveArt: "radial_Either_Left",
																								 	 MoveArt: "PS3_X", OculusArt: "OCC_Y", WindowsMRArt: "radial_Either_Left"})
					});
			}
		} else {
			// navPanel.addButton({text: "$Exit", controls: _cancelControls});
			// navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: {namedKey: "Action_Up"}});
				navPanel.addButton({text: "$Order", controls: {namedKey: "Action_Double_Up"}});
			}
			// navPanel.addButton({text: "$Magic", controls: _switchControls});
		}

		navPanel.addButton({
			text: "$Search",
			controls: skyui.util.Input.pickControls(_platform,
																								{PCArt: "Space", ViveArt: "radial_Either_Down",
																								 MoveArt: "PS3_X", OculusArt: "OCC THUMB_REST", WindowsMRArt: "OCC THUMB_REST",
																								 KnucklesArt: "OCC THUMB_REST"})});

		navPanel.updateButtons(true);
	}
}
