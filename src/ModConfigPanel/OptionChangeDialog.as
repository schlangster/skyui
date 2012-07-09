import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import Components.CrossPlatformButtons

import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ListLayout;
import skyui.components.dialog.BasicDialog;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;



class OptionChangeDialog extends BasicDialog
{	
  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var confirmButton: CrossPlatformButtons;
	public var cancelButton: CrossPlatformButtons;
	public var defaultButton: CrossPlatformButtons;

	
  /* PROPERTIES */
	
	public var layout: ListLayout;
	
	
  /* CONSTRUCTORS */
  
	public function OptionChangeDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoad(): Void
	{
		
		setButtons();
	}
	
	public function onDialogOpening(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}
	
	public function onDialogClosing(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
				
			if (details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT) {
				DialogManager.close();
				bCaught = true;
			}

			if (!bCaught)
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		
		return bCaught;
	}
	
	var _updateButtonID;
	
	private function setButtons(): Void
	{
		var platform = _global.skyui.platform;
		confirmButton.SetPlatform(platform, false);
		cancelButton.SetPlatform(platform, false);
		defaultButton.SetPlatform(platform, false);
		
		_updateButtonID = setInterval(this, "updateButtonPositions", 1);
	}
	
	function updateButtonPositions()
	{
		clearInterval(_updateButtonID);
		delete _updateButtonID;
		cancelButton._x = (background._width / 2) - cancelButton.textField.textWidth - 30;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setColumnListData()
	{
	}
}