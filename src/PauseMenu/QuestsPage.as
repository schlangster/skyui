import Components.CrossPlatformButtons;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

class QuestsPage extends MovieClip
{
	var DescriptionText: TextField;
	var Divider: MovieClip;
	var NoQuestsText: TextField;
	var ObjectiveList: Object;
	var ObjectivesHeader: MovieClip;
	var QuestTitleText: TextField;
	var ShowOnMapButton;
	var TitleList: MovieClip;
	var TitleList_mc: MovieClip;
	var ToggleActiveButton: CrossPlatformButtons;
	var bAllowShowOnMap: Boolean;
	var bHasMiscQuests: Boolean;
	var bUpdated: Boolean;
	var iPlatform: Number;
	var objectiveList: Object;
	var objectivesHeader: MovieClip;
	var questDescriptionText: TextField;
	var questTitleEndpieces: MovieClip;
	var questTitleText: TextField;

	function QuestsPage()
	{
		super();
		TitleList = TitleList_mc.List_mc;
		DescriptionText = questDescriptionText;
		QuestTitleText = questTitleText;
		ObjectiveList = objectiveList;
		ObjectivesHeader = objectivesHeader;
		bHasMiscQuests = false;
		bUpdated = false;
	}

	function onLoad()
	{
		QuestTitleText.SetText(" ");
		DescriptionText.SetText(" ");
		DescriptionText.verticalAutoSize = "top";
		QuestTitleText.textAutoSize = "shrink";
		TitleList.addEventListener("itemPress", this, "onTitleListSelect");
		TitleList.addEventListener("listMovedUp", this, "onTitleListMoveUp");
		TitleList.addEventListener("listMovedDown", this, "onTitleListMoveDown");
		TitleList.addEventListener("selectionChange", this, "onTitleListMouseSelectionChange");
		TitleList.disableInput = true; // Bugfix for vanilla
		ObjectiveList.addEventListener("itemPress", this, "onObjectiveListSelect");
		ObjectiveList.addEventListener("selectionChange", this, "onObjectiveListHighlight");
	}

	function startPage()
	{
		TitleList.disableInput = false; // Bugfix for vanilla
		if (!bUpdated) {
			ShowOnMapButton = _parent._parent.BottomBar_mc.Button2_mc;
			GameDelegate.call("RequestQuestsData", [TitleList], this, "onQuestsDataComplete");
			ToggleActiveButton = _parent._parent.BottomBar_mc.Button1_mc;
			bUpdated = true;
		}
		SwitchFocusToTitles();
	}

	function endPage()
	{
		TitleList.disableInput = true; // Bugfix for vanilla
	}

	function get selectedQuestID(): Number
	{
		return TitleList.entryList.length <= 0 ? undefined : TitleList.centeredEntry.formID;
	}

	function get selectedQuestInstance(): Number
	{
		return TitleList.entryList.length <= 0 ? undefined : TitleList.centeredEntry.instance;
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bhandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if ((details.navEquivalent == NavigationCode.GAMEPAD_X || details.code == 77) && bAllowShowOnMap) 
			{
				var oitem: Object = undefined;
				if (ObjectiveList.selectedEntry != undefined && ObjectiveList.selectedEntry.questTargetID != undefined) {
					oitem = ObjectiveList.selectedEntry;
				} else {
					oitem = ObjectiveList.entryList[0];
				}
				if (oitem != undefined && oitem.questTargetID != undefined) {
					_parent._parent.CloseMenu();
					GameDelegate.call("ShowTargetOnMap", [oitem.questTargetID]);
				} else {
					GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				}
				bhandledInput = true;
			} else if (TitleList.entryList.length > 0) {
				if (details.navEquivalent == NavigationCode.LEFT && FocusHandler.instance.getFocus(0) != TitleList) {
					SwitchFocusToTitles();
					bhandledInput = true;
				} else if (details.navEquivalent == NavigationCode.RIGHT && FocusHandler.instance.getFocus(0) != ObjectiveList) {
					SwitchFocusToObjectives();
					bhandledInput = true;
				}
			}
		}
		if (!bhandledInput && pathToFocus != undefined && pathToFocus.length > 0) {
			bhandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return bhandledInput;
	}

	function IsViewingMiscObjectives(): Boolean
	{
		return bHasMiscQuests && TitleList.selectedEntry.formID == 0;
	}

	function onTitleListSelect(): Void
	{
		if (TitleList.selectedEntry != undefined && !TitleList.selectedEntry.completed) {
			if (!IsViewingMiscObjectives()) {
				GameDelegate.call("ToggleQuestActiveStatus", [TitleList.selectedEntry.formID, TitleList.selectedEntry.instance], this, "ToggleQuestActiveCallback");
				return;
			}
			TitleList.selectedEntry.active = !TitleList.selectedEntry.active;
			GameDelegate.call("ToggleShowMiscObjectives", [TitleList.selectedEntry.active]);
			TitleList.UpdateList();
		}
	}

	function onObjectiveListSelect(): Void
	{
		if (IsViewingMiscObjectives()) {
			GameDelegate.call("ToggleQuestActiveStatus", [ObjectiveList.selectedEntry.formID, ObjectiveList.selectedEntry.instance], this, "ToggleQuestActiveCallback");
		}
	}

	function SwitchFocusToTitles(): Void
	{
		FocusHandler.instance.setFocus(TitleList, 0);
		Divider.gotoAndStop("Right");
		ToggleActiveButton._alpha = 100;
		ObjectiveList.selectedIndex = -1;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = true;
		}
		UpdateShowOnMapButtonAlpha(0);
	}

	function SwitchFocusToObjectives(): Void
	{
		FocusHandler.instance.setFocus(ObjectiveList, 0);
		Divider.gotoAndStop("Left");
		ToggleActiveButton._alpha = IsViewingMiscObjectives() ? 100 : 50;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = false;
		}
		ObjectiveList.selectedIndex = 0;
		UpdateShowOnMapButtonAlpha(0);
	}

	function onObjectiveListHighlight(event): Void
	{
		UpdateShowOnMapButtonAlpha(event.index);
	}

	function UpdateShowOnMapButtonAlpha(aiObjIndex: Number): Void
	{
		var ialpha: Number = 50;
		if ((aiObjIndex >= 0 && ObjectiveList.entryList[aiObjIndex].questTargetID != undefined) || (ObjectiveList.entryList.length > 0 && ObjectiveList.entryList[0].questTargetID != undefined)) {
			ialpha = 100;
		}
		ShowOnMapButton._alpha = ialpha;
	}

	function ToggleQuestActiveCallback(abNewActiveStatus: Number): Void
	{
		if (IsViewingMiscObjectives()) {
			var iformID: Number = ObjectiveList.selectedEntry.formID;
			var iinstance: Number = ObjectiveList.selectedEntry.instance;
			for (var i: String in ObjectiveList.entryList) {
				if (ObjectiveList.entryList[i].formID == iformID && ObjectiveList.entryList[i].instance == iinstance) {
					ObjectiveList.entryList[i].active = abNewActiveStatus;
				}
			}
			ObjectiveList.UpdateList();
		} else {
			TitleList.selectedEntry.active = abNewActiveStatus;
			TitleList.UpdateList();
		}
		if (abNewActiveStatus) {
			GameDelegate.call("PlaySound", ["UIQuestActive"]);
			return;
		}
		GameDelegate.call("PlaySound", ["UIQuestInactive"]);
	}

	function onQuestsDataComplete(auiSavedFormID: Number, auiSavedInstance: Number, abAddMiscQuest: Boolean, abMiscQuestActive: Boolean, abAllowShowOnMap: Boolean): Void
	{
		bAllowShowOnMap = abAllowShowOnMap;
		if (abAddMiscQuest)	{
			TitleList.entryList.push({text: "$MISCELLANEOUS", formID: 0, instance: 0, active: abMiscQuestActive, completed: false, type: 0});
			bHasMiscQuests = true;
		}
		var itimeCompleted: Number = undefined;
		var bCompleted = false;
		var bUncompleted = false;
		
		for (var i: Number; i < TitleList.entryList.length; i++) {
			if (TitleList.entryList[i].formID == 0) {
					TitleList.entryList[i].timeIndex = Number.MAX_VALUE;
				} else {
					TitleList.entryList[i].timeIndex = i;
				}
				if (TitleList.entryList[i].completed) {
					if (itimeCompleted == undefined) {
						itimeCompleted = TitleList.entryList[i].timeIndex - 0.5;
					}
					bCompleted = true;
				} else {
					bUncompleted = true;
				}
		}
		
		if (itimeCompleted != undefined && bCompleted && bUncompleted) {
			// i.e. at least one completed and one uncompleted quest in the list
			TitleList.entryList.push({divider: true, completed: true, timeIndex: itimeCompleted});
		}
		TitleList.entryList.sort(completedQuestSort);
		
		var isavedIndex = 0;

		for (var i: Number; i < TitleList.entryList.length; i++) {
			if (TitleList.entryList[i].text != undefined) {
				TitleList.entryList[i].text = TitleList.entryList[i].text.toUpperCase();
			}
			if (TitleList.entryList[i].formID == auiSavedFormID && TitleList.entryList[i].instance == auiSavedInstance) {
				isavedIndex = i;
			}
		}

		TitleList.InvalidateData();
		TitleList.RestoreScrollPosition(isavedIndex, true);
		TitleList.UpdateList();
		onQuestHighlight();
	}

	function completedQuestSort(aObj1: Object, aObj2: Object): Number
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

	function onQuestHighlight(): Void
	{
		if (TitleList.entryList.length > 0) {
			var aCategories: Array = ["Misc", "Main", "MagesGuild", "ThievesGuild", "DarkBrotherhood", "Companion", "Favor", "Daedric", "Misc", "CivilWar", "DLC01"];
			QuestTitleText.SetText(TitleList.selectedEntry.text);
			if (TitleList.selectedEntry.objectives == undefined) {
				GameDelegate.call("RequestObjectivesData", []);
			}
			ObjectiveList.entryList = TitleList.selectedEntry.objectives;
			SetDescriptionText();
			questTitleEndpieces.gotoAndStop(aCategories[TitleList.selectedEntry.type]);
			questTitleEndpieces._visible = true;
			ObjectivesHeader._visible = !IsViewingMiscObjectives();
			ObjectiveList.selectedIndex = -1;
			ObjectiveList.scrollPosition = 0;
			if (iPlatform != 0) {
				ObjectiveList.disableSelection = true;
			}
			ToggleActiveButton._visible = !TitleList.selectedEntry.completed;
			ShowOnMapButton._visible = !TitleList.selectedEntry.completed && bAllowShowOnMap;
			UpdateShowOnMapButtonAlpha(0);
		} else {
			NoQuestsText.SetText("No Active Quests");
			DescriptionText.SetText(" ");
			QuestTitleText.SetText(" ");
			ObjectiveList.ClearList();
			questTitleEndpieces._visible = false;
			ObjectivesHeader._visible = false;
			ShowOnMapButton._visible = false;
		}
		ObjectiveList.InvalidateData();
	}

	function SetDescriptionText(): Void
	{
		var iHeaderyOffset: Number = 25;
		var iObjectiveyOffset: Number = 10;
		var iObjectiveBorderMaxy: Number = 470;
		var iObjectiveBorderMiny: Number = 40;
		DescriptionText.SetText(TitleList.selectedEntry.description);
		var oCharBoundaries: Object = DescriptionText.getCharBoundaries(DescriptionText.getLineOffset(DescriptionText.numLines - 1));
		ObjectivesHeader._y = DescriptionText._y + oCharBoundaries.bottom + iHeaderyOffset;
		if (IsViewingMiscObjectives()) {
			ObjectiveList._y = DescriptionText._y;
		} else {
			ObjectiveList._y = ObjectivesHeader._y + ObjectivesHeader._height + iObjectiveyOffset;
		}
		ObjectiveList.border._height = Math.max(iObjectiveBorderMaxy - ObjectiveList._y, iObjectiveBorderMiny);
		ObjectiveList.scrollbar.height = ObjectiveList.border._height - 20;
	}

	function onTitleListMoveUp(event: Object): Void
	{
		onQuestHighlight();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			TitleList._parent.gotoAndPlay("moveUp");
		}
	}

	function onTitleListMoveDown(event: Object): Void
	{
		onQuestHighlight();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			TitleList._parent.gotoAndPlay("moveDown");
		}
	}

	function onTitleListMouseSelectionChange(event: Object): Void
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			onQuestHighlight();
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function onRightStickInput(afX: Number, afY: Number): Void
	{
		if (afY < 0) {
			ObjectiveList.moveSelectionDown();
			return;
		}
		ObjectiveList.moveSelectionUp();
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		iPlatform = aiPlatform;
		TitleList.SetPlatform(aiPlatform, abPS3Switch);
		ObjectiveList.SetPlatform(aiPlatform, abPS3Switch);
	}

}
