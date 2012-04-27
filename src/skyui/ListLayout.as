/*
 *  Encapsulates the list layout configuration.
 */
class skyui.ListLayout
{
  /* CONSTANTS */
	public static var COL_TYPE_ITEM_ICON = 0;
	public static var COL_TYPE_EQUIP_ICON = 1;
	public static var COL_TYPE_TEXT = 2;
	public static var COL_TYPE_NAME = 3;
	
	public static var LAYOUT_ITEM = 0;
	public static var LAYOUT_MAGIC = 1;
	
	
  /* PRIVATE VARIABLES */
	
	private var _layoutData: Object;
	
	private var _views: Array;
	
	
  /* PROPERTIES */
	
	public function get views(): Array
	{
		return _views;
	}
	
	public function get type(): Number
	{
		return _layoutData.type;
	}
	
	
  /* CONSTRUCTORS */
	
	public function ListLayout(a_data: Object)
	{
		_layoutData = a_data;
		
		// For quick access
		_views = _layoutData.views;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function getMatchingView(a_flag: Number): Number
	{
		// Find a matching view, or use last index
		for (var i = 0; i < _views.length; i++) {

			// Wrap in array for single category
			var categories = ((_views[i].category) instanceof Array) ? _views[i].category : [_views[i].category];
			
			// Either found a matching category, or the last inded has to be used.
			if (categories.indexOf(a_flag) != undefined || i == _views.length-1)
				return i;
		}
		
		return undefined;
	}
}