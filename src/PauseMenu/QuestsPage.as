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
	var TitleList: MovieClip;
	var TitleList_mc: MovieClip;
	var bAllowShowOnMap: Boolean;
	var bHasMiscQuests: Boolean;
	var bUpdated: Boolean;
	var iPlatform: Number;
	var objectiveList: Object;
	var objectivesHeader: MovieClip;
	var questDescriptionText: TextField;
	var questTitleEndpieces: MovieClip;
	var questTitleText: TextField;

	private var _showOnMapButton: MovieClip;
	private var _toggleActiveButton: MovieClip;
	private var _bottomBar: MovieClip;

	private var _toggleActiveControls: Object;
	private var _showOnMapControls: Object;
	private var _deleteControls: Object;

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

		_bottomBar = _parent._parent.BottomBar_mc;
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
			//ShowOnMapButton = _parent._parent._bottomBar.Button2_mc;
			GameDelegate.call("RequestQuestsData", [TitleList], this, "onQuestsDataComplete");
			//_toggleActiveButton = _parent._parent._bottomBar.Button1_mc;
			bUpdated = true;
		}

		_bottomBar.buttonPanel.clearButtons();
		_toggleActiveButton = _bottomBar.buttonPanel.addButton({text: "$Toggle Active", controls: _toggleActiveControls});
		if (bAllowShowOnMap)
			_showOnMapButton = _bottomBar.buttonPanel.addButton({text: "$Show on Map", controls: _showOnMapControls});
		_bottomBar.buttonPanel.updateButtons(true);
		
		switchFocusToTitles();
	}

	function endPage()
	{
		_showOnMapButton._alpha = 100;
		_toggleActiveButton._alpha = 100;

		_bottomBar.buttonPanel.clearButtons();

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
				var quest: Object = undefined;
				if (ObjectiveList.selectedEntry != undefined && ObjectiveList.selectedEntry.questTargetID != undefined) {
					quest = ObjectiveList.selectedEntry;
				} else {
					quest = ObjectiveList.entryList[0];
				}
				if (quest != undefined && quest.questTargetID != undefined) {
					_parent._parent.CloseMenu();
					GameDelegate.call("ShowTargetOnMap", [quest.questTargetID]);
				} else {
					GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				}
				bhandledInput = true;
			} else if (TitleList.entryList.length > 0) {
				if (details.navEquivalent == NavigationCode.LEFT && FocusHandler.instance.getFocus(0) != TitleList) {
					switchFocusToTitles();
					bhandledInput = true;
				} else if (details.navEquivalent == NavigationCode.RIGHT && FocusHandler.instance.getFocus(0) != ObjectiveList) {
					switchFocusToObjectives();
					bhandledInput = true;
				}
			}
		}
		if (!bhandledInput && pathToFocus != undefined && pathToFocus.length > 0) {
			bhandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return bhandledInput;
	}

	private function isViewingMiscObjectives(): Boolean
	{
		return bHasMiscQuests && TitleList.selectedEntry.formID == 0;
	}

	function onTitleListSelect(): Void
	{
		if (TitleList.selectedEntry != undefined && !TitleList.selectedEntry.completed) {
			if (!isViewingMiscObjectives()) {
				GameDelegate.call("ToggleQuestActiveStatus", [TitleList.selectedEntry.formID, TitleList.selectedEntry.instance], this, "onToggleQuestActive");
				return;
			}
			TitleList.selectedEntry.active = !TitleList.selectedEntry.active;
			GameDelegate.call("ToggleShowMiscObjectives", [TitleList.selectedEntry.active]);
			TitleList.UpdateList();
		}
	}

	function onObjectiveListSelect(): Void
	{
		if (isViewingMiscObjectives()) {
			GameDelegate.call("ToggleQuestActiveStatus", [ObjectiveList.selectedEntry.formID, ObjectiveList.selectedEntry.instance], this, "onToggleQuestActive");
		}
	}

	private function switchFocusToTitles(): Void
	{
		FocusHandler.instance.setFocus(TitleList, 0);
		Divider.gotoAndStop("Right");
		_toggleActiveButton._alpha = 100;
		ObjectiveList.selectedIndex = -1;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = true;
		}
		updateShowOnMapButtonAlpha(0);
	}

	private function switchFocusToObjectives(): Void
	{
		FocusHandler.instance.setFocus(ObjectiveList, 0);
		Divider.gotoAndStop("Left");
		_toggleActiveButton._alpha = isViewingMiscObjectives() ? 100 : 50;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = false;
		}
		ObjectiveList.selectedIndex = 0;
		updateShowOnMapButtonAlpha(0);
	}

	private function onObjectiveListHighlight(event): Void
	{
		updateShowOnMapButtonAlpha(event.index);
	}

	private function updateShowOnMapButtonAlpha(a_entryIdx: Number): Void
	{
		var alpha: Number = 50;

		if (bAllowShowOnMap && (a_entryIdx >= 0 && ObjectiveList.entryList[a_entryIdx].questTargetID != undefined) || (ObjectiveList.entryList.length > 0 && ObjectiveList.entryList[0].questTargetID != undefined)) {
			alpha = 100;
		}
		_toggleActiveButton._alpha = ((!TitleList.selectedEntry.completed) ? 100 : 50);

		_showOnMapButton._alpha = alpha;
	}

	private function onToggleQuestActive(a_bnewActiveStatus: Number): Void
	{
		if (isViewingMiscObjectives()) {
			var iformID: Number = ObjectiveList.selectedEntry.formID;
			var iinstance: Number = ObjectiveList.selectedEntry.instance;
			for (var i: String in ObjectiveList.entryList) {
				if (ObjectiveList.entryList[i].formID == iformID && ObjectiveList.entryList[i].instance == iinstance) {
					ObjectiveList.entryList[i].active = a_bnewActiveStatus;
				}
			}
			ObjectiveList.UpdateList();
		} else {
			TitleList.selectedEntry.active = a_bnewActiveStatus;
			TitleList.UpdateList();
		}
		if (a_bnewActiveStatus) {
			GameDelegate.call("PlaySound", ["UIQuestActive"]);
			return;
		}
		GameDelegate.call("PlaySound", ["UIQuestInactive"]);
	}

	private function onQuestsDataComplete(auiSavedFormID: Number, auiSavedInstance: Number, abAddMiscQuest: Boolean, abMiscQuestActive: Boolean, abAllowShowOnMap: Boolean): Void
	{
		bAllowShowOnMap = abAllowShowOnMap;

		if (abAddMiscQuest)	{
			TitleList.entryList.push({text: "$MISCELLANEOUS", formID: 0, instance: 0, active: abMiscQuestActive, completed: false, type: 0});
			bHasMiscQuests = true;
		}
		var itimeCompleted: Number = undefined;
		var bCompleted = false;
		var bUncompleted = false;
		
		for (var i: Number = 0; i < TitleList.entryList.length; i++) {
			if (TitleList.entryList[i].formID == 0) {
				// Is a misc quest
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
		
		var isavedIndex: Number = 0;

		for (var i: Number = 0; i < TitleList.entryList.length; i++) {
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
			var aCategories: Array = ["Misc", "Main", "MagesGuild", "ThievesGuild", "DarkBrotherhood", "Companion", "Favor", "Daedric", "Misc", "CivilWar", "DLC01", "DLC02"];
			QuestTitleText.SetText(TitleList.selectedEntry.text);
			if (TitleList.selectedEntry.objectives == undefined) {
				GameDelegate.call("RequestObjectivesData", []);
			}
			ObjectiveList.entryList = TitleList.selectedEntry.objectives;
			SetDescriptionText();
			questTitleEndpieces.gotoAndStop(aCategories[TitleList.selectedEntry.type]);
			questTitleEndpieces._visible = true;
			ObjectivesHeader._visible = !isViewingMiscObjectives();
			ObjectiveList.selectedIndex = -1;
			ObjectiveList.scrollPosition = 0;
			if (iPlatform != 0) {
				ObjectiveList.disableSelection = true;
			}

			_showOnMapButton._visible = true;
			updateShowOnMapButtonAlpha(0);
		} else {
			NoQuestsText.SetText("No Active Quests");
			DescriptionText.SetText(" ");
			QuestTitleText.SetText(" ");
			ObjectiveList.ClearList();
			questTitleEndpieces._visible = false;
			ObjectivesHeader._visible = false;

			_showOnMapButton._visible = false;
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
		if (isViewingMiscObjectives()) {
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

	function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		if (a_platform == 0) {
			_toggleActiveControls = {keyCode: 28}; // Enter
			_showOnMapControls = {keyCode: 50}; // M
			_deleteControls = {keyCode: 45}; // X
		} else {
			_toggleActiveControls = {keyCode: 276}; // 360_A
			_showOnMapControls = {keyCode: 278}; // 360_X
			_deleteControls = {keyCode: 278}; // 360_X
		}

		iPlatform = a_platform;
		TitleList.SetPlatform(a_platform, a_bPS3Switch);
		ObjectiveList.SetPlatform(a_platform, a_bPS3Switch);
	}

}
