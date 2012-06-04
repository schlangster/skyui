dynamic class SystemPage extends MovieClip
{
	static var MAIN_STATE: Number = 0;
	static var SAVE_LOAD_STATE: Number = 1;
	static var SAVE_LOAD_CONFIRM_STATE: Number = 2;
	static var SETTINGS_CATEGORY_STATE: Number = 3;
	static var OPTIONS_LISTS_STATE: Number = 4;
	static var DEFAULT_SETTINGS_CONFIRM_STATE: Number = 5;
	static var INPUT_MAPPING_STATE: Number = 6;
	static var QUIT_CONFIRM_STATE: Number = 7;
	static var PC_QUIT_LIST_STATE: Number = 8;
	static var PC_QUIT_CONFIRM_STATE: Number = 9;
	static var DELETE_SAVE_CONFIRM_STATE: Number = 10;
	static var HELP_LIST_STATE: Number = 11;
	static var HELP_TEXT_STATE: Number = 12;
	static var TRANSITIONING: Number = 13;
	var BottomBar_mc;
	var CategoryList;
	var CategoryList_mc;
	var ConfirmPanel;
	var ConfirmTextField;
	var ErrorText;
	var HelpButtonHolder;
	var HelpList;
	var HelpListPanel;
	var HelpText;
	var HelpTextPanel;
	var HelpTitleText;
	var InputMappingPanel;
	var MappingList;
	var OptionsListsPanel;
	var PCQuitList;
	var PCQuitPanel;
	var PanelRect;
	var SaveLoadListHolder;
	var SaveLoadPanel;
	var SettingsList;
	var SettingsPanel;
	var SystemDivider;
	var TopmostPanel;
	var VersionText;
	var _parent;
	var bMenuClosing;
	var bRemapMode;
	var bSavingSettings;
	var bSettingsChanged;
	var bUpdated;
	var iCurrentState;
	var iDebounceRemapModeID;
	var iHideErrorTextID;
	var iPlatform;
	var iSaveDelayTimerID;
	var iSavingSettingsTimerID;

	function SystemPage()
	{
		super();
		this.CategoryList = this.CategoryList_mc.List_mc;
		this.SaveLoadListHolder = this.SaveLoadPanel;
		this.SettingsList = this.SettingsPanel.List_mc;
		this.MappingList = this.InputMappingPanel.List_mc;
		this.PCQuitList = this.PCQuitPanel.List_mc;
		this.HelpList = this.HelpListPanel.List_mc;
		this.HelpText = this.HelpTextPanel.HelpTextHolder.HelpText;
		this.HelpButtonHolder = this.HelpTextPanel.HelpTextHolder.ButtonArtHolder;
		this.HelpTitleText = this.HelpTextPanel.HelpTextHolder.TitleText;
		this.ConfirmTextField = this.ConfirmPanel.ConfirmText.textField;
		this.TopmostPanel = this.PanelRect;
		this.bUpdated = false;
		this.bRemapMode = false;
		this.bSettingsChanged = false;
		this.bMenuClosing = false;
		this.bSavingSettings = false;
		this.iPlatform = 0;
	}

	function onLoad()
	{
		this.CategoryList.entryList.push({text: "$SAVE"});
		this.CategoryList.entryList.push({text: "$LOAD"});
		this.CategoryList.entryList.push({text: "$SETTINGS"});
		this.CategoryList.entryList.push({text: "$CONTROLS"});
		this.CategoryList.entryList.push({text: "$HELP"});
		this.CategoryList.entryList.push({text: "$QUIT"});
		this.CategoryList.InvalidateData();
		this.CategoryList.addEventListener("itemPress", this, "onCategoryButtonPress");
		this.CategoryList.addEventListener("listPress", this, "onCategoryListPress");
		this.CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		this.CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		this.CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		this.ConfirmPanel.handleInput = function ()
		{
			return false;
		}
		;
		this.ConfirmPanel.ButtonRect.AcceptMouseButton.addEventListener("click", this, "onAcceptMousePress");
		this.ConfirmPanel.ButtonRect.CancelMouseButton.addEventListener("click", this, "onCancelMousePress");
		this.ConfirmPanel.ButtonRect.AcceptMouseButton.SetPlatform(0, false);
		this.ConfirmPanel.ButtonRect.CancelMouseButton.SetPlatform(0, false);
		this.SaveLoadListHolder.addEventListener("saveGameSelected", this, "ConfirmSaveGame");
		this.SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
		this.SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
		this.SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
		this.SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");
		this.SettingsList.entryList = [{text: "$Gameplay"}, {text: "$Display"}, {text: "$Audio"}];
		this.SettingsList.InvalidateData();
		this.SettingsList.addEventListener("itemPress", this, "onSettingsCategoryPress");
		this.SettingsList.disableInput = true;
		this.InputMappingPanel.List_mc.addEventListener("itemPress", this, "onInputMappingPress");
		gfx.io.GameDelegate.addCallBack("FinishRemapMode", this, "onFinishRemapMode");
		gfx.io.GameDelegate.addCallBack("SettingsSaved", this, "onSettingsSaved");
		gfx.io.GameDelegate.addCallBack("RefreshSystemButtons", this, "RefreshSystemButtons");
		this.PCQuitList.entryList = [{text: "$Main Menu"}, {text: "$Desktop"}];
		this.PCQuitList.UpdateList();
		this.PCQuitList.addEventListener("itemPress", this, "onPCQuitButtonPress");
		this.HelpList.addEventListener("itemPress", this, "onHelpItemPress");
		this.HelpList.disableInput = true;
		this.HelpTitleText.textAutoSize = "shrink";
		this.BottomBar_mc = this._parent._parent.BottomBar_mc;
		gfx.io.GameDelegate.addCallBack("BackOutFromLoadGame", this, "BackOutFromLoadGame");
	}

	function startPage()
	{
		if (!this.bUpdated) 
		{
			this.currentState = SystemPage.MAIN_STATE;
			gfx.io.GameDelegate.call("SetVersionText", [this.VersionText]);
			gfx.io.GameDelegate.call("SetSaveDisabled", [this.CategoryList.entryList[0], this.CategoryList.entryList[1], this.CategoryList.entryList[2], this.CategoryList.entryList[3], this.CategoryList.entryList[5]]);
			this.BottomBar_mc.SetButtonVisibility(1, false, 50);
			this.CategoryList.UpdateList();
			this.bUpdated = true;
			return;
		}
		this.UpdateStateFocus(this.iCurrentState);
	}

	function endPage()
	{
		this.BottomBar_mc.SetButtonVisibility(1, false, 100);
	}

	function get currentState()
	{
		return this.iCurrentState;
	}

	function set currentState(aiNewState)
	{
		var __reg2 = this.GetPanelForState(aiNewState);
		this.iCurrentState = aiNewState;
		if (__reg2 != this.TopmostPanel) 
		{
			__reg2.swapDepths(this.TopmostPanel);
			this.TopmostPanel = __reg2;
		}
		this.UpdateStateFocus(aiNewState);
	}

	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		var __reg3 = false;
		if (this.bRemapMode || this.bMenuClosing || this.bSavingSettings || this.iCurrentState == SystemPage.TRANSITIONING) 
		{
			__reg3 = true;
		}
		else if (Shared.GlobalFunc.IsKeyPressed(details, this.iCurrentState != SystemPage.INPUT_MAPPING_STATE)) 
		{
			if (this.iCurrentState != SystemPage.OPTIONS_LISTS_STATE) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT && this.iCurrentState == SystemPage.MAIN_STATE) 
				{
					details.navEquivalent = gfx.ui.NavigationCode.ENTER;
				}
				else if (details.navEquivalent == gfx.ui.NavigationCode.LEFT && this.iCurrentState != SystemPage.MAIN_STATE) 
				{
					details.navEquivalent = gfx.ui.NavigationCode.TAB;
				}
			}
			if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R2) && this.isConfirming()) 
			{
				__reg3 = true;
			}
			else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.iCurrentState == SystemPage.SAVE_LOAD_STATE && this.BottomBar_mc.IsButtonVisible(1)) 
			{
				this.ConfirmDeleteSave();
				__reg3 = true;
			}
			else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && (this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE || this.iCurrentState == SystemPage.INPUT_MAPPING_STATE) && this.BottomBar_mc.IsButtonVisible(1)) 
			{
				this.ConfirmTextField.SetText("$Reset settings to default values?");
				this.StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
				__reg3 = true;
			}
			else if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) 
				{
					__reg3 = this.onAcceptPress();
				}
				else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) 
				{
					__reg3 = this.onCancelPress();
				}
			}
		}
		return __reg3;
	}

	function onAcceptPress()
	{
		var __reg2 = true;
		if ((__reg0 = this.iCurrentState) === SystemPage.SAVE_LOAD_CONFIRM_STATE) 
		{
			if (this.SaveLoadListHolder.List_mc.disableSelection) 
			{
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				this.bMenuClosing = true;
				if (this.SaveLoadListHolder.isSaving) 
				{
					this.ConfirmPanel._visible = false;
					if (this.iPlatform == Shared.ButtonChange.PLATFORM_360) 
					{
						this.ErrorText.SetText("$Saving content. Please don\'t turn off your console.");
					}
					else 
					{
						this.ErrorText.SetText("$Saving...");
					}
					this.iSaveDelayTimerID = setInterval(this, "DoSaveGame", 1);
				}
				else 
				{
					gfx.io.GameDelegate.call("LoadGame", [this.SaveLoadListHolder.selectedIndex]);
				}
			}
		}
		else if (__reg0 === SystemPage.TRANSITIONING) 
		{
			if (this.SaveLoadListHolder.List_mc.disableSelection) 
			{
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				this.bMenuClosing = true;
				if (this.SaveLoadListHolder.isSaving) 
				{
					this.ConfirmPanel._visible = false;
					if (this.iPlatform == Shared.ButtonChange.PLATFORM_360) 
					{
						this.ErrorText.SetText("$Saving content. Please don\'t turn off your console.");
					}
					else 
					{
						this.ErrorText.SetText("$Saving...");
					}
					this.iSaveDelayTimerID = setInterval(this, "DoSaveGame", 1);
				}
				else 
				{
					gfx.io.GameDelegate.call("LoadGame", [this.SaveLoadListHolder.selectedIndex]);
				}
			}
		}
		else if (__reg0 === SystemPage.QUIT_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			gfx.io.GameDelegate.call("QuitToMainMenu", []);
			this.bMenuClosing = true;
		}
		else if (__reg0 === SystemPage.PC_QUIT_CONFIRM_STATE) 
		{
			if (this.PCQuitList.selectedIndex == 0) 
			{
				gfx.io.GameDelegate.call("QuitToMainMenu", []);
				this.bMenuClosing = true;
			}
			else if (this.PCQuitList.selectedIndex == 1) 
			{
				gfx.io.GameDelegate.call("QuitToDesktop", []);
			}
		}
		else if (__reg0 === SystemPage.DELETE_SAVE_CONFIRM_STATE) 
		{
			this.SaveLoadListHolder.DeleteSelectedSave();
			if (this.SaveLoadListHolder.numSaves == 0) 
			{
				this.GetPanelForState(SystemPage.SAVE_LOAD_STATE).gotoAndStop(1);
				this.GetPanelForState(SystemPage.DELETE_SAVE_CONFIRM_STATE).gotoAndStop(1);
				this.BottomBar_mc.SetButtonVisibility(1, false);
				this.currentState = SystemPage.MAIN_STATE;
			}
			else 
			{
				this.EndState();
			}
		}
		else if (__reg0 === SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			if (this.ConfirmPanel.returnState == SystemPage.OPTIONS_LISTS_STATE) 
			{
				this.ResetSettingsToDefaults();
			}
			else if (this.ConfirmPanel.returnState == SystemPage.INPUT_MAPPING_STATE) 
			{
				this.ResetControlsToDefaults();
			}
			this.EndState();
		}
		else 
		{
			__reg2 = false;
		}
		return __reg2;
	}

	function onCancelPress()
	{
		var __reg2 = true;
		if ((__reg0 = this.iCurrentState) === SystemPage.SAVE_LOAD_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.PC_QUIT_LIST_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.HELP_LIST_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.QUIT_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.PC_QUIT_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.DELETE_SAVE_CONFIRM_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
		}
		else if (__reg0 === SystemPage.HELP_TEXT_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
			this.StartState(SystemPage.HELP_LIST_STATE);
			this.HelpListPanel.bCloseToMainState = true;
		}
		else if (__reg0 === SystemPage.OPTIONS_LISTS_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.EndState();
			this.StartState(SystemPage.SETTINGS_CATEGORY_STATE);
			this.SettingsPanel.bCloseToMainState = true;
		}
		else if (__reg0 === SystemPage.INPUT_MAPPING_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			if (this.bSettingsChanged) 
			{
				this.ErrorText.SetText("$Saving...");
				this.bSavingSettings = true;
				if (this.iCurrentState == SystemPage.INPUT_MAPPING_STATE) 
				{
					this.iSavingSettingsTimerID = setInterval(this, "SaveControls", 1000);
				}
				else if (this.iCurrentState == SystemPage.SETTINGS_CATEGORY_STATE) 
				{
					this.iSavingSettingsTimerID = setInterval(this, "SaveSettings", 1000);
				}
			}
			else 
			{
				this.onSettingsSaved();
			}
		}
		else if (__reg0 === SystemPage.SETTINGS_CATEGORY_STATE) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			if (this.bSettingsChanged) 
			{
				this.ErrorText.SetText("$Saving...");
				this.bSavingSettings = true;
				if (this.iCurrentState == SystemPage.INPUT_MAPPING_STATE) 
				{
					this.iSavingSettingsTimerID = setInterval(this, "SaveControls", 1000);
				}
				else if (this.iCurrentState == SystemPage.SETTINGS_CATEGORY_STATE) 
				{
					this.iSavingSettingsTimerID = setInterval(this, "SaveSettings", 1000);
				}
			}
			else 
			{
				this.onSettingsSaved();
			}
		}
		else 
		{
			__reg2 = false;
		}
		return __reg2;
	}

	function isConfirming()
	{
		return this.iCurrentState == SystemPage.SAVE_LOAD_CONFIRM_STATE || this.iCurrentState == SystemPage.QUIT_CONFIRM_STATE || this.iCurrentState == SystemPage.PC_QUIT_CONFIRM_STATE || this.iCurrentState == SystemPage.DELETE_SAVE_CONFIRM_STATE || this.iCurrentState == SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE;
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

	function onCategoryButtonPress(event)
	{
		if (event.entry.disabled) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			return;
		}
		if (this.iCurrentState == SystemPage.MAIN_STATE) 
		{
			if ((__reg0 = event.index) === 0) 
			{
				this.SaveLoadListHolder.isSaving = true;
				gfx.io.GameDelegate.call("SAVE", [this.SaveLoadListHolder.List_mc.entryList, this.SaveLoadListHolder.batchSize]);
				return;
			}
			else if (__reg0 === 1) 
			{
				this.SaveLoadListHolder.isSaving = false;
				gfx.io.GameDelegate.call("LOAD", [this.SaveLoadListHolder.List_mc.entryList, this.SaveLoadListHolder.batchSize]);
				return;
			}
			else if (__reg0 === 2) 
			{
				this.StartState(SystemPage.SETTINGS_CATEGORY_STATE);
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				return;
			}
			else if (__reg0 === 3) 
			{
				if (this.MappingList.entryList.length == 0) 
				{
					gfx.io.GameDelegate.call("RequestInputMappings", [this.MappingList.entryList]);
					this.MappingList.entryList.sort(this.inputMappingSort);
					this.MappingList.InvalidateData();
				}
				this.StartState(SystemPage.INPUT_MAPPING_STATE);
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				return;
			}
			else if (__reg0 === 4) 
			{
				if (this.HelpList.entryList.length == 0) 
				{
					gfx.io.GameDelegate.call("PopulateHelpTopics", [this.HelpList.entryList]);
					this.HelpList.entryList.sort(this.doABCSort);
					this.HelpList.InvalidateData();
				}
				if (this.HelpList.entryList.length == 0) 
				{
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				}
				else 
				{
					this.StartState(SystemPage.HELP_LIST_STATE);
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				}
				return;
			}
			else if (__reg0 === 5) 
			{
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				gfx.io.GameDelegate.call("RequestIsOnPC", [], this, "populateQuitList");
				return;
			}
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			return;
		}
	}

	function onCategoryListPress(event)
	{
		if (!this.bRemapMode && !this.bMenuClosing && !this.bSavingSettings && this.iCurrentState != SystemPage.TRANSITIONING) 
		{
			this.onCancelPress();
			this.CategoryList.disableSelection = false;
			this.CategoryList.UpdateList();
			this.CategoryList.disableSelection = true;
		}
	}

	function doABCSort(aObj1, aObj2)
	{
		if (aObj1.text < aObj2.text) 
		{
			return -1;
		}
		if (aObj1.text > aObj2.text) 
		{
			return 1;
		}
		return 0;
	}

	function onCategoryListMoveUp(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	function onCategoryListMoveDown(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	function onCategoryListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function OnSaveListOpenSuccess()
	{
		if (this.SaveLoadListHolder.numSaves > 0) 
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			this.StartState(SystemPage.SAVE_LOAD_STATE);
			return;
		}
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
	}

	function ConfirmSaveGame(event)
	{
		this.SaveLoadListHolder.List_mc.disableSelection = true;
		if (this.iCurrentState == SystemPage.SAVE_LOAD_STATE) 
		{
			if (event.index == 0) 
			{
				this.iCurrentState = SystemPage.SAVE_LOAD_CONFIRM_STATE;
				this.onAcceptPress();
				return;
			}
			this.ConfirmTextField.SetText("$Save over this game?");
			this.StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	function DoSaveGame()
	{
		clearInterval(this.iSaveDelayTimerID);
		gfx.io.GameDelegate.call("SaveGame", [this.SaveLoadListHolder.selectedIndex]);
		this._parent._parent.CloseMenu();
	}

	function onSaveHighlight(event)
	{
		if (this.iCurrentState == SystemPage.SAVE_LOAD_STATE) 
		{
			this.BottomBar_mc.SetButtonVisibility(1, true, event.index == -1 ? 50 : 100);
			if (this.iPlatform == 0) 
			{
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
			}
		}
	}

	function onSaveLoadListPress()
	{
		this.onAcceptPress();
	}

	function ConfirmLoadGame(event)
	{
		this.SaveLoadListHolder.List_mc.disableSelection = true;
		if (this.iCurrentState == SystemPage.SAVE_LOAD_STATE) 
		{
			this.ConfirmTextField.SetText("$Load this game? All unsaved progress will be lost.");
			this.StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	function ConfirmDeleteSave()
	{
		if (!this.SaveLoadListHolder.isSaving || this.SaveLoadListHolder.selectedIndex != 0) 
		{
			this.SaveLoadListHolder.List_mc.disableSelection = true;
			if (this.iCurrentState == SystemPage.SAVE_LOAD_STATE) 
			{
				this.ConfirmTextField.SetText("$Delete this save?");
				this.StartState(SystemPage.DELETE_SAVE_CONFIRM_STATE);
			}
		}
	}

	function onSettingsCategoryPress()
	{
		var __reg2 = this.OptionsListsPanel.OptionsLists.List_mc;
		if ((__reg0 = this.SettingsList.selectedIndex) === 0) 
		{
			__reg2.entryList = [{text: "$Invert Y", movieType: 2}, {text: "$Look Sensitivity", movieType: 0}, {text: "$Vibration", movieType: 2}, {text: "$360 Controller", movieType: 2}, {text: "$Difficulty", movieType: 1, options: ["$Very Easy", "$Easy", "$Normal", "$Hard", "$Very Hard"]}, {text: "$Show Floating Markers", movieType: 2}, {text: "$Save on Rest", movieType: 2}, {text: "$Save on Wait", movieType: 2}, {text: "$Save on Travel", movieType: 2}, {text: "$Save on Pause", movieType: 1, options: ["$5 Mins", "$10 Mins", "$15 Mins", "$30 Mins", "$45 Mins", "$60 Mins", "$Disabled"]}];
			gfx.io.GameDelegate.call("RequestGameplayOptions", [__reg2.entryList]);
		}
		else if (__reg0 === 1) 
		{
			__reg2.entryList = [{text: "$Brightness", movieType: 0}, {text: "$HUD Opacity", movieType: 0}, {text: "$Actor Fade", movieType: 0}, {text: "$Item Fade", movieType: 0}, {text: "$Object Fade", movieType: 0}, {text: "$Grass Fade", movieType: 0}, {text: "$Shadow Fade", movieType: 0}, {text: "$Light Fade", movieType: 0}, {text: "$Specularity Fade", movieType: 0}, {text: "$Tree LOD Fade", movieType: 0}, {text: "$Crosshair", movieType: 2}, {text: "$Dialogue Subtitles", movieType: 2}, {text: "$General Subtitles", movieType: 2}];
			gfx.io.GameDelegate.call("RequestDisplayOptions", [__reg2.entryList]);
		}
		else if (__reg0 === 2) 
		{
			__reg2.entryList = [{text: "$Master", movieType: 0}];
			gfx.io.GameDelegate.call("RequestAudioOptions", [__reg2.entryList]);
			for (var __reg4 in __reg2.entryList) 
			{
				__reg2.entryList[__reg4].movieType = 0;
			}
		}
		var __reg3 = 0;
		while (__reg3 < __reg2.entryList.length) 
		{
			if (__reg2.entryList[__reg3].ID == undefined) 
			{
				__reg2.entryList.splice(__reg3, 1);
			}
			else 
			{
				++__reg3;
			}
		}
		if (this.iPlatform != 0) 
		{
			__reg2.selectedIndex = 0;
		}
		__reg2.InvalidateData();
		this.SettingsPanel.bCloseToMainState = false;
		this.EndState();
		this.StartState(SystemPage.OPTIONS_LISTS_STATE);
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		this.bSettingsChanged = true;
	}

	function ResetSettingsToDefaults()
	{
		var __reg2 = this.OptionsListsPanel.OptionsLists.List_mc;
		for (var __reg3 in __reg2.entryList) 
		{
			if (__reg2.entryList[__reg3].defaultVal != undefined) 
			{
				__reg2.entryList[__reg3].value = __reg2.entryList[__reg3].defaultVal;
				gfx.io.GameDelegate.call("OptionChange", [__reg2.entryList[__reg3].ID, __reg2.entryList[__reg3].value]);
			}
		}
		__reg2.bAllowValueOverwrite = true;
		__reg2.UpdateList();
		__reg2.bAllowValueOverwrite = false;
	}

	function onInputMappingPress(event)
	{
		if (this.bRemapMode == false && this.iCurrentState == SystemPage.INPUT_MAPPING_STATE) 
		{
			this.MappingList.disableSelection = true;
			this.bRemapMode = true;
			this.ErrorText.SetText("$Press a button to map to this action.");
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
			gfx.io.GameDelegate.call("StartRemapMode", [event.entry.text, this.MappingList.entryList]);
		}
	}

	function onFinishRemapMode(abSuccess)
	{
		if (abSuccess) 
		{
			this.HideErrorText();
			this.MappingList.entryList.sort(this.inputMappingSort);
			this.MappingList.UpdateList();
			this.bSettingsChanged = true;
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
		else 
		{
			this.ErrorText.SetText("$That button is reserved.");
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			this.iHideErrorTextID = setInterval(this, "HideErrorText", 1000);
		}
		this.MappingList.disableSelection = false;
		this.iDebounceRemapModeID = setInterval(this, "ClearRemapMode", 200);
	}

	function inputMappingSort(aObj1, aObj2)
	{
		if (aObj1.sortIndex < aObj2.sortIndex) 
		{
			return -1;
		}
		if (aObj1.sortIndex > aObj2.sortIndex) 
		{
			return 1;
		}
		return 0;
	}

	function HideErrorText()
	{
		if (this.iHideErrorTextID != undefined) 
		{
			clearInterval(this.iHideErrorTextID);
		}
		this.ErrorText.SetText(" ");
	}

	function ClearRemapMode()
	{
		if (this.iDebounceRemapModeID != undefined) 
		{
			clearInterval(this.iDebounceRemapModeID);
		}
		this.bRemapMode = false;
	}

	function ResetControlsToDefaults()
	{
		gfx.io.GameDelegate.call("ResetControlsToDefaults", [this.MappingList.entryList]);
		this.MappingList.entryList.splice(0, this.MappingList.entryList.length);
		gfx.io.GameDelegate.call("RequestInputMappings", [this.MappingList.entryList]);
		this.MappingList.entryList.sort(this.inputMappingSort);
		this.MappingList.UpdateList();
		this.bSettingsChanged = true;
	}

	function onHelpItemPress()
	{
		gfx.io.GameDelegate.call("RequestHelpText", [this.HelpList.selectedEntry.index, this.HelpTitleText, this.HelpText]);
		this.ApplyHelpTextButtonArt();
		this.HelpListPanel.bCloseToMainState = false;
		this.EndState();
		this.StartState(SystemPage.HELP_TEXT_STATE);
	}

	function ApplyHelpTextButtonArt()
	{
		var __reg2 = this.HelpButtonHolder.CreateButtonArt(this.HelpText.textField);
		if (__reg2 != undefined) 
		{
			this.HelpText.htmlText = __reg2;
		}
	}

	function populateQuitList(abOnPC)
	{
		if (abOnPC) 
		{
			if (this.iPlatform != 0) 
			{
				this.PCQuitList.selectedIndex = 0;
			}
			this.StartState(SystemPage.PC_QUIT_LIST_STATE);
			return;
		}
		this.ConfirmTextField.textAutoSize = "shrink";
		this.ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
		this.StartState(SystemPage.QUIT_CONFIRM_STATE);
	}

	function onPCQuitButtonPress(event)
	{
		if (this.iCurrentState == SystemPage.PC_QUIT_LIST_STATE) 
		{
			this.PCQuitList.disableSelection = true;
			if (event.index == 0) 
			{
				this.ConfirmTextField.textAutoSize = "shrink";
				this.ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
			}
			else if (event.index == 1) 
			{
				this.ConfirmTextField.textAutoSize = "shrink";
				this.ConfirmTextField.SetText("$Quit to desktop?  Any unsaved progress will be lost.");
			}
			this.StartState(SystemPage.PC_QUIT_CONFIRM_STATE);
		}
	}

	function SaveControls()
	{
		clearInterval(this.iSavingSettingsTimerID);
		gfx.io.GameDelegate.call("SaveControls", []);
	}

	function SaveSettings()
	{
		clearInterval(this.iSavingSettingsTimerID);
		gfx.io.GameDelegate.call("SaveSettings", []);
	}

	function onSettingsSaved()
	{
		this.bSavingSettings = false;
		this.bSettingsChanged = false;
		this.ErrorText.SetText(" ");
		this.EndState();
	}

	function RefreshSystemButtons()
	{
		gfx.io.GameDelegate.call("SetSaveDisabled", [this.CategoryList.entryList[0], this.CategoryList.entryList[1], this.CategoryList.entryList[2], this.CategoryList.entryList[3], this.CategoryList.entryList[5], true]);
		this.CategoryList.UpdateList();
	}

	function StartState(aiState)
	{
		if ((__reg0 = aiState) === SystemPage.SAVE_LOAD_STATE) 
		{
			this.SystemDivider.gotoAndStop("Left");
			this.BottomBar_mc.SetButtonInfo(1, "$Delete", {PCArt: "X", XBoxArt: "360_X", PS3Art: "PS3_X"});
			this.BottomBar_mc.SetButtonVisibility(1, true);
		}
		else if (__reg0 === SystemPage.INPUT_MAPPING_STATE) 
		{
			this.SystemDivider.gotoAndStop("Left");
			this.BottomBar_mc.SetButtonInfo(1, "$Defaults", {PCArt: "T", XBoxArt: "360_Y", PS3Art: "PS3_Y"});
			this.BottomBar_mc.SetButtonVisibility(1, true, 100);
		}
		else if (__reg0 === SystemPage.OPTIONS_LISTS_STATE) 
		{
			this.BottomBar_mc.SetButtonInfo(1, "$Defaults", {PCArt: "T", XBoxArt: "360_Y", PS3Art: "PS3_Y"});
			this.BottomBar_mc.SetButtonVisibility(1, true, 100);
		}
		else if (__reg0 === SystemPage.SETTINGS_CATEGORY_STATE) 
		{
			this.SystemDivider.gotoAndStop("Left");
		}
		else if (__reg0 === SystemPage.PC_QUIT_LIST_STATE) 
		{
			this.SystemDivider.gotoAndStop("Left");
		}
		else if (__reg0 === SystemPage.HELP_LIST_STATE) 
		{
			this.SystemDivider.gotoAndStop("Left");
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_CONFIRM_STATE) 
		{
			this.ConfirmPanel.confirmType = aiState;
			this.ConfirmPanel.returnState = this.iCurrentState;
		}
		else if (__reg0 === SystemPage.QUIT_CONFIRM_STATE) 
		{
			this.ConfirmPanel.confirmType = aiState;
			this.ConfirmPanel.returnState = this.iCurrentState;
		}
		else if (__reg0 === SystemPage.PC_QUIT_CONFIRM_STATE) 
		{
			this.ConfirmPanel.confirmType = aiState;
			this.ConfirmPanel.returnState = this.iCurrentState;
		}
		else if (__reg0 === SystemPage.DELETE_SAVE_CONFIRM_STATE) 
		{
			this.ConfirmPanel.confirmType = aiState;
			this.ConfirmPanel.returnState = this.iCurrentState;
		}
		else if (__reg0 === SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE) 
		{
			this.ConfirmPanel.confirmType = aiState;
			this.ConfirmPanel.returnState = this.iCurrentState;
		}
		this.iCurrentState = SystemPage.TRANSITIONING;
		this.GetPanelForState(aiState).gotoAndPlay("start");
	}

	function EndState()
	{
		if ((__reg0 = this.iCurrentState) === SystemPage.SAVE_LOAD_STATE) 
		{
			this.SystemDivider.gotoAndStop("Right");
			this.BottomBar_mc.SetButtonVisibility(1, false);
		}
		else if (__reg0 === SystemPage.INPUT_MAPPING_STATE) 
		{
			this.SystemDivider.gotoAndStop("Right");
			this.BottomBar_mc.SetButtonVisibility(1, false);
		}
		else if (__reg0 === SystemPage.OPTIONS_LISTS_STATE) 
		{
			this.BottomBar_mc.SetButtonVisibility(1, false);
		}
		else if (__reg0 === SystemPage.HELP_LIST_STATE) 
		{
			this.HelpList.disableInput = true;
			if (this.HelpListPanel.bCloseToMainState != false) 
			{
				this.SystemDivider.gotoAndStop("Right");
			}
		}
		else if (__reg0 === SystemPage.SETTINGS_CATEGORY_STATE) 
		{
			this.SettingsList.disableInput = true;
			if (this.SettingsPanel.bCloseToMainState != false) 
			{
				this.SystemDivider.gotoAndStop("Right");
			}
		}
		else if (__reg0 === SystemPage.PC_QUIT_LIST_STATE) 
		{
			this.SystemDivider.gotoAndStop("Right");
		}
		if (this.iCurrentState != SystemPage.MAIN_STATE) 
		{
			this.GetPanelForState(this.iCurrentState).gotoAndPlay("end");
			this.iCurrentState = SystemPage.TRANSITIONING;
		}
	}

	function GetPanelForState(aiState)
	{
		if ((__reg0 = aiState) === SystemPage.MAIN_STATE) 
		{
			return this.PanelRect;
		}
		else if (__reg0 === SystemPage.SETTINGS_CATEGORY_STATE) 
		{
			return this.SettingsPanel;
		}
		else if (__reg0 === SystemPage.OPTIONS_LISTS_STATE) 
		{
			return this.OptionsListsPanel;
		}
		else if (__reg0 === SystemPage.INPUT_MAPPING_STATE) 
		{
			return this.InputMappingPanel;
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_STATE) 
		{
			return this.SaveLoadPanel;
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_CONFIRM_STATE) 
		{
			return this.ConfirmPanel;
		}
		else if (__reg0 === SystemPage.PC_QUIT_CONFIRM_STATE) 
		{
			return this.ConfirmPanel;
		}
		else if (__reg0 === SystemPage.QUIT_CONFIRM_STATE) 
		{
			return this.ConfirmPanel;
		}
		else if (__reg0 === SystemPage.DELETE_SAVE_CONFIRM_STATE) 
		{
			return this.ConfirmPanel;
		}
		else if (__reg0 === SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE) 
		{
			return this.ConfirmPanel;
		}
		else if (__reg0 === SystemPage.PC_QUIT_LIST_STATE) 
		{
			return this.PCQuitPanel;
		}
		else if (__reg0 === SystemPage.HELP_LIST_STATE) 
		{
			return this.HelpListPanel;
		}
		else if (__reg0 !== SystemPage.HELP_TEXT_STATE) 
		{
			return;
		}
		return this.HelpTextPanel;
	}

	function UpdateStateFocus(aiNewState)
	{
		this.CategoryList.disableSelection = aiNewState != SystemPage.MAIN_STATE;
		if ((__reg0 = aiNewState) === SystemPage.MAIN_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.CategoryList, 0);
			return;
		}
		else if (__reg0 === SystemPage.SETTINGS_CATEGORY_STATE) 
		{
			this.SettingsList.disableInput = false;
			gfx.managers.FocusHandler.instance.setFocus(this.SettingsList, 0);
			return;
		}
		else if (__reg0 === SystemPage.OPTIONS_LISTS_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.OptionsListsPanel.OptionsLists.List_mc, 0);
			return;
		}
		else if (__reg0 === SystemPage.INPUT_MAPPING_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.MappingList, 0);
			return;
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.SaveLoadListHolder.List_mc, 0);
			this.SaveLoadListHolder.List_mc.disableSelection = false;
			return;
		}
		else if (__reg0 === SystemPage.SAVE_LOAD_CONFIRM_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel, 0);
			return;
		}
		else if (__reg0 === SystemPage.QUIT_CONFIRM_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel, 0);
			return;
		}
		else if (__reg0 === SystemPage.PC_QUIT_CONFIRM_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel, 0);
			return;
		}
		else if (__reg0 === SystemPage.DELETE_SAVE_CONFIRM_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel, 0);
			return;
		}
		else if (__reg0 === SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel, 0);
			return;
		}
		else if (__reg0 === SystemPage.PC_QUIT_LIST_STATE) 
		{
			gfx.managers.FocusHandler.instance.setFocus(this.PCQuitList, 0);
			this.PCQuitList.disableSelection = false;
			return;
		}
		else if (__reg0 === SystemPage.HELP_LIST_STATE) 
		{
			this.HelpList.disableInput = false;
			gfx.managers.FocusHandler.instance.setFocus(this.HelpList, 0);
			return;
		}
		else if (__reg0 !== SystemPage.HELP_TEXT_STATE) 
		{
			return;
		}
		gfx.managers.FocusHandler.instance.setFocus(this.HelpText, 0);
		return;
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		this.ConfirmPanel.ButtonRect.AcceptGamepadButton._visible = aiPlatform != 0;
		this.ConfirmPanel.ButtonRect.CancelGamepadButton._visible = aiPlatform != 0;
		this.ConfirmPanel.ButtonRect.AcceptMouseButton._visible = aiPlatform == 0;
		this.ConfirmPanel.ButtonRect.CancelMouseButton._visible = aiPlatform == 0;
		this.BottomBar_mc.SetPlatform(aiPlatform, abPS3Switch);
		this.CategoryList.SetPlatform(aiPlatform, abPS3Switch);
		if (aiPlatform != 0) 
		{
			this.ConfirmPanel.ButtonRect.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
			this.ConfirmPanel.ButtonRect.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
			this.SettingsList.selectedIndex = 0;
			this.PCQuitList.selectedIndex = 0;
			this.HelpList.selectedIndex = 0;
			this.MappingList.selectedIndex = 0;
		}
		this.iPlatform = aiPlatform;
		this.SaveLoadListHolder.platform = aiPlatform;
	}

	function BackOutFromLoadGame()
	{
		this.bMenuClosing = false;
		this.onCancelPress();
	}

}
