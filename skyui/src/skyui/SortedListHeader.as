import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.SortedListHeader extends MovieClip
{
	private var _columns:Array;
	private var _activeColumnIndex:Number;
	private var _bArrowDown:Boolean;
	
	// Children
	var sortIcon:MovieClip;
	
	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function SortedListHeader()
	{
		super();
		EventDispatcher.initialize(this);
		
		_columns = new Array();
		_activeColumnIndex = 0;
		_bArrowDown = false;
	}
	
	function columnPress(a_columnIndex:Number)
	{
		dispatchEvent({type:"columnPress", index: a_columnIndex});
	}
	
	/* Hides all columns (but doesn't delete them since they can be re-used later */
	function clearColumns()
	{
		for (var i=0; i< _columns.length; i++) {
			_columns[i]._visible = false;
		}
	}
	
	function get activeColumnIndex():Number
	{
		return _activeColumnIndex;
	}
	
	function set activeColumnIndex(a_index:Number)
	{
		_activeColumnIndex = a_index;
	}
	
	function get isArrowDown():Boolean
	{
		return _bArrowDown;
	}
	
	function set isArrowDown(a_bArrowDown:Boolean)
	{
		_bArrowDown = a_bArrowDown;
	}
	
	function addColumn(a_index:Number)
	{
		if (a_index < 0) {
			return undefined;
		}
		
		var columnButton = this["Column" + a_index];

		if (columnButton != undefined) {
			_columns[a_index] = columnButton;
			_columns[a_index]._visible = true;
			return columnButton;
		}
		
		// Create on-demand
		columnButton = attachMovie("HeaderColumn", "Column" + a_index, getNextHighestDepth());

		columnButton.columnIndex = a_index;

		columnButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (!this.columnIndex != undefined) {
				_parent.columnPress(this.columnIndex);
			}
		};

		columnButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (!this.columnIndex != undefined) {
				_parent.columnPress(this.columnIndex);
			}
		};

		_columns[a_index] = columnButton;
		return columnButton;
	}
	
	/* Places the buttonAreas around textfields and the sort indicator */
	function positionButtons()
	{
		for (var i=0; i<_columns.length; i++) {
			var e = _columns[i];
			e.label._y = -e.label._height;
			
			e.buttonArea._x = e.label.getLineMetrics(0).x - 4;
			e.buttonArea._width = e.label.getLineMetrics(0).width + 8;
			e.buttonArea._y = e.label._y - 2;
			e.buttonArea._height = e.label._height + 2;
			
			if (_activeColumnIndex == i) {
				sortIcon._x = e._x + e.buttonArea._x + e.buttonArea._width + 2;
				sortIcon._y = -e._height + ((e._height - sortIcon._height) / 2);
				sortIcon.gotoAndStop(_bArrowDown? "desc" : "asc");
			}
		}
	}
}