import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;

class MagicMenu extends ItemMenu
{
	private var _bMenuClosing:Boolean;
	private var _hideButtonFlag:Number;
	
	private var MagicButtonArt:Object;
	private var _bPCControlsReady = true;

	function MagicMenu()
	{
		super();
		_bMenuClosing = false;
		_hideButtonFlag = 0;
	}

	function InitExtensions()
	{
		super.InitExtensions();
		GameDelegate.addCallBack("DragonSoulSpent",this,"DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
		MagicButtonArt = [{PCArt:"M1M2", XBoxArt:"360_LTRT", PS3Art:"PS3_LBRB"}, {PCArt:"F", XBoxArt:"360_Y", PS3Art:"PS3_Y"}, {PCArt:"R", XBoxArt:"360_X", PS3Art:"PS3_X"}, {PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"}];
		BottomBar_mc.SetButtonsArt(MagicButtonArt);
	}

	function positionElements()
	{
		super.positionElements();
		MovieClip(InventoryLists_mc).Lock("R");
		
		InventoryLists_mc._x = InventoryLists_mc._x + 20;
		var _loc3 = Stage.visibleRect.x + Stage.safeRect.x;
		
		ItemCard_mc._parent._x = (_loc3 + InventoryLists_mc._x - InventoryLists_mc._width) / 2 - ItemCard_mc._parent._width / 2 + 25;
		MovieClip(ExitMenuRect).Lock("TR");
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
		RestoreCategoryRect._x = ExitMenuRect._x - InventoryLists_mc.CategoriesList._parent._width;
		MovieClip(ItemsListInputCatcher).Lock("L");
		ItemsListInputCatcher._x = ItemsListInputCatcher._x - Stage.safeRect.x;
		ItemsListInputCatcher._width = RestoreCategoryRect._x - Stage.visibleRect.x + 10;
	}

	function handleInput(details, pathToFocus)
	{
		if (_bFadedIn && !pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details)) {
				if (InventoryLists_mc.currentState == InventoryLists.ONE_PANEL && details.navEquivalent == NavigationCode.RIGHT) {
					startMenuFade();
					GameDelegate.call("ShowTweenMenu",[]);
				} else if (details.navEquivalent == NavigationCode.TAB) {
					startMenuFade();
					GameDelegate.call("CloseTweenMenu",[]);
				}
			}
		}
		return true;
	}

	function onExitMenuRectClick()
	{
		startMenuFade();
		GameDelegate.call("ShowTweenMenu",[]);
	}

	function startMenuFade()
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
			updateButtonText();
		}
	}

	function onItemHighlightChange(event)
	{
		super.onItemHighlightChange(event);

		if (event.index != -1) {
			updateButtonText();
		}
	}

	function DragonSoulSpent()
	{
		ItemCard_mc.itemInfo.soulSpent = true;
		updateButtonText();
	}

	function get hideButtonFlag()
	{
		return _hideButtonFlag;
	}

	function set hideButtonFlag(a_hideFlag)
	{
		_hideButtonFlag = a_hideFlag;
	}

	function updateButtonText()
	{
		if (InventoryLists_mc.ItemsList.selectedEntry != undefined) {
			var _loc3 = (InventoryLists_mc.ItemsList.selectedEntry.filterFlag & InventoryLists_mc.CategoriesList.entryList[0].flag) != 0 ? ("$Unfavorite") : ("$Favorite");
			var _loc2 = ItemCard_mc.itemInfo.showUnlocked == true ? ("$Unlock") : ("");
			if ((InventoryLists_mc.ItemsList.selectedEntry.filterFlag & _hideButtonFlag) != 0) {
				BottomBar_mc.HideButtons();
			} else {
				BottomBar_mc.SetButtonsText("$Equip",_loc3,_loc2);
			}
		}
	}

	function onHideItemsList(event)
	{
		super.onHideItemsList(event);
		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_SPELL_DEFAULT});
	}

	function AttemptEquip(a_slot)
	{
		if (ShouldProcessItemsListInput(true)) {
			GameDelegate.call("ItemSelect",[a_slot]);
		}
	}

	function onItemSelect(event)
	{
		if (event.entry.enabled) {
			if (event.keyboardOrMouse != 0) {
				GameDelegate.call("ItemSelect",[]);
			}
		} else {
			GameDelegate.call("ShowShoutFail",[]);
		}
	}
}