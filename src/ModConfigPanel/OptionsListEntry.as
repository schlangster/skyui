import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;

class OptionsListEntry extends BasicListEntry
{
  /* CONSTANTS */
	
	// 1 byte
	public static var OPTION_EMPTY = 0x00;
	public static var OPTION_HEADER = 0x01;
	public static var OPTION_TEXT = 0x02;
	public static var OPTION_TOGGLE = 0x03;
	public static var OPTION_SLIDER = 0x04;
	public static var OPTION_MENU = 0x05;
	public static var OPTION_COLOR = 0x06;
	public static var OPTION_KEYMAP = 0x07;
	
	// 1 byte
	public static var FLAG_DISABLED = 0x01;
	public static var FLAG_HIDDEN = 0x02;
	public static var FLAG_WITH_UNMAP = 0x04;
	
	public static var ALPHA_SELECTED = 100;
	public static var ALPHA_ACTIVE = 75;

	public static var ALPHA_ENABLED = 100;
	public static var ALPHA_DISABLED = 50;
	
	
  /* STAGE ELMENTS */

	public var selectIndicator: MovieClip;

	public var labelTextField: TextField;
	public var valueTextField: TextField;
	
	public var headerDecor: MovieClip;
	public var sliderIcon: MovieClip;
	public var menuIcon: MovieClip;
	public var toggleIcon: MovieClip;
	public var colorIcon: MovieClip;
	public var buttonArt: MovieClip;
	
	
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

		var flags = a_entryObject.flags;
		var isEnabled = !(flags & (FLAG_DISABLED | FLAG_HIDDEN));
		
		selectIndicator._visible = isSelected;
		
		_alpha = isEnabled ? ALPHA_ENABLED : ALPHA_DISABLED;
		
		// If entry is hidden, treat like empty option
		var optionType = a_entryObject.optionType;
		if (flags & FLAG_HIDDEN)
			optionType = OPTION_EMPTY;
		
		switch (optionType) {
			
			case OPTION_HEADER:
				enabled = false;
				gotoAndStop("header");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = 100;

				headerDecor._x = labelTextField.getLineMetrics(0).width + 10;
				headerDecor._width = entryWidth - headerDecor._x;
				
				break;
				
			case OPTION_TEXT:
				enabled = isEnabled;
				gotoAndStop("text");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				valueTextField.SetText(Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
				
				break;
				
			case OPTION_TOGGLE:
				enabled = isEnabled;
				gotoAndStop("toggle");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				toggleIcon._x = entryWidth - toggleIcon._width;
				toggleIcon.gotoAndStop(a_entryObject.numValue? "on" : "off");
				
				break;
				
			case OPTION_SLIDER:
				enabled = isEnabled;
				gotoAndStop("slider");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				valueTextField.SetText(GlobalFunctions.formatString(Translator.translate(a_entryObject.strValue), a_entryObject.numValue).toUpperCase(), true);
			
				sliderIcon._x = valueTextField.getLineMetrics(0).x - sliderIcon._width;
				
				break;
				
			case OPTION_MENU:
				enabled = isEnabled;
				gotoAndStop("menu");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				valueTextField._width = entryWidth;
				valueTextField.SetText(Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
				
				menuIcon._x = valueTextField.getLineMetrics(0).x - menuIcon._width;
				
				break;

			case OPTION_COLOR:
				enabled = isEnabled;
				gotoAndStop("color");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				colorIcon._x = entryWidth - colorIcon._width;

				var color: Color = new Color(colorIcon.pigment);
				color.setRGB(a_entryObject.numValue);
				
				break;
				
			case OPTION_KEYMAP:
				enabled = isEnabled;
				gotoAndStop("keymap");
				
				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;
				
				var keyCode = a_entryObject.numValue;
				if (keyCode == -1)
					keyCode = 282; // "???"
				buttonArt.gotoAndStop(keyCode);
				buttonArt._x = entryWidth - buttonArt._width;
				
				break;
				
			case OPTION_EMPTY:
			default:
				enabled = false;
				gotoAndStop("empty");
		}
	}
}