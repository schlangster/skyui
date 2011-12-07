import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.SortedListHeader extends MovieClip
{
	private var _bAscending:Boolean;
	private var _columns:Array;
	private var _activeColumnIndex:Number;
	private var _bArrowDown:Boolean;
	private var _bArrowLeft:Boolean;
	
	// Children
	var sortIcon:MovieClip;
	
	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function SortedListHeader()
	{
		EventDispatcher.initialize(this);
		
		_bAscending = true;
		_columns = new Array();
	}
	
	function updateHeader()
	{
		var pos = 5;
		sortIcon._x = pos;
		sortIcon.gotoAndStop(_bAscending? "asc" : "desc");
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
	
	function set activeColumnIndex(a_index:Number)
	{
		_activeColumnIndex = a_index;
	}
	
	function set isArrowDown(a_bArrowDown:Boolean)
	{
		_bArrowDown = a_bArrowDown;
	}
	
	function set isArrowLeft(a_bArrowLeft:Boolean)
	{
		_bArrowLeft = a_bArrowLeft;
	}
	
	function addColumn(a_index:Number)
	{
		if (a_index < 0) {
			return undefined;
		}
		
		var columnButton = this["Column" + a_index];

		if (columnButton != undefined) {
			_columns[a_index] = columnButton;
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
			
			e.label.autoSize = e.label.getTextFormat(0).align;
			
			e.label._y = -e.label._height;
			
			e.buttonArea._x = e.label._x - 4;
			e.buttonArea._width = e.label._width + 8;
			e.buttonArea._y = e.label._y - 2;
			e.buttonArea._height = e.label._height + 2;
		}
	}
}