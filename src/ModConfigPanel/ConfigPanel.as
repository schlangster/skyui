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
  /* PRIVATE VARIABLES */
  
	// Quest_Journal_mc
	private var _parentMenu: MovieClip;
	
	private var _modListPanel: ModListPanel;
	private var _modList: ScrollingList;
	private var _subList: ScrollingList;
	private var _optionsList: MultiColumnScrollingList;
	private var _customContent: MovieClip;
	
	private var _optionChangeDialog: MovieClip;
	
	// Waiting for Papyrus operations to complete
	private var _waitForOptionData: Boolean = false;
	private var _waitForSliderData: Boolean = false;
	private var _waitForMenuData: Boolean = false;
	
	
  /* STAGE ELEMENTS */

	public var contentHolder: MovieClip;
	
	
  /* INITIALIATZION */
	
	function ConfigPanel()
	{
		_parentMenu = _root.QuestJournalFader.Menu_mc;

		_modListPanel = contentHolder.modListPanel;
		_modList = _modListPanel.modListFader.list;
		_subList = _modListPanel.subListFader.list;
		_optionsList = contentHolder.optionsPanel.optionsList;
	}
	
	
  /* PAPYRUS INTERFACE */
	
	public function setModNames(/* names */): Void
	{
		skse.Log("Called setConfigPanelModNames");
		
		_modList.clearList();
		for (var i=0; i<arguments.length; i++)
			if (arguments[i].toLowerCase() != "none")
				_modList.entryList.push({text: arguments[i], align: "right", enabled: true});
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
	
	public function loadCustomContent(a_source: String): Void
	{
		unloadCustomContent();
		
		var optionsPanel: MovieClip = contentHolder.optionsPanel;
		
		_customContent = optionsPanel.createEmptyMovieClip("customContent", optionsPanel.getNextHighestDepth());
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
	
	private static var _optionTypeBuffer = [];
	private static var _optionTextBuffer = [];
	private static var _optionStrValueBuffer = [];
	private static var _optionNumValueBuffer = [];
	
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
		for (var i = 0; i < arguments.length; i++)
			_optionStrValueBuffer[i] = arguments[i];
	}
	
	public function setOptionNumValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			_optionNumValueBuffer[i] = arguments[i];
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
		
		_waitForOptionData = false;
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
			
//		for (var i=0; i<48; i++)
//			_optionsList.entryList.push({optionType: Math.floor(Math.random()*6), enabled: true, text: "Label " + i, strValue: "OPTION " + i, numValue: 123.45});
		

	}
	
	// @override MovieClip
	private function onLoad()
	{
		super.onLoad();
		
		_modList.listEnumeration = new BasicEnumeration(_modList.entryList);
		_modList.entryFormatter = new ButtonEntryFormatter(_modList);
		
		_subList.listEnumeration = new BasicEnumeration(_subList.entryList);
		_subList.entryFormatter = new ButtonEntryFormatter(_subList);
		
		_optionsList.listEnumeration = new BasicEnumeration(_optionsList.entryList);
		_optionsList.entryFormatter = new OptionEntryFormatter(_optionsList);
		
		_modList.addEventListener("itemPress", this, "onModListPress");
		_subList.addEventListener("itemPress", this, "onSubListPress");
		_optionsList.addEventListener("itemPress", this, "onOptionPress");
		
		// Debug
		Shared.GlobalFunc.MaintainTextFormat();
		
		_global.skyui.platform = 0;
		
//		startPage();
//		loadCustomContent("skyui_splash.swf");

		_optionsList._visible = false;
	}
	
	public function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
	}
	
	public function onModListPress(a_event: Object): Void
	{
		selectMod(a_event.index);
	}
	
	public function onSubListPress(a_event: Object): Void
	{
		var e = a_event.entry;
		if (e == undefined)
			return;
		
		ButtonEntryFormatter(_subList.entryFormatter).activeEntry = e;
		_subList.UpdateList();
		
		skse.SendModEvent("pageSelected", e.text);
	}
	
	public function onOptionPress(a_event: Object): Void
	{
		selectOption();
	}
	
	public function onOptionChangeDialogClosing(event: Object): Void
	{
		gotoAndPlay("dimIn");
	}
	
	
	public function onOptionChangeDialogClosed(event: Object): Void
	{
		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		searchWidget.isDisabled = false;
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
	
	private function selectMod(a_index: Number): Void
	{
		if (_waitForOptionData || _waitForSliderData || _waitForMenuData)
			return;
		
		ButtonEntryFormatter(_subList.entryFormatter).activeEntry = null;
		_subList.clearList();
		_subList.InvalidateData();
		
		_waitForOptionData = true;
		skse.SendModEvent("modSelected", null, a_index);

//		unloadCustomContent();
		contentHolder.modListPanel.showSublist();
	}
	
	private function selectOption(a_index: Number): Void
	{
		if (_waitForOptionData || _waitForSliderData || _waitForMenuData)
			return;
		
		_optionChangeDialog = DialogManager.open(this, "OptionChangeDialog", {_x: 562, _y: 265});
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		
		gotoAndPlay("dimOut");
	}
}