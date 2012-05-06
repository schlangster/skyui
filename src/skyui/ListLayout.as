import skyui.SortedListHeader;
import skyui.Translator;
import skyui.Util;
import gfx.events.EventDispatcher;

/*
 *  Encapsulates the list layout configuration.
 */
class skyui.ListLayout
{
  /* CONSTANTS */
  
	private static var MAX_TEXTFIELD_INDEX = 10;
  
	public static var COL_TYPE_ITEM_ICON = 0;
	public static var COL_TYPE_EQUIP_ICON = 1;
	public static var COL_TYPE_TEXT = 2;
	public static var COL_TYPE_NAME = 3;
	
	
  /* PRIVATE VARIABLES */
		
	private var _layoutData: Object;
	private var _defaultsData: Object;

	private var _lastViewIndex: Number = -1;
	
	// viewIndex, columnIndex, stateIndex
	private var _prefData: Object = {viewIndex: -1, columnIndex: 0, stateIndex: 1};
	
	// 1 .. n
	private var _activeColumnState: Number = 0;
	
	
  /* PROPERTIES */

	private var _views: Array;

	public function get views(): Array
	{
		return _views;
	}
	
	private var _activeViewIndex: Number = -1;
	
	public function get activeViewIndex(): Number
	{
		return _activeViewIndex;
	}
	
	public function get currentView(): Object
	{
		return _views[_activeViewIndex];
	}
	
	private var _activeColumnIndex: Number = 0;
	
	public function get activeColumnIndex(): Number
	{
		return _activeColumnIndex;
	}
	
	public function get columnCount(): Number
	{
		return _views[_activeViewIndex].columns.length;
	}
	
	private var _columnTypes: Array = [];
	
	public function get columnTypes(): Array
	{
		return _columnTypes;
	}
	
	// [c1.x, c1.y, c2.x, c2.y, ...] - (x,y) Offset of column fields in a row (relative to the entry clip)
	private var _columnPositions: Array = [];
	
	public function get columnPositions(): Array
	{
		return _columnPositions;
	}
	
	// [c1.width, c1.height, c2.width, c2.height, ...]
	private var _columnSizes: Array = [];
		
	public function get columnSizes(): Array
	{
		return _columnSizes;
	}
	
	// These are the names like textField0, equipIcon etc used when positioning, not the names as defined in the config
	private var _columnNames: Array = [];
	
	public function get columnNames(): Array
	{
		return _columnNames;
	}
	
	private var _hiddenColumnNames: Array = [];
	
	public function get hiddenColumnNames(): Array
	{
		return _hiddenColumnNames;
	}
	
	// Only used for textfield-based columns
	private var _columnEntryValues: Array = [];
	
	public function get columnEntryValues(): Array
	{
		return _columnEntryValues;
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
	
	private var _customEntryTextFormats: Array = [];
	
	public function get customEntryTextFormats(): Array
	{
		return _customEntryTextFormats;
	}
	
	private var _defaultEntryTextFormat: TextFormat;
	
	public function get defaultEntryTextFormat(): TextFormat
	{
		return _defaultEntryTextFormat;
	}
	
	private var _defaultLabelTextFormat: TextFormat;
	
	public function get defaultLabelTextFormat(): TextFormat
	{
		return _defaultLabelTextFormat;
	}
	
	
  /* CONSTRUCTORS */
	
	public function ListLayout(a_layoutData: Object, a_defaultsData: Object, a_entryWidth: Number)
	{
		Util.addArrayFunctions();
		
		EventDispatcher.initialize(this);
		
		_layoutData = a_layoutData;
		_defaultsData = a_defaultsData;
		_entryWidth = a_entryWidth;
		
		// For quick access
		_views = _layoutData.views;
		
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
	
	function changeFilterFlag(a_flag: Number)
	{
		// Find a matching view, or use last index
		for (var i = 0; i < _views.length; i++) {
			
			// Wrap in array for single category
			var categories = ((views[i].category) instanceof Array) ? views[i].category : [views[i].category];
			
			if (categories.indexOf(a_flag) != undefined || i == _views.length-1) {
				_activeViewIndex = i;
				break;
			}
		}
		
		if (_activeViewIndex == -1 || _lastViewIndex == _activeViewIndex)
			return;
		
		_lastViewIndex = _activeViewIndex;
		
		// Restoring a previous state was not necessary or failed? Then use default
		if (! restorePrefState()) {
			_activeColumnIndex = _views[_activeViewIndex].columns.indexOf(_views[_activeViewIndex].primaryColumn);
			if (_activeColumnIndex == undefined)
				_activeColumnIndex = 0;
				
			_activeColumnState = 1;
		}

		skse.Log("Updating " + _activeViewIndex);

		update();
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
	
	private function update(): Void
	{
		var columns = currentView.columns;

		var maxHeight = 0;
		var textFieldIndex = 0;

		_columnTypes.splice(0);
		_columnPositions.splice(0);
		_columnSizes.splice(0);
		_columnNames.splice(0);
		_hiddenColumnNames.splice(0);
		_columnEntryValues.splice(0);
		_customEntryTextFormats.splice(0);
		
		// Set bit at position i if column is weighted
		var weightedFlags = 0;
		
		// Move some data from current state to root of the column so we can access single- and multi-state columns in the same manner.
		// So this is a merge of defaults, column root and current state.
		for (var i = 0; i < columns.length; i++) {				
			// Single-state
			if (columns[i].states == undefined || columns[i].states < 2)
				continue;
				
			// Non-active columns always use state 1
			var stateData;
			if (i == _activeColumnIndex)
				stateData = columns[i]["state" + _activeColumnState];
			else
				stateData = columns[i]["state1"];

			// Might have to create parents nodes first
			if (columns[i].label == undefined)
				columns[i].label = {};
				
			if (columns[i].entry == undefined)
				columns[i].entry = {};

			columns[i].label.text = stateData.label.text;
			columns[i].label.arrowDown = stateData.label.arrowDown;
			columns[i].entry.text = stateData.entry.text;
			columns[i].sortAttributes = stateData.sortAttributes;
			columns[i].sortOptions = stateData.sortOptions;
		}
		
		// Subtract arrow tip width
		var weightedWidth = _entryWidth - 12;
		skse.Log("weightedWidth: " + weightedWidth);
		
		var weightSum = 0;

		var bEnableItemIcon = false;
		var bEnableEquipIcon = false;

		for (var i = 0; i < columns.length; i++) {
			var col = columns[i];

			// Calc total weighted width and set weighted flags
			if (col.weight != undefined) {
				weightSum += col.weight;
				weightedFlags = (weightedFlags | 1) << 1;
			} else
				weightedFlags = (weightedFlags | 0) << 1;
			
			if (col.indent != undefined)
				weightedWidth -= col.indent;
			
			// Height including borders for maxHeight
			var curHeight = 0;
			
			_columnTypes[i] = col.type;
			
			switch (col.type) {
				// ITEM ICON + EQUIP ICON
				case ListLayout.COL_TYPE_ITEM_ICON:
				case ListLayout.COL_TYPE_EQUIP_ICON:
								
					if (col.type == ListLayout.COL_TYPE_ITEM_ICON) {
						_columnNames[i] = "itemIcon";
						bEnableItemIcon = true;
					} else {
						_columnNames[i] = "equipIcon";
						bEnableEquipIcon = true;
					}
					
					_columnSizes[i*2] = col.icon.size;
					weightedWidth -= col.icon.size;
						
					_columnSizes[i*2+1] = col.icon.size;
					curHeight += col.icon.size;
					
					break;

				// REST
				default:
					_columnNames[i] = "textField" + textFieldIndex++;
					
					if (col.width != undefined) {
						// Width >= 1 for absolute width, < 1 for percentage width
						_columnSizes[i*2] = col.width < 1 ? (col.width * _entryWidth) : col.width;
						weightedWidth -= _columnSizes[i*2];
					} else {
						_columnSizes[i*2] = 0;
					}
					
					if (col.height != undefined)
						// Height >= 1 for absolute height, < 1 for percentage height
						_columnSizes[i*2+1] = col.height < 1 ? (col.height * _entryWidth) : col.height;
					else
						_columnSizes[i*2+1] = 0;
					
					_columnEntryValues[i] = col.entry.text;
					
					if (col.entry.format != undefined) {
						var customTextFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultEntryTextFormat)
							customTextFormat[prop] = _defaultEntryTextFormat[prop];
						
						// Then override if necessary
						for (var prop in col.entry.format)
							if (customTextFormat.hasOwnProperty(prop))
								customTextFormat[prop] = col.entry.format[prop];
						
						_customEntryTextFormats[i] = customTextFormat;
					}
			}
			
			if (col.border != undefined) {
				weightedWidth -= col.border[0] + col.border[1];
				curHeight += col.border[2] + col.border[3];
				_columnPositions[i*2+1] = col.border[2];
			} else {
				_columnPositions[i*2+1] = 0;
			}
			
			if (curHeight > maxHeight)
				maxHeight = curHeight;
		}
		
		// Calculate the widths
		skse.Log("a weightedSum: " + weightSum);
		skse.Log("a weightedWidth: " + weightedWidth);
		
		if (weightSum > 0 && weightedWidth > 0 && weightedFlags != 0) {
			for (var i=columns.length-1; i>=0; i--) {
				var col = columns[i];
				
				if ((weightedFlags >>>= 1) & 1) {
					skse.Log("a old: " + _columnSizes[i*2]);
					skse.Log("a col.weight: " + _columnSizes[i*2]);
					
					if (col.border != undefined)
						_columnSizes[i*2] += ((col.weight / weightSum) * weightedWidth) - col.border[0] - col.border[1];
					else
						_columnSizes[i*2] += (col.weight / weightSum) * weightedWidth;

					skse.Log("a result: " + _columnSizes[i*2]);
				}
			}
		}
		
		// Set x positions based on calculated widths
		var xPos = 0;
		
		for (var i=0; i<columns.length; i++) {
			var col = columns[i];
			
			if (col.indent != undefined)
				xPos += col.indent;

			if (col.border != undefined) {
				xPos += col.border[0];
				_columnPositions[i*2] = xPos;
				xPos += col.border[1] + _columnSizes[i*2];
			} else {
				_columnPositions[i*2] = xPos;
				xPos += _columnSizes[i*2];
			}
		}
		
		while (textFieldIndex < MAX_TEXTFIELD_INDEX)
			_hiddenColumnNames.push("textField" + textFieldIndex++);
		
		if (!bEnableItemIcon)
			_hiddenColumnNames.push("itemIcon");
		
		if (!bEnableEquipIcon)
			_hiddenColumnNames.push("equipIcon");
		
		_entryHeight = maxHeight;
		
		updateSortParams();
		
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
			if (_columnEntryValues[_activeColumnIndex] != undefined)
				if (_columnEntryValues[_activeColumnIndex].charAt(0) == "@")
					sortAttributes = [_columnEntryValues[_activeColumnIndex].slice(1)];
		
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
		var prefColumn = _views[_prefData.viewIndex].columns[_prefData.columnIndex];
		
		var index = _views[_activeViewIndex].columns.indexOf(prefColumn);
		if (prefColumn != undefined && index != undefined) {
			_activeColumnIndex = index;
			_activeColumnState = _prefData.stateIndex;
			return true;
		}
		
		// Next, try to search all columns for a similar state by comparing text, sort options and sort attributes
		var prefState = _views[_prefData.viewIndex].columns[_prefData.columnIndex]["state" + _prefData.stateIndex];
		
		for (var i=0; i<_views[_activeViewIndex].columns.length; i++) {
			var col = _views[_activeViewIndex].columns[i];
			if ( col.states == undefined)
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
			
		update();
	}
	
	private function updateHeader()
	{
		var a_header;
		var columns = currentView.columns;
		
		a_header.clearColumns();
		a_header.activeColumnIndex = _activeColumnIndex;
			
		if (columns[_activeColumnIndex].label.arrowDown == true)
			a_header.isArrowDown = true;
		else
			a_header.isArrowDown = false;
			
		for (var i = 0; i < columns.length; i++) {
			var btn = a_header.addColumn(i);

			btn.label._x = 0;

			if (columns[i].border != undefined) {
				btn._x = _columnPositions[i*2] - columns[i].border[0];
				btn.label._width = _columnSizes[i*2] + columns[i].border[0] + columns[i].border[1];

			} else {
				btn._x = _columnPositions[i*2];
				btn.label._width = _columnSizes[i*2];
			}
			
			if (columns[i].entry.format != undefined) {
				var customTextFormat = new TextFormat();

				// Duplicate default format
				for (var prop in _defaultLabelTextFormat)
					customTextFormat[prop] = _defaultLabelTextFormat[prop];
					
				// Overrides
				for (var prop in columns[i].label.format) {
					if (customTextFormat.hasOwnProperty(prop))
						customTextFormat[prop] = columns[i].label.format[prop];
				}
					
				btn.label.setTextFormat(customTextFormat);
			} else {
				btn.label.setTextFormat(_defaultLabelTextFormat);
			}
			
			btn.label.SetText(Translator.translate(columns[i].label.text));
		}
		
		a_header.positionButtons();
	}
}