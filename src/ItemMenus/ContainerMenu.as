import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.util.Translator;
import skyui.util.GlobalFunctions;
import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.defines.Item;


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

	private var _equipModeKey: Number;
	private var _equipModeControls: Object;

	private var _tabBarIconArt: Array;

	private var _pauseInputHandling: Boolean;


  /* PROPERTIES */

	// @API
	public var bNPCMode: Boolean = false;

	// @override ItemMenu
	public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

	public function ContainerMenu()
	{
		super();

		_tabBarIconArt = ["take", "give"];
		_pauseInputHandling = false;
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions(): Void
	{
		super.InitExtensions();

		inventoryLists.tabBarIconArt = _tabBarIconArt;

		// Initialize menu-specific list components
		inventoryLists.categoryList.iconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];

		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
    GameDelegate.addCallBack("AttemptTake",this,"AttemptTake");
    GameDelegate.addCallBack("AttemptTakeAll",this,"AttemptTakeAll");
    GameDelegate.addCallBack("AttemptStore",this,"AttemptStore");
    GameDelegate.addCallBack("AttemptTakeAndEquip",this,"AttemptTakeAndEquip");
    GameDelegate.addCallBack("Vanilla_AttemptEquip",this,"Vanilla_AttemptEquip");
    GameDelegate.addCallBack("Vanilla_XButtonPress",this,"Vanilla_XButtonPress");

		itemCardFadeHolder.StealTextInstance._visible = false;
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

		_equipModeKey = a_config["Input"].controls.pc.equipMode;
		_equipModeControls = {keyCode: _equipModeKey};
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
		// Rate limit input handling
		// For some reason, VR trackpad swipe events seem to be sent in duplictes?
		// This means if we're using the trackpad to enable some kind of toggling logic,
		// the toggle would always cancel itself out. To get around this, we...
		//
		// Limit processing of these events to something reasonable.
		if(_pauseInputHandling)
			return false;

		var _this = this;
		_pauseInputHandling = true;
		setTimeout(function() {
				_this._pauseInputHandling = false;
				}, 10);

		// VR specific behavior
		//
		// Currently, we're not getting a whole lot of keycodes from the game. We cannot
		// hookup additional keypresses to UI behavior arbitrarily. However, we can continue
		// to make use of NavigationCode.LEFT and RIGHT.
		//
		// The original SkyUI category list allows the player to wrap around the list. Here,
		// we alter the behavior so that...
		//
		// If we've reached the beginning the category list and the player is still asking to
		// navigate left, switch active segment instead.
		if (details.navEquivalent == NavigationCode.LEFT && inventoryLists.categoryList.selectionAtBeginningOfSegment()) {
			inventoryLists.toggleTab();
			return true;
		}

		super.handleInput(details,pathToFocus);

		if (shouldProcessItemsListInput(false)) {
			if ((_platform == Shared.Platforms.CONTROLLER_PC ||
					 _platform == Shared.Platforms.CONTROLLER_VIVE ||
					 _platform == Shared.Platforms.CONTROLLER_OCULUS ||
					 _platform == Shared.Platforms.CONTROLLER_WINDOWS_MR)
				&& details.skseKeycode == _equipModeKey && inventoryLists.itemList.selectedIndex != -1) {
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
		// Function not present in VR interface file
	}


	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.SetPlatform(a_platform,a_bPS3Switch);

		_bEquipMode = (a_platform != 0);
	}


	// @API
	public function Vanilla_AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean): Void
	{
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;

		if (!shouldProcessItemsListInput(bCheckOverList) || !confirmSelectedEntry())
			return;

		if (_platform == Shared.Platforms.CONTROLLER_PC ||
			  _platform == Shared.Platforms.CONTROLLER_VIVE ||
			  _platform == Shared.Platforms.CONTROLLER_OCULUS ||
			  _platform == Shared.Platforms.CONTROLLER_WINDOWS_MR) {
			if (_bEquipMode)
				startItemEquip(a_slot);
			else
				startItemTransfer();
		} else {
			startItemEquip(a_slot);
		}
	}

	// @API
  function AttemptTake(abCheckOverList)
  {
    var bCheckOverList = abCheckOverList == undefined ? true : abCheckOverList;
    if(shouldProcessItemsListInput(bCheckOverList))
      startItemTransfer();
  }

	// @API
  function AttemptTakeAndEquip(aiSlot, abCheckOverList)
  {
    var bCheckOverList = abCheckOverList == undefined?true:abCheckOverList;
    if(shouldProcessItemsListInput(bCheckOverList))
      startItemEquip(aiSlot);
  }

	// @API
  function AttemptTakeAll()
  {
    if(isViewingContainer() && !bNPCMode)
      GameDelegate.call("TakeAllItems",[]);
  }

	// @API
  function AttemptStore()
  {
    if(!isViewingContainer())
      startItemTransfer();
  }

	// @API
	public function Vanilla_XButtonPress(): Void
	{
		// If we are zoomed into an item, do nothing
		if (!bFadedIn)
			return;

		if (isViewingContainer() && !bNPCMode)
			GameDelegate.call("TakeAllItems",[]);

		// TODO! Is this really required?
		// Present in SE and VR but not in SkyUI.
		// Maybe skyui already takes care of this case elsewhere?
		else if (!isViewingContainer())
			startItemTransfer();
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
		if (event.index != -1)
			updateBottomBar(true);

		super.onItemHighlightChange(event);
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

		bottomBar.updatePerItemInfo({type:Inventory.ICT_NONE});

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

			if (!checkBook(inventoryLists.itemList.selectedEntry))
				checkPoison(inventoryLists.itemList.selectedEntry);

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

		var equipControl = skyui.util.Input.pickControls(_platform, {PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LTRT",ViveArt:"trigger_LR",MoveArt:"PS3_A",OculusArt:"trigger_LR",WindowsMRArt:"trigger_LR"});
		var takeAllControl = skyui.util.Input.pickControls(_platform, {PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X",ViveArt:"radial_Either_Left",MoveArt:"PS3_B",OculusArt:"OCC_Y",WindowsMRArt:"radial_Either_Left"});
		var activateControl = skyui.util.Input.pickControls(_platform, {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"radial_Either_Center",MoveArt:"PS3_MOVE",OculusArt:"OCC_A",WindowsMRArt:"radial_Either_Center"});
		var favoriteControl = skyui.util.Input.pickControls(_platform, {PCArt:"F",XBoxArt:"360_Y",PS3Art:"PS3_Y",ViveArt:"radial_Either_Right",MoveArt:"PS3_Y",OculusArt:"OCC_B",WindowsMRArt:"radial_Either_Right"});

		if (a_bSelected && inventoryLists.itemList.selectedIndex != -1 && inventoryLists.currentState == InventoryLists.SHOW_PANEL) {
			if (isViewingContainer()) {
				if (_platform != 0) {
					navPanel.addButton({text: "$Take", controls: activateControl});
					navPanel.addButton({text: "$Equip", controls: equipControl});
				} else {
					if (_bEquipMode)
						navPanel.addButton({text: "$Equip", controls: equipControl});
					else
						navPanel.addButton({text: "$Take", controls: activateControl});
				}
				if (!bNPCMode)
					navPanel.addButton({text: "$Take All", controls: takeAllControl});
			} else {
				if (_platform != 0) {
					navPanel.addButton({text: bNPCMode ? "$Give" : "$Store", controls: activateControl});
					navPanel.addButton({text: "$Equip", controls: equipControl});
				} else {
					if (_bEquipMode)
						navPanel.addButton({text: "$Equip", controls: equipControl});
					else
						navPanel.addButton({text: bNPCMode ? "$Give" : "$Store", controls: activateControl});
				}

				navPanel.addButton({text: itemCard.itemInfo.favorite ? "$Unfavorite" : "$Favorite", controls: favoriteControl});

			}
			if (!_bEquipMode)
				navPanel.addButton({text: "$Equip Mode", controls: _equipModeControls});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Switch Tab", controls: _switchControls});

			if (isViewingContainer() && !bNPCMode)
				navPanel.addButton({text: "$Take All", controls: takeAllControl});

		}

		navPanel.updateButtons(true);
	}

	private function startItemTransfer(): Void
	{
		if (inventoryLists.itemList.selectedEntry.enabled) {
			// Don't remove. This is so if an item weighs nothing, it takes the whole stack
			//  Gold, for example.
			if (itemCard.itemInfo.weight == 0 && isViewingContainer()) {
				onQuantityMenuSelect({amount:inventoryLists.itemList.selectedEntry.count});
				return;
			}

			if (_quantityMinCount < 1 || (inventoryLists.itemList.selectedEntry.count < _quantityMinCount)) {
				onQuantityMenuSelect({amount:1});
			} else {
				itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
			}
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
		if (!checkBook(inventoryLists.itemList.selectedEntry))
			checkPoison(inventoryLists.itemList.selectedEntry);
	}

	private function isViewingContainer(): Boolean
	{
		return (inventoryLists.categoryList.activeSegment == 0);
	}

	/*
		This method is only used in ContainerMenu.
		If you attempt to use a poison in Container menu
		  a dialog box is presented to ask whether you want to poison the equipped weapon
		  If you release the _equipModeKey while the diaolog is present, the keyUp event
		  for this key is not received by ContainerMenu, so _bEquipMode remains true
		  meaning that the bottom bar buttons are incorrect
	*/
	private function checkPoison(a_entryObject: Object): Boolean
	{
		if (a_entryObject.type != Inventory.ICT_POTION || _global.skse == null)
			return false;

		if (a_entryObject.subType != Item.POTION_POISON)
			return false;

		// force equip mode to false.
		// Use this until we can detect if a specific keyCode is depressed
		// _bEquipMode = skse.IsKeyDown(_equipModeKey)
		_bEquipMode = false;

		return true;
	}
}
