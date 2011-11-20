import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;

class ContainerMenu extends ItemMenu
{
    static var NULL_HAND = -1;
    static var RIGHT_HAND = 0;
    static var LEFT_HAND = 1;

	var bPCControlsReady = true;
    var ContainerButtonArt;
	var InventoryButtonArt;
	var bNPCMode;
	var bShowEquipButtonHelp;
	var iEquipHand;
	var ShouldProcessItemsListInput;
	
    function ContainerMenu()
    {
        super();
        ContainerButtonArt = [{PCArt: "M1M2", XBoxArt: "360_LTRT", PS3Art: "PS3_LBRB"}, {PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}];
        InventoryButtonArt = [{PCArt: "M1M2", XBoxArt: "360_LTRT", PS3Art: "PS3_LBRB"}, {PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}, {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"}];
        bNPCMode = false;
        bShowEquipButtonHelp = true;
        iEquipHand = undefined;
    }
	
    function InitExtensions()
    {
        super.InitExtensions(false);
        GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
        ItemCardFadeHolder_mc.StealTextInstance._visible = false;
        
		updateButtons();
    }
	
    function ShowItemsList()
    {
        InventoryLists_mc.ShowItemsList(false);
    }
	
    function handleInput(details, pathToFocus)
    {
        super.handleInput(details, pathToFocus);
        if (ShouldProcessItemsListInput(false))
        {
            if (GlobalFunc.IsKeyPressed(details))
            {
                if (details.navEquivalent == NavigationCode.GAMEPAD_X || details.code == 82)
                {
                    if (isViewingContainer() && !bNPCMode)
                    {
                        GameDelegate.call("TakeAllItems", []);
                    }
                    else if (!isViewingContainer())
                    {
                        StartItemTransfer();
                    }
                }
                else if ((details.navEquivalent == NavigationCode.GAMEPAD_Y || details.code == 70) && !isViewingContainer())
                {
                    GameDelegate.call("ToggleFavorite", []);
                }
            }
			
            if (iPlatform == 0 && details.code == 16)
            {
                bShowEquipButtonHelp = details.value != "keyUp";
                updateButtons();
            }
        }
        return (true);
    }
	
    function UpdateItemCardInfo(aUpdateObj)
    {
        super.UpdateItemCardInfo(aUpdateObj);
        updateButtons();
        if (aUpdateObj.pickpocketChance != undefined)
        {
            ItemCardFadeHolder_mc.StealTextInstance._visible = true;
            ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.html = true;
            ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + aUpdateObj.pickpocketChance + "%</font>" + (isViewingContainer() ? (_root.TranslationBass.ToStealTextInstance.text) : (_root.TranslationBass.ToPlaceTextInstance.text));
        }
        else
        {
            ItemCardFadeHolder_mc.StealTextInstance._visible = false;
        }
    }
	
    function onShowItemsList(event)
    {
        updateButtons();
        super.onShowItemsList(event);
    }
	
    function onHideItemsList(event)
    {
        super.onHideItemsList(event);
        BottomBar_mc.UpdatePerItemInfo({type: InventoryDefines.ICT_NONE});
        updateButtons();
    }
	
    function updateButtons()
    {
        BottomBar_mc.SetButtonsArt(isViewingContainer() ? (ContainerButtonArt) : (InventoryButtonArt));
        if (InventoryLists_mc.currentState != InventoryLists.TRANSITIONING_TO_TWO_PANELS && InventoryLists_mc.currentState != InventoryLists.TWO_PANELS)
        {
            BottomBar_mc.SetButtonText("", 0);
            BottomBar_mc.SetButtonText("", 1);
            BottomBar_mc.SetButtonText("", 2);
            BottomBar_mc.SetButtonText("", 3);
        }
        else
        {
            updateEquipButtonText();
            if (isViewingContainer())
            {
                BottomBar_mc.SetButtonText("$Take", 1);
            }
            else
            {
                BottomBar_mc.SetButtonText(!bShowEquipButtonHelp ? (InventoryDefines.GetEquipText(ItemCard_mc.itemInfo.type)) : (""), 1);
            }
			
            if (!isViewingContainer())
            {
                if (bNPCMode)
                {
                    BottomBar_mc.SetButtonText("$Give", 2);
                }
                else
                {
                    BottomBar_mc.SetButtonText("$Store", 2);
                }
            }
            else if (bNPCMode)
            {
                BottomBar_mc.SetButtonText("", 2);
            }
            else if (isViewingContainer())
            {
                BottomBar_mc.SetButtonText("$Take All", 2);
            }
            updateFavoriteText();
        }
    }
	
    function onMouseRotationFastClick(aiMouseButton)
    {
        GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "AttemptEquip");
    }
	
    function updateEquipButtonText()
    {
        BottomBar_mc.SetButtonText(bShowEquipButtonHelp ? (InventoryDefines.GetEquipText(ItemCard_mc.itemInfo.type)) : (""), 0);
    }
	
    function updateFavoriteText()
    {
        if (!isViewingContainer())
        {
            BottomBar_mc.SetButtonText(ItemCard_mc.itemInfo.favorite ? ("$Unfavorite") : ("$Favorite"), 3);
        }
        else
        {
            BottomBar_mc.SetButtonText("", 3);
        }
    }
	
    function isViewingContainer()
    {
        return InventoryLists_mc.CategoriesList.IsSelectionAboveDivider();
    }
	
    function onQuantityMenuSelect(event)
    {
        if (iEquipHand != undefined)
        {
            GameDelegate.call("EquipItem", [iEquipHand, event.amount]);
            iEquipHand = undefined;
        }
        else if (InventoryLists_mc.ItemsList.selectedEntry.enabled)
        {
            GameDelegate.call("ItemTransfer", [event.amount, isViewingContainer()]);
        }
        else
        {
            GameDelegate.call("DisabledItemSelect", []);
        }
    }
	
    function AttemptEquip(aiSlot, abCheckOverList)
    {
        var _loc2 = abCheckOverList != undefined ? (abCheckOverList) : (true);
		
        if (ShouldProcessItemsListInput(_loc2))
        {
            if (iPlatform == 0)
            {
                if (!isViewingContainer() || bShowEquipButtonHelp)
                {
                    StartItemEquip(aiSlot);
                }
                else
                {
                    StartItemTransfer();
                }
            }
            else
            {
                StartItemEquip(aiSlot);
            }
        }
    }
	
    function onItemSelect(event)
    {
        if (event.keyboardOrMouse != 0)
        {
            if (!isViewingContainer())
            {
                StartItemEquip(NULL_HAND);
            }
            else
            {
                StartItemTransfer();
            }
        }
    }
	
    function StartItemTransfer()
    {
        if (ItemCard_mc.itemInfo.weight == 0 && isViewingContainer())
        {
            onQuantityMenuSelect({amount: InventoryLists_mc.ItemsList.selectedEntry.count});
        }
        else if (InventoryLists_mc.ItemsList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
        {
            onQuantityMenuSelect({amount: 1});
        }
        else
        {
            ItemCard_mc.ShowQuantityMenu(InventoryLists_mc.ItemsList.selectedEntry.count);
        }
    }
	
    function StartItemEquip(aiEquipHand)
    {
        if (isViewingContainer())
        {
            iEquipHand = aiEquipHand;
            StartItemTransfer();
        }
        else
        {
            GameDelegate.call("EquipItem", [aiEquipHand]);
        }
    }
	
    function onItemCardSubMenuAction(event)
    {
        super.onItemCardSubMenuAction(event);
		
        if (event.menu == "quantity")
        {
            GameDelegate.call("QuantitySliderOpen", [event.opening]);
        }
    }
	
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        super.SetPlatform(aiPlatform, abPS3Switch);
        iPlatform = aiPlatform;
        bShowEquipButtonHelp = aiPlatform != 0;
        updateButtons();
    }
}
