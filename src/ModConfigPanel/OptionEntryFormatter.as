import skyui.components.list.BasicList;
import skyui.components.list.IEntryFormatter;

import skyui.util.GlobalFunctions;

class OptionEntryFormatter implements IEntryFormatter
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
		var isSelected = a_entryObject == _list.selectedEntry;
		
		var selectIndicator = a_entryClip.selectIndicator;
		selectIndicator._visible = isSelected;
			
		switch (a_entryObject.optionType) {
			
			case OPTION_HEADER:
				a_entryClip.gotoAndStop("header");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = 100;

				var headerDecor = a_entryClip.headerDecor;
				headerDecor._x = labelTextField.getLineMetrics(0).width + 10;
				headerDecor._width = entryWidth - headerDecor._x;
				
				break;
				
			case OPTION_TEXT:
				a_entryClip.gotoAndStop("text");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.strValue.toUpperCase());
				
				break;
				
			case OPTION_TOGGLE:
				a_entryClip.gotoAndStop("toggle");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				var toggleIcon = a_entryClip.toggleIcon;
				toggleIcon._x = entryWidth - toggleIcon._width;
				toggleIcon.gotoAndStop(a_entryObject.numValue? "on" : "off");
				
				break;
				
			case OPTION_SLIDER:
				a_entryClip.gotoAndStop("slider");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? 100 : ALPHA_ACTIVE;
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				if (a_entryObject.strValue)
					valueTextField.SetText(GlobalFunctions.format(a_entryObject.strValue, a_entryObject.numValue).toUpperCase());
				else
					valueTextField.SetText(Math.round(a_entryObject.numValue * 100) / 100);
			
				var sliderIcon = a_entryClip.sliderIcon;
				sliderIcon._x = valueTextField.getLineMetrics(0).x - sliderIcon._width;
				
				break;
				
			case OPTION_MENU:
				a_entryClip.gotoAndStop("menu");
				
				var labelTextField = a_entryClip.labelTextField;
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				var valueTextField = a_entryClip.valueTextField;
				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.strValue.toUpperCase());
				
				var menuIcon = a_entryClip.menuIcon;
				menuIcon._x = valueTextField.getLineMetrics(0).x - menuIcon._width;
				
				break;
				
			case OPTION_EMPTY:
			default:
				a_entryClip.gotoAndStop("empty");
		}
	}
}