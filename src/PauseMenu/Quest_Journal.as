import gfx.controls.RadioButton;
import gfx.controls.ButtonGroup;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

import skyui.components.ButtonPanel;

class Quest_Journal extends MovieClip
{
	#include "../version.as"
	
	var bTabsDisabled: Boolean;
	
	var iCurrentTab: Number;
	
	var BottomBar: MovieClip;
	var BottomBar_mc: MovieClip;
	
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
	}

	function InitExtensions()
	{
		GlobalFunc.SetLockFunction();
		MovieClip(BottomBar_mc).Lock("B");
		
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
		
		BottomBar_mc.InitBar();
		
		ConfigPanel.initExtensions();
	}

	function RestoreSavedSettings(aiSavedTab: Number, abTabsDisabled: Boolean): Void
	{
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

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		if (!bHandledInput && GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent === NavigationCode.TAB) {
				CloseMenu();
			} else if (details.navEquivalent === NavigationCode.GAMEPAD_L2) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == NavigationCode.GAMEPAD_L2 ? -1 : 1);
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			} else if (details.navEquivalent === NavigationCode.GAMEPAD_R2) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab = iCurrentTab + (details.navEquivalent == NavigationCode.GAMEPAD_L2 ? -1 : 1);
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
		if (abForceClose != true) {
			GameDelegate.call("PlaySound", ["UIJournalClose"]);
		}
		GameDelegate.call("CloseMenu", [iCurrentTab, QuestsFader.Page_mc.selectedQuestID, QuestsFader.Page_mc.selectedQuestInstance]);
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
		if (aiPlatform == 0) {
			previousTabButton._visible = nextTabButton._visible = false;
		} else {
			previousTabButton._visible = nextTabButton._visible = true;
			previousTabButton.gotoAndStop(280); // LT
			nextTabButton.gotoAndStop(281); // RT
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
