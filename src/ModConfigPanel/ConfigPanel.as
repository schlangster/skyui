import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ScrollingList;
import skyui.util.DialogManager;


class ConfigPanel extends MovieClip
{
  /* CONSTANTS */
  
  	private var READY = 0;
	private var WAIT_FOR_OPTION_DATA = 1;
	private var WAIT_FOR_SLIDER_DATA = 2;
	private var WAIT_FOR_MENU_DATA = 3;
	private var WAIT_FOR_SELECT = 4;
	private var DIALOG = 5;
	
  /* PRIVATE VARIABLES */
  
	// Quest_Journal_mc
	private var _parentMenu: MovieClip;
	
	private var _modListPanel: ModListPanel;
	private var _modList: ScrollingList;
	private var _subList: ScrollingList;
	private var _optionsList: MultiColumnScrollingList;

	private var _customContent: MovieClip;
	private var _customContentX: Number = 0;
	private var _customContentY: Number = 0;
	
	private var _optionChangeDialog: MovieClip;
	
	private var _state: Number;
	
	private var _optionTypeBuffer: Array;
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
	
	
  /* STAGE ELEMENTS */

	public var contentHolder: MovieClip;
	
	public var titlebar: MovieClip;
	
	
  /* INITIALIATZION */
	
	function ConfigPanel()
	{
		_parentMenu = _root.QuestJournalFader.Menu_mc;

		_modListPanel = contentHolder.modListPanel;
		_modList = _modListPanel.modListFader.list;
		_subList = _modListPanel.subListFader.list;
		_optionsList = contentHolder.optionsPanel.optionsList;
		
		_state = READY;
		
		_optionTypeBuffer = [];
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

		_global.skyui.platform = 0;

		_modList.listEnumeration = new BasicEnumeration(_modList.entryList);
		_subList.listEnumeration = new BasicEnumeration(_subList.entryList);
		_optionsList.listEnumeration = new BasicEnumeration(_optionsList.entryList);
		
		_modList.addEventListener("itemPress", this, "onModListPress");
		_subList.addEventListener("itemPress", this, "onSubListPress");
		_optionsList.addEventListener("itemPress", this, "onOptionPress");
		_optionsList.addEventListener("selectionChange", this, "onOptionChange");
		
		_modListPanel.addEventListener("modListEnter", this, "onModListEnter");
		_modListPanel.addEventListener("modListExit", this, "onModListExit");
		_modListPanel.addEventListener("subListEnter", this, "onSubListEnter");
		_modListPanel.addEventListener("subListExit", this, "onSubListExit");

		_optionsList._visible = false;
		showWelcomeScreen();
	}
	
	public function onModListEnter(event: Object): Void
	{
		showWelcomeScreen();
	}
	
	public function onModListExit(event: Object): Void
	{
	}
	
	public function onSubListEnter(event: Object): Void
	{
	}
	
	public function onSubListExit(event: Object): Void
	{
		_optionsList.clearList();
		_optionsList.InvalidateData();
		unloadCustomContent();
	}
	
	
  /* PAPYRUS INTERFACE */
  
  	public function unlock(): Void
	{
		_state = READY;
	}
	
	public function setModNames(/* names */): Void
	{
		skse.Log("Called setConfigPanelModNamesDBG");
			
		_modList.clearList();
		for (var i=0; i<arguments.length; i++)
			if (arguments[i].toLowerCase() != "none")
				_modList.entryList.push({modIndex: i, text: arguments[i], align: "right", enabled: true});
		_modList.InvalidateData();
	}
	
	public function setPageNames(/* names */): Void
	{
		skse.Log("Called setConfigPanelPageNames");
		
		_subList.clearList();
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
	
	public function setOptionTypeBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionTypeBuffer[i] = arguments[i];
	}
	
	public function setOptionTextBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionTextBuffer[i] = arguments[i];
	}
	
	public function setOptionStrValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++) {
			_optionStrValueBuffer[i] = arguments[i] === "None" ? null : arguments[i];
		}
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
			_x: 562, _y: 265,
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
		gotoAndPlay("dimOut");
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
			_x: 562, _y: 265,
			titleText: _dialogTitleText,
			menuOptions: _menuDialogOptions,
			menuStartIndex: a_startIndex,
			menuDefaultIndex: a_defaultIndex
		};
		
		_optionChangeDialog = DialogManager.open(this, "OptionMenuDialog", initObj);
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		gotoAndPlay("dimOut");
	}
	
	public function flushOptionBuffers(a_optionCount: Number): Void
	{
		_optionsList.clearList();
		for (var i=0; i<a_optionCount; i++) {
			_optionsList.entryList.push({optionType: _optionTypeBuffer[i], 
										 text: _optionTextBuffer[i],
 										 strValue: _optionStrValueBuffer[i],
										 numValue: _optionNumValueBuffer[i],
										 enabled: true});
		}
			
		_optionsList.InvalidateData();
		
		_optionTypeBuffer.splice(0);
		_optionTextBuffer.splice(0);
		_optionStrValueBuffer.splice(0);
		_optionNumValueBuffer.splice(0);
		
		applyTitleText();
		
		_highlightIndex = -1;
		clearInterval(_highlightIntervalID);
		
		_infoText = "";
		applyInfoText();
	}
	
	public var optionCursorIndex = -1;
	
	public function get optionCursor(): Object
	{
		return _optionsList.entryList[optionCursorIndex];
	}
	
	public function invalidateOptionData(): Void
	{
		_optionsList.InvalidateData();
	}
	
	private function startModSelectMode(): Void
	{
		
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function startPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		_parent.gotoAndPlay("fadeIn");
	}
	
	public function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
	}
	
	public function onModListPress(a_event: Object): Void
	{
		selectMod(a_event.entry);
	}
	
	public function onSubListPress(a_event: Object): Void
	{
		selectPage(a_event.entry);
	}
	
	public function onOptionPress(a_event: Object): Void
	{
		selectOption(a_event.index);
	}
	
	public function onOptionChange(a_event: Object): Void
	{
		initHighlightOption(a_event.index);
	}
	
	public function onOptionChangeDialogClosing(event: Object): Void
	{
		gotoAndPlay("dimIn");
	}
	
	
	public function onOptionChangeDialogClosed(event: Object): Void
	{
//		categoryList.disableSelection = categoryList.disableInput = false;
//		itemList.disableSelection = itemList.disableInput = false;
//		searchWidget.isDisabled = false;
	}
	
	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput = false;
		
		if (pathToFocus != undefined && pathToFocus.length > 0)
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
	
		if (!bHandledInput && GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				_parentMenu.ConfigPanelClose(); // Close the config panel and return to System Page
				bHandledInput = true;
			}
		}
		return bHandledInput;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
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
		
		contentHolder.modListPanel.showSublist();
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
		}
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
		_highlightIntervalID = setInterval(doHighlightOption, 300, a_index);
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
	
	private function showWelcomeScreen(): Void
	{
		setCustomContentParams(150, 50);
		loadCustomContent("skyui/mcm_splash.swf");

		setTitleText("MOD CONFIGURATION");
		setInfoText("");
	}
}