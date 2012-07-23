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
	
	private var SHOW_MODLIST = 1;
	private var SHOW_SUBMODLIST = 2;
	private var FADE_TO_MODLIST = 3;
	private var FADE_TO_SUBMODLIST = 4;
	
	
  /* PRIVATE VARIABLES */
  
	// Quest_Journal_mc
	private var _parentMenu: MovieClip;
	
	private var _modListPanel: ModListPanel;
	private var _modList: ScrollingList;
	private var _subList: ScrollingList;
	private var _optionsList: MultiColumnScrollingList;
	private var _customContent: MovieClip;

	private var _state: Number;
	
	private var _optionChangeDialog: MovieClip;
	
	
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
	
	private static var in_optionTypeBuffer = [];
	private static var in_optionTextBuffer = [];
	private static var in_optionStrValueBuffer = [];
	private static var in_optionNumValueBuffer = [];
	
	public function setOptionTypeBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			in_optionTypeBuffer[i] = arguments[i];
	}
	
	public function setOptionTextBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			in_optionTextBuffer[i] = arguments[i];
	}
	
	public function setOptionStrValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			in_optionStrValueBuffer[i] = arguments[i];
	}
	
	public function setOptionNumValueBuffer(/* values */): Void
	{
		for (var i = 0; i < arguments.length; i++)
			in_optionNumValueBuffer[i] = arguments[i];
	}
	
	public function flushOptionBuffers(a_optionCount: Number): Void
	{
		_optionsList.clearList();
		for (var i=0; i<a_optionCount; i++) {
			_optionsList.entryList.push({optionType: in_optionTypeBuffer[i], 
										 text: in_optionTextBuffer[i],
 										 strValue: in_optionStrValueBuffer[i],
										 numValue: in_optionNumValueBuffer[i],
										 enabled: true});
		}
			
		_optionsList.InvalidateData();
		
		in_optionTypeBuffer.splice(0);
		in_optionTextBuffer.splice(0);
		in_optionStrValueBuffer.splice(0);
		in_optionNumValueBuffer.splice(0);
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
		ButtonEntryFormatter(_subList.entryFormatter).activeEntry = null;
		_subList.clearList();
		_subList.InvalidateData();
		
		skse.SendModEvent("modSelected", null, a_event.index);

//		unloadCustomContent();
		contentHolder.modListPanel.showSublist();
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
		_optionChangeDialog = DialogManager.open(this, "OptionChangeDialog", {_x: 562, _y: 265});
		_optionChangeDialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		_optionChangeDialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		
		gotoAndPlay("dimOut");
	}
	
	public function onOptionChangeDialogClosing(event: Object): Void
	{
//		categoryList.disableSelection = categoryList.disableInput = false;
//		itemList.disableSelection = itemList.disableInput = false;
//		searchWidget.isDisabled = false;
		
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
}