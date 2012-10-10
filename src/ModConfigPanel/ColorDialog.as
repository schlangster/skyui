import skyui.components.colorswatch.ColorSwatch;
import skyui.util.DialogManager;
import gfx.managers.FocusHandler;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;


class ColorDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
	
  	private var _defaultButton: MovieClip;
  	private var _closeButton: MovieClip;
	

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
		var closeControls: Object;
		
		if (platform == 0) {
			closeControls = InputDefines.Escape;
		} else {
			closeControls = InputDefines.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		_defaultButton = leftButtonPanel.addButton({text: "$Default", controls: InputDefines.ReadyWeapon});
		_defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		_closeButton = rightButtonPanel.addButton({text: "$Exit", controls: closeControls});
		_closeButton.addEventListener("press", this, "onExitPress");
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
	
	public function onDefaultPress(): Void
	{
		colorSwatch.selectedColor = defaultColor;
	}
	
	public function onExitPress(): Void
	{
		skse.SendModEvent("SKICP_colorAccepted", null, colorSwatch.selectedColor);
		DialogManager.close();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				onExitPress();
				return true;
			}
		}
		
		return false;
	}
}