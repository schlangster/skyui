import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.dialog.BasicDialog;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;


class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */
  
  	private var _defaultButton: MovieClip;
  	private var _closeButton: MovieClip;
	

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
		var d = sliderInterval;
		sliderPanel.slider.setScrollProperties(((sliderMax - sliderMin) / d) / 10, sliderMin / d, sliderMax / d);
		sliderPanel.slider.addEventListener("scroll", this, "onScroll");
		sliderPanel.slider.position = sliderValue / d;
	}
	
	public function onExitPress(): Void
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
		DialogManager.close();
	}
	
	public function onDefaultPress(): Void
	{
		sliderPanel.slider.position = sliderDefault / sliderInterval;
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
	
	public function onScroll(event: Object): Void
	{
		sliderValue = event.position * sliderInterval;
		var t = sliderFormatString	? GlobalFunctions.formatString(sliderFormatString, sliderValue)
									: t = Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
	}
}