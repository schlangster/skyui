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
  /* CONSTANTS */
	
	public var OPTION_SLIDER = 0;
	public var OPTION_MENU = 1;
	

  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var confirmButton: CrossPlatformButtons;
	public var cancelButton: CrossPlatformButtons;
	public var defaultButton: CrossPlatformButtons;
	
	public var sliderContent: MovieClip;

	
  /* PROPERTIES */
	
	public var optionType: ListLayout;
	
	
  /* CONSTRUCTORS */
  
	public function OptionChangeDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoad(): Void
	{

		initButtons();
		
		sliderContent.slider.setScrollProperties(0.7, 0, 20);
		sliderContent.slider.addEventListener("scroll", this, "onScroll");
		sliderContent.slider.position = 50;
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
	
	
  /* PRIVATE FUNCTIONS */
	
	private function initButtons(): Void
	{
		var platform = _global.skyui.platform;
		confirmButton.SetPlatform(platform, false);
		cancelButton.SetPlatform(platform, false);
		defaultButton.SetPlatform(platform, false);

		confirmButton.addEventListener("press", this, "onConfirmPress");
		cancelButton.addEventListener("press", this, "onCancelPress");
		defaultButton.addEventListener("press", this, "onDefaultPress");

		_updateButtonID = setInterval(this, "updateButtonPositions", 1);
	}
	
	private function updateButtonPositions(): Void
	{
		clearInterval(_updateButtonID);
		delete _updateButtonID;
		
		cancelButton._x = (background._width / 2) - cancelButton.textField.textWidth - 30;
		confirmButton._x = cancelButton._x - cancelButton.textField.textWidth - 30;
		defaultButton._x = -(background._width / 2) + 55;
	}
	
	private function onCancelPress(): Void
	{
		DialogManager.close();
	}
	
	private function onConfirmPress(): Void
	{
		DialogManager.close();
	}
	
	private function onDefaultPress(): Void
	{
		DialogManager.close();
	}
}