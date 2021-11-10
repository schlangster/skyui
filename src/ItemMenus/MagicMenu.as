import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.util.Debug;
import skyui.VRInput;

class MagicMenu extends ItemMenu
{
	#include "../version.as"

  /* PRIVATE VARIABLES */

	private var _hideButtonFlag: Number = 0;
	private var _bMenuClosing: Boolean = false;
	private var _bSwitchMenus: Boolean = false;

	private var _categoryListIconArt: Array;


  /* PROPERTIES */

	public var hideButtonFlag: Number;


  /* INITIALIZATION */

	public function MagicMenu()
	{
		super();

		_categoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
							   "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
							   "mag_powers", "mag_activeeffects"];
	}

	public function OnShow() {
		super.OnShow();

		_bMenuClosing = false;
		//iLastItemType = InventoryDefines.ICT_NONE;
		//bottomBar.iLastItemType = Inventory.ICT_NONE;
		/* ResetItemCard({type:Inventory.ICT_SPELL_DEFAULT}); */
		/* itemCard.bFadedIn = false; */
		/* itemCard._visible = false; */
		if(!bFadedIn) {
			inventoryLists.showPanel(false);
			this.ToggleMenuFade();
		}
		/* bottomBar.GoToDefaultFrame(); */
		/* bottomBar.HideButtons(); */
	}

  /* PUBLIC FUNCTIONS */

	public function InitExtensions(): Void
	{
		super.InitExtensions();

		GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip", this , "AttemptEquip");

		bottomBar.updatePerItemInfo({type:Inventory.ICT_SPELL_DEFAULT});

		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		// SkyrimVR moves some variables from the "Interface" section to the "VRUI" section.
		// Originally, SkyUI patched these positions in papyrus scripts to line up with the new UI.
		// It does seem to make sense for this kind of patching to be done from the UI itself though.
		var itemPosXSettingName = "fMagic3DItemPosX:VRUI";
		skse.SetINISetting(itemPosXSettingName, skse.GetINISetting(itemPosXSettingName) - 37);
	}

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);

		var itemList: TabularList = inventoryLists.itemList;
		itemList.addDataProcessor(new MagicDataSetter(a_config["Appearance"]));
		itemList.addDataProcessor(new MagicIconSetter(a_config["Appearance"]));
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "magicProperties", "magicIcons", "magicCompoundProperties"));

		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "MagicListLayout");
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
				GameDelegate.call("CloseTweenMenu",[]);
			} else if (!inventoryLists.itemList.disableInput) {
				// Gamepad back || ALT (default) || 'I'
				if (details.skseKeycode == _switchTabKey || details.control == "Quick Inventory")
					openInventoryMenu(true);
			}
		}
		return true;
	}

	public function classname(): String{
		return "Class MagicMenu";
	}

	public function handleVRInput(event): Boolean {
		if (!bFadedIn)
			return;
		if(event.phaseName == "clicked" && event.eventName == "start") {
			var state = event.curState;
			if(state.widgetName == "touchpad" && VRInput.axisRegion(state.axis) == "bottom") {
				inventoryLists.searchWidget.startInput();
			}
		}
		return false;
	}

	// @API
	public function DragonSoulSpent(): Void
	{
		itemCard.itemInfo.soulSpent = true;
		updateBottomBar();
	}

	// @API
	public function AttemptEquip(a_slot: Number): Void
	{
		if (shouldProcessItemsListInput(true) && confirmSelectedEntry())
			GameDelegate.call("ItemSelect",[a_slot]);
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onItemSelect(event: Object): Void
	{
		//Vanilla bugfix
 		if (event.keyboardOrMouse != 0) {
 			if (event.entry.enabled)
 				GameDelegate.call("ItemSelect",[]);
 			else
 				GameDelegate.call("ShowShoutFail",[]);
 		}
	}

	// @override ItemMenu
	private function onExitMenuRectClick(): Void
	{
		startMenuFade();
		GameDelegate.call("ShowTweenMenu",[]);
	}

	private function onFadeCompletion(): Void
	{
		if (!_bMenuClosing)
			return;

		GameDelegate.call("CloseMenu", []);
		if (_bSwitchMenus) {
			GameDelegate.call("CloseTweenMenu",[]);
			skse.OpenMenu("InventoryMenu");
		}
	}

	// @override ItemMenu
	private function onShowItemsList(event: Object): Void
	{
		super.onShowItemsList(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onItemHighlightChange(event: Object)
	{
		super.onItemHighlightChange(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:Inventory.ICT_SPELL_DEFAULT});

		updateBottomBar(false);
	}

	private function openInventoryMenu(a_bFade: Boolean): Void
	{
		if (a_bFade) {
			_bSwitchMenus = true;
			startMenuFade();
		} else {
			saveIndices();
			GameDelegate.call("CloseMenu",[]);
			GameDelegate.call("CloseTweenMenu",[]);
			skse.OpenMenu("InventoryMenu");
		}
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();

		var activateControls = skyui.util.Input.pickControls(_platform,
				{PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"trigger",MoveArt:"PS3_MOVE",OculusArt:"trigger",WindowsMRArt:"trigger"});
		var exitControls = skyui.util.Input.pickControls(_platform,
				{PCArt:"Tab",XBoxArt:"360_B",PS3Art:"PS3_B",ViveArt:"grip",MoveArt:"PS3_B",OculusArt:"grab",WindowsMRArt:"grab"});
		var favoriteControls = skyui.util.Input.pickControls(_platform,
				{PCArt:"F",XBoxArt:"360_Y",PS3Art:"PS3_Y",ViveArt:"radial_Either_Right",MoveArt:"PS3_Y",OculusArt:"OCC_B",WindowsMRArt:"radial_Either_Right"});
		var unlockControls = skyui.util.Input.pickControls(_platform,
				{PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X",ViveArt:"radial_Either_Left",MoveArt:"PS3_X",OculusArt:"OCC_Y",WindowsMRArt:"radial_Either_Left"});

		if (a_bSelected && (inventoryLists.itemList.selectedEntry.filterFlag & Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS) == 0) {
			navPanel.addButton({text: "$Equip", controls: activateControls});

			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: favoriteControls});
			else
				navPanel.addButton({text: "$Favorite", controls: favoriteControls});

			if (itemCard.itemInfo.showUnlocked)
				navPanel.addButton({text: "$Unlock", controls: unlockControls});

			navPanel.addButton({
				text: "$Search",
				controls: skyui.util.Input.pickControls(_platform,
																									{PCArt: "Space", ViveArt: "radial_Either_Down",
																								 	 MoveArt: "PS3_X", OculusArt: "OCC_X", WindowsMRArt: "radial_Either_Down"})});
		} else {
			// navPanel.addButton({text: "$Exit", controls: _cancelControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: {namedKey: "Action_Up"}});
				navPanel.addButton({text: "$Order", controls: {namedKey: "Action_Double_Up"}});
			}
			// navPanel.addButton({text: "$Inventory", controls: _switchControls});
		}

		navPanel.updateButtons(true);
	}

	private function startMenuFade(): Void
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}
}
