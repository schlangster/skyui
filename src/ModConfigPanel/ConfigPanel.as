import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.FilteredEnumeration;
import skyui.components.list.ButtonEntryFormatter;


class ConfigPanel extends MovieClip
{
  /* PRIVATE VARIABLES */
  
	// Quest_Journal_mc
	private var _parentMenu: MovieClip;
	
	
  /* STAGE ELEMENTS */
	
	private var modList: ModList;
	
	function ConfigPanel()
	{
		_parentMenu = _root.QuestJournalFader.Menu_mc;
		
		modList.listEnumeration = new BasicEnumeration(modList.entryList);
		modList.entryFormatter = new ButtonEntryFormatter(modList);
		
		modList.addEventListener("itemPress", this, "onColumnToggle");
	}
	
	function startPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuOK"]); // Make some noise
		_parent.gotoAndPlay("fadeIn"); // Fade in ConfigPanelFader
	}
	
	function endPage(): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]); // Make some noise
		_parent.gotoAndPlay("fadeOut"); // Fade out ConfigPanelFader
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