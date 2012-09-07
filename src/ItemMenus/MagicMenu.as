import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.props.PropertyDataExtender;


class MagicMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */
  
	private var _hideButtonFlag: Number = 0;
	private var _bMenuClosing: Boolean = false;

	private var _magicButtonArt: Object;
	private var _categoryListIconArt: Array;
	
	
  /* PROPERTIES */
  
	public var hideButtonFlag: Number;
	

  /* CONSTRUCTORS */

	public function MagicMenu()
	{
		super();
		
		_3DIconXSettingStr = "fMagic3DItemPosX:Interface";
		_3DIconZSettingStr = "fMagic3DItemPosZ:Interface";
		_3DIconScaleSettingStr = "fMagic3DItemPosScale:Interface";
		_3DIconWideXSettingStr = "fMagic3DItemPosXWide:Interface";
		_3DIconWideZSettingStr = "fMagic3DItemPosZWide:Interface";
		_3DIconWideScaleSettingStr = "fMagic3DItemPosScaleWide:Interface";
		
		_magicButtonArt = [{PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"},
						  {PCArt:"F",XBoxArt:"360_Y", PS3Art:"PS3_Y"},
						  {PCArt:"R",XBoxArt:"360_X", PS3Art:"PS3_X"},
						  {PCArt:"Tab",XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		_categoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
							   "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
							   "mag_powers", "mag_activeeffects"];
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function InitExtensions(): Void
	{
		super.InitExtensions();
		
		GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip", this , "AttemptEquip");
		
		bottomBar.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
		
		bottomBar.SetButtonsArt(_magicButtonArt);
		
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
		
		var itemList: TabularList = inventoryLists.itemList;
		var entryFormatter = new InventoryEntryFormatter(itemList);
		entryFormatter.maxTextLength = 80;
		itemList.entryFormatter = entryFormatter;
		itemList.addDataProcessor(new MagicDataExtender());
		itemList.addDataProcessor(new PropertyDataExtender('magicProperties', 'magicIcons', 'magicCompoundProperties', 'translateProperties'));
		itemList.layout = ListLayoutManager.instance.getLayoutByName("MagicListLayout");
	}

	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		if (bFadedIn && ! pathToFocus[0].handleInput(details,pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details)) {
				if (inventoryLists.currentState == InventoryLists.SHOW_PANEL && details.navEquivalent == NavigationCode.RIGHT) {
					startMenuFade();
					GameDelegate.call("ShowTweenMenu",[]);
				} else if (details.navEquivalent == NavigationCode.TAB) {
					startMenuFade();
					GameDelegate.call("CloseTweenMenu",[]);
				} else if (!inventoryLists.itemList.disableInput)  {
					if (details.navEquivalent == NavigationCode.GAMEPAD_BACK && details.code != 8 && _platform != 0)
						openInventoryMenu();
				}
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
		if (_bMenuClosing)
			GameDelegate.call("CloseMenu",[]);
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
		
		bottomBar.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
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
	
	// currently only used for controller users when pressing the BACK button
	private function openInventoryMenu(): Void
	{
		saveIndices();
		GameDelegate.call("CloseMenu",[]);
		GameDelegate.call("CloseTweenMenu",[]);
		skse.OpenMenu("Inventory Menu");
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function updateButtonText(): Void
	{
		if (inventoryLists.itemList.selectedEntry != undefined) {
			var favStr = (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag) != 0 ? "$Unfavorite" : "$Favorite";
			var unlockStr = itemCard.itemInfo.showUnlocked ? "$Unlock":"";
			
			if ((inventoryLists.itemList.selectedEntry.filterFlag & _hideButtonFlag) != 0)
				bottomBar.HideButtons();
			else
				bottomBar.SetButtonsText("$Equip", favStr, unlockStr);
		}
	}
	
	private function startMenuFade(): Void
	{
		inventoryLists.hideCategoriesList();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}
}