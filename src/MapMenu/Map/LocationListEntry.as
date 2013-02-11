import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;

// Entry objects are the actual markers
class Map.LocationListEntry extends BasicListEntry
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
	
	public static var ALPHA_SELECTED = 100;
	public static var ALPHA_ACTIVE = 75;

	public static var ALPHA_ENABLED = 100;
	public static var ALPHA_DISABLED = 50;
	
	
  /* STAGE ELMENTS */

	public var selectIndicator: MovieClip;

	public var icon: MovieClip;
	public var textField: TextField;
	
	
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
	
  	// @override BasicListEntry
	public function initialize(a_index: Number, a_list: ScrollingList): Void
	{
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var entryWidth = background._width;
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		selectIndicator._visible = isSelected;
		
		icon.gotoAndStop(a_entryObject.iconType+1);
		textField.SetText(a_entryObject.label);
	}
}