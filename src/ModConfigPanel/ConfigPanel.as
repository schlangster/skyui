import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;
import skyui.util.DialogManager;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;


class ConfigPanel extends MovieClip
{
  /* CONSTANTS */
  
  	private static var READY = 0;
	private static var WAIT_FOR_OPTION_DATA = 1;
	private static var WAIT_FOR_SLIDER_DATA = 2;
	private static var WAIT_FOR_MENU_DATA = 3;
	private static var WAIT_FOR_SELECT = 4;
	private static var DIALOG = 5;
	
	private static var FOCUS_MODLIST = 0;
	private static var FOCUS_OPTIONS = 1;
	
	
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
  
	// Quest_Journal_mc
	private var _parentMenu: MovieClip;
	private var _buttonPanelL: ButtonPanel;
	private var _buttonPanelR: ButtonPanel;
	
	private var _bottomBarStartY: Number;
	
	private var _modListPanel: ModListPanel;
	private var _modList: ScrollingList;
	private var _subList: ScrollingList;
	private var _optionsList: MultiColumnScrollingList;

	private var _customContent: MovieClip;
	private var _customContentX: Number = 0;
	private var _customContentY: Number = 0;
	
	private var _optionChangeDialog: MovieClip;
	
	private var _state: Number;
	private var _focus: Number;
	
	private var _optionFlagsBuffer: Array;
	private var _optionTextBuffer: Array;
	private var _optionStrValueBuffer: Array;
	private var _optionNumValueBuffer: Array;
	
	private var _titleText: String = "";
	private var _infoText: String = "";
	private var	_dialogTitleText: String = "";
	
	private var _highlightIndex: Number = -1;
	private var _highlightIntervalID: Number;
	
	private var _menuDialogOptions: Array;
	
	private var	_sliderDialogFormatString: String = "";
	
	private var _currentRemapOption: Number = -1;
	private var _bRemapMode = false;
	private var _remapDelayID: Number;
	
	private var _acceptControls: Object;
	private var _cancelControls: Object;
	private var _defaultControls: Object;
	
	
  /* STAGE ELEMENTS */

	public var contentHolder: MovieClip;
	
	public var titlebar: MovieClip;
	
	public var bottomBar: MovieClip;
	
	
  /* INITIALIATZION */
	
	function ConfigPanel()
	{
		// A bit hackish but w/e
		_parentMenu = _root.QuestJournalFader.Menu_mc;

		_modListPanel = contentHolder.modListPanel;
		_modList = _modListPanel.modListFader.list;
		_subList = _modListPanel.subListFader.list;
		_optionsList = contentHolder.optionsPanel.optionsList;
		
		_buttonPanelL = bottomBar.buttonPanelL;
		_buttonPanelR = bottomBar.buttonPanelR;
		
		_state = READY;
		
		_optionFlagsBuffer = [];
		_optionTextBuffer = [];
		_optionStrValueBuffer = [];
		_optionNumValueBuffer = [];
		
		_menuDialogOptions = [];

		contentHolder.infoPanel.textField.verticalAutoSize = "top";
	}
	
	// @override MovieClip
	private function onLoad()
	{
		super.onLoad();

		_modList.listEnumeration = new BasicEnumeration(_modList.entryList);
		_subList.listEnumeration = new BasicEnumeration(_subList.entryList);
		_optionsList.listEnumeration = new BasicEnumeration(_optionsList.entryList);
		
		_modList.addEventListener("itemPress", this, "onModListPress");
		_modList.addEventListener("selectionChange", this, "onModListChange");
		
		_subList.addEventListener("itemPress", this, "onSubListPress");
		_subList.addEventListener("selectionChange", this, "onSubListChange");
		
		_optionsList.addEventListener("itemPress", this, "onOptionPress");
		_optionsList.addEventListener("selectionChange", this, "onOptionChange");
		
		_modListPanel.addEventListener("modListEnter", this, "onModListEnter");
		_modListPanel.addEventListener("modListExit", this, "onModListExit");
		_modListPanel.addEventListener("subListEnter", this, "onSubListEnter");
		_modListPanel.addEventListener("subListExit", this, "onSubListExit");

		_optionsList._visible = false;
	}
	
	
  /* PAPYRUS INTERFACE */
  
	// Holds last selected key
	public var selectedKeyCode = -1;
  
  	public function unlock(): Void
	{
		_state = READY;
	}
	
	public function setModNames(/* names */): Void
	{
		_modList.clearList();
		_modList.listState.savedIndex = null;
		
		for (var i=0; i<arguments.length; i++)
			if (arguments[i].toLowerCase() != "none")
				_modList.entryList.push({modIndex: i, text: arguments[i], align: "right", enabled: true});
		_modList.InvalidateData();
	}
	
	public function setPageNames(/* names */): Void
	{
		_subList.clearList();
		_subList.listState.savedIndex = null;
		
		for (var i=0; i<arguments.length; i++)
			if (arguments[i].toLowerCase() != "none")
				_subList.entryList.push({text: arguments[i], align: "right", enabled: true});
		_subList.InvalidateData();

	}
	
	public function setCustomContentParams(a_x: Number, a_y: Number): Void
	{
		_customContentX = a_x;
		_customContentY = a_y;
	}
	
	public function loadCustomContent(a_source: String): Void
	{
		unloadCustomContent();
		
		var optionsPanel: MovieClip = contentHolder.optionsPanel;
		
		_customContent = optionsPanel.createEmptyMovieClip("customContent", optionsPanel.getNextHighestDepth());
		_customContent._x = _customContentX;
		_customContent._y = _customContentY;
		_customContent.loadMovie(a_source);
		
		_optionsList._visible = false;
	}
	
	public function unloadCustomContent(): Void
	{
		if (!_customContent)
			return;
			
		_customContent.removeMovieClip();
		_customContent = undefined;
		
		_optionsList._visible = true;
	}
	
	public function setTitleText(a_text: String): Void
	{
		_titleText = a_text.toUpperCase();
		
		// Don't apply yet if waiting for option data
		if (_state != WAIT_FOR_OPTION_DATA)
			applyTitleText();
	}
	
	public function setInfoText(a_text: String): Void
	{
		_infoText = a_text;
		
		// Don't apply yet if waiting for option data
		if (_state != WAIT_FOR_OPTION_DATA)
			applyInfoText();
	}
	
	public function setOptionFlagsBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionFlagsBuffer[i] = arguments[i];
	}
	
	public function setOptionTextBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionTextBuffer[i] = arguments[i];
	}
	
	public function setOptionStrValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionStrValueBuffer[i] = arguments[i] === "None" ? null : arguments[i];
	}
	
	public function setOptionNumValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionNumValueBuffer[i] = arguments[i];
	}

	public function setSliderDialogParams(a_value: Number, a_default: Number, a_min: Number, a_max: Number, a_interval: Number): Void
	{
		_state = DIALOG;
		
		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			sliderValue: a_value,
			sliderDefault: a_default,
			sliderMax: a_max,
			sliderMin: a_min,
			sliderInterval: a_interval,
			sliderFormatString: _sliderDialogFormatString
		};
		
		_optionChangeDialog = DialogManager.open(this, "OptionSliderDialog", initObj);
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}
	
	public function setMenuDialogOptions(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_menuDialogOptions[i] = arguments[i];
	}
	
	public function setMenuDialogParams(a_startIndex: Number, a_defaultIndex: Number): Void
	{
		_state = DIALOG;
		
		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			menuOptions: _menuDialogOptions,
			menuStartIndex: a_startIndex,
			menuDefaultIndex: a_defaultIndex
		};
		
		_optionChangeDialog = DialogManager.open(this, "OptionMenuDialog", initObj);
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}

	public function setColorDialogParams(a_currentColor: Number, a_defaultColor: Number): Void
	{
		_state = DIALOG;
		
		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			currentColor: a_currentColor,
			defaultColor: a_defaultColor
		};
		
		_optionChangeDialog = DialogManager.open(this, "OptionColorDialog", initObj);
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}
	
	public function flushOptionBuffers(a_optionCount: Number): Void
	{
		_optionsList.clearList();
		_optionsList.listState.savedIndex = null;
		
		for (var i=0; i<a_optionCount; i++) {
			// Both option type and flags are passed in the flags buffer
			var optionType = _optionFlagsBuffer[i] & 0xFF;
			var flags = (_optionFlagsBuffer[i] >>> 8) & 0xFF;
			
			_optionsList.entryList.push({optionType: optionType, 
										 text: _optionTextBuffer[i],
 										 strValue: _optionStrValueBuffer[i],
										 numValue: _optionNumValueBuffer[i],
										 flags: flags});
		}
		
		// Pad uneven option count with empty option keyboard selection area is symmetrical
		if ((_optionsList.entryList.length % 2) != 0)
			_optionsList.entryList.push({optionType: OptionsListEntry.OPTION_EMPTY});
			
		_optionsList.InvalidateData();
		_optionsList.selectedIndex = -1;
		
		_optionFlagsBuffer.splice(0);
		_optionTextBuffer.splice(0);
		_optionStrValueBuffer.splice(0);
		_optionNumValueBuffer.splice(0);
		
		applyTitleText();
		
		_highlightIndex = -1;
		clearInterval(_highlightIntervalID);
		
		_infoText = "";
		applyInfoText();
	}
	
	// Direct access to option data
	public var optionCursorIndex = -1;
	
	public function get optionCursor(): Object
	{
		return _optionsList.entryList[optionCursorIndex];
	}
	
	public function invalidateOptionData(): Void
	{
		_optionsList.InvalidateData();
	}
	
	public function setOptionFlags(/* values */): Void
	{
		var index = arguments[0];
		var flags = arguments[1] >>> 8;
		_optionsList.entryList[index].flags = flags;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function initExtensions(): Void
	{
		bottomBar.Lock("B");
		_bottomBarStartY = bottomBar._y;
		
		showWelcomeScreen();
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		if (a_platform == 0) {
			_acceptControls = InputDefines.Enter;
			_cancelControls = InputDefines.Escape;
		} else {
			_acceptControls = InputDefines.Accept;
			_cancelControls = InputDefines.Cancel;
		}
		
		_buttonPanelL.setPlatform(a_platform, a_bPS3Switch);
		_buttonPanelR.setPlatform(a_platform, a_bPS3Switch);
		
		updateModListButtons(false);
	}

	public function startPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		_parent.gotoAndPlay("fadeIn");
		
		changeFocus(FOCUS_MODLIST);
		showWelcomeScreen();
	}
	
	public function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_bRemapMode)
			return true;
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if (_focus == FOCUS_OPTIONS) {
				var valid = _optionsList.selectedIndex % 2 == 0 && _subList.entryList.length > 0 && _subList._visible;
				if (valid && details.navEquivalent == NavigationCode.LEFT) {
					changeFocus(FOCUS_MODLIST);
					_optionsList.listState.savedIndex = _optionsList.selectedIndex;
					_optionsList.selectedIndex = -1;
					
					var restored = _subList.listState.savedIndex;
					_subList.selectedIndex = restored ? restored : _subList.listState.activeEntry.itemIndex;
					return true;
				}
			} else if (_focus == FOCUS_MODLIST) {
				var valid = _optionsList.entryList.length > 0 && _optionsList._visible;
				if (valid && details.navEquivalent == NavigationCode.RIGHT) {
					changeFocus(FOCUS_OPTIONS);
					_subList.listState.savedIndex = _subList.selectedIndex;
					_subList.selectedIndex = -1;
					
					var restored = _optionsList.listState.savedIndex;
					_optionsList.selectedIndex = restored ? restored : 0;
					return true;
				}
			}
		}
		
		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;
	
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				_parentMenu.ConfigPanelClose();
				return true;
			}
		}
		
		return false;
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onModListEnter(event: Object): Void
	{
		showWelcomeScreen();
	}
	
	private function onModListExit(event: Object): Void
	{
	}
	
	private function onSubListEnter(event: Object): Void
	{
	}
	
	private function onSubListExit(event: Object): Void
	{
		_optionsList.clearList();
		_optionsList.InvalidateData();
		unloadCustomContent();
	}
	
	private function onModListPress(a_event: Object): Void
	{
		selectMod(a_event.entry);
	}
	
	private function onModListChange(a_event: Object): Void
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_MODLIST);
			
		updateModListButtons(false);
	}
	
	private function onSubListPress(a_event: Object): Void
	{
		selectPage(a_event.entry);
	}
	
	private function onSubListChange(a_event: Object): Void
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_MODLIST);
			
		updateModListButtons(true);
	}
	
	private function onOptionPress(a_event: Object): Void
	{
		selectOption(a_event.index);
	}
	
	private function onOptionChange(a_event: Object): Void
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_OPTIONS);
		
		initHighlightOption(a_event.index);
		updateOptionButtons();
	}
	
	private function onOptionChangeDialogClosing(event: Object): Void
	{
		dimIn();
	}
	
	
	private function onOptionChangeDialogClosed(event: Object): Void
	{
//		categoryList.disableSelection = categoryList.disableInput = false;
//		itemList.disableSelection = itemList.disableInput = false;
//		searchWidget.isDisabled = false;
	}
	
	private function selectMod(a_entry: Object): Void
	{		
		if (_state != READY)
			return;
		
		_subList.listState.activeEntry = null;
		_subList.clearList();
		_subList.InvalidateData();
		
		_optionsList.clearList();
		_optionsList.InvalidateData();
		unloadCustomContent();
		
		_state = WAIT_FOR_OPTION_DATA;
		skse.SendModEvent("SKICP_modSelected", null, a_entry.modIndex);
		
		_modListPanel.showSublist();
	}
	
	private function selectPage(a_entry: Object): Void
	{		
		if (_state != READY)
			return;
			
		if (a_entry == undefined)
			return;
		
		_subList.listState.activeEntry = a_entry;
		_subList.UpdateList();
		
		_state = WAIT_FOR_OPTION_DATA;
		skse.SendModEvent("SKICP_pageSelected", a_entry.text);
	}
	
	private function selectOption(a_index: Number): Void
	{
		if (_state != READY)
			return;
		
		var e = _optionsList.selectedEntry;
		if (e == undefined)
			return;
		
		switch (e.optionType) {
			case OptionsListEntry.OPTION_EMPTY:
			case OptionsListEntry.OPTION_HEADER:
				break;
				
			case OptionsListEntry.OPTION_TEXT:
			case OptionsListEntry.OPTION_TOGGLE:
				_state = WAIT_FOR_SELECT;
				skse.SendModEvent("SKICP_optionSelected", null, a_index);
				break;
				
			case OptionsListEntry.OPTION_SLIDER:
				_state = WAIT_FOR_SLIDER_DATA;
				_dialogTitleText = e.text;
				_sliderDialogFormatString = e.strValue;
				skse.SendModEvent("SKICP_sliderSelected", null, a_index);
				break;
				
			case OptionsListEntry.OPTION_MENU:
				_state = WAIT_FOR_MENU_DATA;
				_dialogTitleText = e.text;
				skse.SendModEvent("SKICP_menuSelected", null, a_index);
				break;

			case OptionsListEntry.OPTION_COLOR:
				_state = WAIT_FOR_MENU_DATA;
				_dialogTitleText = e.text;
				skse.SendModEvent("SKICP_colorSelected", null, a_index);
				break;
				
			case OptionsListEntry.OPTION_KEYMAP:
				if (!_bRemapMode) {
					_currentRemapOption = a_index;
					initRemapMode();
				}
				break;
		}
	}
	
	private function initRemapMode(): Void
	{
		dimOut();
		var dialog = DialogManager.open(this, "KeymapDialog", {_x: 719, _y: 240});
		dialog.background._width = dialog.textField.textWidth + 100;
		
		_bRemapMode = true;
		skse.StartRemapMode(this);
	}
	
	// @SKSE
	private function EndRemapMode(a_keyCode: Number): Void
	{
		selectedKeyCode = a_keyCode;
		_state = WAIT_FOR_SELECT;
		skse.SendModEvent("SKICP_keymapChanged", null, _currentRemapOption);
		_remapDelayID = setInterval(this, "clearRemap", 200);
		
		DialogManager.close();
		dimIn();
	}
	
	private function clearRemap(): Void
	{
		clearInterval(_remapDelayID);
		delete _remapDelayID;
		
		_optionsList.disableSelection = false;
		_optionsList.disableInput = false;
		_bRemapMode = false;
		_currentRemapOption = -1;
	}
	
	private function initHighlightOption(a_index: Number): Void
	{
		if (_state != READY)
			return;
		
		// Same option?
		if (a_index == _highlightIndex)
			return;

		_highlightIndex = a_index;
		
		clearInterval(_highlightIntervalID);
		_highlightIntervalID = setInterval(doHighlightOption, 200, a_index);
	}
	
	private function doHighlightOption(a_index: Number): Void
	{
		clearInterval(_highlightIntervalID);
		delete _highlightIntervalID;
		
		skse.SendModEvent("SKICP_optionHighlighted", null, a_index);
	}
	
	private function applyTitleText(): Void
	{
		titlebar.textField.text = _titleText;
		
		var w = titlebar.textField.textWidth + 100;
		if (w < 300)
			w = 300;
			
		titlebar.background._width = w;
	}
	
	private function applyInfoText(): Void
	{
		var t = contentHolder.infoPanel;
		
		t.textField.text = _infoText;
		
		if (_infoText != "") {
			var h = t.textField.textHeight + 22;
			t.background._height = h;
		} else {
			t.background._height = 32;
		}
	}
	
	private function changeFocus(a_focus: Number): Void
	{
		_focus = a_focus;
		FocusHandler.instance.setFocus(a_focus == FOCUS_OPTIONS ? _optionsList : _modListPanel, 0);
	}
	
	private function dimOut(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		_optionsList.disableSelection = true;
		_optionsList.disableInput = true;
		TweenLite.to(bottomBar, 0.5, {_alpha: 0, _y: _bottomBarStartY+50, overwrite: 1, easing: Linear.easeNone});
		TweenLite.to(contentHolder, 0.5, {_alpha: 75, overwrite: 1, easing: Linear.easeNone});
	}
	
	private function dimIn(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		_optionsList.disableSelection = false;
		_optionsList.disableInput = false;
		TweenLite.to(bottomBar, 0.5, {_alpha: 100, _y: _bottomBarStartY, overwrite: 1, easing: Linear.easeNone});
		TweenLite.to(contentHolder, 0.5, {_alpha: 100, overwrite: 1, easing: Linear.easeNone});
	}
	
	private function showWelcomeScreen(): Void
	{
		setCustomContentParams(150, 50);
		loadCustomContent("skyui/mcm_splash.swf");

		setTitleText("MOD CONFIGURATION");
		setInfoText("");

	}
	
	private function updateModListButtons(a_bSubList: Boolean): Void
	{
		var entry = _modListPanel.selectedEntry;
		
		_buttonPanelL.clearButtons();
		if (entry != null)
			_buttonPanelL.addButton({text: "$Select", controls: _acceptControls});
		_buttonPanelL.updateButtons(true);

		_buttonPanelR.clearButtons();
		_buttonPanelR.addButton({text: a_bSubList? "$Back" : "$Exit", controls: _cancelControls});
		_buttonPanelR.updateButtons(true);
	}
	
	private function updateOptionButtons(): Void
	{
		var entry = _optionsList.selectedEntry;
		
		_buttonPanelL.clearButtons();
		
		if (entry != null) {
			var type = entry.optionType;
			switch (type) {
				case OptionsListEntry.OPTION_EMPTY:
				case OptionsListEntry.OPTION_HEADER:
					break;
				case OptionsListEntry.OPTION_TOGGLE:
					_buttonPanelL.addButton({text: "$Toggle", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_TEXT:
					_buttonPanelL.addButton({text: "$Select", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_SLIDER:
					_buttonPanelL.addButton({text: "$Open Slider", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_MENU:
					_buttonPanelL.addButton({text: "$Open Menu", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_COLOR:
					_buttonPanelL.addButton({text: "$Pick Color", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_KEYMAP:
					_buttonPanelL.addButton({text: "$Remap", controls: _acceptControls});
					break;
			}			
			_buttonPanelL.addButton({text: "$Default", controls: InputDefines.ReadyWeapon});
		}
		
		_buttonPanelL.updateButtons(true);

		_buttonPanelR.clearButtons();
		_buttonPanelR.addButton({text: "$Back", controls: _cancelControls});
		_buttonPanelR.updateButtons(true);
	}
}