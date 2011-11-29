import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.SortedListHeader extends MovieClip
{
	private var _bAscending:Boolean;
	private var _sortBy:Number;	
	private var _statType:Number;
	
	// Children
	var buttons:MovieClip;
	var sortIcon:MovieClip;
	
	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function SortedListHeader()
	{
		EventDispatcher.initialize(this);
		
		_bAscending = true;
		_sortBy = ItemSortingFilter.SORT_BY_NAME;
	}
	
	function set statType(a_type:Number)
	{		
		_statType = a_type;
		updateHeader();
	}
	
	function get statType():Number
	{
		return _statType;
	}
		
	function onLoad()
	{		
		buttons.textButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			_parent._parent.toggleSort(ItemSortingFilter.SORT_BY_NAME);
		};
		
		buttons.valueButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			_parent._parent.toggleSort(ItemSortingFilter.SORT_BY_VALUE);
		};
		
		buttons.weightButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			_parent._parent.toggleSort(ItemSortingFilter.SORT_BY_WEIGHT);
		};
		
		buttons.statButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			_parent._parent.toggleSort(ItemSortingFilter.SORT_BY_STAT);
		};
		
		buttons.textLabel.autoSize = "left";
		buttons.statLabel.autoSize = "left";
		buttons.valueLabel.autoSize = "left";
		buttons.weightLabel.autoSize = "left";
		buttons.statLabel.SetText(" ", true);
		
		updateHeader();
	}
	
	function updateHeader()
	{
		switch (_statType) {
			case Defines.FLAG_DAMAGE:
				buttons.statLabel.SetText("$DAMAGE");
				break;
			case Defines.FLAG_ARMOR:
				buttons.statLabel.SetText("$ARMOR");
				break;
			default:
				buttons.statLabel.SetText(" ");
		}
		
		var pos = 5;
		
		switch (_sortBy) {
			case ItemSortingFilter.SORT_BY_STAT:
				pos = pos + buttons.statLabel._x + buttons.statLabel._width;
				break;
			case ItemSortingFilter.SORT_BY_VALUE:
				pos = pos + buttons.valueLabel._x + buttons.valueLabel._width;			
				break;
			case ItemSortingFilter.SORT_BY_WEIGHT:
				pos = pos + buttons.weightLabel._x + buttons.weightLabel._width;
				break;
			case ItemSortingFilter.SORT_BY_NAME:
			default:
				pos = pos + buttons.textLabel._x + buttons.textLabel._width;
		}
		
		sortIcon._x = pos;
		sortIcon.gotoAndStop(_bAscending? "asc" : "desc");
	}
	
	function toggleSort(a_sortBy:Number)
	{
		if (_sortBy == a_sortBy) {
			_bAscending = !_bAscending
		} else if (a_sortBy == ItemSortingFilter.SORT_BY_NAME) {
			_bAscending = true;
		} else {
			_bAscending = false;
		}
		_sortBy = a_sortBy;
		
		updateHeader();
		dispatchEvent({type:"sortChange", sortBy: _sortBy, ascending: _bAscending});
	}
}