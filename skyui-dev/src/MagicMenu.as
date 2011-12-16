import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;

class MagicMenu extends ItemMenu
{
	var bMenuClosing;
	var iHideButtonFlag;
	var MagicButtonArt;
	var ToggleMenuFade;
	var SaveIndices;
	var ShouldProcessItemsListInput;
	var bPCControlsReady = true;
	
	function MagicMenu()
	{
		super();
		bMenuClosing = false;
		iHideButtonFlag = 0;
	}
	
	function InitExtensions()
	{
		super.InitExtensions();
		GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		BottomBar_mc.UpdatePerItemInfo({type: InventoryDefines.ICT_SPELL_DEFAULT});
		MagicButtonArt = [{PCArt: "M1M2", XBoxArt: "360_LTRT", PS3Art: "PS3_LBRB"}, {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}, {PCArt: "Tab", XBoxArt: "360_B", PS3Art: "PS3_B"}];
		BottomBar_mc.SetButtonsArt(MagicButtonArt);	
	}

   /* Unusued to force MagicMenu to use same positioning as Inventory
	   function PositionElements()
	{
		super.PositionElements();
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
	}*/
	
	function handleInput(details, pathToFocus)
	{
		if (bFadedIn && !pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
		{
			if (Shared.GlobalFunc.IsKeyPressed(details))
			{
				// Change navigation to LEFT since menu is on left now
				if (InventoryLists_mc.currentState == InventoryLists.ONE_PANEL && details.navEquivalent == NavigationCode.LEFT)
				{
					StartMenuFade();
					GameDelegate.call("ShowTweenMenu", []);
				}
				else if (details.navEquivalent == NavigationCode.TAB)
				{
					StartMenuFade();
					GameDelegate.call("CloseTweenMenu", []);
				}
			} 
		}
		return (true);
	}
	
	function onExitMenuRectClick()
	{
		StartMenuFade();
		GameDelegate.call("ShowTweenMenu", []);
	}
	
	function StartMenuFade()
	{
		InventoryLists_mc.HideCategoriesList();
		ToggleMenuFade();
		SaveIndices();
		bMenuClosing = true;
	}
	
	function onFadeCompletion()
	{
		if (bMenuClosing)
		{
			GameDelegate.call("CloseMenu", []);
		}
	}
	
	function onShowItemsList(event)
	{
		super.onShowItemsList(event);
		
		if (event.index != -1)
		{
			UpdateButtonText();
		}
	}
	
	function onItemHighlightChange(event)
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1)
		{
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
		return (iHideButtonFlag);
	}
	
	function set hideButtonFlag(aiHideFlag)
	{
		iHideButtonFlag = aiHideFlag;
	}
	
	function UpdateButtonText()
	{
		if (InventoryLists_mc.ItemsList.selectedEntry != undefined)
		{
			var _loc3 = (InventoryLists_mc.ItemsList.selectedEntry.filterFlag & InventoryLists_mc.CategoriesList.entryList[0].flag) != 0 ? ("$Unfavorite") : ("$Favorite");
			var _loc2 = ItemCard_mc.itemInfo.showUnlocked == true ? ("$Unlock") : ("");
			if ((InventoryLists_mc.ItemsList.selectedEntry.filterFlag & iHideButtonFlag) != 0)
			{
				BottomBar_mc.HideButtons();
			}
			else
			{
				BottomBar_mc.SetButtonsText("$Equip", _loc3, _loc2);
			}
		}
	}
	
	function onHideItemsList(event)
	{
		super.onHideItemsList(event);
		BottomBar_mc.UpdatePerItemInfo({type: InventoryDefines.ICT_SPELL_DEFAULT});
	}
	
	function AttemptEquip(aiSlot)
	{
		if (ShouldProcessItemsListInput(true))
		{
			GameDelegate.call("ItemSelect", [aiSlot]);
		} 
	}
	
	function onItemSelect(event)
	{
		if (event.entry.enabled)
		{
			if (event.keyboardOrMouse != 0)
			{
				GameDelegate.call("ItemSelect", []);
			} 
		}
		else
		{
			GameDelegate.call("ShowShoutFail", []);
		} 
	}
}
