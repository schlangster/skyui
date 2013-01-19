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
		
		if (a_bSelected && (inventoryLists.itemList.selectedEntry.filterFlag & Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS) == 0) {
			navPanel.addButton({text: "$Equip", controls: Input.Equip});
			
			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: Input.YButton});
			else
				navPanel.addButton({text: "$Favorite", controls: Input.YButton});
	
			if (itemCard.itemInfo.showUnlocked)
				navPanel.addButton({text: "$Unlock", controls: Input.XButton});
				
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Inventory", controls: _switchControls});
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