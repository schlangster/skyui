dynamic class Quest_Journal extends MovieClip
{
	var BottomBar;
	var BottomBar_mc;
	var PageArray;
	var QuestsFader;
	var QuestsTab;
	var StatsFader;
	var StatsTab;
	var SystemFader;
	var SystemTab;
	var TabButtonGroup;
	var TabButtonHelp;
	var TopmostPage;
	var _parent;
	var bTabsDisabled;
	var iCurrentTab;

	public function Quest_Journal()
	{
		super();
		this.QuestsTab = this.QuestsTab;
		this.StatsTab = this.StatsTab;
		this.SystemTab = this.SystemTab;
		this.BottomBar_mc = this.BottomBar;
		this.PageArray = new Array(this.QuestsFader.Page_mc, this.StatsFader.Page_mc, this.SystemFader.Page_mc);
		this.TopmostPage = this.QuestsFader;
		this.bTabsDisabled = false;
	}

	public function InitExtensions(): Void
	{
		Shared.GlobalFunc.SetLockFunction();
		MovieClip(this.BottomBar_mc).Lock("B");
		this.QuestsTab.disableFocus = true;
		this.StatsTab.disableFocus = true;
		this.SystemTab.disableFocus = true;
		this.TabButtonGroup = gfx.controls.ButtonGroup(this.QuestsTab.group);
		this.TabButtonGroup.addEventListener("itemClick", this, "onTabClick");
		this.TabButtonGroup.addEventListener("change", this, "onTabChange");
		gfx.io.GameDelegate.addCallBack("RestoreSavedSettings", this, "RestoreSavedSettings");
		gfx.io.GameDelegate.addCallBack("onRightStickInput", this, "onRightStickInput");
		gfx.io.GameDelegate.addCallBack("HideMenu", this, "DoHideMenu");
		gfx.io.GameDelegate.addCallBack("ShowMenu", this, "DoShowMenu");
		gfx.io.GameDelegate.addCallBack("StartCloseMenu", this, "CloseMenu");
		this.BottomBar_mc.InitBar();
	}

	function RestoreSavedSettings(aiSavedTab, abTabsDisabled)
	{
		this.iCurrentTab = Math.min(Math.max(aiSavedTab, 0), this.TabButtonGroup.length - 1);
		this.bTabsDisabled = abTabsDisabled;
		if (this.bTabsDisabled) 
		{
			this.iCurrentTab = this.TabButtonGroup.length - 1;
			this.QuestsTab.disabled = true;
			this.StatsTab.disabled = true;
		}
		this.SwitchPageToFront(this.iCurrentTab, true);
		this.TabButtonGroup.setSelectedButton(this.TabButtonGroup.getButtonAt(this.iCurrentTab));
	}

	function SwitchPageToFront(aiTab, abForceFade)
	{
		if (this.TopmostPage != this.PageArray[this.iCurrentTab]._parent) 
		{
			this.TopmostPage.gotoAndStop("hide");
			this.PageArray[this.iCurrentTab]._parent.swapDepths(this.TopmostPage);
			this.TopmostPage = this.PageArray[this.iCurrentTab]._parent;
		}
		this.TopmostPage.gotoAndPlay(abForceFade ? "ForceFade" : "fadeIn");
		this.BottomBar_mc.SetMode(this.iCurrentTab);
	}

	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		var __reg4 = false;
		if (pathToFocus != undefined && pathToFocus.length > 0) 
		{
			__reg4 = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		if (!__reg4 && Shared.GlobalFunc.IsKeyPressed(details, false)) 
		{
			if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.TAB) 
			{
				this.CloseMenu();
			}
			else if (__reg0 === gfx.ui.NavigationCode.GAMEPAD_L2) 
			{
				if (!this.bTabsDisabled) 
				{
					this.PageArray[this.iCurrentTab].endPage();
					this.iCurrentTab = this.iCurrentTab + (details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 ? -1 : 1);
					if (this.iCurrentTab == -1) 
					{
						this.iCurrentTab = this.TabButtonGroup.length - 1;
					}
					if (this.iCurrentTab == this.TabButtonGroup.length) 
					{
						this.iCurrentTab = 0;
					}
					this.SwitchPageToFront(this.iCurrentTab, false);
					this.TabButtonGroup.setSelectedButton(this.TabButtonGroup.getButtonAt(this.iCurrentTab));
				}
			}
			else if (__reg0 === gfx.ui.NavigationCode.GAMEPAD_R2) 
			{
				if (!this.bTabsDisabled) 
				{
					this.PageArray[this.iCurrentTab].endPage();
					this.iCurrentTab = this.iCurrentTab + (details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 ? -1 : 1);
					if (this.iCurrentTab == -1) 
					{
						this.iCurrentTab = this.TabButtonGroup.length - 1;
					}
					if (this.iCurrentTab == this.TabButtonGroup.length) 
					{
						this.iCurrentTab = 0;
					}
					this.SwitchPageToFront(this.iCurrentTab, false);
					this.TabButtonGroup.setSelectedButton(this.TabButtonGroup.getButtonAt(this.iCurrentTab));
				}
			}
		}
		return true;
	}

	function CloseMenu(abForceClose)
	{
		if (abForceClose != true) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIJournalClose"]);
		}
		gfx.io.GameDelegate.call("CloseMenu", [this.iCurrentTab, this.QuestsFader.Page_mc.selectedQuestID, this.QuestsFader.Page_mc.selectedQuestInstance]);
	}

	function onTabClick(event)
	{
		if (this.bTabsDisabled) 
		{
			return;
		}
		var __reg2 = this.iCurrentTab;
		if (event.item == this.QuestsTab) 
		{
			this.iCurrentTab = 0;
		}
		else if (event.item == this.StatsTab) 
		{
			this.iCurrentTab = 1;
		}
		else if (event.item == this.SystemTab) 
		{
			this.iCurrentTab = 2;
		}
		if (__reg2 != this.iCurrentTab) 
		{
			this.PageArray[__reg2].endPage();
		}
		this.SwitchPageToFront(this.iCurrentTab, false);
	}

	function onTabChange(event)
	{
		event.item.gotoAndPlay("selecting");
		this.PageArray[this.iCurrentTab].startPage();
		gfx.io.GameDelegate.call("PlaySound", ["UIJournalTabsSD"]);
	}

	function onRightStickInput(afX, afY)
	{
		if (this.PageArray[this.iCurrentTab].onRightStickInput != undefined) 
		{
			this.PageArray[this.iCurrentTab].onRightStickInput(afX, afY);
		}
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		for (var __reg4 in this.PageArray) 
		{
			if (this.PageArray[__reg4].SetPlatform != undefined) 
			{
				this.PageArray[__reg4].SetPlatform(aiPlatform, abPS3Switch);
			}
		}
		this.BottomBar_mc.SetPlatform(aiPlatform, abPS3Switch);
		this.TabButtonHelp.gotoAndStop(aiPlatform + 1);
	}

	function DoHideMenu()
	{
		this._parent.gotoAndPlay("fadeOut");
	}

	function DoShowMenu()
	{
		this._parent.gotoAndPlay("fadeIn");
	}

}
