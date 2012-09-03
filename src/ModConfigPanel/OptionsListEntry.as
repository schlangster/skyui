import skyui.components.list.ScrollingList;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;


class OptionsListEntry extends BasicListEntry
{
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
}