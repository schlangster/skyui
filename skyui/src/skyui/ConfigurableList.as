import skyui.Config;

class skyui.ConfigurableList extends skyui.FilteredList
{
	private var _config:Config;

	private var _views:Array;
	private var _viewIndex:Number;

	private var _bEnableItemIcon:Boolean;
	private var _bEnableEquipIcon:Boolean;
	
	// Cache the pre-calculated values so they can be looked up fast&easy
	
	// [c1.x, c1.y, c2.x, c2.y, ...] - (x,y) Offset of column fields in a row (relative to the entry clip)
	private var _columnPositions:Array;
	// [c1.width, c1.height, c2.width, c2.height, ...]
	private var _columnSizes:Array;
	// These are the names like textField0, equipIcon etc used when positioning, not the names as defined in the config
	private var _columnNames:Array;
	private var _hiddenColumnNames:Array;
	
	// Only used for textfield-based columns
	private var _columnEntryValues:Array;
	
	private var _entryHeight:Number;
	private var _bReposition:Boolean;

	function ConfigurableList()
	{
		super();
		_bEnableItemIcon = false;
		_bEnableEquipIcon = false;

		_columnPositions = new Array();
		_columnSizes = new Array();
		_columnNames = new Array();
		_hiddenColumnNames = new Array();
		_columnEntryValues = new Array();
		
		_viewIndex = 1;
		
		_bReposition = false;
		_entryHeight = 0;

		Config.instance.addEventListener("configLoad",this,"onConfigLoad");
	}
	
	function get currentView()
	{
		return _views[_viewIndex];
	}

	function onConfigLoad(event)
	{
		_config = event.config;
		_views = _config.ItemList.views;

//		createEntryClip(0);
		updateView();
//		setEntry(createEntryClip(0), undefined);

	}

	function createEntryClip(a_index:Number):MovieClip
	{
		var entryClip = attachMovie(_entryClassName, "Entry" + a_index, getNextHighestDepth());

		for (var i = 0; entryClip["textField" + i] != undefined; i++) {
			//entryClip["textField" + i]._visible = false;
		}

		return entryClip;
	}
	
	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		var columns = currentView.columns;
		
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
			
			if (_columnEntryValues[i] != undefined) {
				if (_columnEntryValues[i].charAt(0) == "@") {
					e.SetText(a_entryObject[_columnEntryValues[i].slice(1)]);
				}
			}
		}
		
		for (var i=0; i<_hiddenColumnNames.length; i++) {
			a_entryClip[_hiddenColumnNames[i]]._visible = false;
		}
		

		
		super.setEntry(a_entryClip, a_entryObject);
	}
	
	function UpdateList()
	{
		super.UpdateList();
		
		// Done repositiong
		_bReposition = false;
	}

	function changeFilterFlag(a_flag:Number)
	{
		// Match view
		for (var i = 0; i < _views.length; i++) {
			if (_views[i].category == a_flag) {
				if (i != _viewIndex) {
					_viewIndex = i;
					updateView();
				}
				break;
			}
		}
	}

	/* Calculate new column positions and widths for current view */
	function updateView()
	{
		_bReposition = true;
		_bEnableItemIcon = false;
		_bEnableEquipIcon = false;
		
		var columns = currentView.columns;

		var weightedWidth = 562;
		var weightSum = 0;
		var maxHeight = 0;
		
		var textFieldIndex = 0;

		_columnPositions.splice(0);
		_columnSizes.splice(0);
		_columnNames.splice(0);
		_hiddenColumnNames.splice(0);
		_columnEntryValues.splice(0);
		
		// Set bit at position i if column is weighted
		var weightedFlags = 0;

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
			
			// ITEM ICON
			if (columns[i].type == Config.COL_TYPE_ITEM_ICON) {
				_columnNames[i] = "itemIcon";
				_bEnableItemIcon = true;
				
				if (columns[i].icon.size != undefined) {
					_columnSizes[i*2] = columns[i].icon.size;
					weightedWidth -= columns[i].icon.size;
					
					_columnSizes[i*2+1] = columns[i].icon.size;
					curHeight += columns[i].icon.size;
				}
				
			// EQUIP ICON
			} else if (columns[i].type == Config.COL_TYPE_EQUIP_ICON) {
				_columnNames[i] = "equipIcon";
				_bEnableEquipIcon = true;
					
				if (columns[i].icon.size != undefined) {
					_columnSizes[i*2] = columns[i].icon.size;
					weightedWidth -= columns[i].icon.size;
					
					_columnSizes[i*2+1] = columns[i].icon.size;
					curHeight += columns[i].icon.size;
				}

			// REST
			} else {
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
					_columnSizes[i*2] += (columns[i].weight / weightSum) * weightedWidth;
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
		
		for (var i=0; i<columns.length; i++) {
			trace("[" + _columnNames[i] + "]\t w:" + _columnSizes[i*2] + "\tx: " + _columnPositions[i*2] + "\ty: " + _columnPositions[i*2+1] + "\ttext: " + _columnEntryValues[i]);
		}
		
		trace("Max height: " + maxHeight);
		trace("Weighted width: " + weightedWidth);
		trace("Weight sum: " + weightSum);
	}
}