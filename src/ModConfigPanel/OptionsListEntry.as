import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;


class OptionsListEntry extends BasicListEntry
{
  /* CONSTANTS */
	
	public static var OPTION_EMPTY = 0;
	public static var OPTION_HEADER = 1;
	public static var OPTION_TEXT = 2;
	public static var OPTION_TOGGLE = 3;
	public static var OPTION_SLIDER = 4;
	public static var OPTION_MENU = 5;
	
	public static var ALPHA_SELECTED = 100;
	public static var ALPHA_ACTIVE = 75;
	
	
  /* STAGE ELMENTS */

	public var selectIndicator: MovieClip;

	public var labelTextField: TextField;
	public var valueTextField: TextField;
	
	public var headerDecor: MovieClip;
	public var sliderIcon: MovieClip;
	public var menuIcon: MovieClip;
	public var toggleIcon: MovieClip;
	
	
  /* PROPERTIES */
	
	public function get width(): Number
	{
		return background._width;
	}

	public function set width(a_val: Number)
	{
		background._width = a_val;
		selectIndicator._width = a_val;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_list: ScrollingList): Void
	{
		gotoAndStop("empty");
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var entryWidth = background._width;
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		selectIndicator._visible = isSelected;
			
		switch (a_entryObject.optionType) {
			
			case OPTION_HEADER:
				gotoAndStop("header");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = 100;

				headerDecor._x = labelTextField.getLineMetrics(0).width + 10;
				headerDecor._width = entryWidth - headerDecor._x;
				
				break;
				
			case OPTION_TEXT:
				gotoAndStop("text");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.strValue.toUpperCase());
				
				break;
				
			case OPTION_TOGGLE:
				gotoAndStop("toggle");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				toggleIcon._x = entryWidth - toggleIcon._width;
				toggleIcon.gotoAndStop(a_entryObject.numValue? "on" : "off");
				
				break;
				
			case OPTION_SLIDER:
				gotoAndStop("slider");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? 100 : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				if (a_entryObject.strValue)
					valueTextField.SetText(GlobalFunctions.formatString(a_entryObject.strValue, a_entryObject.numValue).toUpperCase());
				else
					valueTextField.SetText(Math.round(a_entryObject.numValue * 100) / 100);
			
				sliderIcon._x = valueTextField.getLineMetrics(0).x - sliderIcon._width;
				
				break;
				
			case OPTION_MENU:
				gotoAndStop("menu");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.strValue.toUpperCase());
				
				menuIcon._x = valueTextField.getLineMetrics(0).x - menuIcon._width;
				
				break;
				
			case OPTION_EMPTY:
			default:
				gotoAndStop("empty");
		}
	}
}