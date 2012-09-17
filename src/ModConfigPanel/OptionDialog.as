import gfx.io.GameDelegate;
import Components.CrossPlatformButtons

import skyui.components.dialog.BasicDialog;


// @abstract
class OptionDialog extends BasicDialog
{	
  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var confirmButton: CrossPlatformButtons;
	public var cancelButton: CrossPlatformButtons;
	public var defaultButton: CrossPlatformButtons;
	
	public var titleTextField: TextField;

	
  /* PROPERTIES */
  
	public var titleText: String;
	
	
  /* INITIALIZATION */
  
	public function OptionDialog()
	{
		super();
	}
	
	// @override MovieClip
	public function onLoad(): Void
	{
		initButtons();

		titleTextField.textAutoSize = "shrink";
		titleTextField.SetText(titleText.toUpperCase());
		
		initContent();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
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
		
		return bCaught;
	}
	
	// @abstract
	public function initContent(): Void {}
	
	// @abstract
	public function onCancelPress(): Void {}
	
	// @abstract
	public function onConfirmPress(): Void {}
	
	// @abstract
	public function onDefaultPress(): Void {}
	
	
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
		
		confirmButton._x = (background._width / 2) - confirmButton.textField.textWidth - 30;
		cancelButton._x = confirmButton._x - cancelButton.textField.textWidth - 50;
		defaultButton._x = -(background._width / 2) + 55;
	}
}