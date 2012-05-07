import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.components.list.ColumnLayoutData;
import skyui.components.list.IEntryFormatter;


// @abstract
class skyui.components.list.TabularEntryFormatter implements IEntryFormatter
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
		var layout: ListLayout = _list.layout;
		
		
		if (a_entryClip == undefined)
			return;
			
		// Show select area if this is the current entry
		a_entryClip.selectArea._alpha = a_entryObject == _list.selectedEntry ? 40 : 0;
		
		var activeViewIndex = layout.activeViewIndex;
		
		// View changed? Update the columns positions etc.
		if (activeViewIndex != -1 && a_entryClip.viewIndex != activeViewIndex) {
			a_entryClip.viewIndex = activeViewIndex;
			
			setEntryLayout(a_entryClip, a_entryObject);
			setSpecificEntryLayout(a_entryClip, a_entryObject);
		}
		
		// Format the actual entry contents. Do this with every upate.
		for (var i = 0; i < layout.columnCount; i++) {
			var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
			var e = a_entryClip[columnLayoutData.stageName];

			// Substitute @variables by entryObject properties
			if (columnLayoutData.entryValue != undefined)
				if (columnLayoutData.entryValue.charAt(0) == "@")
					e.SetText(a_entryObject[columnLayoutData.entryValue.slice(1)]);
			
			// Process based on column type 
			switch (columnLayoutData.type) {
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
		var layout: ListLayout = _list.layout;
			
		a_entryClip.border._width = a_entryClip.selectArea._width = layout.entryWidth;
		a_entryClip.border._height = a_entryClip.selectArea._height = layout.entryHeight;
	
		// Set up all visible elements in this entry
		for (var i=0; i<layout.columnCount; i++) {
			var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
			var e = a_entryClip[columnLayoutData.stageName];
			
			e._visible = true;
		
			e._x = columnLayoutData.x;
			e._y = columnLayoutData.y;
		
			if (columnLayoutData.width > 0)
				e._width = columnLayoutData.width;
		
			if (columnLayoutData.height > 0)
				e._height = columnLayoutData.height;
			
			if (e instanceof TextField)
				e.setTextFormat(columnLayoutData.textFormat);
		}
		
		// Hide any unused elements
		var hiddenStageNames = layout.hiddenStageNames;
		
		for (var i=0; i<hiddenStageNames.length; i++)
			a_entryClip[hiddenStageNames]._visible = false;

	}
	
	// Do any clip-specific tasks when the view was changed for this entry.
	// @abstract
	public function setSpecificEntryLayout(a_entryClip: MovieClip, a_entryObject: Object): Void {}

	// @abstract
	public function formatName(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void {}
	
	// @abstract
	public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void {}

	// @abstract
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void {}
	
	// @abstract
	public function formatText(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void {}
}