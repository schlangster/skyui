import skyui.components.colorswatch.ColorSwatch;
import skyui.util.DialogManager;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.defines.Input;


class ColorDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
	
	private var _acceptButton: MovieClip;
	private var _defaultButton: MovieClip;
	private var _cancelButton: MovieClip;

	private var _defaultControls: Object;
	

  /* STAGE ELEMENTS */
	
	public var colorSwatch: ColorSwatch;
	

  /* PROPERTIES */
	
	public var currentColor: Number;
	public var defaultColor: Number;
	
	
  /* INITIALIZATION */
  
	public function ColorDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// @override OptionDialog
	private function initButtons(): Void
	{	
		var acceptControls: Object;
		var cancelControls: Object;

		if (platform == 0) {
			acceptControls = Input.Enter;
			_defaultControls = Input.ReadyWeapon;
			cancelControls = Input.Tab;
		} else {
			acceptControls = Input.Accept;
			_defaultControls = Input.YButton;
			cancelControls = Input.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		var cancelButton = rightButtonPanel.addButton({text: "$Cancel", controls: cancelControls});
		cancelButton.addEventListener("press", this, "onCancelPress");
		var acceptButton = rightButtonPanel.addButton({text: "$Accept", controls: acceptControls});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	public function initContent(): Void
	{
		colorSwatch._x = -colorSwatch._width/2;
		colorSwatch._y = -colorSwatch._height/2;
		colorSwatch.selectedColor = currentColor;

		FocusHandler.instance.setFocus(colorSwatch, 0);
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				onCancelPress();
				return true;
			} else if (details.navEquivalent == NavigationCode.ENTER) {
				onAcceptPress();
				return true;
			} else if (details.control == _defaultControls.name) {
				onDefaultPress();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function onAcceptPress(): Void
	{
		skse.SendModEvent("SKICP_colorAccepted", null, colorSwatch.selectedColor);
		DialogManager.close();
	}
	
	private function onDefaultPress(): Void
	{
		colorSwatch.selectedColor = defaultColor;
	}
	
	private function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}
}