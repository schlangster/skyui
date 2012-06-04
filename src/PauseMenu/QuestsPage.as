dynamic class QuestsPage extends MovieClip
{
	var DescriptionText;
	var Divider;
	var NoQuestsText;
	var ObjectiveList;
	var ObjectivesHeader;
	var QuestTitleText;
	var ShowOnMapButton;
	var TitleList;
	var TitleList_mc;
	var ToggleActiveButton;
	var _parent;
	var bAllowShowOnMap;
	var bHasMiscQuests;
	var bUpdated;
	var iPlatform;
	var objectiveList;
	var objectivesHeader;
	var questDescriptionText;
	var questTitleEndpieces;
	var questTitleText;

	function QuestsPage()
	{
		super();
		this.TitleList = this.TitleList_mc.List_mc;
		this.DescriptionText = this.questDescriptionText;
		this.QuestTitleText = this.questTitleText;
		this.ObjectiveList = this.objectiveList;
		this.ObjectivesHeader = this.objectivesHeader;
		this.bHasMiscQuests = false;
		this.bUpdated = false;
	}

	function onLoad()
	{
		this.QuestTitleText.SetText(" ");
		this.DescriptionText.SetText(" ");
		this.DescriptionText.verticalAutoSize = "top";
		this.QuestTitleText.textAutoSize = "shrink";
		this.TitleList.addEventListener("itemPress", this, "onTitleListSelect");
		this.TitleList.addEventListener("listMovedUp", this, "onTitleListMoveUp");
		this.TitleList.addEventListener("listMovedDown", this, "onTitleListMoveDown");
		this.TitleList.addEventListener("selectionChange", this, "onTitleListMouseSelectionChange");
		this.ObjectiveList.addEventListener("itemPress", this, "onObjectiveListSelect");
		this.ObjectiveList.addEventListener("selectionChange", this, "onObjectiveListHighlight");
	}

	function startPage()
	{
		if (!this.bUpdated) 
		{
			this.ShowOnMapButton = this._parent._parent.BottomBar_mc.Button2_mc;
			gfx.io.GameDelegate.call("RequestQuestsData", [this.TitleList], this, "onQuestsDataComplete");
			this.ToggleActiveButton = this._parent._parent.BottomBar_mc.Button1_mc;
			this.bUpdated = true;
		}
		this.SwitchFocusToTitles();
	}

	function endPage()
	{
	}

	function get selectedQuestID()
	{
		return this.TitleList.entryList.length <= 0 ? undefined : this.TitleList.centeredEntry.formID;
	}

	function get selectedQuestInstance()
	{
		return this.TitleList.entryList.length <= 0 ? undefined : this.TitleList.centeredEntry.instance;
	}

	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		var __reg2 = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) 
		{
			if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 77) && this.bAllowShowOnMap) 
			{
				var __reg3 = undefined;
				if (this.ObjectiveList.selectedEntry != undefined && this.ObjectiveList.selectedEntry.questTargetID != undefined) 
				{
					__reg3 = this.ObjectiveList.selectedEntry;
				}
				else 
				{
					__reg3 = this.ObjectiveList.entryList[0];
				}
				if (__reg3 != undefined && __reg3.questTargetID != undefined) 
				{
					this._parent._parent.CloseMenu();
					gfx.io.GameDelegate.call("ShowTargetOnMap", [__reg3.questTargetID]);
				}
				else 
				{
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				}
				__reg2 = true;
			}
			else if (this.TitleList.entryList.length > 0) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.LEFT && gfx.managers.FocusHandler.instance.getFocus(0) != this.TitleList) 
				{
					this.SwitchFocusToTitles();
					__reg2 = true;
				}
				else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT && gfx.managers.FocusHandler.instance.getFocus(0) != this.ObjectiveList) 
				{
					this.SwitchFocusToObjectives();
					__reg2 = true;
				}
			}
		}
		if (!__reg2 && pathToFocus != undefined && pathToFocus.length > 0) 
		{
			__reg2 = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return __reg2;
	}

	function IsViewingMiscObjectives()
	{
		return this.bHasMiscQuests && this.TitleList.selectedEntry.formID == 0;
	}

	function onTitleListSelect()
	{
		if (this.TitleList.selectedEntry != undefined && !this.TitleList.selectedEntry.completed) 
		{
			if (!this.IsViewingMiscObjectives()) 
			{
				gfx.io.GameDelegate.call("ToggleQuestActiveStatus", [this.TitleList.selectedEntry.formID, this.TitleList.selectedEntry.instance], this, "ToggleQuestActiveCallback");
				return;
			}
			this.TitleList.selectedEntry.active = !this.TitleList.selectedEntry.active;
			gfx.io.GameDelegate.call("ToggleShowMiscObjectives", [this.TitleList.selectedEntry.active]);
			this.TitleList.UpdateList();
		}
	}

	function onObjectiveListSelect()
	{
		if (this.IsViewingMiscObjectives()) 
		{
			gfx.io.GameDelegate.call("ToggleQuestActiveStatus", [this.ObjectiveList.selectedEntry.formID, this.ObjectiveList.selectedEntry.instance], this, "ToggleQuestActiveCallback");
		}
	}

	function SwitchFocusToTitles()
	{
		gfx.managers.FocusHandler.instance.setFocus(this.TitleList, 0);
		this.Divider.gotoAndStop("Right");
		this.ToggleActiveButton._alpha = 100;
		this.ObjectiveList.selectedIndex = -1;
		if (this.iPlatform != 0) 
		{
			this.ObjectiveList.disableSelection = true;
		}
		this.UpdateShowOnMapButtonAlpha(0);
	}

	function SwitchFocusToObjectives()
	{
		gfx.managers.FocusHandler.instance.setFocus(this.ObjectiveList, 0);
		this.Divider.gotoAndStop("Left");
		this.ToggleActiveButton._alpha = this.IsViewingMiscObjectives() ? 100 : 50;
		if (this.iPlatform != 0) 
		{
			this.ObjectiveList.disableSelection = false;
		}
		this.ObjectiveList.selectedIndex = 0;
		this.UpdateShowOnMapButtonAlpha(0);
	}

	function onObjectiveListHighlight(event)
	{
		this.UpdateShowOnMapButtonAlpha(event.index);
	}

	function UpdateShowOnMapButtonAlpha(aiObjIndex)
	{
		var __reg2 = 50;
		if ((aiObjIndex >= 0 && this.ObjectiveList.entryList[aiObjIndex].questTargetID != undefined) || (this.ObjectiveList.entryList.length > 0 && this.ObjectiveList.entryList[0].questTargetID != undefined)) 
		{
			__reg2 = 100;
		}
		this.ShowOnMapButton._alpha = __reg2;
	}

	function ToggleQuestActiveCallback(abNewActiveStatus)
	{
		if (this.IsViewingMiscObjectives()) 
		{
			var __reg3 = this.ObjectiveList.selectedEntry.formID;
			var __reg2 = this.ObjectiveList.selectedEntry.instance;
			for (var __reg5 in this.ObjectiveList.entryList) 
			{
				if (this.ObjectiveList.entryList[__reg5].formID == __reg3 && this.ObjectiveList.entryList[__reg5].instance == __reg2) 
				{
					this.ObjectiveList.entryList[__reg5].active = abNewActiveStatus;
				}
			}
			this.ObjectiveList.UpdateList();
		}
		else 
		{
			this.TitleList.selectedEntry.active = abNewActiveStatus;
			this.TitleList.UpdateList();
		}
		if (abNewActiveStatus) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIQuestActive"]);
			return;
		}
		gfx.io.GameDelegate.call("PlaySound", ["UIQuestInactive"]);
	}

	function onQuestsDataComplete(auiSavedFormID, auiSavedInstance, abAddMiscQuest, abMiscQuestActive, abAllowShowOnMap)
	{
		this.bAllowShowOnMap = abAllowShowOnMap;
		if (abAddMiscQuest) 
		{
			this.TitleList.entryList.push({text: "$MISCELLANEOUS", formID: 0, instance: 0, active: abMiscQuestActive, completed: false, type: 0});
			this.bHasMiscQuests = true;
		}
		var __reg3 = undefined;
		var __reg5 = false;
		var __reg6 = false;
		var __reg2 = 0;
		while (__reg2 < this.TitleList.entryList.length) 
		{
			if (this.TitleList.entryList[__reg2].formID == 0) 
			{
				this.TitleList.entryList[__reg2].timeIndex = 1.79769313486e+308;
			}
			else 
			{
				this.TitleList.entryList[__reg2].timeIndex = __reg2;
			}
			if (this.TitleList.entryList[__reg2].completed) 
			{
				if (__reg3 == undefined) 
				{
					__reg3 = this.TitleList.entryList[__reg2].timeIndex - 0.5;
				}
				__reg5 = true;
			}
			else 
			{
				__reg6 = true;
			}
			++__reg2;
		}
		if (__reg3 != undefined && __reg5 && __reg6) 
		{
			this.TitleList.entryList.push({divider: true, completed: true, timeIndex: __reg3});
		}
		this.TitleList.entryList.sort(this.completedQuestSort);
		var __reg4 = 0;
		__reg2 = 0;
		while (__reg2 < this.TitleList.entryList.length) 
		{
			if (this.TitleList.entryList[__reg2].text != undefined) 
			{
				this.TitleList.entryList[__reg2].text = this.TitleList.entryList[__reg2].text.toUpperCase();
			}
			if (this.TitleList.entryList[__reg2].formID == auiSavedFormID && this.TitleList.entryList[__reg2].instance == auiSavedInstance) 
			{
				__reg4 = __reg2;
			}
			++__reg2;
		}
		this.TitleList.InvalidateData();
		this.TitleList.RestoreScrollPosition(__reg4, true);
		this.TitleList.UpdateList();
		this.onQuestHighlight();
	}

	function completedQuestSort(aObj1, aObj2)
	{
		if (!aObj1.completed && aObj2.completed) 
		{
			return -1;
		}
		if (aObj1.completed && !aObj2.completed) 
		{
			return 1;
		}
		if (aObj1.timeIndex < aObj2.timeIndex) 
		{
			return -1;
		}
		if (aObj1.timeIndex > aObj2.timeIndex) 
		{
			return 1;
		}
		return 0;
	}

	function onQuestHighlight()
	{
		if (this.TitleList.entryList.length > 0) 
		{
			var __reg2 = ["Misc", "Main", "MagesGuild", "ThievesGuild", "DarkBrotherhood", "Companion", "Favor", "Daedric", "Misc", "CivilWar"];
			this.QuestTitleText.SetText(this.TitleList.selectedEntry.text);
			if (this.TitleList.selectedEntry.objectives == undefined) 
			{
				gfx.io.GameDelegate.call("RequestObjectivesData", []);
			}
			this.ObjectiveList.entryList = this.TitleList.selectedEntry.objectives;
			this.SetDescriptionText();
			this.questTitleEndpieces.gotoAndStop(__reg2[this.TitleList.selectedEntry.type]);
			this.questTitleEndpieces._visible = true;
			this.ObjectivesHeader._visible = !this.IsViewingMiscObjectives();
			this.ObjectiveList.selectedIndex = -1;
			this.ObjectiveList.scrollPosition = 0;
			if (this.iPlatform != 0) 
			{
				this.ObjectiveList.disableSelection = true;
			}
			this.ToggleActiveButton._visible = !this.TitleList.selectedEntry.completed;
			this.ShowOnMapButton._visible = !this.TitleList.selectedEntry.completed && this.bAllowShowOnMap;
			this.UpdateShowOnMapButtonAlpha(0);
		}
		else 
		{
			this.NoQuestsText.SetText("No Active Quests");
			this.DescriptionText.SetText(" ");
			this.QuestTitleText.SetText(" ");
			this.ObjectiveList.ClearList();
			this.questTitleEndpieces._visible = false;
			this.ObjectivesHeader._visible = false;
			this.ShowOnMapButton._visible = false;
		}
		this.ObjectiveList.InvalidateData();
	}

	function SetDescriptionText()
	{
		var __reg2 = 25;
		var __reg5 = 10;
		var __reg3 = 470;
		var __reg4 = 40;
		this.DescriptionText.SetText(this.TitleList.selectedEntry.description);
		var __reg6 = this.DescriptionText.getCharBoundaries(this.DescriptionText.getLineOffset(this.DescriptionText.numLines - 1));
		this.ObjectivesHeader._y = this.DescriptionText._y + __reg6.bottom + __reg2;
		if (this.IsViewingMiscObjectives()) 
		{
			this.ObjectiveList._y = this.DescriptionText._y;
		}
		else 
		{
			this.ObjectiveList._y = this.ObjectivesHeader._y + this.ObjectivesHeader._height + __reg5;
		}
		this.ObjectiveList.border._height = Math.max(__reg3 - this.ObjectiveList._y, __reg4);
		this.ObjectiveList.scrollbar.height = this.ObjectiveList.border._height - 20;
	}

	function onTitleListMoveUp(event)
	{
		this.onQuestHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.TitleList._parent.gotoAndPlay("moveUp");
		}
	}

	function onTitleListMoveDown(event)
	{
		this.onQuestHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.TitleList._parent.gotoAndPlay("moveDown");
		}
	}

	function onTitleListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) 
		{
			this.onQuestHighlight();
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function onRightStickInput(afX, afY)
	{
		if (afY < 0) 
		{
			this.ObjectiveList.moveSelectionDown();
			return;
		}
		this.ObjectiveList.moveSelectionUp();
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		this.iPlatform = aiPlatform;
		this.TitleList.SetPlatform(aiPlatform, abPS3Switch);
		this.ObjectiveList.SetPlatform(aiPlatform, abPS3Switch);
	}

}
