import Shared.ButtonTextArtHolder;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

class SystemPage extends MovieClip
{
	public static var MAIN_STATE: Number = 0;
	public static var SAVE_LOAD_STATE: Number = 1;
	public static var SAVE_LOAD_CONFIRM_STATE: Number = 2;
	public static var SETTINGS_CATEGORY_STATE: Number = 3;
	public static var OPTIONS_LISTS_STATE: Number = 4;
	public static var DEFAULT_SETTINGS_CONFIRM_STATE: Number = 5;
	public static var INPUT_MAPPING_STATE: Number = 6;
	public static var QUIT_CONFIRM_STATE: Number = 7;
	public static var PC_QUIT_LIST_STATE: Number = 8;
	public static var PC_QUIT_CONFIRM_STATE: Number = 9;
	public static var DELETE_SAVE_CONFIRM_STATE: Number = 10;
	public static var HELP_LIST_STATE: Number = 11;
	public static var HELP_TEXT_STATE: Number = 12;
	public static var TRANSITIONING: Number = 13;
	public static var MOD_CONFIG_STATE: Number = 14;

	public static var SAVE_INDEX: Number = 0;
	public static var LOAD_INDEX: Number = 1;
	public static var SETTINGS_INDEX: Number = 2;
	public static var MOD_CONFIG_INDEX: Number = 3;
	public static var CONTROLS_INDEX: Number = 4;
	public static var HELP_INDEX: Number = 5;
	public static var QUIT_INDEX: Number = 6;
	
	var HelpButtonHolder: ButtonTextArtHolder;
	
	var BottomBar_mc: MovieClip;
	var CategoryList: MovieClip;
	var CategoryList_mc: MovieClip;
	var ConfirmPanel: MovieClip;
	var HelpList: MovieClip;
	var HelpListPanel: MovieClip;
	var HelpTextPanel: MovieClip;
	var InputMappingPanel: MovieClip;
	var MappingList: MovieClip;
	var OptionsListsPanel: MovieClip;
	var PCQuitList: MovieClip;
	var PCQuitPanel: MovieClip;
	var PanelRect: MovieClip;
	var SaveLoadListHolder: MovieClip;
	var SaveLoadPanel: MovieClip;
	var SettingsList: MovieClip;
	var SettingsPanel: MovieClip;
	var SystemDivider: MovieClip;
	var TopmostPanel: MovieClip;
	
	var ConfirmTextField: TextField;
	var ErrorText: TextField;
	var HelpText: TextField;
	var HelpTitleText: TextField;
	var VersionText: TextField;
	
	var bMenuClosing: Boolean;
	var bRemapMode: Boolean;
	var bSavingSettings: Boolean;
	var bSettingsChanged: Boolean;
	var bUpdated: Boolean;
	var bShowKinectTunerButton: Boolean;
	
	var iCurrentState: Number;
	var iDebounceRemapModeID: Number;
	var iHideErrorTextID: Number;
	var iPlatform: Number;
	var iSaveDelayTimerID: Number;
	var iSavingSettingsTimerID: Number;

	private var _saveDisabledList: Array;

	private var _deleteControls: Object;
	private var _defaultControls: Object;
	private var _kinectControls: Object;
	private var _acceptControls: Object;
	private var _cancelControls: Object;

	private var _acceptButton: MovieClip;
	private var _cancelButton: MovieClip;

	private var _skyrimVersion: Number;
	private var _skyrimVersionMinor: Number;
	private var _skyrimVersionBuild: Number;


	function SystemPage()
	{
		super();
		CategoryList = CategoryList_mc.List_mc;
		SaveLoadListHolder = SaveLoadPanel;
		SettingsList = SettingsPanel.List_mc;
		MappingList = InputMappingPanel.List_mc;
		PCQuitList = PCQuitPanel.List_mc;
		HelpList = HelpListPanel.List_mc;
		HelpText = HelpTextPanel.HelpTextHolder.HelpText;
		HelpButtonHolder = HelpTextPanel.HelpTextHolder.ButtonArtHolder;
		HelpTitleText = HelpTextPanel.HelpTextHolder.TitleText;
		ConfirmTextField = ConfirmPanel.ConfirmText.textField;
		TopmostPanel = PanelRect;
		bUpdated = false;
		bRemapMode = false;
		bSettingsChanged = false;
		bMenuClosing = false;
		bSavingSettings = false;
		bShowKinectTunerButton = false;
		iPlatform = 0;
	}

	function onLoad(): Void
	{
		CategoryList.entryList.push({text: "$SAVE", index: SystemPage.SAVE_INDEX});
		CategoryList.entryList.push({text: "$LOAD", index: SystemPage.LOAD_INDEX});
		CategoryList.entryList.push({text: "$SETTINGS", index: SystemPage.SETTINGS_INDEX});
		CategoryList.entryList.push({text: "$CONTROLS", index: SystemPage.CONTROLS_INDEX});
		CategoryList.entryList.push({text: "$HELP", index: SystemPage.HELP_INDEX});
		CategoryList.entryList.push({text: "$QUIT", index: SystemPage.QUIT_INDEX});

		_saveDisabledList = CategoryList.entryList.slice();  // Make copy
		_saveDisabledList.splice(4, 1); //[CategoryList.entryList[0], CategoryList.entryList[1], CategoryList.entryList[2], CategoryList.entryList[3], CategoryList.entryList[5]]

		CategoryList.InvalidateData();

		CategoryList.addEventListener("itemPress", this, "onCategoryButtonPress");
		CategoryList.addEventListener("listPress", this, "onCategoryListPress");
		CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		CategoryList.disableInput = true; // Bugfix for vanilla

		ConfirmPanel.handleInput = function () {
			return false;
		};

		SaveLoadListHolder.addEventListener("saveGameSelected", this, "ConfirmSaveGame");
		SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
		SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
		SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
		SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");
		SettingsList.entryList = [{text: "$Gameplay"}, {text: "$Display"}, {text: "$Audio"}];
		SettingsList.InvalidateData();
		SettingsList.addEventListener("itemPress", this, "onSettingsCategoryPress");
		SettingsList.disableInput = true;
		InputMappingPanel.List_mc.addEventListener("itemPress", this, "onInputMappingPress");
		GameDelegate.addCallBack("FinishRemapMode", this, "onFinishRemapMode");
		GameDelegate.addCallBack("SettingsSaved", this, "onSettingsSaved");
		GameDelegate.addCallBack("RefreshSystemButtons", this, "RefreshSystemButtons");
		PCQuitList.entryList = [{text: "$Main Menu"}, {text: "$Desktop"}];
		PCQuitList.InvalidateData();
		PCQuitList.addEventListener("itemPress", this, "onPCQuitButtonPress");
		HelpList.addEventListener("itemPress", this, "onHelpItemPress");
		HelpList.disableInput = true;
		HelpTitleText.textAutoSize = "shrink";
		BottomBar_mc = _parent._parent.BottomBar_mc;
		GameDelegate.addCallBack("BackOutFromLoadGame", this, "BackOutFromLoadGame");
	}

	function startPage(): Void
	{
		CategoryList.disableInput = false; // Bugfix for vanilla
		if (!bUpdated) {
			currentState = SystemPage.MAIN_STATE;

			GameDelegate.call("SetVersionText", [VersionText]);

			var versionArr: Array = VersionText.text.split("."); // "1.8.151.0.7" without SKSE, "1.8.151.0.7 (SKSE 1.6.9 rel 37)" with
			_skyrimVersion = versionArr[0];
			_skyrimVersionMinor = versionArr[1];
			_skyrimVersionBuild = versionArr[2];

			GameDelegate.call("ShouldShowKinectTunerOption", [], this, "SetShouldShowKinectTunerOption");
			GameDelegate.call("SetSaveDisabled", _saveDisabledList);

			if (_global.skse != undefined) {
				CategoryList.entryList.push({text: "$MOD CONFIGURATION", index: SystemPage.MOD_CONFIG_INDEX});
				CategoryList.entryList.sortOn("index");
				CategoryList.InvalidateData();
			} else {
				CategoryList.entryList.sortOn("index");
				CategoryList.UpdateList();
			}

			bUpdated = true;
			return;
		}
		UpdateStateFocus(iCurrentState);
	}

	function endPage(): Void
	{
		BottomBar_mc.buttonPanel.clearButtons();

		CategoryList.disableInput = true; // Bugfix for vanilla
	}

	function get currentState(): Number
	{
		return iCurrentState;
	}

	function set currentState(aiNewState: Number): Void
	{
		var Panel_mc: MovieClip = GetPanelForState(aiNewState);
		iCurrentState = aiNewState;
		if (Panel_mc != TopmostPanel) {
			Panel_mc.swapDepths(TopmostPanel);
			TopmostPanel = Panel_mc;
		}
		UpdateStateFocus(aiNewState);
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bhandledInput: Boolean = false;
		if (bRemapMode || bMenuClosing || bSavingSettings || iCurrentState == SystemPage.TRANSITIONING) {
			bhandledInput = true;
		} else if (GlobalFunc.IsKeyPressed(details, iCurrentState != SystemPage.INPUT_MAPPING_STATE)) {

			if (iCurrentState != SystemPage.OPTIONS_LISTS_STATE) {
				if (details.navEquivalent == NavigationCode.RIGHT && iCurrentState == SystemPage.MAIN_STATE) {
					details.navEquivalent = NavigationCode.ENTER;
				} else if (details.navEquivalent == NavigationCode.LEFT && iCurrentState != SystemPage.MAIN_STATE) {
					details.navEquivalent = NavigationCode.TAB;
				}
			}

			if ((details.navEquivalent == NavigationCode.GAMEPAD_L2 || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R2) && isConfirming()) {
				bhandledInput = true;
			} else if ((details.navEquivalent == NavigationCode.GAMEPAD_X || details.code == 88) && iCurrentState == SystemPage.SAVE_LOAD_STATE) {
				ConfirmDeleteSave();
				bhandledInput = true;
			} else if ((details.navEquivalent == NavigationCode.GAMEPAD_Y || details.code == 84) && (iCurrentState == SystemPage.OPTIONS_LISTS_STATE || iCurrentState == SystemPage.INPUT_MAPPING_STATE)) {
				ConfirmTextField.SetText("$Reset settings to default values?");
				StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
				bhandledInput = true;
			} else if (bShowKinectTunerButton && details.navEquivalent == NavigationCode.GAMEPAD_R1 && iCurrentState == SystemPage.OPTIONS_LISTS_STATE) {
				GameDelegate.call("OpenKinectTuner", []);
				bhandledInput = true;
			} else if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
				if (details.navEquivalent == NavigationCode.ENTER) {
					bhandledInput = onAcceptPress();
				} else if (details.navEquivalent == NavigationCode.TAB) {
					bhandledInput = onCancelPress();
				}
			}
		}
		return bhandledInput;
	}

	function onAcceptPress(): Boolean
	{
		var bAcceptPressed: Boolean = true;
		
		switch (iCurrentState) {
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.TRANSITIONING:
				if (SaveLoadListHolder.List_mc.disableSelection) {
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					bMenuClosing = true;
					if (SaveLoadListHolder.isSaving) {
						ConfirmPanel._visible = false;
						if (iPlatform > 1) {
							ErrorText.SetText("$Saving content. Please don\'t turn off your console.");
						} else {
							ErrorText.SetText("$Saving...");
						}
						iSaveDelayTimerID = setInterval(this, "DoSaveGame", 1);
					} else {
						GameDelegate.call("LoadGame", [SaveLoadListHolder.selectedIndex]);
					}
				}
				break;
				
			case SystemPage.QUIT_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				GameDelegate.call("QuitToMainMenu", []);
				bMenuClosing = true;
				break;
				
			case SystemPage.PC_QUIT_CONFIRM_STATE:
				if (PCQuitList.selectedIndex == 0) {
					GameDelegate.call("QuitToMainMenu", []);
					bMenuClosing = true;
				} else if (PCQuitList.selectedIndex == 1) {
					GameDelegate.call("QuitToDesktop", []);
				}
				break;
				
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
				SaveLoadListHolder.DeleteSelectedSave();
				if (SaveLoadListHolder.numSaves == 0) {
					GetPanelForState(SystemPage.SAVE_LOAD_STATE).gotoAndStop(1);
					GetPanelForState(SystemPage.DELETE_SAVE_CONFIRM_STATE).gotoAndStop(1);
					currentState = SystemPage.MAIN_STATE;
				} else {
					EndState();
				}
				break;
				
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				if (ConfirmPanel.returnState == SystemPage.OPTIONS_LISTS_STATE) {
					ResetSettingsToDefaults();
				} else if (ConfirmPanel.returnState == SystemPage.INPUT_MAPPING_STATE) {
					ResetControlsToDefaults();
				}
				EndState();
				break;
				
			default:
				bAcceptPressed = false;
				break;
		}
		return bAcceptPressed;		
	}

	function onCancelPress(): Boolean
	{
		var bCancelPressed: Boolean = true;
		
		switch (iCurrentState) {
			case SystemPage.SAVE_LOAD_STATE:
			case SystemPage.PC_QUIT_LIST_STATE:
			case SystemPage.HELP_LIST_STATE:
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:	
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				break;
				
			case SystemPage.HELP_TEXT_STATE:
				GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				StartState(SystemPage.HELP_LIST_STATE);
				HelpListPanel.bCloseToMainState = true;
				break;
				
			case SystemPage.OPTIONS_LISTS_STATE:
				GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				StartState(SystemPage.SETTINGS_CATEGORY_STATE);
				SettingsPanel.bCloseToMainState = true;
				break;
				
			case SystemPage.INPUT_MAPPING_STATE:
			case SystemPage.SETTINGS_CATEGORY_STATE:
				GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				if (bSettingsChanged) {
					ErrorText.SetText("$Saving...");
					bSavingSettings = true;
					if (iCurrentState == SystemPage.INPUT_MAPPING_STATE) {
						iSavingSettingsTimerID = setInterval(this, "SaveControls", 1000);
					} else if (iCurrentState == SystemPage.SETTINGS_CATEGORY_STATE) {
						iSavingSettingsTimerID = setInterval(this, "SaveSettings", 1000);
					}
				} else {
					onSettingsSaved();
				}
				break;
				
			default:
				bCancelPressed = false;
				break;
		}
		return bCancelPressed;
	}

	function isConfirming(): Boolean
	{
		return iCurrentState == SystemPage.SAVE_LOAD_CONFIRM_STATE || iCurrentState == SystemPage.QUIT_CONFIRM_STATE || iCurrentState == SystemPage.PC_QUIT_CONFIRM_STATE || iCurrentState == SystemPage.DELETE_SAVE_CONFIRM_STATE || iCurrentState == SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE;
	}

	function onAcceptMousePress(): Void
	{
		if (isConfirming()) {
			onAcceptPress();
		}
	}

	function onCancelMousePress(): Void
	{
		if (isConfirming()) {
			onCancelPress();
		}
	}

	function onCategoryButtonPress(event: Object): Void
	{
		if (event.entry.disabled) {
			GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			return;
		}

		if (iCurrentState == SystemPage.MAIN_STATE) 
		{
			switch (event.entry.index) {
				case SystemPage.SAVE_INDEX:
					SaveLoadListHolder.isSaving = true;
					GameDelegate.call("SAVE", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
					break;
					
				case SystemPage.LOAD_INDEX:
					SaveLoadListHolder.isSaving = false;
					GameDelegate.call("LOAD", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
					break;
					
				case SystemPage.SETTINGS_INDEX:
					StartState(SystemPage.SETTINGS_CATEGORY_STATE);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					break;
					
				case SystemPage.MOD_CONFIG_INDEX:
					_root.QuestJournalFader.Menu_mc.ConfigPanelOpen();
					break;
					
				case SystemPage.CONTROLS_INDEX:
					if (MappingList.entryList.length == 0)
						requestInputMappings();
					StartState(SystemPage.INPUT_MAPPING_STATE);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					break;
					
				case SystemPage.HELP_INDEX:
					if (HelpList.entryList.length == 0) {
						GameDelegate.call("PopulateHelpTopics", [HelpList.entryList]);
						HelpList.entryList.sort(doABCSort);
						HelpList.InvalidateData();
					}
					if (HelpList.entryList.length == 0) {
						GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					} else {
						StartState(SystemPage.HELP_LIST_STATE);
						GameDelegate.call("PlaySound", ["UIMenuOK"]);
					}
					break;
					
				case SystemPage.QUIT_INDEX:
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					GameDelegate.call("RequestIsOnPC", [], this, "populateQuitList");
					break;
					
				default:
					GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					break;
			}
		}
	}

	function onCategoryListPress(event: Object): Void
	{
		if (!bRemapMode && !bMenuClosing && !bSavingSettings && iCurrentState != SystemPage.TRANSITIONING) {
			onCancelPress();
			CategoryList.disableSelection = false;
			CategoryList.UpdateList();
			CategoryList.disableSelection = true;
		}
	}

	function doABCSort(aObj1: Object, aObj2: Object): Number
	{
		if (aObj1.text < aObj2.text) {
			return -1;
		}
		if (aObj1.text > aObj2.text) {
			return 1;
		}
		return 0;
	}

	function onCategoryListMoveUp(event: Object): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	function onCategoryListMoveDown(event: Object): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	function onCategoryListMouseSelectionChange(event: Object): Void
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function OnSaveListOpenSuccess(): Void
	{
		if (SaveLoadListHolder.numSaves > 0) {
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(SystemPage.SAVE_LOAD_STATE);
			return;
		}
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
	}

	function ConfirmSaveGame(event: Object): Void
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			if (event.index == 0) {
				iCurrentState = SystemPage.SAVE_LOAD_CONFIRM_STATE;
				onAcceptPress();
				return;
			}
			ConfirmTextField.SetText("$Save over this game?");
			StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	function DoSaveGame(): Void
	{
		clearInterval(iSaveDelayTimerID);
		GameDelegate.call("SaveGame", [SaveLoadListHolder.selectedIndex]);
		_parent._parent.CloseMenu();
	}

	function onSaveHighlight(event: Object): Void
	{
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			BottomBar_mc.deleteButton._alpha = ((event.index == -1) ? 50 : 100);
			if (iPlatform == 0)
				GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function onSaveLoadListPress(): Void
	{
		onAcceptPress();
	}

	function ConfirmLoadGame(event: Object): Void
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			ConfirmTextField.SetText("$Load this game? All unsaved progress will be lost.");
			StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	function ConfirmDeleteSave(): Void
	{
		if (!SaveLoadListHolder.isSaving || SaveLoadListHolder.selectedIndex != 0) {
			SaveLoadListHolder.List_mc.disableSelection = true;
			if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
				ConfirmTextField.SetText("$Delete this save?");
				StartState(SystemPage.DELETE_SAVE_CONFIRM_STATE);
			}
		}
	}

	function onSettingsCategoryPress(): Void
	{
		var List_mc: MovieClip = OptionsListsPanel.OptionsLists.List_mc;
		
		switch (SettingsList.selectedIndex) {
			case 0:
				List_mc.entryList = [{text: "$Invert Y", movieType: 2}, {text: "$Look Sensitivity", movieType: 0}, {text: "$Vibration", movieType: 2}, {text: "$360 Controller", movieType: 2}, {text: "$Difficulty", movieType: 1, options: ["$Very Easy", "$Easy", "$Normal", "$Hard", "$Very Hard", "$Legendary"]}, {text: "$Show Floating Markers", movieType: 2}, {text: "$Save on Rest", movieType: 2}, {text: "$Save on Wait", movieType: 2}, {text: "$Save on Travel", movieType: 2}, {text: "$Save on Pause", movieType: 1, options: ["$5 Mins", "$10 Mins", "$15 Mins", "$30 Mins", "$45 Mins", "$60 Mins", "$Disabled"]}, {text: "$Use Kinect Commands", movieType: 2}];
				if (_skyrimVersion == 1 && _skyrimVersionMinor < 9)
					List_mc.entryList[4].options.pop(); // Versions prior to 1.9.26 don't have the Legendary option
				GameDelegate.call("RequestGameplayOptions", [List_mc.entryList]);
				break;
				
			case 1:
				List_mc.entryList = [{text: "$Brightness", movieType: 0}, {text: "$HUD Opacity", movieType: 0}, {text: "$Actor Fade", movieType: 0}, {text: "$Item Fade", movieType: 0}, {text: "$Object Fade", movieType: 0}, {text: "$Grass Fade", movieType: 0}, {text: "$Shadow Fade", movieType: 0}, {text: "$Light Fade", movieType: 0}, {text: "$Specularity Fade", movieType: 0}, {text: "$Tree LOD Fade", movieType: 0}, {text: "$Crosshair", movieType: 2}, {text: "$Dialogue Subtitles", movieType: 2}, {text: "$General Subtitles", movieType: 2}];
				GameDelegate.call("RequestDisplayOptions", [List_mc.entryList]);
				break;
				
			case 2:
				List_mc.entryList = [{text: "$Master", movieType: 0}];
				GameDelegate.call("RequestAudioOptions", [List_mc.entryList]);
				for (var i: String in List_mc.entryList)
					List_mc.entryList[i].movieType = 0;
				break;
		}
		
		for (var i: Number = 0; i < List_mc.entryList.length; ){
			if (List_mc.entryList[i].ID == undefined) {
				List_mc.entryList.splice(i, 1);
			} else {
				i++;
			}
		}
		
		if (iPlatform != 0) {
			List_mc.selectedIndex = 0;
		}
		
		List_mc.InvalidateData();
		SettingsPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.OPTIONS_LISTS_STATE);
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		bSettingsChanged = true;
	}

	function ResetSettingsToDefaults(): Void
	{
		var List_mc: MovieClip = OptionsListsPanel.OptionsLists.List_mc;
		for (var i: String in List_mc.entryList) {
			if (List_mc.entryList[i].defaultVal != undefined) {
				List_mc.entryList[i].value = List_mc.entryList[i].defaultVal;
				GameDelegate.call("OptionChange", [List_mc.entryList[i].ID, List_mc.entryList[i].value]);
			}
		}
		List_mc.bAllowValueOverwrite = true;
		List_mc.UpdateList();
		List_mc.bAllowValueOverwrite = false;
	}

	function onInputMappingPress(event: Object): Void
	{
		if (bRemapMode == false && iCurrentState == SystemPage.INPUT_MAPPING_STATE) 
		{
			MappingList.disableSelection = true;
			bRemapMode = true;
			ErrorText.SetText("$Press a button to map to this action.");
			GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
			GameDelegate.call("StartRemapMode", [event.entry.text, MappingList.entryList]);
		}
	}

	function onFinishRemapMode(abSuccess: Boolean): Void
	{
		if (abSuccess) {
			HideErrorText();
			MappingList.entryList.sort(inputMappingSort);
			MappingList.UpdateList();
			bSettingsChanged = true;
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		} else {
			ErrorText.SetText("$That button is reserved.");
			GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			iHideErrorTextID = setInterval(this, "HideErrorText", 1000);
		}
		MappingList.disableSelection = false;
		iDebounceRemapModeID = setInterval(this, "ClearRemapMode", 200);
	}

	private function inputMappingSort(a_obj1: Object, a_obj2: Object): Number
	{
		if (a_obj1.sortIndex < a_obj2.sortIndex) {
			return -1;
		}
		if (a_obj1.sortIndex > a_obj2.sortIndex) {
			return 1;
		}
		return 0;
	}

	function HideErrorText(): Void
	{
		if (iHideErrorTextID != undefined) {
			clearInterval(iHideErrorTextID);
		}
		ErrorText.SetText(" ");
	}

	function ClearRemapMode(): Void
	{
		if (iDebounceRemapModeID != undefined) {
			clearInterval(iDebounceRemapModeID);
			delete(iDebounceRemapModeID);
		}
		bRemapMode = false;
	}

	function ResetControlsToDefaults(): Void
	{
		GameDelegate.call("ResetControlsToDefaults", [MappingList.entryList]);
		requestInputMappings(true);
		bSettingsChanged = true;
	}

	function onHelpItemPress(): Void
	{
		GameDelegate.call("RequestHelpText", [HelpList.selectedEntry.index, HelpTitleText, HelpText]);
		ApplyHelpTextButtonArt();
		HelpListPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.HELP_TEXT_STATE);
	}

	function ApplyHelpTextButtonArt(): Void
	{
		var strTextWithButtons: String = HelpButtonHolder.CreateButtonArt(HelpText.textField);
		if (strTextWithButtons != undefined) 
			HelpText.htmlText = strTextWithButtons;
	}

	function populateQuitList(abOnPC: Boolean): Void
	{
		if (abOnPC) {
			if (iPlatform != 0) {
				PCQuitList.selectedIndex = 0;
			}
			StartState(SystemPage.PC_QUIT_LIST_STATE);
			return;
		}
		ConfirmTextField.textAutoSize = "shrink";
		ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
		StartState(SystemPage.QUIT_CONFIRM_STATE);
	}

	function onPCQuitButtonPress(event: Object): Void
	{
		if (iCurrentState == SystemPage.PC_QUIT_LIST_STATE) {
			PCQuitList.disableSelection = true;
			if (event.index == 0) {
				ConfirmTextField.textAutoSize = "shrink";
				ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
			}
			else if (event.index == 1) {
				ConfirmTextField.textAutoSize = "shrink";
				ConfirmTextField.SetText("$Quit to desktop?  Any unsaved progress will be lost.");
			}
			StartState(SystemPage.PC_QUIT_CONFIRM_STATE);
		}
	}

	function SaveControls(): Void
	{
		if (iSavingSettingsTimerID != undefined) {
			clearInterval(iSavingSettingsTimerID);
			delete(iSavingSettingsTimerID);
		}
		GameDelegate.call("SaveControls", []);
	}

	function SaveSettings(): Void
	{
		if (iSavingSettingsTimerID != undefined) {
			clearInterval(iSavingSettingsTimerID);
			delete(iSavingSettingsTimerID);
		}
		GameDelegate.call("SaveSettings", []);
	}

	function onSettingsSaved(): Void
	{
		bSavingSettings = false;
		bSettingsChanged = false;
		ErrorText.SetText(" ");
		EndState();
	}

	function RefreshSystemButtons()
	{
		_saveDisabledList.push(true);
		GameDelegate.call("SetSaveDisabled", _saveDisabledList);
		_saveDisabledList.pop();

		CategoryList.UpdateList();
	}

	function StartState(aiState: Number): Void
	{
		BottomBar_mc.buttonPanel.clearButtons();

		switch (aiState) {
			case SystemPage.SAVE_LOAD_STATE:
				SystemDivider.gotoAndStop("Left");
				BottomBar_mc.buttonPanel.addButton({text: "$Delete", controls: _deleteControls}); // X or 360_X
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;
				
			case SystemPage.INPUT_MAPPING_STATE:
				SystemDivider.gotoAndStop("Left");
			case SystemPage.OPTIONS_LISTS_STATE:
				BottomBar_mc.buttonPanel.addButton({text: "$Defaults", controls: _defaultControls}); // T or 360_Y
				if (aiState == SystemPage.OPTIONS_LISTS_STATE && bShowKinectTunerButton && iPlatform == 2 && SettingsList.selectedIndex == 0)
					BottomBar_mc.buttonPanel.addButton({text: "$Kinect Tuner", controls: _kinectControls}); // K or RB
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;
				
			case SystemPage.SETTINGS_CATEGORY_STATE:
			case SystemPage.PC_QUIT_LIST_STATE:
			case SystemPage.HELP_LIST_STATE:
				SystemDivider.gotoAndStop("Left");
				break;
				
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				ConfirmPanel.confirmType = aiState;
				ConfirmPanel.returnState = iCurrentState;
				break;
		}

		iCurrentState = SystemPage.TRANSITIONING;
		GetPanelForState(aiState).gotoAndPlay("start");
	}

	function EndState(): Void
	{
		BottomBar_mc.buttonPanel.clearButtons();

		switch (iCurrentState) {
			case SystemPage.SAVE_LOAD_STATE:
			case SystemPage.INPUT_MAPPING_STATE:
				SystemDivider.gotoAndStop("Right");
			case SystemPage.OPTIONS_LISTS_STATE:
				break;
				
			case SystemPage.HELP_LIST_STATE:
				HelpList.disableInput = true;
				if (HelpListPanel.bCloseToMainState != false) {
					SystemDivider.gotoAndStop("Right");
				}
				break;
				
			case SystemPage.SETTINGS_CATEGORY_STATE:
				SettingsList.disableInput = true;
				if (SettingsPanel.bCloseToMainState != false) {
					SystemDivider.gotoAndStop("Right");
				}
				break;
				
			case SystemPage.PC_QUIT_LIST_STATE:
				SystemDivider.gotoAndStop("Right");
				break;
		}
		if (iCurrentState != SystemPage.MAIN_STATE) 
		{
			GetPanelForState(iCurrentState).gotoAndPlay("end");
			iCurrentState = SystemPage.TRANSITIONING;
		}
	}

	function GetPanelForState(aiState: Number): MovieClip
	{
		switch (aiState) {
			case SystemPage.MAIN_STATE:
				return PanelRect;
				
			case SystemPage.SETTINGS_CATEGORY_STATE:
				return SettingsPanel;
				
			case SystemPage.OPTIONS_LISTS_STATE:
				return OptionsListsPanel;
				
			case SystemPage.INPUT_MAPPING_STATE:
				return InputMappingPanel;
				
			case SystemPage.SAVE_LOAD_STATE:
				return SaveLoadPanel;
				
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				return ConfirmPanel;
				
			case SystemPage.PC_QUIT_LIST_STATE:
				return PCQuitPanel;
				
			case SystemPage.HELP_LIST_STATE:
				return HelpListPanel;
				
			case SystemPage.HELP_TEXT_STATE:
				return HelpTextPanel;
		}
	}

	function UpdateStateFocus(aiNewState: Number): Void
	{
		CategoryList.disableSelection = aiNewState != SystemPage.MAIN_STATE;
		
		switch (aiNewState) {
			case SystemPage.MAIN_STATE:
				FocusHandler.instance.setFocus(CategoryList, 0);
				break;
			
			case SystemPage.SETTINGS_CATEGORY_STATE:
				SettingsList.disableInput = false;
				FocusHandler.instance.setFocus(SettingsList, 0);
				break;
			
			case SystemPage.OPTIONS_LISTS_STATE:
				FocusHandler.instance.setFocus(OptionsListsPanel.OptionsLists.List_mc, 0);
				break;
			
			case SystemPage.INPUT_MAPPING_STATE:
				FocusHandler.instance.setFocus(MappingList, 0);
				break;
			
			case SystemPage.SAVE_LOAD_STATE:
				FocusHandler.instance.setFocus(SaveLoadListHolder.List_mc, 0);
				SaveLoadListHolder.List_mc.disableSelection = false;
				break;
			
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				FocusHandler.instance.setFocus(ConfirmPanel, 0);
				break;
				
			case SystemPage.PC_QUIT_LIST_STATE:
				FocusHandler.instance.setFocus(PCQuitList, 0);
				PCQuitList.disableSelection = false;
				break;
				
			case SystemPage.HELP_LIST_STATE:
				HelpList.disableInput = false;
				FocusHandler.instance.setFocus(HelpList, 0);
				break;

			case SystemPage.HELP_TEXT_STATE:
				FocusHandler.instance.setFocus(HelpText, 0);
				break;
		}
	}

	function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		BottomBar_mc.SetPlatform(a_platform, a_bPS3Switch);
		CategoryList.SetPlatform(a_platform, a_bPS3Switch);


		if (a_platform != 0) {
			SettingsList.selectedIndex = 0;
			PCQuitList.selectedIndex = 0;
			HelpList.selectedIndex = 0;
			MappingList.selectedIndex = 0;

			_deleteControls = {keyCode: 278}; // 360_X
			_defaultControls = {keyCode: 279}; // 360_Y
			_kinectControls = {keyCode: 275}; // 360_RB
			_acceptControls = {keyCode: 276}; // 360_A
			_cancelControls = {keyCode: 277}; // 360_B
		} else {
			_deleteControls = {keyCode: 45}; // X
			_defaultControls = {keyCode: 20}; // T
			_kinectControls = {keyCode: 37}; // K
			_acceptControls = {keyCode: 28}; // Enter
			_cancelControls = {keyCode: 15}; // Tab
		}

		ConfirmPanel.buttonPanel.clearButtons();
		_acceptButton = ConfirmPanel.buttonPanel.addButton({text: "$Yes", controls: _acceptControls});
		_acceptButton.addEventListener("click", this, "onAcceptMousePress");
		_cancelButton = ConfirmPanel.buttonPanel.addButton({text: "$No", controls: _cancelControls});
		_cancelButton.addEventListener("click", this, "onCancelMousePress");
		ConfirmPanel.buttonPanel.updateButtons(true);

		iPlatform = a_platform;
		SaveLoadListHolder.platform = a_platform;

		requestInputMappings();
	}

	function BackOutFromLoadGame(): Void
	{
		bMenuClosing = false;
		onCancelPress();
	}
	
	function SetShouldShowKinectTunerOption(abFlag: Boolean): Void
	{
		bShowKinectTunerButton = abFlag == true;
	}

	private function requestInputMappings(a_updateOnly: Boolean): Void
	{
		MappingList.entryList.splice(0);
		GameDelegate.call("RequestInputMappings", [MappingList.entryList]);
		MappingList.entryList.sort(inputMappingSort);
		if (a_updateOnly)
			MappingList.UpdateList();
		else
			MappingList.InvalidateData();
	}
}
