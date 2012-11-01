import skyui.util.DialogManager;
import skyui.util.GlobalFunctions;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;


class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */

	private var _acceptControls: Object;
	private var _defaultControls: Object;
	private var _cancelControls: Object;
	

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
	

   /* PUBLIC FUNCTIONS */
   
	// @override OptionDialog
	public function initButtons(): Void
	{	
		if (platform == 0) {
			_acceptControls = InputDefines.Enter;
			_defaultControls = InputDefines.ReadyWeapon;
			_cancelControls = InputDefines.Tab;
		} else {
			_acceptControls = InputDefines.Accept;
			_defaultControls = InputDefines.YButton;
			_cancelControls = InputDefines.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		var cancelButton = rightButtonPanel.addButton({text: "$Cancel", controls: _cancelControls});
		cancelButton.addEventListener("press", this, "onCancelPress");
		var acceptButton = rightButtonPanel.addButton({text: "$Accept", controls: _acceptControls});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		rightButtonPanel.updateButtons();
	}

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

	private function onValueChange(event: Object): Void
	{
		sliderValue = event.target.value;
		updateValueText();
	}
	
	private function onAcceptPress(): Void
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
		DialogManager.close();
	}
	
	private function onDefaultPress(): Void
	{
		sliderValue = sliderPanel.slider.value = sliderDefault;
		updateValueText();
	}

	private function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}

	private function updateValueText(): Void
	{
		var t = sliderFormatString	? GlobalFunctions.formatString(sliderFormatString, sliderValue)
									: t = Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
	}
}