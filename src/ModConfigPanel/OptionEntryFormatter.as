import skyui.components.list.BasicList;
import skyui.components.list.IEntryFormatter;

class OptionEntryFormatter implements IEntryFormatter
{
  /* CONSTANTS */
	
	public static var OPTION_EMPTY = 0;
	public static var OPTION_HEADER = 1;
	public static var OPTION_TEXT = 2;
	public static var OPTION_TOGGLE = 3;
	public static var OPTION_SLIDER = 4;
	public static var OPTION_MENU = 5;
	
	
  /* PRIVATE VARIABLES */
  
	private var _list: BasicList;
	
	
  /* CONSTRUCTORS */
	
	public function OptionEntryFormatter(a_list: BasicList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;
			
		switch (a_entryObject.optionType) {
			
			case OPTION_HEADER:
				a_entryClip.gotoAndStop("header");
				
				a_entryClip.labelTextField.SetText(a_entryObject.labelText);
				break;
				
			case OPTION_TEXT:
				a_entryClip.gotoAndStop("text");
				
				a_entryClip.labelTextField._width;
				a_entryClip.labelTextField.SetText(a_entryObject.labelText);				
				a_entryClip.valueTextField.SetText(a_entryObject.valueText);
				
				break;
				
			case OPTION_TOGGLE:
				a_entryClip.gotoAndStop("toggle");
				a_entryClip.labelTextField.SetText(a_entryObject.labelText);
				break;
				
			case OPTION_SLIDER:
				a_entryClip.gotoAndStop("slider");
				
				a_entryClip.labelTextField.SetText(a_entryObject.labelText);
				
				a_entryClip.valueTextField.SetText(a_entryObject.valueText);
			
				a_entryClip.onEnterFrame = updateSliderIconFunc;
				break;
				
			case OPTION_MENU:
				a_entryClip.gotoAndStop("menu");
				
				a_entryClip.labelTextField.SetText(a_entryObject.labelText);
				
				a_entryClip.valueTextField.SetText(a_entryObject.valueText);
				
				a_entryClip.onEnterFrame = updateMenuIconFunc;
				break;
				
			case OPTION_EMPTY:
			default:
				a_entryClip.gotoAndStop("empty");
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	// For some reason getLineMetrics is off by 5px in the same frame. Sad story.
	private function updateSliderIconFunc(): Void
	{
		var e = this;
		e.sliderIcon._x = e.valueTextField.getLineMetrics(0).x - e.sliderIcon._width;
		delete e.onEnterFrame;
	}
	
	private function updateMenuIconFunc(): Void
	{
		var e = this;
		e.menuIcon._x = e.valueTextField.getLineMetrics(0).x - e.menuIcon._width;
		delete e.onEnterFrame;
	}
}