import skyui.util.DialogManager;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;


class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */
	
	private var _acceptButton: MovieClip;
	private var _defaultButton: MovieClip;
	private var _cancelButton: MovieClip;
	

  /* STAGE ELEMENTS */
  
	public var sliderPanel: MovieClip;


  /* PUBLIC VARIABLES */
	public var focusTarget;

	
  /* PROPERTIES */
	
	public var sliderValue: Number;
	public var sliderDefault: Number;
	public var sliderMax: Number;
	public var sliderMin: Number;
	public var sliderInterval: Number;
	public var sliderFormatString: String;

	
  /* INITIALIZATION */
  
	public function SliderDialog()
	{
		super();
		focusTarget = sliderPanel.slider;
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	// @override OptionDialog
	private function initButtons(): Void
	{
		var cancelControls: Object;
		
		if (platform == 0) {
			cancelControls = InputDefines.Escape;
		} else {
			cancelControls = InputDefines.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		_acceptButton = leftButtonPanel.addButton({text: "$Accept", controls: InputDefines.Accept});
		_acceptButton.addEventListener("press", this, "onAcceptPress");
		_defaultButton = leftButtonPanel.addButton({text: "$Default", controls: InputDefines.ReadyWeapon});
		_defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		_cancelButton = rightButtonPanel.addButton({text: "$Exit", controls: cancelControls});
		_cancelButton.addEventListener("press", this, "onCancelPress");
		rightButtonPanel.updateButtons();
	}

	private function onValueChange(event: Object): Void
	{
		sliderValue = event.target.value;
		updateValueText();
	}

	private function updateValueText(): Void
	{
		var t = sliderFormatString	? GlobalFunctions.formatString(sliderFormatString, sliderValue)
									: t = Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
	}

   /* PUBLIC FUNCTIONS */

	// @override OptionDialog
	public function initContent(): Void
	{
		sliderPanel.slider.maximum = sliderMax;
		sliderPanel.slider.minimum = sliderMin;
		sliderPanel.slider.liveDragging = true;
		sliderPanel.slider.snapInterval = sliderInterval;
		sliderPanel.slider.snapping = true;
		sliderPanel.slider.value = sliderValue;
		updateValueText();	
		sliderPanel.slider.addEventListener("change", this, "onValueChange");
	}
	
	public function onAcceptPress(): Void
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderDefault);
		DialogManager.close();
	}
	
	public function onDefaultPress(): Void
	{
		sliderValue = sliderPanel.slider.value = sliderDefault;
		updateValueText();
	}

	public function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.control == InputDefines.Cancel.name) {
				onCancelPress();
				return true;
			} else if (details.control == InputDefines.Accept.name) {
				onAcceptPress();
				return true;
			} else if (details.control == InputDefines.ReadyWeapon.name) {
				onDefaultPress();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
}