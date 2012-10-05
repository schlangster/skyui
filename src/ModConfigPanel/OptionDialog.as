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
  
	public var platform: Number;
	
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
		var acceptControls: Object;
		var cancelControls: Object;
		var defaultControls = [{name: "XButton", context: skseDefines.kContext_ItemMenu}];
		
		if (platform == 0) {
			acceptControls = [{keyCode: 28}];
			cancelControls = [{keyCode: 15}];
		} else {
			acceptControls = [{name: "Accept", context: skseDefines.kContext_MenuMode}];
			cancelControls = [{name: "Cancel", context: skseDefines.kContext_MenuMode}];
		}
		
		confirmButton.setPlatform(platform);
		confirmButton.setButtonData({text: "$Accept", controls: acceptControls});
		confirmButton.addEventListener("press", this, "onConfirmPress");
		
		cancelButton.setPlatform(platform);
		cancelButton.setButtonData({text: "$Cancel", controls: cancelControls});
		cancelButton.addEventListener("press", this, "onCancelPress");
		
		defaultButton.setPlatform(platform);
		defaultButton.setButtonData({text: "$Default", controls: defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");

		_updateButtonID = setInterval(this, "updateButtonPositions", 1);
	}
	
	private function updateButtonPositions(): Void
	{
		clearInterval(_updateButtonID);
		delete _updateButtonID;
		
		confirmButton._x = -(background._width / 2) + 30;
		defaultButton._x = confirmButton._x + confirmButton.width + 1;
		cancelButton._x = (background._width / 2) - cancelButton.width - 20;
	}
}