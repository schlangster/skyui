import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;


class MagicMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */
  
	private var _hideButtonFlag: Number = 0;
	private var _bMenuClosing: Boolean = false;
	private var _bSwitchMenus: Boolean = false;

	private var _magicButtonArt: Object;
	private var _categoryListIconArt: Array;
	
	
  /* PROPERTIES */
  
	public var hideButtonFlag: Number;
	

  /* INITIALIZATION */

	public function MagicMenu()
	{
		super();
		
		_magicButtonArt = [{PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"},
						  {PCArt:"F",XBoxArt:"360_Y", PS3Art:"PS3_Y"},
						  {PCArt:"R",XBoxArt:"360_X", PS3Art:"PS3_X"},
						  {PCArt:"Tab",XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_categoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
							   "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
							   "mag_powers", "mag_activeeffects"];
	}

	public function InitExtensions(): Void
	{
		super.InitExtensions();
		
		GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip", this , "AttemptEquip");
		
		bottomBar.updatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
		
		bottomBar.setButtonsArt(_magicButtonArt);
		
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);
		
		skyui.util.Debug.log("Setting config");
		
		var itemList: TabularList = inventoryLists.itemList;
		itemList.addDataProcessor(new MagicDataExtender());
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Properties"], "magicProperties", "magicIcons", "magicCompoundProperties"));
		
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
			if (details.navEquivalent == NavigationCode.TAB) {
				startMenuFade();
				GameDelegate.call("CloseTweenMenu",[]);
			} else if (!inventoryLists.itemList.disableInput) {
				// Gamepad back || ALT (default) || 'I'
				var bGamepadBackPressed = (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8);
				if (bGamepadBackPressed || (_tabToggleKey && details.code == _tabToggleKey) || details.code == 73)
					openInventoryMenu(true);
			}
		}
		return true;
	}

	// @override ItemMenu
	public function onExitMenuRectClick(): Void
	{
		startMenuFade();
		GameDelegate.call("ShowTweenMenu",[]);
	}

	public function onFadeCompletion(): Void
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
	public function onShowItemsList(event: Object): Void
	{
		super.onShowItemsList(event);
		
		if (event.index != -1)
			updateButtonText();
	}

	// @override ItemMenu
	public function onItemHighlightChange(event: Object)
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1)
			updateButtonText();
	}

	// @API
	public function DragonSoulSpent(): Void
	{
		itemCard.itemInfo.soulSpent = true;
		updateButtonText();
	}


	// @override ItemMenu
	public function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
		
		bottomBar.updatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
	}
	
	// @API
	public function AttemptEquip(a_slot: Number): Void
	{
		if (shouldProcessItemsListInput(true) && confirmSelectedEntry())
			GameDelegate.call("ItemSelect",[a_slot]);
	}

	// @override ItemMenu
	public function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled) {
			if (event.keyboardOrMouse != 0)
				GameDelegate.call("ItemSelect",[]);
			return;
		}
		GameDelegate.call("ShowShoutFail",[]);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
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
	
	private function updateButtonText(): Void
	{
		if (inventoryLists.itemList.selectedEntry != undefined) {
			var favStr = (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag) != 0 ? "$Unfavorite" : "$Favorite";
			var unlockStr = itemCard.itemInfo.showUnlocked ? "$Unlock":"";
			
			if ((inventoryLists.itemList.selectedEntry.filterFlag & _hideButtonFlag) != 0)
				bottomBar.hideButtons();
			else
				bottomBar.setButtonsText("$Equip", favStr, unlockStr);
		}
	}
	
	private function startMenuFade(): Void
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}
}