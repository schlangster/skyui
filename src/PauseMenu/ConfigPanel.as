import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;


class ConfigPanel extends MovieClip
{
	var Quest_Journal_mc: MovieClip;
	
	function ConfigPanel()
	{
		Quest_Journal_mc = _root.QuestJournalFader.Menu_mc;
	}
	
	function onLoad(): Void {
	}
	
	function startPage(): Void {
		GameDelegate.call("PlaySound", ["UIMenuOK"]); // Make some noise
		_parent.gotoAndPlay("fadeIn"); // Fade in ConfigPanelFader
	}
	
	function endPage(): Void {
		GameDelegate.call("PlaySound", ["UIMenuCancel"]); // Make some noise
		_parent.gotoAndPlay("fadeOut"); // Fade out ConfigPanelFader
	}
	
	function handleInput(details: InputDetails, pathToFocus: Array): Boolean {
		var bHandledInput: Boolean = false;
		
		if (pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
	
		if (!bHandledInput && GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				Quest_Journal_mc.ConfigPanelClose(); // Close the config panel and return to System Page
				bHandledInput = true;
			}
		}
		return bHandledInput;
	}

}