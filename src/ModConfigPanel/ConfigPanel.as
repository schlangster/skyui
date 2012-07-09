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
	
	private var _platform: Number = 0;
	private var _bPS3Switch: Boolean = false;
	
	private var _modList: ScrollingList;
	private var _subList: ScrollingList;
	private var _optionsList: MultiColumnScrollingList;

	private var _state: Number;
	
	private var _optionChangeDialog: MovieClip;
	
	
  /* STAGE ELEMENTS */

	public var contentHolder: MovieClip;
	
	
  /* CONSTRUCTORS */
	
	function ConfigPanel()
	{
		_parentMenu = _root.QuestJournalFader.Menu_mc;

		_modList = contentHolder.modListPanel.modListFader.list;
		_subList = contentHolder.modListPanel.subListFader.list;
		_optionsList = contentHolder.optionsPanel.optionsList;
	}
	
	function startPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		_parent.gotoAndPlay("fadeIn");
		
		for (var i=0; i<25; i++)
			_modList.entryList.push({text: "MOD NUMBER " + i, align: "right", enabled: true, state: "normal"});
			
		for (var i=0; i<5; i++)
			_subList.entryList.push({text: "Sub Entry " + i, align: "right", enabled: true, state: "normal"});
			
		for (var i=0; i<48; i++)
			_optionsList.entryList.push({optionType: Math.floor(Math.random()*6), enabled: true, text: "Label " + i, strValue: "OPTION " + i, numValue: 123.45});
		
		_modList.InvalidateData();
		_subList.InvalidateData();
		_optionsList.InvalidateData();
	}
	
	function onLoad()
	{
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
		_global.skyui.bPS3Switch = false;
		
		startPage();
	}
	
	function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
	}
	
	public function onModListPress(a_event: Object): Void
	{
		contentHolder.modListPanel.showSublist();
	}
	
	public function onSubListPress(a_event: Object): Void
	{
		contentHolder.modListPanel.showList();
	}
	
	public function onOptionPress(a_event: Object): Void
	{
		_optionChangeDialog = DialogManager.open(this, "OptionChangeDialog", {_x: 562, _y: 265});
		_optionChangeDialog.addEventListener("dialogClosed", this, "onColumnSelectDialogClosed");
		
		contentHolder._alpha = 50;
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