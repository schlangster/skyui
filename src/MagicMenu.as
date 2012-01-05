import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;

import skyui.MagicColumnFormatter;
import skyui.MagicDataFetcher;


class MagicMenu extends ItemMenu
{
	private var _hideButtonFlag:Number;
	private var _bMenuClosing:Boolean;

	var MagicButtonArt:Object;
	var CategoryListIconArt:Array;

	var ColumnFormatter:MagicColumnFormatter;
	var DataFetcher:MagicDataFetcher;

	// ?
	var bPCControlsReady = true;


	function MagicMenu()
	{
		super();
		_bMenuClosing = false;
		_hideButtonFlag = 0;
		
		_3DIconXSettingStr = "fMagic3DItemPosX:Interface";
		_3DIconZSettingStr = "fMagic3DItemPosZ:Interface";
		_3DIconScaleSettingStr = "fMagic3DItemPosScale:Interface";
		_3DIconWideXSettingStr = "fMagic3DItemPosXWide:Interface";
		_3DIconWideZSettingStr = "fMagic3DItemPosZWide:Interface";
		_3DIconWideScaleSettingStr = "fMagic3DItemPosScaleWide:Interface";
		
		MagicButtonArt = [{PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"},
						  {PCArt:"F",XBoxArt:"360_Y", PS3Art:"PS3_Y"},
						  {PCArt:"R",XBoxArt:"360_X", PS3Art:"PS3_X"},
						  {PCArt:"Tab",XBoxArt:"360_B", PS3Art:"PS3_B"}];
		
		CategoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
							   "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
							   "mag_powers", "mag_activeeffects"];
		
		ColumnFormatter = new MagicColumnFormatter();
		ColumnFormatter.maxTextLength = 80;
		
		DataFetcher = new MagicDataFetcher();
	}

	function InitExtensions()
	{
		super.InitExtensions();
		
		GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip", this , "AttemptEquip");
		
		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
		
		BottomBar_mc.SetButtonsArt(MagicButtonArt);
		
		InventoryLists_mc.CategoriesList.setIconArt(CategoryListIconArt);
		
		InventoryLists_mc.ItemsList.entryClassName = "ItemsListEntryMagic";
		InventoryLists_mc.ItemsList.columnFormatter = ColumnFormatter;
		InventoryLists_mc.ItemsList.dataFetcher = DataFetcher;
		InventoryLists_mc.ItemsList.setConfigSection("MagicList");
	}

	function handleInput(details,pathToFocus)
	{
		if (bFadedIn && ! pathToFocus[0].handleInput(details,pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details)) {
				if (InventoryLists_mc.currentState == InventoryLists.SHOW_PANEL && details.navEquivalent == NavigationCode.RIGHT) {
					StartMenuFade();
					GameDelegate.call("ShowTweenMenu",[]);
				} else if (details.navEquivalent == NavigationCode.TAB) {
					StartMenuFade();
					GameDelegate.call("CloseTweenMenu",[]);
				}
			}
		}
		return true;
	}

	function onExitMenuRectClick()
	{
		StartMenuFade();
		GameDelegate.call("ShowTweenMenu",[]);
	}

	function StartMenuFade()
	{
		InventoryLists_mc.HideCategoriesList();
		ToggleMenuFade();
		SaveIndices();
		_bMenuClosing = true;
	}

	function onFadeCompletion()
	{
		if (_bMenuClosing) {
			GameDelegate.call("CloseMenu",[]);
		}
	}

	function onShowItemsList(event)
	{
		super.onShowItemsList(event);
		
		if (event.index != -1) {
			UpdateButtonText();
		}
	}

	function onItemHighlightChange(event)
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1) {
			UpdateButtonText();
		}
	}

	function DragonSoulSpent()
	{
		ItemCard_mc.itemInfo.soulSpent = true;
		UpdateButtonText();
	}

	function get hideButtonFlag()
	{
		return _hideButtonFlag;
	}

	function set hideButtonFlag(a_hideFlag)
	{
		_hideButtonFlag = a_hideFlag;
	}

	function UpdateButtonText()
	{
		if (InventoryLists_mc.ItemsList.selectedEntry != undefined) {
			var favStr = InventoryLists_mc.ItemsList.selectedEntry.filterFlag & InventoryLists_mc.CategoriesList.entryList[0].flag == 0 ? "$Favorite":"$Unfavorite";
			var unlockStr = ItemCard_mc.itemInfo.showUnlocked == true ? "$Unlock":"";
			
			if (InventoryLists_mc.ItemsList.selectedEntry.filterFlag & _hideButtonFlag != 0) {
				BottomBar_mc.HideButtons();
			} else {
				BottomBar_mc.SetButtonsText("$Equip", favStr, unlockStr);
			}
		}
	}

	function onHideItemsList(event)
	{
		super.onHideItemsList(event);
		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
	}

	function AttemptEquip(aiSlot)
	{
		if (ShouldProcessItemsListInput(true) && ConfirmSelectedEntry()) {
			GameDelegate.call("ItemSelect",[aiSlot]);
		}
	}

	function onItemSelect(event)
	{
		if (event.entry.enabled) {
			if (event.keyboardOrMouse != 0) {
				GameDelegate.call("ItemSelect",[]);
			}
			return;
		}
		GameDelegate.call("ShowShoutFail",[]);
	}
}