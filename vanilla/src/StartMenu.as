dynamic class StartMenu extends MovieClip
{
    static var PRESS_START_STATE: String = "PressStart";
    static var MAIN_STATE: String = "Main";
    static var MAIN_CONFIRM_STATE: String = "MainConfirm";
    static var SAVE_LOAD_STATE: String = "SaveLoad";
    static var SAVE_LOAD_CONFIRM_STATE: String = "SaveLoadConfirm";
    static var DELETE_SAVE_CONFIRM_STATE: String = "DeleteSaveConfirm";
    static var DLC_STATE: String = "DLC";
    static var MARKETPLACE_CONFIRM_STATE: String = "MarketplaceConfirm";
    static var CONTINUE_INDEX: Number = 0;
    static var NEW_INDEX: Number = 1;
    static var LOAD_INDEX: Number = 2;
    static var DLC_INDEX: Number = 3;
    static var CREDITS_INDEX: Number = 4;
    static var QUIT_INDEX: Number = 5;
    var ButtonRect;
    var ConfirmPanel_mc;
    var DLCList_mc;
    var DLCPanel;
    var DeleteButton;
    var DeleteSaveButton;
    var LoadingContentMessage;
    var Logo_mc;
    var MainList;
    var MainListHolder;
    var MarketplaceButton;
    var SaveLoadConfirmText;
    var SaveLoadListHolder;
    var SaveLoadPanel_mc;
    var VersionText;
    var _parent;
    var fadeOutParams;
    var gotoAndPlay;
    var iLoadDLCContentMessageTimerID;
    var iLoadDLCListTimerID;
    var iPlatform;
    var strCurrentState;
    var strFadeOutCallback;

    function StartMenu()
    {
        super();
        this.MainList = this.MainListHolder.List_mc;
        this.SaveLoadListHolder = this.SaveLoadPanel_mc;
        this.DLCList_mc = this.DLCPanel.DLCList;
        this.DeleteSaveButton = this.DeleteButton;
        this.MarketplaceButton = this.DLCPanel.MarketplaceButton;
    }

    function InitExtensions()
    {
        Shared.GlobalFunc.SetLockFunction();
        this._parent.Lock("BR");
        this.Logo_mc.Lock("BL");
        this.Logo_mc._y = this.Logo_mc._y - 80;
        gfx.io.GameDelegate.addCallBack("sendMenuProperties", this, "setupMainMenu");
        gfx.io.GameDelegate.addCallBack("ConfirmNewGame", this, "ShowConfirmScreen");
        gfx.io.GameDelegate.addCallBack("ConfirmContinue", this, "ShowConfirmScreen");
        gfx.io.GameDelegate.addCallBack("FadeOutMenu", this, "DoFadeOutMenu");
        gfx.io.GameDelegate.addCallBack("FadeInMenu", this, "DoFadeInMenu");
        gfx.io.GameDelegate.addCallBack("onProfileChange", this, "onProfileChange");
        gfx.io.GameDelegate.addCallBack("StartLoadingDLC", this, "StartLoadingDLC");
        gfx.io.GameDelegate.addCallBack("DoneLoadingDLC", this, "DoneLoadingDLC");
        this.MainList.addEventListener("itemPress", this, "onMainButtonPress");
        this.MainList.addEventListener("listPress", this, "onMainListPress");
        this.MainList.addEventListener("listMovedUp", this, "onMainListMoveUp");
        this.MainList.addEventListener("listMovedDown", this, "onMainListMoveDown");
        this.MainList.addEventListener("selectionChange", this, "onMainListMouseSelectionChange");
        this.ButtonRect.handleInput = function ()
        {
            return false;
        }
        ;
        this.ButtonRect.AcceptMouseButton.addEventListener("click", this, "onAcceptMousePress");
        this.ButtonRect.CancelMouseButton.addEventListener("click", this, "onCancelMousePress");
        this.ButtonRect.AcceptMouseButton.SetPlatform(0, false);
        this.ButtonRect.CancelMouseButton.SetPlatform(0, false);
        this.SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
        this.SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
        this.SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
        this.SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");
        this.DeleteSaveButton._alpha = 50;
        this.MarketplaceButton._alpha = 50;
        this.DLCList_mc._visible = false;
    }

    function setupMainMenu()
    {
        var __reg7 = 0;
        var __reg5 = 1;
        var __reg6 = 2;
        var __reg8 = 3;
        var __reg9 = 4;
        var __reg4 = StartMenu.NEW_INDEX;
        if (this.MainList.entryList.length > 0) 
        {
            __reg4 = this.MainList.centeredEntry.index;
        }
        this.MainList.ClearList();
        if (arguments[__reg5]) 
        {
            this.MainList.entryList.push({text: "$CONTINUE", index: StartMenu.CONTINUE_INDEX, disabled: false});
            if (__reg4 == StartMenu.NEW_INDEX) 
            {
                __reg4 = StartMenu.CONTINUE_INDEX;
            }
        }
        this.MainList.entryList.push({text: "$NEW", index: StartMenu.NEW_INDEX, disabled: false});
        this.MainList.entryList.push({text: "$LOAD", disabled: !arguments[__reg5], index: StartMenu.LOAD_INDEX});
        if (arguments[__reg9] == true) 
        {
            this.MainList.entryList.push({text: "$DOWNLOADABLE CONTENT", index: StartMenu.DLC_INDEX, disabled: false});
        }
        this.MainList.entryList.push({text: "$CREDITS", index: StartMenu.CREDITS_INDEX, disabled: false});
        if (arguments[__reg7]) 
        {
            this.MainList.entryList.push({text: "$QUIT", index: StartMenu.QUIT_INDEX, disabled: false});
        }
        var __reg3 = 0;
        while (__reg3 < this.MainList.entryList.length) 
        {
            if (this.MainList.entryList[__reg3].index == __reg4) 
            {
                this.MainList.RestoreScrollPosition(__reg3, false);
            }
            ++__reg3;
        }
        this.MainList.InvalidateData();
        if (this.currentState == undefined) 
        {
            if (arguments[__reg8]) 
            {
                this.StartState(StartMenu.PRESS_START_STATE);
            }
            else 
            {
                this.StartState(StartMenu.MAIN_STATE);
            }
        }
        else if (this.currentState == StartMenu.SAVE_LOAD_STATE || this.currentState == StartMenu.SAVE_LOAD_CONFIRM_STATE || this.currentState == StartMenu.DELETE_SAVE_CONFIRM_STATE) 
        {
            this.ShowDeleteButtonHelp(false);
            this.StartState(StartMenu.MAIN_STATE);
        }
        if (arguments[__reg6] != undefined) 
        {
            this.VersionText.SetText("v " + arguments[__reg6]);
            return;
        }
        this.VersionText.SetText(" ");
    }

    function get currentState()
    {
        return this.strCurrentState;
    }

    function set currentState(strNewState)
    {
        if (strNewState == StartMenu.MAIN_STATE) 
        {
            this.MainList.disableSelection = false;
        }
        this.strCurrentState = strNewState;
        this.ChangeStateFocus(strNewState);
    }

    function handleInput(details, pathToFocus)
    {
        if (this.currentState == StartMenu.PRESS_START_STATE) 
        {
            if (Shared.GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_START || details.navEquivalent == gfx.ui.NavigationCode.ENTER)) 
            {
                this.EndState(StartMenu.PRESS_START_STATE);
            }
            gfx.io.GameDelegate.call("EndPressStartState", []);
        }
        else if (pathToFocus.length > 0 && !pathToFocus[0].handleInput(details, pathToFocus.slice(1))) 
        {
            if (Shared.GlobalFunc.IsKeyPressed(details)) 
            {
                if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) 
                {
                    this.onAcceptPress();
                }
                else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) 
                {
                    this.onCancelPress();
                }
                else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.DeleteSaveButton._visible && this.DeleteSaveButton._alpha == 100) 
                {
                    this.ConfirmDeleteSave();
                }
                else if (details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y && this.currentState == StartMenu.DLC_STATE && this.MarketplaceButton._visible && this.MarketplaceButton._alpha == 100) 
                {
                    this.SaveLoadConfirmText.textField.SetText("$Open Xbox LIVE Marketplace?");
                    this.SetPlatform(this.iPlatform);
                    this.StartState(StartMenu.MARKETPLACE_CONFIRM_STATE);
                }
            }
        }
        return true;
    }

    function onAcceptPress()
    {
        if ((__reg0 = this.strCurrentState) === StartMenu.MAIN_CONFIRM_STATE) 
        {
            if (this.MainList.selectedEntry.index == StartMenu.NEW_INDEX) 
            {
                gfx.io.GameDelegate.call("PlaySound", ["UIStartNewGame"]);
                this.FadeOutAndCall("StartNewGame");
            }
            else if (this.MainList.selectedEntry.index == StartMenu.CONTINUE_INDEX) 
            {
                gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
                this.FadeOutAndCall("ContinueLastSavedGame");
            }
            else if (this.MainList.selectedEntry.index == StartMenu.QUIT_INDEX) 
            {
                gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
                gfx.io.GameDelegate.call("QuitToDesktop", []);
            }
            return;
        }
        else if (__reg0 === StartMenu.SAVE_LOAD_CONFIRM_STATE) 
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
            this.FadeOutAndCall("LoadGame", [this.SaveLoadListHolder.selectedIndex]);
            return;
        }
        else if (__reg0 === "SaveLoadConfirmStartAnim") 
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
            this.FadeOutAndCall("LoadGame", [this.SaveLoadListHolder.selectedIndex]);
            return;
        }
        else if (__reg0 === StartMenu.DELETE_SAVE_CONFIRM_STATE) 
        {
            this.SaveLoadListHolder.DeleteSelectedSave();
            if (this.SaveLoadListHolder.numSaves == 0) 
            {
                this.ShowDeleteButtonHelp(false);
                this.StartState(StartMenu.MAIN_STATE);
                if (this.MainList.entryList[2].index == StartMenu.LOAD_INDEX) 
                {
                    this.MainList.entryList[2].disabled = true;
                }
                if (this.MainList.entryList[0].index == StartMenu.CONTINUE_INDEX) 
                {
                    this.MainList.entryList.shift();
                }
                this.MainList.RestoreScrollPosition(1, true);
                this.MainList.InvalidateData();
            }
            else 
            {
                this.EndState();
            }
            return;
        }
        else if (__reg0 !== StartMenu.MARKETPLACE_CONFIRM_STATE) 
        {
            return;
        }
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
        gfx.io.GameDelegate.call("OpenMarketplace", []);
        this.StartState(StartMenu.MAIN_STATE);
        return;
    }

    function isConfirming()
    {
        return this.strCurrentState == StartMenu.SAVE_LOAD_CONFIRM_STATE || this.strCurrentState == StartMenu.DELETE_SAVE_CONFIRM_STATE || this.strCurrentState == StartMenu.MARKETPLACE_CONFIRM_STATE || this.strCurrentState == StartMenu.MAIN_CONFIRM_STATE;
    }

    function onAcceptMousePress()
    {
        if (this.isConfirming()) 
        {
            this.onAcceptPress();
        }
    }

    function onCancelMousePress()
    {
        if (this.isConfirming()) 
        {
            this.onCancelPress();
        }
    }

    function onCancelPress()
    {
        if ((__reg0 = this.strCurrentState) !== StartMenu.MAIN_CONFIRM_STATE) 
        {
            if (__reg0 !== StartMenu.SAVE_LOAD_STATE) 
            {
                if (__reg0 !== StartMenu.SAVE_LOAD_CONFIRM_STATE) 
                {
                    if (__reg0 !== StartMenu.DELETE_SAVE_CONFIRM_STATE) 
                    {
                        if (__reg0 !== StartMenu.DLC_STATE) 
                        {
                            if (__reg0 !== StartMenu.MARKETPLACE_CONFIRM_STATE) 
                            {
                                return;
                            }
                        }
                    }
                }
            }
        }
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
        this.EndState();
        return;
    }

    function onMainButtonPress(event)
    {
        if (this.strCurrentState == StartMenu.MAIN_STATE || this.iPlatform == 0) 
        {
            if ((__reg0 = event.entry.index) === StartMenu.CONTINUE_INDEX) 
            {
                gfx.io.GameDelegate.call("CONTINUE", []);
                gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
                return;
            }
            else if (__reg0 === StartMenu.NEW_INDEX) 
            {
                gfx.io.GameDelegate.call("NEW", []);
                gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
                return;
            }
            else if (__reg0 === StartMenu.QUIT_INDEX) 
            {
                this.ShowConfirmScreen("$Quit to desktop?  Any unsaved progress will be lost.");
                gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
                return;
            }
            else if (__reg0 === StartMenu.LOAD_INDEX) 
            {
                if (event.entry.disabled) 
                {
                    gfx.io.GameDelegate.call("OnDisabledLoadPress", []);
                }
                else 
                {
                    this.SaveLoadListHolder.isSaving = false;
                    gfx.io.GameDelegate.call("LOAD", [this.SaveLoadListHolder.List_mc.entryList, this.SaveLoadListHolder.batchSize]);
                }
                return;
            }
            else if (__reg0 === StartMenu.DLC_INDEX) 
            {
                this.StartState(StartMenu.DLC_STATE);
                return;
            }
            else if (__reg0 === StartMenu.CREDITS_INDEX) 
            {
                this.FadeOutAndCall("OpenCreditsMenu");
                return;
            }
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
            return;
        }
    }

    function onMainListPress(event)
    {
        this.onCancelPress();
    }

    function onPCQuitButtonPress(event)
    {
        if (event.index == 0) 
        {
            gfx.io.GameDelegate.call("QuitToMainMenu", []);
            return;
        }
        if (event.index == 1) 
        {
            gfx.io.GameDelegate.call("QuitToDesktop", []);
        }
    }

    function onSaveLoadListPress()
    {
        this.onAcceptPress();
    }

    function onMainListMoveUp(event)
    {
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        if (event.scrollChanged == true) 
        {
            this.MainList._parent.gotoAndPlay("moveUp");
        }
    }

    function onMainListMoveDown(event)
    {
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        if (event.scrollChanged == true) 
        {
            this.MainList._parent.gotoAndPlay("moveDown");
        }
    }

    function onMainListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0 && event.index != -1) 
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        }
    }

    function SetPlatform(aiPlatform, abPS3Switch)
    {
        this.ButtonRect.AcceptGamepadButton._visible = aiPlatform != 0;
        this.ButtonRect.CancelGamepadButton._visible = aiPlatform != 0;
        this.ButtonRect.AcceptMouseButton._visible = aiPlatform == 0;
        this.ButtonRect.CancelMouseButton._visible = aiPlatform == 0;
        this.DeleteSaveButton.SetPlatform(aiPlatform, abPS3Switch);
        this.MarketplaceButton.SetPlatform(aiPlatform, abPS3Switch);
        this.MainListHolder.SelectionArrow._visible = aiPlatform != 0;
        if (aiPlatform != 0) 
        {
            this.ButtonRect.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
            this.ButtonRect.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
        }
        this.MarketplaceButton._visible = aiPlatform == 2;
        this.iPlatform = aiPlatform;
        this.SaveLoadListHolder.platform = this.iPlatform;
        this.MainList.SetPlatform(aiPlatform, abPS3Switch);
    }

    function DoFadeOutMenu()
    {
        this.FadeOutAndCall();
    }

    function DoFadeInMenu()
    {
        this._parent.gotoAndPlay("fadeIn");
        this.EndState();
    }

    function FadeOutAndCall(strCallback, paramList)
    {
        this.strFadeOutCallback = strCallback;
        this.fadeOutParams = paramList;
        this._parent.gotoAndPlay("fadeOut");
        gfx.io.GameDelegate.call("fadeOutStarted", []);
    }

    function onFadeOutCompletion()
    {
        if (this.strFadeOutCallback != undefined && this.strFadeOutCallback.length > 0) 
        {
            if (this.fadeOutParams != undefined) 
            {
                gfx.io.GameDelegate.call(this.strFadeOutCallback, this.fadeOutParams);
                return;
            }
            gfx.io.GameDelegate.call(this.strFadeOutCallback, []);
        }
    }

    function StartState(strStateName)
    {
        if (strStateName == StartMenu.SAVE_LOAD_STATE) 
        {
            this.ShowDeleteButtonHelp(true);
        }
        else if (strStateName == StartMenu.DLC_STATE) 
        {
            this.ShowMarketplaceButtonHelp(true);
        }
        if (this.strCurrentState == StartMenu.MAIN_STATE) 
        {
            this.MainList.disableSelection = true;
        }
        this.strCurrentState = strStateName + "StartAnim";
        this.gotoAndPlay(this.strCurrentState);
        gfx.managers.FocusHandler.instance.setFocus(this, 0);
    }

    function EndState()
    {
        if (this.strCurrentState == StartMenu.SAVE_LOAD_STATE) 
        {
            this.ShowDeleteButtonHelp(false);
        }
        else if (this.strCurrentState == StartMenu.DLC_STATE) 
        {
            this.ShowMarketplaceButtonHelp(false);
        }
        if (this.strCurrentState != StartMenu.MAIN_STATE) 
        {
            this.strCurrentState = this.strCurrentState + "EndAnim";
            this.gotoAndPlay(this.strCurrentState);
        }
    }

    function ChangeStateFocus(strNewState)
    {
        if ((__reg0 = strNewState) === StartMenu.MAIN_STATE) 
        {
            gfx.managers.FocusHandler.instance.setFocus(this.MainList, 0);
            return;
        }
        else if (__reg0 === StartMenu.SAVE_LOAD_STATE) 
        {
            gfx.managers.FocusHandler.instance.setFocus(this.SaveLoadListHolder.List_mc, 0);
            this.SaveLoadListHolder.List_mc.disableSelection = false;
            return;
        }
        else if (__reg0 === StartMenu.DLC_STATE) 
        {
            this.iLoadDLCListTimerID = setInterval(this, "DoLoadDLCList", 500);
            gfx.managers.FocusHandler.instance.setFocus(this.DLCList_mc, 0);
            return;
        }
        else if (__reg0 !== StartMenu.MAIN_CONFIRM_STATE) 
        {
            if (__reg0 !== StartMenu.SAVE_LOAD_CONFIRM_STATE) 
            {
                if (__reg0 !== StartMenu.DELETE_SAVE_CONFIRM_STATE) 
                {
                    if (__reg0 !== StartMenu.PRESS_START_STATE) 
                    {
                        if (__reg0 !== StartMenu.MARKETPLACE_CONFIRM_STATE) 
                        {
                            return;
                        }
                    }
                }
            }
        }
        gfx.managers.FocusHandler.instance.setFocus(this.ButtonRect, 0);
        return;
    }

    function ShowConfirmScreen(astrConfirmText)
    {
        this.ConfirmPanel_mc.textField.SetText(astrConfirmText);
        this.SetPlatform(this.iPlatform);
        this.StartState(StartMenu.MAIN_CONFIRM_STATE);
    }

    function OnSaveListOpenSuccess()
    {
        if (this.SaveLoadListHolder.numSaves > 0) 
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
            this.StartState(StartMenu.SAVE_LOAD_STATE);
            return;
        }
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
    }

    function onSaveHighlight(event)
    {
        this.DeleteSaveButton._alpha = event.index == -1 ? 50 : 100;
        if (this.iPlatform == 0) 
        {
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
        }
    }

    function ConfirmLoadGame(event)
    {
        this.SaveLoadListHolder.List_mc.disableSelection = true;
        this.SaveLoadConfirmText.textField.SetText("$Load this game?");
        this.SetPlatform(this.iPlatform);
        this.StartState(StartMenu.SAVE_LOAD_CONFIRM_STATE);
    }

    function ConfirmDeleteSave()
    {
        this.SaveLoadListHolder.List_mc.disableSelection = true;
        this.SaveLoadConfirmText.textField.SetText("$Delete this save?");
        this.SetPlatform(this.iPlatform);
        this.StartState(StartMenu.DELETE_SAVE_CONFIRM_STATE);
    }

    function ShowDeleteButtonHelp(abFlag)
    {
        this.DeleteSaveButton._visible = abFlag;
        this.VersionText._visible = !abFlag;
    }

    function ShowMarketplaceButtonHelp(abFlag)
    {
        this.MarketplaceButton._visible = abFlag;
        this.VersionText._visible = !abFlag;
    }

    function onProfileChange()
    {
        this.ShowDeleteButtonHelp(false);
        if (this.strCurrentState != StartMenu.MAIN_STATE && this.strCurrentState != StartMenu.PRESS_START_STATE) 
        {
            this.StartState(StartMenu.MAIN_STATE);
        }
    }

    function StartLoadingDLC()
    {
        this.LoadingContentMessage.gotoAndPlay("startFadeIn");
        clearInterval(this.iLoadDLCContentMessageTimerID);
        this.iLoadDLCContentMessageTimerID = setInterval(this, "onLoadingDLCMessageFadeCompletion", 1000);
    }

    function onLoadingDLCMessageFadeCompletion()
    {
        clearInterval(this.iLoadDLCContentMessageTimerID);
        gfx.io.GameDelegate.call("DoLoadDLCPlugins", []);
    }

    function DoneLoadingDLC()
    {
        this.LoadingContentMessage.gotoAndPlay("startFadeOut");
    }

    function DoLoadDLCList()
    {
        clearInterval(this.iLoadDLCListTimerID);
        this.DLCList_mc.entryList.splice(0, this.DLCList_mc.entryList.length);
        gfx.io.GameDelegate.call("LoadDLC", [this.DLCList_mc.entryList], this, "UpdateDLCPanel");
    }

    function UpdateDLCPanel(abMarketplaceAvail, abNewDLCAvail)
    {
        if (this.DLCList_mc.entryList.length > 0) 
        {
            this.DLCList_mc._visible = true;
            this.DLCPanel.warningText.SetText(" ");
            if (this.iPlatform != 0) 
            {
                this.DLCList_mc.selectedIndex = 0;
            }
            this.DLCList_mc.InvalidateData();
        }
        else 
        {
            this.DLCList_mc._visible = false;
            this.DLCPanel.warningText.SetText("$No content downloaded");
        }
        this.MarketplaceButton._alpha = abMarketplaceAvail ? 100 : 50;
        if (abNewDLCAvail == true) 
        {
            this.DLCPanel.NewContentAvail.SetText("$New content available");
        }
    }

}
