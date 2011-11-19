import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

class DialogueMenu extends MovieClip
{
	static var ALLOW_PROGRESS_DELAY = 750;
    static var SHOW_GREETING = 0;
    static var TOPIC_LIST_SHOWN = 1;
    static var TOPIC_CLICKED = 2;
    static var TRANSITIONING = 3;
    static var iMouseDownExecutionCount = 0;
	
    var TopicListHolder;
	var TopicList;
	var SubtitleText;
	var ExitButton;
	var eMenuState;
	var bFadedIn;
	var bAllowProgress;
	var SpeakerName;
	var iAllowProgressTimerID;
	
    function DialogueMenu()
    {
        super();
        TopicListHolder = TopicListHolder;
        TopicList = TopicListHolder.List_mc;
        SubtitleText = SubtitleText;
        ExitButton = ExitButton;
        eMenuState = DialogueMenu.SHOW_GREETING;
        bFadedIn = true;
        bAllowProgress = false;
    }
	
    function InitExtensions()
    {
        Mouse.addListener(this);
        GameDelegate.addCallBack("Cancel", this, "onCancelPress");
        GameDelegate.addCallBack("ShowDialogueText", this, "ShowDialogueText");
        GameDelegate.addCallBack("HideDialogueText", this, "HideDialogueText");
        GameDelegate.addCallBack("PopulateDialogueList", this, "PopulateDialogueLists");
        GameDelegate.addCallBack("ShowDialogueList", this, "DoShowDialogueList");
        GameDelegate.addCallBack("StartHideMenu", this, "StartHideMenu");
        GameDelegate.addCallBack("SetSpeakerName", this, "SetSpeakerName");
        GameDelegate.addCallBack("NotifyVoiceReady", this, "OnVoiceReady");
        GameDelegate.addCallBack("AdjustForPALSD", this, "AdjustForPALSD");
        TopicList.addEventListener("listMovedUp", this, "playListUpAnim");
        TopicList.addEventListener("listMovedDown", this, "playListDownAnim");
        TopicList.addEventListener("itemPress", this, "onItemSelect");
        Shared.GlobalFunc.SetLockFunction();
        ExitButton.Lock("BR");
        ExitButton._x = ExitButton._x - 50;
        ExitButton._y = ExitButton._y - 30;
        ExitButton.addEventListener("click", this, "onCancelPress");
        TopicListHolder._visible = false;
        TopicListHolder.TextCopy_mc._visible = false;
        TopicListHolder.TextCopy_mc.textField.textColor = 6316128;
        TopicListHolder.TextCopy_mc.textField.verticalAutoSize = "top";
        TopicListHolder.PanelCopy_mc._visible = false;
        FocusHandler.instance.setFocus(TopicList, 0);
        SubtitleText.verticalAutoSize = "top";
        SubtitleText.SetText(" ");
        SpeakerName.verticalAutoSize = "top";
        SpeakerName.SetText(" ");
    }
	
    function AdjustForPALSD()
    {
        _root.DialogueMenu_mc._x = _root.DialogueMenu_mc._x - 35;
    }
	
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        ExitButton.SetPlatform(aiPlatform, abPS3Switch);
        TopicList.SetPlatform(aiPlatform, abPS3Switch);
    }
	
    function SetSpeakerName(strName)
    {
        SpeakerName.SetText(strName);
    }
	
    function handleInput(details, pathToFocus)
    {
        if (bFadedIn && Shared.GlobalFunc.IsKeyPressed(details))
        {
            if (details.navEquivalent == NavigationCode.TAB)
            {
                onCancelPress();
            }
            else if (details.navEquivalent != NavigationCode.UP && details.navEquivalent != NavigationCode.DOWN || eMenuState == DialogueMenu.TOPIC_LIST_SHOWN)
            {
                pathToFocus[0].handleInput(details, pathToFocus.slice(1));
            }
        }
        return (true);
    }
	
    function get menuState()
    {
        return eMenuState;
    }
	
    function set menuState(aNewState)
    {
        eMenuState = aNewState;
    }
	
    function ShowDialogueText(astrText)
    {
        SubtitleText.SetText(astrText);
    }
	
    function OnVoiceReady()
    {
        StartProgressTimer();
    }
	
    function StartProgressTimer()
    {
        bAllowProgress = false;
        clearInterval(iAllowProgressTimerID);
        iAllowProgressTimerID = setInterval(this, "SetAllowProgress", DialogueMenu.ALLOW_PROGRESS_DELAY);
    }
	
    function HideDialogueText()
    {
        SubtitleText.SetText(" ");
    }
	
    function SetAllowProgress()
    {
        clearInterval(iAllowProgressTimerID);
        bAllowProgress = true;
    }
	
    function PopulateDialogueLists()
    {
        var _loc9 = 0;
        var _loc11 = 1;
        var _loc8 = 2;
        var _loc10 = 3;
        TopicList.ClearList();
		
        for (var _loc3 = 0; _loc3 < arguments.length - 1; _loc3 = _loc3 + _loc10)
        {
            var _loc4 = {text: arguments[_loc3 + _loc9], topicIsNew: arguments[_loc3 + _loc11], topicIndex: arguments[_loc3 + _loc8]};
            TopicList.entryList.push(_loc4);
        }
		
        if (arguments[arguments.length - 1] != -1)
        {
            TopicList.SetSelectedTopic(arguments[arguments.length - 1]);
        }
        TopicList.InvalidateData();
    }
	
    function DoShowDialogueList(abNewList, abHideExitButton)
    {
        if (eMenuState == DialogueMenu.TOPIC_CLICKED || eMenuState == DialogueMenu.SHOW_GREETING && TopicList.entryList.length > 0)
        {
            this.ShowDialogueList(abNewList, abNewList && eMenuState == DialogueMenu.TOPIC_CLICKED);
        }
		
        ExitButton._visible = !abHideExitButton;
    }
	
    function ShowDialogueList(abSlideAnim, abCopyVisible)
    {
        TopicListHolder._visible = true;
        TopicListHolder.gotoAndPlay(abSlideAnim ? ("slideListIn") : ("fadeListIn"));
        eMenuState = DialogueMenu.TRANSITIONING;
        TopicListHolder.TextCopy_mc._visible = abCopyVisible;
        TopicListHolder.PanelCopy_mc._visible = abCopyVisible;
    }
	
    function onItemSelect(event)
    {
        if (bAllowProgress && event.keyboardOrMouse != 0)
        {
            if (eMenuState == DialogueMenu.TOPIC_LIST_SHOWN)
            {
                this.onSelectionClick();
            }
            else if (eMenuState == DialogueMenu.TOPIC_CLICKED || eMenuState == DialogueMenu.SHOW_GREETING)
            {
                this.SkipText();
            } // end else if
            bAllowProgress = false;
        } // end if
    }
	
    function SkipText()
    {
        if (bAllowProgress)
        {
            GameDelegate.call("SkipText", []);
            bAllowProgress = false;
        } // end if
    }
	
    function onMouseDown()
    {
        iMouseDownExecutionCount = ++DialogueMenu.iMouseDownExecutionCount;
        if (DialogueMenu.iMouseDownExecutionCount % 2 == 0)
        {
            return;
        } // end if
        this.onItemSelect();
    }
	
    function onCancelPress()
    {
        if (eMenuState == DialogueMenu.SHOW_GREETING)
        {
            this.SkipText();
        }
        else
        {
            this.StartHideMenu();
        } // end else if
    }
	
    function StartHideMenu()
    {
        SubtitleText._visible = false;
        bFadedIn = false;
        SpeakerName.SetText(" ");
        ExitButton._visible = false;
        _parent.gotoAndPlay("startFadeOut");
        GameDelegate.call("CloseMenu", []);
    }
	
    function playListUpAnim(aEvent)
    {
        if (aEvent.scrollChanged == true)
        {
            aEvent.target._parent.gotoAndPlay("moveUp");
        } // end if
    }
	
    function playListDownAnim(aEvent)
    {
        if (aEvent.scrollChanged == true)
        {
            aEvent.target._parent.gotoAndPlay("moveDown");
        } // end if
    }
	
    function onSelectionClick()
    {
        if (eMenuState == DialogueMenu.TOPIC_LIST_SHOWN)
        {
            eMenuState = DialogueMenu.TOPIC_CLICKED;
        } // end if
        if (TopicList.scrollPosition != TopicList.selectedIndex)
        {
            TopicList.RestoreScrollPosition(TopicList.selectedIndex, true);
            TopicList.UpdateList();
        } // end if
        TopicListHolder.gotoAndPlay("topicClicked");
        TopicListHolder.TextCopy_mc._visible = true;
        TopicListHolder.TextCopy_mc.textField.SetText(TopicListHolder.List_mc.selectedEntry.text);
        var _loc2 = TopicListHolder.TextCopy_mc._y - TopicListHolder.List_mc._y - TopicListHolder.List_mc.Entry4._y;
        TopicListHolder.TextCopy_mc.textField._y = 6.250000 - _loc2;
        GameDelegate.call("TopicClicked", [TopicList.selectedEntry.topicIndex]);
    }
	
    function onFadeOutCompletion()
    {
        GameDelegate.call("FadeDone", []);
    }
}
