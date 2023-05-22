﻿import gfx.controls.RadioButton;
import gfx.controls.ButtonGroup;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

import skyui.components.ButtonPanel;
import skyui.defines.ButtonArtNames;
import skyui.util.Debug;
import skyui.VRInput;
import skyui.util.GlobalFunctions;

class Quest_Journal extends MovieClip
{
	#include "../version.as"

	var bTabsDisabled: Boolean;

	var iCurrentTab: Number;

	var BottomBar: MovieClip;
	var BottomBar_mc: MovieClip;
	var TextPanel: MovieClip;
	var showInputReadout: Boolean;

	var PageArray: Array;

	public var previousTabButton: MovieClip;
	public var nextTabButton: MovieClip;
	var TopmostPage: MovieClip;
	var QuestsFader: MovieClip;
	var StatsFader: MovieClip;
	var SystemFader: MovieClip;

	var QuestsTab: RadioButton;
	var StatsTab: RadioButton;
	var SystemTab: RadioButton;
	var TabButtonGroup: ButtonGroup;

	var ConfigPanel: MovieClip;

	var _VRInput: VRInput;

  public static var PAGE_QUEST: Number = 0;
  public static var PAGE_STATS: Number = 1;
  public static var PAGE_SYSTEM: Number = 2;
	public static var QUESTS_TAB: Number = 0;
	public static var STATS_TAB: Number = 1;
	public static var SETTINGS_TAB: Number = 2;

	function Quest_Journal()
	{
		super();
		BottomBar_mc = BottomBar;
		PageArray = new Array(QuestsFader.Page_mc, StatsFader.Page_mc, SystemFader.Page_mc);
		TopmostPage = QuestsFader;
		bTabsDisabled = false;
		iCurrentTab = Quest_Journal.PAGE_QUEST;
	}

	function InitExtensions()
	{
		GlobalFunc.SetLockFunction();

		ConfigPanel = _root.ConfigPanelFader.configPanel;

		QuestsTab.disableFocus = true;
		StatsTab.disableFocus = true;
		SystemTab.disableFocus = true;

		TabButtonGroup = ButtonGroup(QuestsTab.group);
		TabButtonGroup.addEventListener("itemClick", this, "onTabClick");
		TabButtonGroup.addEventListener("change", this, "onTabChange");

		GameDelegate.addCallBack("RestoreSavedSettings", this, "RestoreSavedSettings");
		GameDelegate.addCallBack("onRightStickInput", this, "onRightStickInput");
		GameDelegate.addCallBack("HideMenu", this, "DoHideMenu");
		GameDelegate.addCallBack("ShowMenu", this, "DoShowMenu");
		GameDelegate.addCallBack("StartCloseMenu", this, "CloseMenu");
		GameDelegate.addCallBack("OnShow", this, "OnShow");
		GameDelegate.call("ShouldShowMod", [], this, "SetShowMod");

		BottomBar_mc.InitBar();

		ConfigPanel.initExtensions();
	}

	function OnShow(): Void
	{
		var vrtools = skse["plugins"]["vrinput"];
		if(vrtools != undefined)
		{
			//vrtools.ShutoffButtonEventsToGame(true);
		} else {
			Debug.log("SkyrimVRTools plugin not available");
		}

		showInputReadout = skse["plugins"]["skyui"].IniGetBool("Settings/showInputReadout");
		if(!showInputReadout)
			TextPanel._visible = false;
		else {
			// For whatever reason, Scaleform API requires an object to be somewhere
			// on the stage to be able to send inputs via a registered callback.
			// By adding it here, VRInput should start receiving and button updates
			// and start pumping out button events.
			_VRInput = VRInput.instance;
			VRInput.instance.setup();
		}

    QuestsTab.disableFocus = true;
    StatsTab.disableFocus = true;
    SystemTab.disableFocus = true;
    QuestsTab.disabled = false;
    StatsTab.disabled = false;
    SystemTab.disabled = false;
    BottomBar_mc.InitBar();
    var pageCursor = 0;
    while(pageCursor <= Quest_Journal.PAGE_SYSTEM)
    {
      var page = PageArray[pageCursor];
      Shared.Macros.BSASSERT(page != null && page != undefined,"Unable to open page " + pageCursor);
      Shared.Macros.BSASSERT(page.OnShow != null && page.OnShow != undefined,"page does not have OnShow function");
      page.OnShow();
      if(pageCursor == iCurrentTab)
      {
        page.startPage();
      }
      pageCursor = pageCursor + 1;
    }
    if(TopmostPage != null && TopmostPage != undefined)
    {
      TopmostPage.gotoAndPlay("fadeIn");
    }
	}

	function SetShowMod(): Void
	{
		PageArray[Quest_Journal.PAGE_SYSTEM].SetShowMod(arguments[0]);
	}

	function RestoreSavedSettings(aiSavedTab: Number, abTabsDisabled: Boolean): Void
	{
		// For some reason, the game will ask for the tab to be set to 0 (PAGE_QUEST)
		// *every* time after 'OnShow' is called.
		// This means the player will always be sent to the Quest page when the
		// quest_journal menu is brought up.
		// Strangely, the vanilla VR interface does not suffer from this problem.
		if(aiSavedTab != 0)
			iCurrentTab = Math.min(Math.max(aiSavedTab, 0), TabButtonGroup.length - 1);

		bTabsDisabled = abTabsDisabled;
		if (bTabsDisabled) {
			iCurrentTab = TabButtonGroup.length - 1;
			QuestsTab.disabled = true;
			StatsTab.disabled = true;
		}
		SwitchPageToFront(iCurrentTab, true);
		TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
	}

	function SwitchPageToFront(aiTab: Number, abForceFade: Boolean): Void
	{
		if (TopmostPage != PageArray[iCurrentTab]._parent)
		{
			TopmostPage.gotoAndStop("hide");
			PageArray[iCurrentTab]._parent.swapDepths(TopmostPage);
			TopmostPage = PageArray[iCurrentTab]._parent;
		}
		TopmostPage.gotoAndPlay(abForceFade ? "ForceFade" : "fadeIn");
		BottomBar_mc.LevelMeterRect._visible = iCurrentTab != 0;
	}

	function classname():String {
		return "class Quest_Journal"
	}

	function handleVRButtonUpdate(update)
	{
		if(!showInputReadout)
			return;

		//Debug.dump("update", update);
		var stateString = VRInput.instance.controllerStateString(update);
		Debug.log("stateString: " + stateString);
		if(stateString.length != 0) {
			TextPanel.TextArea.SetText(stateString);
		} else {
			TextPanel.TextArea.SetText(update.timestamp.toString());
		}
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		if (!bHandledInput && GlobalFunc.IsKeyPressed(details, false)) {
			var triggerLeft = NavigationCode.GAMEPAD_L2;
			var triggerRight = NavigationCode.GAMEPAD_R2;
			if(PageArray[Quest_Journal.PAGE_SYSTEM].GetIsRemoteDevice()) {
				triggerLeft = NavigationCode.GAMEPAD_L1;
				triggerRight = NavigationCode.GAMEPAD_R1;
			}
			if (details.navEquivalent === NavigationCode.TAB) {
				CloseMenu();
			} else if (details.navEquivalent === triggerLeft) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == triggerLeft ? -1 : 1);
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			} else if (details.navEquivalent === triggerRight) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == triggerLeft ? -1 : 1);
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			}
		}
		return true;
	}

	function CloseMenu(abForceClose: Boolean): Void
	{
		//Debug.log(">>> Quest_Journal::CloseMenu");

		var vrtools = skse["plugins"]["vrinput"];
		if(vrtools != undefined)
		{
			//vrtools.ShutoffButtonEventsToGame(false);
		}

		VRInput.instance.teardown();

		if (abForceClose != true) {
			GameDelegate.call("PlaySound", ["UIJournalClose"]);
		}
		GameDelegate.call("CloseMenu", [iCurrentTab, QuestsFader.Page_mc.selectedQuestID, QuestsFader.Page_mc.selectedQuestInstance]);
		//Debug.log("<<< Quest_Journal::CloseMenu");
	}

	function onTabClick(event: Object): Void
	{
		if (bTabsDisabled) {
			return;
		}

		var iOldTab: Number = iCurrentTab;

		if (event.item == QuestsTab) {
			iCurrentTab = 0;
		} else if (event.item == StatsTab) {
			iCurrentTab = 1;
		} else if (event.item == SystemTab) {
			iCurrentTab = 2;
		}
		if (iOldTab != iCurrentTab) {
			PageArray[iOldTab].endPage();
			// Moved SwitchPageToFront to within this statement
			// if you click the same tab it won't reload it
			SwitchPageToFront(iCurrentTab, false); // Bugfix for vanilla
		}
	}

	function onTabChange(event: Object): Void
	{
		event.item.gotoAndPlay("selecting");
		PageArray[iCurrentTab].startPage();
		GameDelegate.call("PlaySound", ["UIJournalTabsSD"]);
	}

	function onRightStickInput(afX: Number, afY: Number): Void
	{
		if (PageArray[iCurrentTab].onRightStickInput != undefined) {
			PageArray[iCurrentTab].onRightStickInput(afX, afY);
		}
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		VRInput.instance.updatePlatform(aiPlatform);

		// Not sure if these are the correct mapping for next/prev tab
		var nextTabArt = ButtonArtNames.lookup(skyui.util.Input.pickButtonArt(aiPlatform, {ViveArt:"radial_Either_Right", MoveArt:"PS3_Y",OculusArt:"OCC_B", WindowsMRArt:"radial_Either_Right"}));
		var prevTabArt = ButtonArtNames.lookup(skyui.util.Input.pickButtonArt(aiPlatform, {ViveArt:"radial_Either_Left", MoveArt:"PS3_X", OculusArt:"OCC_Y", WindowsMRArt:"radial_Either_Left"}));

		// If we can't find the right button art by name, provide some defaults
		if (nextTabArt == undefined)
			nextTabArt = 281; 	// RT
		if (prevTabArt == undefined)
			prevTabArt = 280; 			// LT

		if (aiPlatform == 0) {
			previousTabButton._visible = nextTabButton._visible = false;
		} else {
			previousTabButton._visible = nextTabButton._visible = true;
			previousTabButton.gotoAndStop(prevTabArt);
			nextTabButton.gotoAndStop(nextTabArt);
		}

		for (var i: String in PageArray) {
			if (PageArray[i].SetPlatform != undefined) {
				PageArray[i].SetPlatform(aiPlatform, abPS3Switch);
			}
		}
		BottomBar_mc.setPlatform(aiPlatform, abPS3Switch);

		ConfigPanel.setPlatform(aiPlatform, abPS3Switch);
	}

	function DoHideMenu(): Void
	{
		_parent.gotoAndPlay("fadeOut");
	}

	function DoShowMenu(): Void
	{
		_parent.gotoAndPlay("fadeIn");
	}

	function DisableTabs(abEnable: Boolean): Void
	{
		QuestsTab.disabled = abEnable;
		StatsTab.disabled = abEnable;
		SystemTab.disabled = abEnable;
	}

	function ConfigPanelOpen(): Void
	{
		DisableTabs(true);
		SystemFader.Page_mc.endPage();
		DoHideMenu();
		_root.ConfigPanelFader.swapDepths(_root.QuestJournalFader);
		FocusHandler.instance.setFocus(ConfigPanel, 0);
		ConfigPanel.startPage();
	}

	function ConfigPanelClose(): Void
	{
		ConfigPanel.endPage();
		_root.QuestJournalFader.swapDepths(_root.ConfigPanelFader);
		FocusHandler.instance.setFocus(this, 0);
		DoShowMenu();
		SystemFader.Page_mc.startPage();
		DisableTabs(false);
	}
}
