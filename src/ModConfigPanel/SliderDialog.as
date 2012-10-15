import skyui.util.DialogManager;
import skyui.util.GlobalFunctions;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;


class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */
	
	private var _acceptButton: MovieClip;
	private var _defaultButton: MovieClip;
	private var _cancelButton: MovieClip;

	private var _defaultControls: Object;
	

  /* STAGE ELEMENTS */
  
	public var sliderPanel: MovieClip;

	
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
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	// @override OptionDialog
	private function initButtons(): Void
	{	
		var acceptControls: Object;
		var cancelControls: Object;
		
		if (platform == 0) {
			acceptControls = InputDefines.Enter;
			_defaultControls = InputDefines.ReadyWeapon;
			cancelControls = InputDefines.Escape;
		} else {
			acceptControls = InputDefines.Accept;
			_defaultControls = InputDefines.YButton;
			cancelControls = InputDefines.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		_acceptButton = leftButtonPanel.addButton({text: "$Accept", controls: acceptControls});
		_acceptButton.addEventListener("press", this, "onAcceptPress");
		_defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
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

		FocusHandler.instance.setFocus(sliderPanel.slider, 0);
	}
	
	public function onAcceptPress(): Void
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
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
}