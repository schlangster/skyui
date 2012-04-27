import skyui.ConfigLoader;
import skyui.ListLayout;


/*
 *  Encapsulates the list layout configuration.
 */
class skyui.ListLayoutManager
{
	private static var MAX_TEXTFIELD_INDEX = 10;
	
	// [c1.x, c1.y, c2.x, c2.y, ...] - (x,y) Offset of column fields in a row (relative to the entry clip)
	private var _columnPositions:Array;
	
	// [c1.width, c1.height, c2.width, c2.height, ...]
	private var _columnSizes:Array;
	
	// These are the names like textField0, equipIcon etc used when positioning, not the names as defined in the config
	private var _cellNames:Array;
	private var _hiddenCellNames:Array;
	
	// Only used for textfield-based columns
	private var _columnEntryValues:Array;
	
	private var _customEntryFormats:Array;
	private var _defaultEntryFormat:TextFormat;
	private var _defaultLabelFormat:TextFormat;
	
	
	function ListLayoutManager()
	{
		_columnPositions = [];
		_columnSizes = [];
		_cellNames = [];
		_hiddenCellNames = [];
		_columnEntryValues = [];
		_customEntryFormats = [];
		
		_defaultEntryFormat = new TextFormat(); 
		_defaultLabelFormat = new TextFormat();
		
		ConfigLoader.registerCallback(this, "onConfigLoad");
	}
	
	function onConfigLoad(event)
	{
		var config = event.config;
		if (config == undefined)
			return;
	}

	// Calculate new column positions and widths for current view
	function update()
	{
		var columns = currentView.columns;

		var maxHeight = 0;
		var textFieldIndex = 0;

		_columnPositions.splice(0);
		_columnSizes.splice(0);
		_cellNames.splice(0);
		_hiddenCellNames.splice(0);
		_columnEntryValues.splice(0);
		_customEntryFormats.splice(0);
		
		// Set bit at position i if column is weighted
		var weightedFlags = 0;
		
		// Subtract arrow tip width
		var weightedWidth = _entryWidth - 12;
		
		var weightSum = 0;

		var bEnableItemIcon = false;
		var bEnableEquipIcon = false;

		for (var i = 0; i < columns.length; i++) {

			// Calc total weighted width and weight flags
			if (columns[i].weight != undefined) {
				weightSum += columns[i].weight;
				weightedFlags = (weightedFlags | 1) << 1;
			} else
				weightedFlags = (weightedFlags | 0) << 1;
			
			if (columns[i].indent != undefined)
				weightedWidth -= columns[i].indent;
			
			// Height including borders for maxHeight
			var curHeight = 0;
			
			switch (columns[i].type) {
				// ITEM ICON + EQUIP ICON
				case ListLayout.COL_TYPE_ITEM_ICON:
				case ListLayout.COL_TYPE_EQUIP_ICON:
								
					if (columns[i].type == ListLayout.COL_TYPE_ITEM_ICON) {
						_cellNames[i] = "itemIcon";
						bEnableItemIcon = true;
					} else if (columns[i].type == ListLayout.COL_TYPE_EQUIP_ICON) {
						_cellNames[i] = "equipIcon";
						bEnableEquipIcon = true;
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
					_cellNames[i] = "textField" + textFieldIndex++;
					
					if (columns[i].entry.width != undefined) {
						_columnSizes[i*2] = columns[i].entry.width;
						weightedWidth -= columns[i].entry.width;
					} else
						_columnSizes[i*2] = 0;
					
					if (columns[i].entry.height != undefined)
						_columnSizes[i*2+1] = columns[i].entry.height;
					else
						_columnSizes[i*2+1] = 0;
					
					_columnEntryValues[i] = columns[i].entry.text;
					
					if (columns[i].entry.format != undefined) {
						var customFormat = new TextFormat();

						// First clone default format
						for (var prop in _defaultEntryFormat)
							customFormat[prop] = _defaultEntryFormat[prop];
						
						// Then override if necessary
						for (var prop in columns[i].entry.format)
							if (customFormat.hasOwnProperty(prop))
								customFormat[prop] = columns[i].entry.format[prop];
						
						_customEntryFormats[i] = customFormat;
					}
			}
			
			if (columns[i].border != undefined) {
				weightedWidth -= columns[i].border[0] + columns[i].border[1];
				curHeight += columns[i].border[2] + columns[i].border[3];
				_columnPositions[i*2+1] = columns[i].border[2];
			} else
				_columnPositions[i*2+1] = 0;
			
			if (curHeight > maxHeight)
				maxHeight = curHeight;
		}
		
		// Calculate the widths
		if (weightSum > 0 && weightedWidth > 0 && weightedFlags != 0) {
			for (var i=columns.length-1; i>=0; i--) {
				if ((weightedFlags >>>= 1) & 1) {
					if (columns[i].border != undefined)
						_columnSizes[i*2] += ((columns[i].weight / weightSum) * weightedWidth) - columns[i].border[0] - columns[i].border[1];
					else
						_columnSizes[i*2] += (columns[i].weight / weightSum) * weightedWidth;
				}
			}
		}
		
		// Set x positions based on calculated widths
		var xPos = 0;
		
		for (var i=0; i<columns.length; i++) {
			
			if (columns[i].indent != undefined)
				xPos += columns[i].indent;

			if (columns[i].border != undefined) {
				xPos += columns[i].border[0];
				_columnPositions[i*2] = xPos;
				xPos += columns[i].border[1] + _columnSizes[i*2];
			} else {
				_columnPositions[i*2] = xPos;
				xPos += _columnSizes[i*2];
			}
		}
		
		while (textFieldIndex < MAX_TEXTFIELD_INDEX)
			_hiddenCellNames.push("textField" + textFieldIndex++);
		
		if (!bEnableItemIcon)
			_hiddenCellNames.push("itemIcon");
		
		if (!bEnableEquipIcon)
			_hiddenCellNames.push("equipIcon");
	}
}