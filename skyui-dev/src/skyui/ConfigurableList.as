import skyui.Config;
import skyui.Util;

class skyui.ConfigurableList extends skyui.FilteredList
{
	private var _config:Config;

	private var _views:Array;
	private var _activeViewIndex:Number;
	
	private var _activeColumnIndex:Number;
	
	// 1 .. n
	private var _activeColumnState:Number;
	
	private var _bEnableItemIcon:Boolean;
	private var _bEnableEquipIcon:Boolean;
	
	// Preset in config
	private var _entryWidth:Number;
	
	// --- Store lots of pre-calculated values in memory so we don't have to recalculate them for each entry
	
	// [c1.x, c1.y, c2.x, c2.y, ...] - (x,y) Offset of column fields in a row (relative to the entry clip)
	private var _columnPositions:Array;
	
	// [c1.width, c1.height, c2.width, c2.height, ...]
	private var _columnSizes:Array;
	
	// These are the names like textField0, equipIcon etc used when positioning, not the names as defined in the config
	private var _columnNames:Array;
	private var _hiddenColumnNames:Array;
	
	// Only used for textfield-based columns
	private var _columnEntryValues:Array;

	private var _customEntryFormats:Array;
	private var _defaultEntryFormat:TextFormat;
	private var _defaultLabelFormat:TextFormat;
	
	// Children
	var header:MovieClip;


	function ConfigurableList()
	{
		super();

		_columnPositions = new Array();
		_columnSizes = new Array();
		_columnNames = new Array();
		_hiddenColumnNames = new Array();
		_columnEntryValues = new Array();
		_customEntryFormats = new Array();
		
		_defaultEntryFormat = new TextFormat(); 
		_defaultLabelFormat = new TextFormat();
		
		// Reasonable defaults, will be overridden later
		_entryWidth = 525;
		_entryHeight = 28;
		_activeViewIndex = 0;
		_bEnableItemIcon = false;
		_bEnableEquipIcon = false;
		_activeColumnState = 1;
		_activeColumnIndex = 0;

		Config.instance.addEventListener("configLoad", this, "onConfigLoad");
	}
	
	function onLoad()
	{
		super.onLoad();
		
		if (header != 0) {
			header.addEventListener("columnPress", this, "onColumnPress");
		}
	}
	
	function get currentView()
	{
		return _views[_activeViewIndex];
	}

	function onConfigLoad(event)
	{
		_config = event.config;
		_views = _config.ItemList.views;
		_entryWidth = _config.ItemList.entry.width;

		// Create default formats
		for (var prop in _config.ItemList.entry.format) {
			if (_defaultEntryFormat.hasOwnProperty(prop)) {
				_defaultEntryFormat[prop] = _config.ItemList.entry.format[prop];
			}
		}
		for (var prop in _config.ItemList.label.format) {
			if (_defaultLabelFormat.hasOwnProperty(prop)) {
				_defaultLabelFormat[prop] = _config.ItemList.label.format[prop];
			}
		}

		updateView();
	}

	function createEntryClip(a_index:Number):MovieClip
	{
		var entryClip = attachMovie(_entryClassName, "Entry" + a_index, getNextHighestDepth());

		for (var i = 0; entryClip["textField" + i] != undefined; i++) {
			entryClip["textField" + i]._visible = false;
		}
		entryClip["itemIcon"]._visible = false;
		entryClip["equipIcon"]._visible = false;

		return entryClip;
	}
	
	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip.viewIndex != _activeViewIndex) {
			a_entryClip.viewIndex = _activeViewIndex;
			
			var columns = currentView.columns;
			
			a_entryClip.border._width = a_entryClip.selectArea._width = _entryWidth;
			a_entryClip.border._height = a_entryClip.selectArea._height =  _entryHeight;
			
			var iconY = _entryHeight * 0.25;
			var iconSize = _entryHeight * 0.5;
			
			a_entryClip.bestIcon._height = a_entryClip.bestIcon._width = iconSize;
			a_entryClip.favoriteIcon._height = a_entryClip.favoriteIcon._width = iconSize;
			a_entryClip.poisonIcon._height = a_entryClip.poisonIcon._width = iconSize;
			a_entryClip.stolenIcon._height = a_entryClip.stolenIcon._width = iconSize;
			a_entryClip.enchIcon._height = a_entryClip.enchIcon._width = iconSize;
			
			a_entryClip.bestIcon._y = iconY;
			a_entryClip.favIcon._y = iconY;
			a_entryClip.poisonIcon._y = iconY;
			a_entryClip.stolenIcon._y = iconY;
			a_entryClip.enchIcon._y = iconY;
		
			for (var i=0; i<columns.length; i++) {
				var e = a_entryClip[_columnNames[i]];
				e._visible = true;
			
				e._x = _columnPositions[i*2];
				e._y = _columnPositions[i*2+1];
			
				if (_columnSizes[i*2] > 0) {
					e._width = _columnSizes[i*2];
				}
			
				if (_columnSizes[i*2+1] > 0) {
					e._height = _columnSizes[i*2+1];
				}
				
				if (e instanceof TextField) {
					if (_customEntryFormats[i] != undefined) {
						e.setTextFormat(_customEntryFormats[i]);
					} else {
						e.setTextFormat(_defaultEntryFormat);
					}
				}
			}
			
			for (var i=0; i<_hiddenColumnNames.length; i++) {
				var e = a_entryClip[_hiddenColumnNames[i]];
				e._visible = false;
			}
		}
		
		super.setEntry(a_entryClip, a_entryObject);
	}

	function changeFilterFlag(a_flag:Number)
	{
		var newIndex = -1;
		
		// Find a match, or use last index
		for (var i = 0; i < _views.length; i++) {
			if (_views[i].category == a_flag || i == _views.length-1) {
				newIndex = i;
				break;
			}
		}
		
		if (_activeViewIndex == newIndex) {
			return;
		}
		
		_activeViewIndex = newIndex;
		_activeColumnState = 1;
		_activeColumnIndex = _views[_activeViewIndex].columns.indexOf(_views[_activeViewIndex].primaryColumn);
					
		if (_activeColumnIndex == undefined) {
			_activeColumnIndex = 0;
		}
		
		updateView();
	}
	
	function onColumnPress(event)
	{
		if (event.index != undefined) {
			
			// Don't process for passive columns
			if (currentView.columns[event.index].passive) {
				return;
			}
			
			if (_activeColumnIndex != event.index) {
				_activeColumnIndex = event.index;
				_activeColumnState = 1;
			} else {
				if (_activeColumnState < currentView.columns[_activeColumnIndex].states) {
					_activeColumnState++;
				} else {
					_activeColumnState = 1;
				}
			}
			
			updateView();
		}
	}

	/* Calculate new column positions and widths for current view */
	function updateView()
	{
		_bEnableItemIcon = false;
		_bEnableEquipIcon = false;
		
		var columns = currentView.columns;

		var weightedWidth = _entryWidth;
		var weightSum = 0;
		var maxHeight = 0;
		
		var textFieldIndex = 0;

		_columnPositions.splice(0);
		_columnSizes.splice(0);
		_columnNames.splice(0);
		_hiddenColumnNames.splice(0);
		_columnEntryValues.splice(0);
		_customEntryFormats.splice(0);
		
		// Set bit at position i if column is weighted
		var weightedFlags = 0;
		
		// Move some data from current state to root of the column so we can access single- and multi-state columns in the same manner
		for (var i = 0; i < columns.length; i++) {
			
			// Single-state
			if (columns[i].states == undefined || columns[i].states < 2) {
				continue;
			}
			
			// Non-active columns always use state 1
			var stateData;
			if (i == _activeColumnIndex) {
				stateData = columns[i]["state" + _activeColumnState];
			} else {
				stateData = columns[i]["state1"];
			}

			// Might have to create parents nodes first
			if (columns[i].label == undefined) {
				columns[i].label = {};
			}
			if (columns[i].entry == undefined) {
				columns[i].entry = {};
			}

			columns[i].label.text = stateData.label.text;
			columns[i].label.arrowDown = stateData.label.arrowDown;
			columns[i].entry.text = stateData.entry.text;
			columns[i].sortAttributes = stateData.sortAttributes;
			columns[i].sortOptions = stateData.sortOptions;
		}

		// Subtract fixed widths to get weighted width & summ up weights & already set as much as possible
		for (var i = 0; i < columns.length; i++) {
			
			if (columns[i].weight != undefined) {
				weightSum += columns[i].weight;
				weightedFlags = (weightedFlags | 1) << 1;
			} else {
				weightedFlags = (weightedFlags | 0) << 1;
			}
			
			if (columns[i].indent != undefined) {
				weightedWidth -= columns[i].indent;
			}
			
			// Height including borders for maxHeight
			var curHeight = 0;
			
			switch (columns[i].type) {
				// ITEM ICON + EQUIP ICON
				case Config.COL_TYPE_ITEM_ICON:
				case Config.COL_TYPE_EQUIP_ICON:
								
					if (columns[i].type == Config.COL_TYPE_ITEM_ICON) {
						_columnNames[i] = "itemIcon";
						_bEnableItemIcon = true;
					} else if (columns[i].type == Config.COL_TYPE_EQUIP_ICON) {
						_columnNames[i] = "equipIcon";
						_bEnableEquipIcon = true;
					}
					
					if (columns[i].icon.size != undefined) {
						_columnSizes[i*2] = columns[i].icon.size;
						weightedWidth -= columns[i].icon.size;
						
						_columnSizes[i*2+1] = columns[i].icon.size;
						curHeight += columns[i].icon.size;
					}
					
					break;

				// REST
				default:
					_columnNames[i] = "textField" + textFieldIndex++;
					
					if (columns[i].entry.width != undefined) {
						_columnSizes[i*2] = columns[i].entry.width;
						weightedWidth -= columns[i].entry.width;
					} else {
						_columnSizes[i*2] = 0;
					}
					
					if (columns[i].entry.height != undefined) {
						_columnSizes[i*2+1] = columns[i].entry.height;
					} else {
						_columnSizes[i*2+1] = 0;
					}
					
					_columnEntryValues[i] = columns[i].entry.text;
					
					if (columns[i].entry.format != undefined) {
						var customFormat = new TextFormat();

						// Duplicate default format
						for (var prop in _defaultEntryFormat) {
							customFormat[prop] = _defaultEntryFormat[prop];
						}
						
						// Overrides
						for (var prop in columns[i].entry.format) {
							if (customFormat.hasOwnProperty(prop)) {
								customFormat[prop] = columns[i].entry.format[prop];
							}
						}
						
						_customEntryFormats[i] = customFormat;
					}
			}
			
			if (columns[i].border != undefined) {
				weightedWidth -= columns[i].border[0] + columns[i].border[1];
				curHeight += columns[i].border[2] + columns[i].border[3];
				_columnPositions[i*2+1] = columns[i].border[2];
			} else {
				_columnPositions[i*2+1] = 0;
			}
			
			if (curHeight > maxHeight) {
				maxHeight = curHeight;
			}
		}
		
		if (weightSum > 0 && weightedWidth > 0 && weightedFlags != 0) {
			for (var i=columns.length-1; i>=0; i--) {
				if ((weightedFlags >>>= 1) & 1) {
					if (columns[i].border != undefined) {
						_columnSizes[i*2] += ((columns[i].weight / weightSum) * weightedWidth) - columns[i].border[0] - columns[i].border[1];
					} else {
						_columnSizes[i*2] += (columns[i].weight / weightSum) * weightedWidth;
					}
				}
			}
		}
		
		// Set x positions based on calculated widths
		var xPos = 0;
		
		for (var i=0; i<columns.length; i++) {
			
			if (columns[i].indent != undefined) {
				xPos += columns[i].indent;
			}

			if (columns[i].border != undefined) {
				xPos += columns[i].border[0];
				_columnPositions[i*2] = xPos;
				xPos += columns[i].border[1] + _columnSizes[i*2];
			} else {
				_columnPositions[i*2] = xPos;
				xPos += _columnSizes[i*2];
			}
		}
		
		while (textFieldIndex < 10) {
			_hiddenColumnNames.push("textField" + textFieldIndex++);
		}
		
		if (!_bEnableItemIcon) {
			_hiddenColumnNames.push("itemIcon");
		}
		
		if (!_bEnableEquipIcon) {
			_hiddenColumnNames.push("equipIcon");
		}
		
		// Set up header
		if (header != undefined) {
			
			header.clearColumns();
			header.activeColumnIndex = _activeColumnIndex;
			
			if (columns[_activeColumnIndex].label.arrowDown == true) {
				header.isArrowDown = true;
			} else {
				header.isArrowDown = false;
			}
			
			for (var i = 0; i < columns.length; i++) {
				var btn = header.addColumn(i);

				btn.label._x = 0;

				if (columns[i].border != undefined) {
					btn._x = _columnPositions[i*2] - columns[i].border[0];
					btn.label._width = _columnSizes[i*2] + columns[i].border[0] + columns[i].border[1];

				} else {
					btn._x = _columnPositions[i*2];
					btn.label._width = _columnSizes[i*2];
				}

				btn.label.setTextFormat(_defaultLabelFormat);
				
				
				if (columns[i].entry.format != undefined) {
					var customFormat = new TextFormat();

					// Duplicate default format
					for (var prop in _defaultLabelFormat) {
						customFormat[prop] = _defaultLabelFormat[prop];
					}
						
					// Overrides
					for (var prop in columns[i].label.format) {
						if (customFormat.hasOwnProperty(prop)) {
							customFormat[prop] = columns[i].label.format[prop];
						}
					}
						
					btn.label.setTextFormat(customFormat);
				} else {
					btn.label.setTextFormat(_defaultLabelFormat);
				}
				
				btn.label.SetText(columns[i].label.text);
			}
			
			header.activeColumn = _activeColumnIndex;
			header.positionButtons();
		}
		
		_entryHeight = maxHeight;
		_maxListIndex = Math.floor((_listHeight / _entryHeight) + 0.05);
		
		updateSortParams();
	}
	
	function updateSortParams()
	{

		var columns = currentView.columns;
		var sortAttributes = columns[_activeColumnIndex].sortAttributes;
		var sortOptions = columns[_activeColumnIndex].sortOptions;
		
		if (sortOptions == undefined) {
			return;
		}
		
		// No attribute(s) set? Try to use entry value
		if (sortAttributes == undefined) {
			if (_columnEntryValues[_activeColumnIndex] != undefined) {

				if (_columnEntryValues[_activeColumnIndex].charAt(0) == "@") {
					sortAttributes = [_columnEntryValues[_activeColumnIndex].slice(1)];
				}
			}
		}
		
		if (sortAttributes == undefined) {
			return;
		}
		
		// Wrap single attribute in array
		if (! sortAttributes instanceof Array) {
			sortAttributes = [sortAttributes];
		}
		if (! sortOptions instanceof Array) {
			sortOptions = [sortOptions];
		}
		
		dispatchEvent({type:"sortChange", attributes: sortAttributes, options: sortOptions});
	}
}