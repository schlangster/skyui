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

		var entryWidth = a_entryClip.width;
			
		switch (a_entryObject.optionType) {
			
			case OPTION_HEADER:
				a_entryClip.gotoAndStop("header");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.labelText);

				var headerDecor = a_entryClip.headerDecor;
				headerDecor._x = labelTextField.getLineMetrics(0).width + 10;
				headerDecor._width = entryWidth - headerDecor._x;
				
				break;
				
			case OPTION_TEXT:
				a_entryClip.gotoAndStop("text");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.labelText);
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.valueText);
				
				break;
				
			case OPTION_TOGGLE:
				a_entryClip.gotoAndStop("toggle");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.labelText);
				
				var toggleIcon = a_entryClip.toggleIcon;
				toggleIcon._x = entryWidth - toggleIcon._width;
				
				break;
				
			case OPTION_SLIDER:
				a_entryClip.gotoAndStop("slider");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.labelText);
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.valueText);
			
				var sliderIcon = a_entryClip.sliderIcon;
				sliderIcon._x = valueTextField.getLineMetrics(0).x - sliderIcon._width;
				
				break;
				
			case OPTION_MENU:
				a_entryClip.gotoAndStop("menu");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.labelText);
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.valueText);
				
				var menuIcon = a_entryClip.menuIcon;
				menuIcon._x = valueTextField.getLineMetrics(0).x - menuIcon._width;
				break;
				
			case OPTION_EMPTY:
			default:
				a_entryClip.gotoAndStop("empty");
		}
	}
}