import gfx.events.EventDispatcher;

import skyui.components.list.ColumnLayoutData;
import skyui.components.list.ColumnDescriptor;
import skyui.util.GlobalFunctions;


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
  
	private var _activeViewIndex: Number = -1;
		
	private var _layoutData: Object;
	private var _viewData: Object;
	private var _columnData: Object;
	private var _defaultsData: Object;

	private var _lastViewIndex: Number = -1;
	
	// viewIndex, columnIndex, stateIndex
	private var _prefData: Object;
	
	private var _stateData: Object;
	
	private var _defaultEntryTextFormat: TextFormat;
	private var _defaultLabelTextFormat: TextFormat;
	
	// List of views in this layout (updated only when the config changes)
	private var _viewList: Array;
	
	// List of columns for the current view (updated when the view changes
	private var _columnList: Array;
	
	private var _lastFilterFlag: Number = -1;
	
	
  /* PROPERTIES */
	
	public function get currentView(): Object
	{
		return _viewList[_activeViewIndex];
	}
	
	private var _activeColumnIndex: Number = -1;
	
	public function get activeColumnIndex(): Number
	{
		return _activeColumnIndex;
	}
	
	public function get columnCount(): Number
	{
		return _columnLayoutData.length;
	}
	
	private var _activeColumnState: Number = 1;

	public function get activeColumnState(): Number
	{
		return _activeColumnState;
	}
	
	private var _columnLayoutData: Array;
	
	public function get columnLayoutData(): Array
	{
		return _columnLayoutData;
	}
	
	private var _hiddenStageNames: Array;
	
	public function get hiddenStageNames(): Array
	{
		return _hiddenStageNames;
	}
	
	private var _entryWidth: Number;
	
	public function get entryWidth(): Number
	{
		return _entryWidth;
	}
	
	public function set entryWidth(a_width: Number): Void
	{
		_entryWidth = a_width;
	}

	private var _entryHeight: Number;

	public function get entryHeight(): Number
	{
		return _entryHeight;
	}
	
	private var _layoutUpdateCount: Number = 1;
	
	public function get layoutUpdateCount(): Number
	{
		return _layoutUpdateCount;
	}
	
	private var _columnDescriptors: Array;
	
	public function get columnDescriptors(): Array
	{
		return _columnDescriptors;
	}
	
	private var _sortOptions: Array;
	
	public function get sortOptions(): Array
	{
		return _sortOptions;
	}
	
	private var _sortAttributes: Array;
	
	public function get sortAttributes(): Array
	{
		return _sortAttributes;
	}
	
	
  /* INITIALIZATION */
	
	public function ListLayout(a_layoutData: Object, a_viewData: Object, a_columnData: Object, a_defaultsData: Object)
	{
		GlobalFunctions.addArrayFunctions();
		
		EventDispatcher.initialize(this);
		
		_prefData = {column: null, stateIndex: 1};
		_viewList = [];
		_columnList = [];
		_columnLayoutData = [];
		_hiddenStageNames = [];
		_columnDescriptors = [];
		
		_layoutData = a_layoutData;
		_viewData = a_viewData;
		_columnData = a_columnData;
		_defaultsData = a_defaultsData;

		if (_entryWidth == undefined)
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
	
	
  /* PUBLIC FUNCTIONS */
  
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function refresh(): Void
	{
		updateViewList();
		_lastViewIndex = -1;
		changeFilterFlag(_lastFilterFlag);
	}
	
	public function changeFilterFlag(a_flag: Number): Void
	{
		_lastFilterFlag = a_flag;
		
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
		
		// Do this before restoring the pref state!
		updateColumnList();
		
		// Restoring a previous state was not necessary or failed? Then use default
		if (! restorePrefState()) {
			_activeColumnIndex = currentView.columns.indexOf(currentView.primaryColumn);
			if (_activeColumnIndex == undefined)
				_activeColumnIndex = 0;
				
			_activeColumnState = 1;
		}

		updateLayout();
	}
	
	public function selectColumn(a_index: Number): Void
	{
		var listIndex = toColumnListIndex(a_index);
		var col = _columnList[listIndex];
		
		// Invalid column
		if (col == null || col.passive)
			return;
			
		if (_activeColumnIndex != a_index) {
			_activeColumnIndex = a_index;
			_activeColumnState = 1;
		} else {
			if (_activeColumnState < col.states)
				_activeColumnState++;
			else
				_activeColumnState = 1;
		}
		
		// Save as preferred state
		_prefData.column = col;
		_prefData.stateIndex = _activeColumnState;
			
		updateLayout();
	}
	
	public function restoreColumnState(a_activeIndex: Number, a_activeState: Number): Void
	{
		var listIndex = toColumnListIndex(a_activeIndex);
		var col = _columnList[listIndex];
		
		// Invalid column
		if (col == null || col.passive)
			return;

		if (a_activeState < 1 || a_activeState > col.states)
			return;
		
		_activeColumnIndex = a_activeIndex;
		_activeColumnState = a_activeState;
		
		// Save as preferred state
		_prefData.column = col;
		_prefData.stateIndex = _activeColumnState;
	
		updateLayout();
	}
	

  /* PRIVATE FUNCTIONS */
	
	private function updateLayout(): Void
	{
		_layoutUpdateCount++;

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
			_columnLayoutData[c] = columnLayoutData;
				
			// Non-active columns always use state 1
			var stateData: Object;
			if (c == _activeColumnIndex) {
				stateData = col["state" + _activeColumnState];
				updateSortParams(stateData);
			} else {
				stateData = col["state1"];
			}
				
			columnLayoutData.type = col.type;
			columnLayoutData.labelArrowDown = stateData.label.arrowDown ? true : false;
			columnLayoutData.labelValue = stateData.label.text;
			columnLayoutData.entryValue = stateData.entry.text;
			columnLayoutData.colorAttribute = stateData.colorAttribute;
			
			c++;
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
					
					if (col.entry.textFormat != undefined) {
						var customTextFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultEntryTextFormat)
							customTextFormat[prop] = _defaultEntryTextFormat[prop];
						
						// Then override if necessary
						for (var prop in col.entry.textFormat)
							if (customTextFormat.hasOwnProperty(prop))
								customTextFormat[prop] = col.entry.textFormat[prop];
						
						columnLayoutData.textFormat = customTextFormat;
					} else {
						columnLayoutData.textFormat = _defaultEntryTextFormat;
					}
					
					if (col.label.textFormat != undefined) {
						var customTextFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultLabelTextFormat)
							customTextFormat[prop] = _defaultLabelTextFormat[prop];
					
						// Then override if necessary
						for (var prop in col.label.textFormat)
							if (customTextFormat.hasOwnProperty(prop))
								customTextFormat[prop] = col.label.textFormat[prop];
								
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
		
		// sortChange might not always trigger an update, so we have to make sure the list is updated,
		// even if that means we update it twice.
		dispatchEvent({type: "layoutChange"});
	}
	
	private function updateSortParams(stateData: Object): Void
	{
		var sortAttributes = stateData.sortAttributes;
		var sortOptions = stateData.sortOptions;
		
		if (!sortOptions) {
			_sortOptions = null;
			_sortAttributes = null;
			return;
		}
		
		// No attribute(s) set? Try to use entry value
		if (!sortAttributes)
			if (stateData.entry.text.charAt(0) == "@")
				sortAttributes = [ stateData.entry.text.slice(1) ];
		
		if (!sortAttributes) {
			_sortOptions = null;
			_sortAttributes = null;
			return;
		}
		
		// Wrap single attribute in array
		if (!(sortAttributes instanceof Array))
			sortAttributes = [sortAttributes];
			
		if (!(sortOptions instanceof Array))
			sortOptions = [sortOptions];
			
		_sortOptions = sortOptions;
		_sortAttributes = sortAttributes;
	}
	
	private function restorePrefState(): Boolean
	{
		// No preference to restore yet
		if (!_prefData.column)
			return false;

		var listIndex = _columnList.indexOf(_prefData.column);
		var layoutDataIndex = toColumnLayoutDataIndex(listIndex);

		if (listIndex > -1 && layoutDataIndex > -1) {
			_activeColumnIndex = layoutDataIndex;
			_activeColumnState = _prefData.stateIndex;
			return true;
		}
		
		// Found no match, reset prefData and return false
		_prefData.column = null;
		_prefData.stateIndex = 1;
		return false;
	}
	
	// columnLayoutData index (no hidden columns) -> columnList index (all columns for this view)
	private function toColumnListIndex(a_index): Number
	{
		for (var i = 0, c = 0; i < _columnList.length; i++) {
			if (_columnList[i].hidden == true)
				continue;
			if (c == a_index)
				return i;
			c++;
		}
		
		return -1;
	}
	
	// columnList index (all columns for this view) -> columnLayoutData index (no hidden columns)
	private function toColumnLayoutDataIndex(a_index): Number
	{
		for (var i = 0, c = 0; i < _columnList.length; i++) {
			if (_columnList[i].hidden == true)
				continue;
			if (i == a_index)
				return c;
			c++;
		}
		
		return -1;
	}
	
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
		_columnDescriptors.splice(0);
		
		var columnNames = currentView.columns;
		
		for (var i=0; i<columnNames.length; i++) {
			var col = _columnData[columnNames[i]];
			var cd : ColumnDescriptor = new ColumnDescriptor();
			cd.hidden = col.hidden;
			cd.identifier = columnNames[i];
			cd.longName = col.name;
			cd.type = col.type;
			
			_columnList.push(col);
			_columnDescriptors.push(cd);
		}
	}
}