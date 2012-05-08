import gfx.events.EventDispatcher;

import skyui.components.list.ColumnLayoutData;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;


/*
 *  Encapsulates the list layout configuration.
 */
class skyui.components.list.ListLayout
{
  /* CONSTANTS */
  
	private static var MAX_TEXTFIELD_INDEX = 10;
	
	private static var LEFT = 0;
	private static var RIGHT = 1;
	private static var TOP = 2;
	private static var BOTTOM = 3;
  
	public static var COL_TYPE_ITEM_ICON = 0;
	public static var COL_TYPE_EQUIP_ICON = 1;
	public static var COL_TYPE_TEXT = 2;
	public static var COL_TYPE_NAME = 3;
	
	
  /* PRIVATE VARIABLES */
		
	private var _layoutData: Object;
	private var _viewData: Object;
	private var _columnData: Object;
	private var _defaultsData: Object;

	private var _lastViewIndex: Number = -1;
	
	// viewIndex, columnIndex, stateIndex
	private var _prefData: Object = {viewIndex: -1, columnIndex: 0, stateIndex: 1};
	
	// 1 .. n
	private var _activeColumnState: Number = 0;
	
	private var _defaultEntryTextFormat: TextFormat;
	private var _defaultLabelTextFormat: TextFormat;
	
	// List of views in this layout (updated only when the config changes)
	private var _viewList: Array = [];
	
	// List of columns for the current view (updated when the view changes
	private var _columnList: Array = [];
	
	
  /* PROPERTIES */
	
	private var _activeViewIndex: Number = -1;
	
	public function get activeViewIndex(): Number
	{
		return _activeViewIndex;
	}
	
	public function get currentView(): Object
	{
		return _viewList[_activeViewIndex];
	}
	
	private var _activeColumnIndex: Number = 0;
	
	public function get activeColumnIndex(): Number
	{
		return _activeColumnIndex;
	}
	
	public function get columnCount(): Number
	{
		return _columnLayoutData.length;
	}
	
	private var _columnLayoutData: Array = [];
	
	public function get columnLayoutData(): Array
	{
		return _columnLayoutData;
	}
	
	private var _hiddenStageNames: Array = [];
	
	public function get hiddenStageNames(): Array
	{
		return _hiddenStageNames;
	}
	
	private var _entryWidth: Number;
	
	public function get entryWidth(): Number
	{
		return _entryWidth;
	}

	private var _entryHeight: Number;

	public function get entryHeight(): Number
	{
		return _entryHeight;
	}
	
	
  /* CONSTRUCTORS */
  
	private function updateViewList(): Void
	{
		_viewList.splice(0);
		var viewNames = _layoutData.views;
		for (var i=0; i<viewNames.length; i++)
			_viewList.push(_viewData[viewNames[i]]);
	}
	
	private function updateColumnList(): Void
	{
		_columnList.splice(0);
		var columnNames = _viewList[_activeViewIndex].columns;
		for (var i=0; i<columnNames.length; i++)
			_columnList.push(_columnData[columnNames[i]]);
	}
	
	public function ListLayout(a_layoutData: Object, a_viewData: Object, a_columnData: Object, a_defaultsData)
	{
		GlobalFunctions.addArrayFunctions();
		
		EventDispatcher.initialize(this);
		
		_layoutData = a_layoutData;
		_viewData = a_viewData;
		_columnData = a_columnData;
		_defaultsData = a_defaultsData;

		_entryWidth = _defaultsData.entryWidth;
		
		updateViewList();
		updateColumnList();
		
		// Initial textformats
		_defaultEntryTextFormat = new TextFormat(); 
		_defaultLabelTextFormat = new TextFormat();
		
		// Copy default textformat values from config
		for (var prop in _defaultsData.entry.textFormat)
			if (_defaultEntryTextFormat.hasOwnProperty(prop))
				_defaultEntryTextFormat[prop] = _defaultsData.entry.textFormat[prop];
		
		for (var prop in _defaultsData.label.textFormat)
			if (_defaultLabelTextFormat.hasOwnProperty(prop))
				_defaultLabelTextFormat[prop] = _defaultsData.label.textFormat[prop];
				
	}
	
	public function changeFilterFlag(a_flag: Number): Void
	{
		// Find a matching view, or use last index
		for (var i = 0; i < _viewList.length; i++) {
			
			// Wrap in array for single category
			var categories = ((_viewList[i].category) instanceof Array) ? _viewList[i].category : [_viewList[i].category];
			
			if (categories.indexOf(a_flag) != undefined || i == _viewList.length-1) {
				_activeViewIndex = i;
				break;
			}
		}
		
		if (_activeViewIndex == -1 || _lastViewIndex == _activeViewIndex)
			return;
		
		_lastViewIndex = _activeViewIndex;
		
		// Restoring a previous state was not necessary or failed? Then use default
		if (! restorePrefState()) {
			_activeColumnIndex = _viewList[_activeViewIndex].columns.indexOf(_viewList[_activeViewIndex].primaryColumn);
			if (_activeColumnIndex == undefined)
				_activeColumnIndex = 0;
				
			_activeColumnState = 1;
		}

		updateLayout();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	

	
	
	private function updateLayout(): Void
	{
		updateColumnList();

		var maxHeight = 0;
		var textFieldIndex = 0;

		_hiddenStageNames.splice(0);
		_columnLayoutData.splice(0);
		
		// Set bit at position i if column is weighted
		var weightedFlags = 0;
		
		// Move some data from current state to root of the column so we can access single- and multi-state columns in the same manner.
		// So this is a merge of defaults, column root and current state.
		for (var i = 0, c = 0; i < _columnList.length; i++) {			
			var col = _columnList[i];
			// Skip
			if (col.hidden == true)
				continue;
				
			var columnLayoutData = new ColumnLayoutData();
			_columnLayoutData[c++] = columnLayoutData;
			
			// Single-state
			if (col.states == undefined || col.states < 2)
				continue;
				
			// Non-active columns always use state 1
			var stateData;
			if (i == _activeColumnIndex)
				stateData = col["state" + _activeColumnState];
			else
				stateData = col["state1"];

			// Might have to create parents nodes first
			if (col.label == undefined)
				col.label = {};
				
			if (col.entry == undefined)
				col.entry = {};

			col.label.text = stateData.label.text;
			col.label.arrowDown = stateData.label.arrowDown;
			col.entry.text = stateData.entry.text;
			col.sortAttributes = stateData.sortAttributes;
			col.sortOptions = stateData.sortOptions;
		}
		
		// Subtract arrow tip width
		var weightedWidth = _entryWidth - 12;
		
		var weightSum = 0;

		var bEnableItemIcon = false;
		var bEnableEquipIcon = false;

		for (var i = 0, c = 0; i < _columnList.length; i++) {
			var col = _columnList[i];
			// Skip
			if (col.hidden == true)
				continue;
				
			var columnLayoutData = _columnLayoutData[c++];

			// Calc total weighted width and set weighted flags
			if (col.weight != undefined) {
				weightSum += col.weight;
				weightedFlags = (weightedFlags | 1) << 1;
			} else {
				weightedFlags = (weightedFlags | 0) << 1;
			}
			
			if (col.indent != undefined)
				weightedWidth -= col.indent;
			
			// Height including borders for maxHeight
			var curHeight = 0;
			
			columnLayoutData.type = col.type;
			columnLayoutData.labelValue = col.label.text
			
			switch (col.type) {
				// ITEM ICON + EQUIP ICON
				case ListLayout.COL_TYPE_ITEM_ICON:
				case ListLayout.COL_TYPE_EQUIP_ICON:
								
					if (col.type == ListLayout.COL_TYPE_ITEM_ICON) {
						columnLayoutData.stageName = "itemIcon";
						bEnableItemIcon = true;
					} else {
						columnLayoutData.stageName = "equipIcon";
						bEnableEquipIcon = true;
					}
					
					columnLayoutData.width = _columnLayoutData[i].height = col.icon.size;
					weightedWidth -= col.icon.size;
						
					curHeight += col.icon.size;
					
					break;

				// REST
				default:
					columnLayoutData.stageName = "textField" + textFieldIndex++;
					
					if (col.width != undefined) {
						// Width >= 1 for absolute width, < 1 for percentage width
						columnLayoutData.width = col.width < 1 ? (col.width * _entryWidth) : col.width;
						weightedWidth -= columnLayoutData.width;
					} else {
						columnLayoutData.width = 0;
					}
					
					if (col.height != undefined)
						// Height >= 1 for absolute height, < 1 for percentage height
						columnLayoutData.height = col.height < 1 ? (col.height * _entryWidth) : col.height;
					else
						columnLayoutData.height = 0;
					
					columnLayoutData.entryValue = col.entry.text;
					
					if (col.entry.format != undefined) {
						var customTextFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultEntryTextFormat)
							customTextFormat[prop] = _defaultEntryTextFormat[prop];
						
						// Then override if necessary
						for (var prop in col.entry.format)
							if (customTextFormat.hasOwnProperty(prop))
								customTextFormat[prop] = col.entry.format[prop];
						
						columnLayoutData.textFormat = customTextFormat;
					} else {
						columnLayoutData.textFormat = _defaultEntryTextFormat;
					}
					
					if (col.entry.format != undefined) {
						var customTextFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultLabelTextFormat)
							customTextFormat[prop] = _defaultLabelTextFormat[prop];
					
						// Then override if necessary
						for (var prop in _columnList[i].label.format)
							if (customTextFormat.hasOwnProperty(prop))
								customTextFormat[prop] = col.label.format[prop];
								
						columnLayoutData.labelTextFormat = customTextFormat;
					} else {
						columnLayoutData.labelTextFormat = _defaultLabelTextFormat;
					}
			}
			
			if (col.border != undefined) {
				weightedWidth -= col.border[LEFT] + col.border[RIGHT];
				curHeight += col.border[TOP] + col.border[BOTTOM];
				columnLayoutData.y = col.border[TOP];
			} else {
				columnLayoutData.y = 0;
			}
			
			if (curHeight > maxHeight)
				maxHeight = curHeight;
		}
		
		// Calculate the widths
		if (weightSum > 0 && weightedWidth > 0 && weightedFlags != 0) {
			for (var i = _columnList.length-1, c = _columnLayoutData.length-1; i >= 0; i--) {
				var col = _columnList[i];
				// Skip
				if (col.hidden == true)
					continue;
					
				var columnLayoutData = _columnLayoutData[c--];
				
				if ((weightedFlags >>>= 1) & 1) {
					if (col.border != undefined)
						columnLayoutData.width += ((col.weight / weightSum) * weightedWidth) - col.border[LEFT] - col.border[RIGHT];
					else
						columnLayoutData.width += (col.weight / weightSum) * weightedWidth;
				}
			}
		}
		
		// Set x positions based on calculated widths, and set label data
		var xPos = 0;
		
		for (var i=0, c=0; i<_columnList.length; i++) {
			var col = _columnList[i];
			// Skip
			if (col.hidden == true)
				continue;
				
			var columnLayoutData = _columnLayoutData[c++];
			
			if (col.indent != undefined)
				xPos += col.indent;

			columnLayoutData.labelX = xPos;

			if (col.border != undefined) {
				columnLayoutData.labelWidth = columnLayoutData.width + col.border[LEFT] + col.border[RIGHT];
				columnLayoutData.x = xPos;
				xPos += col.border[LEFT];
				columnLayoutData.x = xPos;
				xPos += col.border[RIGHT] + columnLayoutData.width;
			} else {
				columnLayoutData.labelWidth = columnLayoutData.width;
				columnLayoutData.x = xPos;
				xPos += columnLayoutData.width;
			}
		}
		
		while (textFieldIndex < MAX_TEXTFIELD_INDEX)
			_hiddenStageNames.push("textField" + textFieldIndex++);
		
		if (!bEnableItemIcon)
			_hiddenStageNames.push("itemIcon");
		
		if (!bEnableEquipIcon)
			_hiddenStageNames.push("equipIcon");
		
		_entryHeight = maxHeight;
		
		updateSortParams();
		
		for (var i=0; i<_columnLayoutData.length; i++) {
			var columnLayoutData = _columnLayoutData[i];
			columnLayoutData.dump();
		}
		
		// sortChange might not always trigger an update, so we have to make sure the list is updated,
		// even if that means we update it twice.
		dispatchEvent({type: "layoutChange"});
	}
	
	function updateSortParams()
	{
		var columns = currentView.columns;
		var sortAttributes = columns[_activeColumnIndex].sortAttributes;
		var sortOptions = columns[_activeColumnIndex].sortOptions;
		
		if (sortOptions == undefined)
			return;
		
		// No attribute(s) set? Try to use entry value
		if (sortAttributes == undefined)
			if (_columnLayoutData[_activeColumnIndex].entryValue.charAt(0) == "@")
				sortAttributes = [ _columnLayoutData[_activeColumnIndex].entryValue.slice(1) ];
		
		if (sortAttributes == undefined)
			return;
		
		// Wrap single attribute in array
		if (! sortAttributes instanceof Array)
			sortAttributes = [sortAttributes];
			
		if (! sortOptions instanceof Array)
			sortOptions = [sortOptions];
			
		dispatchEvent({type:"sortChange", attributes: sortAttributes, options: sortOptions});
	}
	
	private function restorePrefState(): Boolean
	{
		// No preference to restore yet
		if (_prefData == undefined || _prefData.viewIndex == -1)
			return false;

		// First check if current view contains preferred column
		var prefColumnName = _viewList[_prefData.viewIndex].columns[_prefData.columnIndex];
		
		var index = _viewList[_activeViewIndex].columns.indexOf(prefColumnName);
		if (prefColumnName != undefined && index != undefined) {
			_activeColumnIndex = index;
			_activeColumnState = _prefData.stateIndex;
			return true;
		}
		
		// Next, try to search all columns for a similar state by comparing text, sort options and sort attributes
		var prefState = _layoutData[_viewList[_prefData.viewIndex].columns[_prefData.columnIndex]]["state" + _prefData.stateIndex];
		
		for (var i=0; i<_viewList[_activeViewIndex].columns.length; i++) {
			var col = _layoutData[_viewList[_activeViewIndex].columns[i]];
			if (col.states == undefined)
				continue;
				
			for (var j=1; j <=  col.states; j++) {
				var st = col["state" + j];
				if (st.entry.text != prefState.entry.text)
					continue;
				
				if (st.sortAttributes.equals(prefState.sortAttributes) && st.sortOptions.equals(prefState.sortOptions) && st.label.arrowDown == prefState.label.arrowDown) {
					_activeColumnIndex = i;
					_activeColumnState = j;
					return true;
				}
			}
		}

		// Found no match, reset prefData and return false
		_prefData = {viewIndex: -1, columnIndex: 0, stateIndex: 1};
		return false;
	}
	
	public function selectColumn(a_index: Number)
	{
		// Invalid column
		if (currentView.columns[a_index] == undefined)
			return;
		
		// Don't process for passive columns
		if (currentView.columns[a_index].passive)
			return;
			
		if (_activeColumnIndex != a_index) {
			_activeColumnIndex = a_index;
			_activeColumnState = 1;
		} else {
			if (_activeColumnState < currentView.columns[_activeColumnIndex].states)
				_activeColumnState++;
			else
				_activeColumnState = 1;
		}
		
		// Save as preferred state
		_prefData = {viewIndex: _activeViewIndex, columnIndex: _activeColumnIndex, stateIndex: _activeColumnState};
			
		updateLayout();
	}
}