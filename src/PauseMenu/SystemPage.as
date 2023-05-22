import Shared.ButtonTextArtHolder;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;
import skyui.defines.Input;
import skyui.VRInput;

import skyui.util.Debug;

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
	public static var CHARACTER_LOAD_STATE: Number = 14;
	public static var CHARACTER_SELECTION_STATE: Number = 15;

	public static var MOD_MANAGER_BUTTON_INDEX: Number = 3;
	public static var CONTROLS_BUTTON_INDEX: Number = 5

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
	var bDefaultButtonVisible: Boolean;
	var bIsRemoteDevice: Boolean;

	private var _saveDisabledList: Array;

	private var _deleteControls: Object;
	private var _defaultControls: Object;
	private var _kinectControls: Object;
	private var _acceptControls: Object;
	private var _cancelControls: Object;
	private var _characterSelectionControls: Object;

	private var _acceptButton: MovieClip;
	private var _cancelButton: MovieClip;

	private var _skyrimVersion: Number;
	private var _skyrimVersionMinor: Number;
	private var _skyrimVersionBuild: Number;

	private var _showModMenu: Boolean;
	private var _showControlsMenu: Boolean;
	private var _deleteButton: Object;

	private var pageWasEnded: Boolean = true;
	private var iTurnModeID: Number = undefined;
	private var bJustRefreshedSettings: Boolean  = false;

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
		bDefaultButtonVisible = false;
		_showModMenu = false;
		_showControlsMenu = false;
	}

	function GetIsRemoteDevice() {
		return bIsRemoteDevice;
	}

	function OnShow(): Void
	{
		if(pageWasEnded == false) {
			endPage();
		}

		bMenuClosing = false;
		bUpdated = false;
		bRemapMode = false;
		bSettingsChanged = false;
		bSavingSettings = false;
		bShowKinectTunerButton = false;
		bDefaultButtonVisible = false;

		// Reset all panels and their animations (?)
		var cursor = SystemPage.SAVE_LOAD_STATE;
		while(cursor <= SystemPage.CHARACTER_SELECTION_STATE) {
			GetPanelForState(cursor).gotoAndStop(1);
			cursor++;
		}

		SystemDivider.gotoAndStop("Right");
		HideErrorText();
		GameDelegate.call("ShouldShowMod", [], this, "SetShowMod");
		if(Shared.Platforms.IsUsingWands(iPlatform)) {
			_showControlsMenu = false;
		} else {
			_showControlsMenu = true;
		}

		/* CategoryList.clearList(); */
		CategoryList.entryList = new Array();
		CategoryList.entryList.push({text: "$QUICKSAVE"});
		CategoryList.entryList.push({text: "$SAVE"});
		CategoryList.entryList.push({text: "$LOAD"});
		CategoryList.entryList.push({text: "$SETTINGS"});
		CategoryList.entryList.push({text: "$MOD CONFIGURATION"});
		if(_showModMenu) {
			CategoryList.entryList.push({text:"$MOD MANAGER"});
		}
		if(_showControlsMenu) {
			CategoryList.entryList.push({text: "$CONTROLS"});
		}
		CategoryList.entryList.push({text: "$HELP"});
		CategoryList.entryList.push({text: "$QUIT"});

		CategoryList.InvalidateData();

		ConfirmPanel.handleInput = function () {
			return false;
		};

		if(HelpList.entryList.length != 0) {
			HelpList.entryList = new Array();
		}
	}

	static function IsOrbis(aiPlatform)
	{
		return aiPlatform == Shared.Platforms.CONTROLLER_ORBIS || aiPlatform == Shared.Platforms.CONTROLLER_ORBIS_MOVE;
	}

	function onLoad()
	{
		OnShow();
		SaveLoadListHolder.addEventListener("saveGameSelected", this, "ConfirmSaveGame");
		SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
		SaveLoadListHolder.addEventListener("saveListCharactersPopulated", this, "OnSaveListCharactersOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListOnBatchAdded", this, "OnSaveListBatchAdded");
		SaveLoadListHolder.addEventListener("OnCharacterSelected", this, "OnCharacterSelected");
		GameDelegate.addCallBack("OnSaveDataEventSaveSUCCESS", this, "OnSaveDataEventSaveSUCCESS");
		GameDelegate.addCallBack("OnSaveDataEventSaveCANCEL", this, "OnSaveDataEventSaveCANCEL");
		GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL", this, "OnSaveDataEventLoadCANCEL");
		SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
		SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");

		CategoryList.addEventListener("itemPress", this,"onCategoryButtonPress");
		CategoryList.addEventListener("listPress", this,"onCategoryListPress");
		CategoryList.addEventListener("listMovedUp", this,"onCategoryListMoveUp");
		CategoryList.addEventListener("listMovedDown", this,"onCategoryListMoveDown");
		CategoryList.addEventListener("selectionChange", this,"onCategoryListMouseSelectionChange");
		this.CategoryList.disableInput = true;
		SettingsList.entryList = [{text: "$Gameplay"}, {text: "$Display"}, {text: "$Audio"}, {text: "$VR"}, {text: "$VR Performance"}];
		SettingsList.InvalidateData();
		SettingsList.addEventListener("itemPress", this, "onSettingsCategoryPress");
		SettingsList.disableInput = true;
		InputMappingPanel.List_mc.addEventListener("itemPress", this, "onInputMappingPress");
		GameDelegate.addCallBack("FinishRemapMode", this, "onFinishRemapMode");
		GameDelegate.addCallBack("SettingsSaved", this, "onSettingsSaved");
		GameDelegate.addCallBack("RefreshSystemButtons", this, "RefreshSystemButtons");
		PCQuitList.entryList = [{text: "$Main Menu"}, {text: "$Desktop"}];
		PCQuitList.UpdateList();
		PCQuitList.addEventListener("itemPress", this, "onPCQuitButtonPress");
		HelpList.addEventListener("itemPress", this, "onHelpItemPress");
		HelpList.disableInput = true;
		HelpTitleText.textAutoSize = "shrink";
		BottomBar_mc = _parent._parent.BottomBar_mc;
		GameDelegate.addCallBack("BackOutFromLoadGame", this, "BackOutFromLoadGame");
		GameDelegate.addCallBack("SetRemoteDevice", this, "SetRemoteDevice");
		GameDelegate.addCallBack("UpdatePermissions", this, "UpdatePermissions");
		GameDelegate.addCallBack("ConfirmDeleteSave", this, "ConfirmDeleteSave");
		GameDelegate.addCallBack("StartDefaultSettingsConfirmState", this, "StartDefaultSettingsConfirmState");
		GameDelegate.addCallBack("UpdateVRPerformanceValues", this, "UpdateVRPerformanceValues");
	}

	function SetShowMod(bshow) {
		_showModMenu = bshow;
	}

	function startPage(): Void
	{
		pageWasEnded = false;
		CategoryList.disableInput = false; // Bugfix for vanilla
		if (!bUpdated) {
			currentState = SystemPage.MAIN_STATE;

			GameDelegate.call("SetVersionText", [VersionText]);

			var versionArr: Array = VersionText.text.split("."); // "1.8.151.0.7" without SKSE, "1.8.151.0.7 (SKSE 1.6.9 rel 37)" with
			_skyrimVersion = versionArr[0];
			_skyrimVersionMinor = versionArr[1];
			_skyrimVersionBuild = versionArr[2];

			GameDelegate.call("ShouldShowKinectTunerOption", [], this, "SetShouldShowKinectTunerOption");

			UpdatePermissions();
			bUpdated = true;
		} else {
			UpdateStateFocus(iCurrentState);
		}
	}

	function endPage(): Void
	{
		BottomBar_mc.buttonPanel.clearButtons();

		CategoryList.disableInput = true; // Bugfix for vanilla

		pageWasEnded = true;
	}

	function get currentState(): Number
	{
		return iCurrentState;
	}

	function set currentState(aiNewState: Number): Void
	{
		if(aiNewState == undefined)
			return;

		if(aiNewState == SystemPage.MAIN_STATE) {
			SaveLoadListHolder.isShowingCharacterList = false;
		} else if (aiNewState == SystemPage.SAVE_LOAD_STATE && this.SaveLoadListHolder.isShowingCharacterList) {
			aiNewState = SystemPage.CHARACTER_SELECTION_STATE;
		}

		var Panel_mc: MovieClip = GetPanelForState(aiNewState);
		iCurrentState = aiNewState;
		if (Panel_mc != TopmostPanel) {
			Panel_mc.swapDepths(TopmostPanel);
			TopmostPanel = Panel_mc;
		}
		UpdateStateFocus(aiNewState);
		GameDelegate.call("SetJournalMenuState", [aiNewState]);
	}

  function OnSaveDataEventSaveSUCCESS()
  {
    if(SystemPage.IsOrbis(iPlatform))
    {
      this.bMenuClosing = true;
      this.EndState();
    }
  }

  function OnSaveDataEventSaveCANCEL()
  {
    if(SystemPage.IsOrbis(iPlatform))
    {
      this.HideErrorText();
      this.EndState();
      this.StartState(SystemPage.SAVE_LOAD_STATE);
    }
  }

  function OnSaveDataEventLoadCANCEL()
  {
    this.StartState(SystemPage.CHARACTER_SELECTION_STATE);
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
        if(SystemPage.IsOrbis(iPlatform))
        {
          gfx.io.GameDelegate.call("ORBISDeleteSave",[]);
        } else {
					ConfirmDeleteSave();
				}
				bhandledInput = true;
			} else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && iCurrentState == SystemPage.SAVE_LOAD_STATE && !SaveLoadListHolder.isSaving) {
            StartState(SystemPage.CHARACTER_LOAD_STATE);
            bhandledInput = true;
      } else if ((details.navEquivalent == NavigationCode.GAMEPAD_Y || details.code == 84) && (iCurrentState == SystemPage.OPTIONS_LISTS_STATE || iCurrentState == SystemPage.INPUT_MAPPING_STATE)) {
        StartDefaultSettingsConfirmState();
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
      case SystemPage.CHARACTER_SELECTION_STATE:
        GameDelegate.call("PlaySound",["UIMenuOK"]);
        GameDelegate.call("CharacterSelected",[SaveLoadListHolder.selectedIndex]);
        break;

			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.TRANSITIONING:
				if (SaveLoadListHolder.List_mc.disableSelection) {
					GameDelegate.call("PlaySound", ["UIMenuOK"]);

          if(SystemPage.IsOrbis(iPlatform))
          {
            if(this.SaveLoadListHolder.isSaving)
            {
              this.iSaveDelayTimerID = setInterval(this,"DoSaveGame",1);
            }
            else
            {
              gfx.io.GameDelegate.call("LoadGame",[this.SaveLoadListHolder.selectedIndex]);
            }
          }
          else
          {
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
				}
				break;

			case SystemPage.QUIT_CONFIRM_STATE:
				// Have skyui dll release any GFxValues it's holding before actually quitting
				Debug.log(">>> Quest_Journal SystemPage.QUIT_CONFIRM_STATE");
				VRInput.instance.teardown();
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				GameDelegate.call("QuitToMainMenu", []);
				bMenuClosing = true;
				Debug.log("<<< Quest_Journal SystemPage.QUIT_CONFIRM_STATE");
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
          SystemDivider.gotoAndStop("Right");
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
      case SystemPage.CHARACTER_LOAD_STATE:
      case SystemPage.CHARACTER_SELECTION_STATE:
			case SystemPage.SAVE_LOAD_STATE:
        SaveLoadListHolder.ForceStopLoading();

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

	function StartDefaultSettingsConfirmState(): Void
	{
		if(iCurrentState == SystemPage.OPTIONS_LISTS_STATE || iCurrentState == SystemPage.INPUT_MAPPING_STATE)
		{
			ConfirmTextField.SetText("$Reset settings to default values?");
			StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
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
			var categoryName = CategoryList.entryList[event.index].text;

			switch (categoryName) {
				case "$QUICKSAVE":
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					GameDelegate.call("QuickSave", []);
					break;

				case "$SAVE":
          GameDelegate.call("UseCurrentCharacterFilter",[]);
          SaveLoadListHolder.isSaving = true;
          if (SystemPage.IsOrbis(iPlatform)) {
            SaveLoadListHolder.PopulateEmptySaveList();
          } else {
            GameDelegate.call("SAVE",[SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
          }
          break;

				case "$LOAD":
					SaveLoadListHolder.isSaving = false;
					GameDelegate.call("LOAD", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
					break;

        case "$MOD MANAGER":
          gfx.io.GameDelegate.call("ModManager",[]);
          break;

				case "$SETTINGS":
					StartState(SystemPage.SETTINGS_CATEGORY_STATE);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					break;

				case "$MOD CONFIGURATION":
					_root.QuestJournalFader.Menu_mc.ConfigPanelOpen();
					break;

				case "$CONTROLS":
					if (MappingList.entryList.length == 0)
						requestInputMappings();
					StartState(SystemPage.INPUT_MAPPING_STATE);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					break;

				case "$HELP":
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

				case "$QUIT":
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
		if(aObj1.text.indexOf("VR ") >= 0 && aObj2.text.indexOf("VR ") >= 0)
		{
			if(aObj1.text < aObj2.text) {
				return -1;
			}
			if(aObj1.text > aObj2.text) {
				return 1;
			}
		}
		if(aObj1.text.indexOf("VR ") >= 0) {
		 	return -1;
		}
		if(aObj2.text.indexOf("VR ") >= 0) {
			return 1;
		}

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

  function OnCharacterSelected()
  {
    if(!SystemPage.IsOrbis(iPlatform)) {
      StartState(SystemPage.SAVE_LOAD_STATE);
    }
  }

  function OnSaveListCharactersOpenSuccess()
  {
    if(this.SaveLoadListHolder.numSaves > 0) {
      GameDelegate.call("PlaySound",["UIMenuOK"]);
      StartState(SystemPage.CHARACTER_SELECTION_STATE);
    } else {
      GameDelegate.call("PlaySound",["UIMenuCancel"]);
    }
  }

	function OnSaveListOpenSuccess(): Void
	{
		if (SaveLoadListHolder.numSaves > 0) {
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(SystemPage.SAVE_LOAD_STATE);
		} else {
			StartState(SystemPage.CHARACTER_LOAD_STATE);
		}
	}

	function OnSaveListBatchAdded() {
	}

	function ConfirmSaveGame(event: Object): Void
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			if (event.index == 0) {
				iCurrentState = SystemPage.SAVE_LOAD_CONFIRM_STATE;
				onAcceptPress();
			} else {
				ConfirmTextField.SetText("$Save over this game?");
				StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
			}
		}
	}

	function DoSaveGame(): Void
	{
		clearInterval(iSaveDelayTimerID);
		GameDelegate.call("SaveGame", [SaveLoadListHolder.selectedIndex]);
		if(!SystemPage.IsOrbis(iPlatform)) {
			_parent._parent.CloseMenu();
		}
	}

	function onSaveHighlight(event: Object): Void
	{
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE && !SaveLoadListHolder.isShowingCharacterList) {
			if (_deleteButton != null) {
				_deleteButton._alpha = ((event.index == -1) ? 50 : 100);
			}
			if (iPlatform == Shared.Platforms.CONTROLLER_PC)
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
				List_mc.entryList = [
				{text: "$Invert Y", movieType: 2},
				{text: "$Look Sensitivity", movieType: 0},
				{text: "$Vibration", movieType: 2},
				{text: "$360 Controller", movieType: 2},
				{text: "$Difficulty", movieType: 1, options: ["$Very Easy", "$Easy", "$Normal", "$Hard", "$Very Hard", "$Legendary"]},
				{text: "$Show Floating Markers", movieType: 2},
				{text: "$Save on Rest", movieType: 2},
				{text: "$Save on Wait", movieType: 2},
				{text: "$Save on Travel", movieType: 2},
				{text: "$Save on Pause", movieType: 1, options: ["$5 Mins", "$10 Mins", "$15 Mins", "$30 Mins", "$45 Mins", "$60 Mins", "$Disabled"]},
				{text: "$Use Kinect Commands", movieType: 2}];
				GameDelegate.call("RequestGameplayOptions", [List_mc.entryList]);
				break;

			case 1:
				List_mc.entryList = [
				{text: "$Brightness", movieType: 0},
				{text: "$HUD Opacity", movieType: 0},
				{text: "$Actor Fade", movieType: 0},
				{text: "$Item Fade", movieType: 0},
				{text: "$Object Fade", movieType: 0},
				{text: "$Grass Fade", movieType: 0},
				{text: "$Shadow Fade", movieType: 0},
				{text: "$Light Fade", movieType: 0},
				{text: "$Specularity Fade", movieType: 0},
				{text: "$Tree LOD Fade", movieType: 0},
				{text: "$Crosshair", movieType: 2},
				{text: "$Dialogue Subtitles", movieType: 2},
				{text: "$General Subtitles", movieType: 2}];
				GameDelegate.call("RequestDisplayOptions", [List_mc.entryList]);
				break;

			case 2:
				List_mc.entryList = [{text: "$Master", movieType: 0}];
				GameDelegate.call("RequestAudioOptions", [List_mc.entryList]);
				for (var i: String in List_mc.entryList)
					List_mc.entryList[i].movieType = 0;
				break;

			case 3:
				List_mc.entryList = [
				{text:"$Turning Mode",movieType:1,options:["$Snap","$Smooth"]},
				{text:"$Snap Transition",movieType:1,options:["$Gradual","$Instant"]},
				{text:"$Angle Snap Amount",movieType:0},
				{text:"$Rotation Speed",movieType:0},
				{text:"$Movement Mode",movieType:1,options:["$Teleportation","$Direct Movement"]},
				{text:"$Direct Movement Mode",movieType:1,options:["$HMD Relative","$Wand Relative"]},
				{text:"$Compass Position",movieType:1,options:["$Compass Low","$Compass High","$Compass Off"]},
				{text:"$Main Hand",movieType:1,options:["$Right","$Left"]},
				{text:"$Show Hands While Sheathed",movieType:2},
				{text:"$Height",movieType:0},
				{text:"$Movement Speed",movieType:0},
				{text:"$Crosshair",movieType:2},
				{text:"$Physical Sneaking",movieType:2},
				{text:"$Realistic Swimming",movieType:2},
				{text:"$Realistic Shield Grip",movieType:2},
				{text:"$Realistic Bow",movieType:2},
				{text:"$FOV Filter While Turning",movieType:2},
				{text:"$FOV Filter While Moving",movieType:2},
				{text:"$FOV Filter Strength",movieType:0}];
				GameDelegate.call("RequestVROptions", [List_mc.entryList]);
				break;

			case 4:
				GameDelegate.call("RequestVRPerformanceOptions", [List_mc.entryList]);
				break;
		}

		for (var i: Number = 0; i < List_mc.entryList.length; ){
			if (List_mc.entryList[i].ID == undefined) {
				List_mc.entryList.splice(i, 1);
			} else {
				i++;
			}
		}

		if (iPlatform != Shared.Platforms.CONTROLLER_PC) {
			List_mc.selectedIndex = 0;
		}

		List_mc.bAllowValueOverwrite = true;
		List_mc.InvalidateData();
		List_mc.bAllowValueOverwrite = false;
		SettingsPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.OPTIONS_LISTS_STATE);
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		bSettingsChanged = true;
		GameDelegate.call("RequestTurnModeID", [], this, "SetTurningModeID");

		var i = 0;
		var item = List_mc["Entry" + i];
		while(item != undefined) {
			item.SetOnChangedCAllback(this, "OnOptionValueChanged");
			i++;
			item = List_mc["Entry" + i];
		}
	}

	function SetTurningModeID(afID)
	{
		iTurnModeID = afID;
	}

	function OnOptionValueChanged(aObject)
	{
		if(aObject.ID == this.iTurnModeID)
		{
			GameDelegate.call("GetGradualSpeedData", [], this, "UpdateGradualSpeed");
		}
	}

	function UpdateGradualSpeed(afValue, afDefaultValue, afGradualSpeedID)
	{
		if(SettingsList.selectedIndex == 3) {

			var List_mc: MovieClip = OptionsListsPanel.OptionsLists.List_mc;
			if(List_mc != null && List_mc != undefined) {
				var i = 0;
				while(i < List_mc.entryList.length) {
					if(List_mc.entryList[i].ID == afGradualSpeedID) {
						List_mc.entryList[i].value = afValue;
						List_mc.entryList[i].defaultVal = afDefaultValue;
						if(List_mc.entryList[i].clipIndex != undefined) {
							List_mc["Entry" + List_mc.entryList[i].clipIndex].value = afValue;
						}
						return;
					}
					i++;
				}
			}
		}
	}

	function UpdateVRPerformanceValues()
	{
		bJustRefreshedSettings = true;
		if(SettingsList.selectedIndex == 4)
		{
			var List_mc: MovieClip = OptionsListsPanel.OptionsLists.List_mc;
			if(List_mc != null && List_mc != undefined) {

				// Grab the value of the performance options
				var optionValues = new Array();
				GameDelegate.call("RequestVRPerformanceOptions", [optionValues]);

				// Go through each item in the entry list
				var i = 0;
				while(i < List_mc.entryList.length) {
					var optionIdx = -1;
					var j = 0;

					// Try to find a matching entry in the optionsValues array
					while(j < optionValues.length) {
						if(optionValues[j].ID == List_mc.entryList[i].ID) {
							optionIdx = j;
							break;
						}
						j++
					}

					// If a matching entry is found, copy the current value into List_mc
					if(optionIdx >= 0) {
						List_mc.entryList[i].value = optionValues[optionIdx].value;
						List_mc.entryList[i].defaultVal = optionValues[optionIdx].defaultVal;
					}
					i++;
				}
				List_mc.bAllowVAlueOverwrite = true;
				List_mc.UpdateList();
				List_mc.bAllowVAlueOverwrite = false;
			}
		}
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
		GameDelegate.call("OnresetToDefault", []);
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
		HelpText.text = Shared.ExtractPlatformText.Extract(HelpText.text, iPlatform);
		ApplyHelpTextButtonArt();
		HelpListPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.HELP_TEXT_STATE);
	}

	function ApplyHelpTextButtonArt(): Void
	{
		var strTextWithButtons: String = HelpButtonHolder.CreateButtonArtCustomSize(HelpText.textField, 32);
		if (strTextWithButtons != undefined)
			HelpText.htmlText = strTextWithButtons;
	}

	function populateQuitList(abOnPC: Boolean): Void
	{
		if (abOnPC) {
			if (iPlatform != Shared.Platforms.CONTROLLER_PC) {
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
		clearInterval(iSavingSettingsTimerID);
		GameDelegate.call("SaveControls", []);
	}

	function SaveSettings(): Void
	{
		clearInterval(iSavingSettingsTimerID);
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
		var params = new Array();
		var i = 0;
		while(i < CategoryList.entryList.length) {
			if( i != CategoryList.entryList.length - 2) {
				params.push(CategoryList.entryList[i]);
			}
			i++;
		}
    params.push(true);

    GameDelegate.call("SetSaveDisabled", params)
		CategoryList.UpdateList();
	}

	function StartState(aiState: Number): Void
	{
		BottomBar_mc.buttonPanel.clearButtons();

		switch (aiState) {
      case SystemPage.CHARACTER_LOAD_STATE:
        SaveLoadListHolder.isShowingCharacterList = true;
        SystemDivider.gotoAndStop("Left");
        GameDelegate.call("PopulateCharacterList", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
        break;

      case SystemPage.CHARACTER_SELECTION_STATE:
        BottomBar_mc.buttonPanel.addButton({text:"$Cancel", controls: _cancelControls});
        break;

			case SystemPage.SAVE_LOAD_STATE:
        SaveLoadListHolder.isShowingCharacterList = false;
				SystemDivider.gotoAndStop("Left");
				_deleteButton = BottomBar_mc.buttonPanel.addButton({text: "$Delete", controls: _deleteControls}); // X or 360_X
        if(SaveLoadListHolder.isSaving == false)
        {
          BottomBar_mc.buttonPanel.addButton({text:"$CharacterSelection",controls: _characterSelectionControls});
        }
        BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;

			case SystemPage.INPUT_MAPPING_STATE:
				SystemDivider.gotoAndStop("Left");
        if(bIsRemoteDevice) {
          bDefaultButtonVisible = false;
        } else {
          BottomBar_mc.buttonPanel.addButton({text:"$Defaults", controls: _defaultControls});
          bDefaultButtonVisible = true;
        }
        BottomBar_mc.buttonPanel.addButton({text:"$Cancel", controls: _cancelControls});
        BottomBar_mc.buttonPanel.updateButtons(true);
        break;

			case SystemPage.OPTIONS_LISTS_STATE:
				BottomBar_mc.buttonPanel.addButton({text: "$Defaults", controls: _defaultControls}); // T or 360_Y
				if (aiState == SystemPage.OPTIONS_LISTS_STATE && bShowKinectTunerButton && iPlatform == 2 && SettingsList.selectedIndex == 0)
					BottomBar_mc.buttonPanel.addButton({text: "$Kinect Tuner", controls: _kinectControls}); // K or RB
        BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;

			case SystemPage.HELP_TEXT_STATE:
			case SystemPage.HELP_LIST_STATE:
			case SystemPage.SETTINGS_CATEGORY_STATE:
				BottomBar_mc.buttonPanel.addButton({text:"$Cancel", controls:_cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
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
      case SystemPage.CHARACTER_LOAD_STATE:
      case SystemPage.CHARACTER_SELECTION_STATE:
			case SystemPage.SAVE_LOAD_STATE:
			case SystemPage.INPUT_MAPPING_STATE:
      case SystemPage.HELP_TEXT_STATE:
        if(!SystemPage.IsOrbis(iPlatform))
        {
					SystemDivider.gotoAndStop("Right");
        }
        break;
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

      case SystemPage.CHARACTER_LOAD_STATE:
      case SystemPage.CHARACTER_SELECTION_STATE:
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
      case SystemPage.CHARACTER_LOAD_STATE:
      case SystemPage.CHARACTER_SELECTION_STATE:
				FocusHandler.instance.setFocus(SaveLoadListHolder.List_mc, 0);
				SaveLoadListHolder.List_mc.disableSelection = false;
				break;

			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				ConfirmPanel._visible = true;
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

	function Exists(apObject)
	{
		return apObject != null && apObject != undefined;
	}

	function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		if(bJustRefreshedSettings) {
			bJustRefreshedSettings = false;
			return;
		}

		BottomBar_mc.SetPlatform(a_platform, a_bPS3Switch);
		CategoryList.SetPlatform(a_platform, a_bPS3Switch);

		// Setup the buttons by platform
		_deleteControls = skyui.util.Input.pickControls(a_platform, {PCArt:"X", XBoxArt:"360_X", PS3Art:"PS3_X", ViveArt:"radial_Either_Right", MoveArt:"PS3_A", OculusArt:"OCC_A", WindowsMRArt:"radial_Either_Right"});
		_defaultControls = skyui.util.Input.pickControls(a_platform, {PCArt: "T", XBoxArt: "360_Y"});
		_kinectControls = skyui.util.Input.pickControls(a_platform, {PCArt:"K", XBoxArt:"360_RB"});
		_acceptControls = skyui.util.Input.pickControls(a_platform, {PCArt:"Enter", XBoxArt:"360_A", ViveArt:"trigger", MoveArt:"trigger",OculusArt: "trigger", WindowsMRArt:"trigger"});
		_cancelControls = skyui.util.Input.pickControls(a_platform, {PCArt:"Esc", XBoxArt:"360_B", PS3Art:"PS3_B", ViveArt:"grip", MoveArt:"PS3_B", OculusArt:"grab", WindowsMRArt:"grab"});
    _characterSelectionControls = skyui.util.Input.pickControls(a_platform, {PCArt:"T", XBoxArt:"360_Y", PS3Art:"PS3_Y", ViveArt:"radial_Either_Left", MoveArt:"PS3_A", OculusArt:"OCC_A", WindowsMRArt:"radial_Either_Left"});

		if (a_platform != Shared.Platforms.CONTROLLER_PC) {
			SettingsList.selectedIndex = 0;
			PCQuitList.selectedIndex = 0;
			HelpList.selectedIndex = 0;
			MappingList.selectedIndex = 0;
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

  function SetRemoteDevice(abISRemoteDevice)
  {
    bIsRemoteDevice = abISRemoteDevice;
    if(bIsRemoteDevice)
    {
      MappingList.entryList.clear();
    }
  }

	// It's not very clear what this function is supposed to do.
	// This is a refactoring of what ships with SE, VR, and Skyui swfs.
	// Instead of handling all possible permutations of the various settings that may
	// affect the menu entry order, this simply puts together the correct list of
	// items to send at runtime.
  function UpdatePermissions()
  {
  	var itemsList = CategoryList.entryList;
  	var itemsToSend = new Array();

		// Which entries do we want to send?
  	var matchList = ["$QUICKSAVE", "$SAVE", "$LOAD", "$SETTINGS", "$MOD MANAGER", "$CONTROLS", "$QUIT"];

  	// Locate all entries specified by the matchList
  	for(var itemIdx = 0; itemIdx < itemsList.length; itemIdx++) {
  		var item = itemsList[itemIdx];

			for(var matchIdx in matchList) {
				if(matchList[matchIdx] == item.text) {
					itemsToSend.push(item);
				}
			}
  	}

		// Send the data to the engine for... something...
    GameDelegate.call("SetSaveDisabled", itemsToSend);

		// Make sure the help item is not disabled
		for(var itemIdx in itemsList) {
			if("$HELP" == itemsList[itemIdx].text) {
				item[itemIdx].disabled = false;
			}
		}

    CategoryList.UpdateList();
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
