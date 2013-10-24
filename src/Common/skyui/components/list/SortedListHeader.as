import gfx.events.EventDispatcher;

import skyui.components.list.ListLayout;

class skyui.components.list.SortedListHeader extends MovieClip
{
  /* PRIVATE VARIABLES */
	
	private var _columns: Array;
	
	
  /* STAGE ELEMENTS */
  
	public var sortIcon: MovieClip;
	public var iconColumnIndicator: MovieClip;
	
  
  /* PROPERTIES */ 
  
	private var _layout: ListLayout;
	
	public function get layout(): ListLayout
	{
		return _layout;
	}
	
	public function set layout(a_layout: ListLayout)
	{
		if (_layout)
			_layout.removeEventListener("layoutChange", this, "onLayoutChange");
		_layout = a_layout;
		_layout.addEventListener("layoutChange", this, "onLayoutChange");
	}
	

  /* INITIALIZATION */

	public function SortedListHeader()
	{
		super();
		
		_columns = new Array();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function columnPress(a_columnIndex: Number): Void
	{
		_layout.selectColumn(a_columnIndex);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	// Hides all columns (but doesn't delete them since they can be re-used later).
	private function clearColumns(): Void
	{
		for (var i=0; i< _columns.length; i++)
			_columns[i]._visible = false;
	}
  
	private function addColumn(a_index: Number): MovieClip
	{
		if (a_index < 0)
			return undefined;
		
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
			if (!this.columnIndex != undefined)
				this._parent.columnPress(this.columnIndex);
		};

		columnButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (!this.columnIndex != undefined)
				this._parent.columnPress(this.columnIndex);
		};

		_columns[a_index] = columnButton;
		return columnButton;
	}
	
	private function onLayoutChange(event): Void
	{
		clearColumns();
		
		var activeIndex = _layout.activeColumnIndex;
			
		for (var i = 0; i < _layout.columnCount; i++) {
			var columnLayoutData = _layout.columnLayoutData[i];
			var btn = addColumn(i);

			btn.label._x = 0;

			btn._x = columnLayoutData.labelX;
			
			btn.label._width = columnLayoutData.labelWidth;
			btn.label.setTextFormat(columnLayoutData.labelTextFormat);
			
			btn.label.SetText(columnLayoutData.labelValue);
			
			if (activeIndex == i)
				sortIcon.gotoAndStop(columnLayoutData.labelArrowDown ? "desc" : "asc");
		}
		
		positionButtons();
	}
	
	// Places the buttonAreas around textfields and the sort indicator.
	private function positionButtons(): Void
	{
		var activeIndex = _layout.activeColumnIndex;
		for (var i=0; i<_columns.length; i++) {
			var e = _columns[i];
			e.label._y = -e.label._height;
			
			e.buttonArea._x = e.label.getLineMetrics(0).x - 4;
			e.buttonArea._width = e.label.getLineMetrics(0).width + 8;
			e.buttonArea._y = e.label._y - 2;
			e.buttonArea._height = e.label._height + 2;
			
			if (_layout.columnLayoutData[i].type == ListLayout.COL_TYPE_ITEM_ICON) {
				iconColumnIndicator._x = e._x + e.buttonArea._x + e.buttonArea._width;
				iconColumnIndicator._y = -e._height + ((e._height - iconColumnIndicator._height) / 2);
			}
			
			if (activeIndex == i) {
				sortIcon._x = e._x + e.buttonArea._x + e.buttonArea._width;
				sortIcon._y = -e._height + ((e._height - sortIcon._height) / 2) - 1;
				
				iconColumnIndicator._visible = _layout.columnLayoutData[i].type != ListLayout.COL_TYPE_ITEM_ICON;
			}
		}
	}
}