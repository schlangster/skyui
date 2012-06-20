import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ButtonEntryFormatter;


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
	
	private var _modList: ModList;

	private var _state: Number;
	
	
  /* STAGE ELEMENTS */
	

	public var modListHolder: ModListPanel;
	
	public var decorTop: MovieClip;
	public var decorTitle: MovieClip;
	public var decorBottom: MovieClip;
	
	
  /* CONSTRUCTORS */
	
	function ConfigPanel()
	{
		_parentMenu = _root.QuestJournalFader.Menu_mc;
		_modList = modListHolder.modList;
	}
	
	function startPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuOK"]);
		_parent.gotoAndPlay("fadeIn");
		
		for (var i=0; i<25; i++)
			_modList.entryList.push({text: "MOD NUMBER " + i, align: "right", enabled: true, state: "normal"});
		
		_modList.InvalidateData();
	}
	
	function onLoad()
	{
		_modList.addEventListener("itemPress", this, "onColumnToggle");
		
		_modList.listEnumeration = new BasicEnumeration(_modList.entryList);
		_modList.entryFormatter = new ButtonEntryFormatter(_modList);
	}
	
	function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
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