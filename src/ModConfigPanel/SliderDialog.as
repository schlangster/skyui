import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.dialog.BasicDialog;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;


class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */
	

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
	public function initContent(): Void
	{		
		var d = sliderInterval;
		sliderPanel.slider.setScrollProperties(((sliderMax - sliderMin) / d) / 10, sliderMin / d, sliderMax / d);
		sliderPanel.slider.addEventListener("scroll", this, "onScroll");
		sliderPanel.slider.position = sliderValue / d;
	}
	
	// @override OptionDialog
	public function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}
	
	// @override OptionDialog
	public function onConfirmPress(): Void
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
		DialogManager.close();
	}
	
	// @override OptionDialog
	public function onDefaultPress(): Void
	{
		sliderPanel.slider.position = sliderDefault / sliderInterval;
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;
		
		return bCaught;
	}
	
	public function onScroll(event: Object): Void
	{
		sliderValue = event.position * sliderInterval;
		var t = sliderFormatString	? GlobalFunctions.formatString(sliderFormatString, sliderValue)
									: t = Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
	}
}