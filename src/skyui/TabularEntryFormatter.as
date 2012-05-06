import skyui.TabularList;
import skyui.ListLayout;

// @abstract
class skyui.TabularEntryFormatter implements skyui.IEntryFormatter
{
  /* PRIVATE VARIABLES */
  
	private var _list: TabularList;
	
	
  /* CONSTRUCTORS */
	
	public function TabularEntryFormatter(a_list: TabularList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		var layout = _list.layout;
		
		if (a_entryClip == undefined)
			return;
			
		// Show select area if this is the current entry
		a_entryClip.selectArea._alpha = a_entryObject == _list.selectedEntry ? 40 : 0;
		
		var activeViewIndex = layout.activeViewIndex;
		var columnCount = layout.columnCount;
		var columnNames = layout.columnNames;
		var columnEntryValues = layout.columnEntryValues;
		var columnTypes = layout.columnTypes;
		
		// View changed? Update the columns positions etc.
		if (activeViewIndex != -1 && a_entryClip.viewIndex != activeViewIndex) {
			a_entryClip.viewIndex = activeViewIndex;
			
			setEntryLayout(a_entryClip, a_entryObject);
			setSpecificEntryLayout(a_entryClip, a_entryObject);
		}
		
		// Format the actual entry contents. Do this with every upate.
		for (var i = 0; i < columnCount; i++) {
			var e = a_entryClip[columnNames[i]];

			// Substitute @variables by entryObject properties
			if (columnEntryValues[i] != undefined)
				if (columnEntryValues[i].charAt(0) == "@")
					e.SetText(a_entryObject[columnEntryValues[i].slice(1)]);
			
			// Process based on column type 
			switch (columnTypes[i]) {
				case ListLayout.COL_TYPE_EQUIP_ICON :
					formatEquipIcon(e, a_entryObject, a_entryClip);
					break;

				case ListLayout.COL_TYPE_ITEM_ICON :
					formatItemIcon(e, a_entryObject, a_entryClip);
					break;

				case ListLayout.COL_TYPE_NAME :
					formatName(e, a_entryObject, a_entryClip);
					break;

				case ListLayout.COL_TYPE_TEXT :
				default :
					formatText(e, a_entryObject, a_entryClip);
			}
		}
	}
	
	public function setEntryLayout(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		var layout = _list.layout;
		
		var columnCount = layout.columnCount;
		var columnNames = layout.columnNames;
		var columnPositions = layout.columnPositions;
		var columnSizes = layout.columnSizes;
		var entryWidth = layout.entryWidth;
		var entryHeight = layout.entryHeight;
		var customEntryTextFormats = layout.customEntryTextFormats;
		var defaultEntryTextFormat = layout.defaultEntryTextFormat;
			
		a_entryClip.border._width = a_entryClip.selectArea._width = entryWidth;
		a_entryClip.border._height = a_entryClip.selectArea._height = entryHeight;
	
		// Set up all visible elements in this entry
		for (var i=0; i<columnCount; i++) {
			var e = a_entryClip[columnNames[i]];
			e._visible = true;
		
			e._x = columnPositions[i*2];
			e._y = columnPositions[i*2+1];
		
			if (columnSizes[i*2] > 0)
				e._width = columnSizes[i*2];
		
			if (columnSizes[i*2+1] > 0)
				e._height = columnSizes[i*2+1];
			
			if (e instanceof TextField)
				e.setTextFormat(customEntryTextFormats[i] ? customEntryTextFormats[i] : defaultEntryTextFormat);
		}
		
		// Hide any unused elements
		var hiddenColumnNames = layout.hiddenColumnNames;
		
		for (var i=0; i<hiddenColumnNames.length; i++)
			a_entryClip[hiddenColumnNames[i]]._visible = false;
	}
	
	// Do any clip-specific tasks when the view was changed for this entry.
	// @abstract
	public function setSpecificEntryLayout(a_entryClip: MovieClip, a_entryObject: Object): Void {}

	// @abstract
	function formatName(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip) {}
	
	// @abstract
	function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip) {}

	// @abstract
	function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip) {}
	
	// @abstract
	function formatText(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip) {}
}