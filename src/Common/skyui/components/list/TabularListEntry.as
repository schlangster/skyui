﻿import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.components.list.ListState;
import skyui.components.list.ColumnLayoutData;
import skyui.components.list.IEntryFormatter;
import skyui.components.list.BasicListEntry;


// @abstract
class skyui.components.list.TabularListEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */
  
	private var _layoutUpdateCount: Number = -1;
	
	
  /* STAGE ELEMENTS */

	public var selectIndicator: MovieClip;
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override BasicListEntry
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var layout: ListLayout = TabularList(a_state.list).layout;
			
		// Show select area if this is the current entry
		selectIndicator._visible = (a_entryObject == a_state.list.selectedEntry);
		
		var curLayoutUpdateCount = layout.layoutUpdateCount;
		
		// Has the view update sequence number changed? Then Update the columns positions etc.
		if (_layoutUpdateCount != curLayoutUpdateCount) {
			_layoutUpdateCount = curLayoutUpdateCount;
			
			setEntryLayout(a_entryObject, a_state);
			setSpecificEntryLayout(a_entryObject, a_state);
		}
		
		// The entire entry should be using the same font & size
		// We want to fetch the lineMetrics just once (not sure how expensive this call is)
		var textMetrics = undefined;

		// Format the actual entry contents. Do this with every upate.
		for (var i = 0; i < layout.columnCount; i++) {
			var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
			var e = this[columnLayoutData.stageName];
			if (textMetrics == undefined)
				textMetrics = e.getLineMetrics(0);

			// Substitute @variables by entryObject properties
			var entryValue: String = columnLayoutData.entryValue;
			if (entryValue != undefined) {
				if (entryValue.charAt(0) == "@") {
					var subVal = a_entryObject[entryValue.slice(1)];
					e.SetText(subVal != undefined ? subVal : "-");					
				} else {
					e.SetText(entryValue);
				}
			}
			
			// Process based on column type 
			switch (columnLayoutData.type) {
				case ListLayout.COL_TYPE_EQUIP_ICON :
					formatEquipIcon(e, a_entryObject, a_state);
					break;

				case ListLayout.COL_TYPE_ITEM_ICON :
					formatItemIcon(e, a_entryObject, a_state);
					break;

				case ListLayout.COL_TYPE_NAME :
					formatName(e, a_entryObject, a_state);
					break;

				case ListLayout.COL_TYPE_TEXT :
				default :
					formatText(e, a_entryObject, a_state);
			}
			
			// Process color overrides after regular formatting
			if (columnLayoutData.colorAttribute != undefined) {
				var color = a_entryObject[columnLayoutData.colorAttribute];
				if (color != undefined)
					e.textColor = color;
			}

			// Center the text vertically, using the selectIndicator as a reference
			//
			// For some reason, text alignment is more difficult than it should be.
			// The idea here is to align the top of the select indicator and the TextField.
			// Then, we vertically center the TextField using the `ascent` height only.
			//
			// There is a small wrinkle here. For some reason, even if selectIndicator._y
			// and TextField._y is set to 0, they are not perfectly vertically aligned.
			// There is a small vertical gap which throws off this centering calculation.
			// By experiementation, it looks like subtracting the `descent` hight gets the
			// text to mostly align with the top of the indicator selector. It's still off
			// by a few pixels, but at least it's much better than not accounting for it.
			e._y = selectIndicator._y - textMetrics.descent + ((selectIndicator._height - textMetrics.ascent)/2);
		}
	}
	
	// Do any clip-specific tasks when the view was changed for this entry.
	// @abstract
	public function setSpecificEntryLayout(a_entryObject: Object, a_state: ListState): Void {}

	// @abstract
	public function formatName(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void {}
	
	// @abstract
	public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void {}

	// @abstract
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void {}
	
	// @abstract
	public function formatText(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void {}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setEntryLayout(a_entryObject: Object, a_state: ListState): Void
	{
		var layout: ListLayout = TabularList(a_state.list).layout;
			
		background._width = selectIndicator._width = layout.entryWidth;
		background._height = selectIndicator._height = layout.entryHeight;
	
		// Set up all visible elements in this entry
		for (var i=0; i<layout.columnCount; i++) {
			var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
			var e = this[columnLayoutData.stageName];
			
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
			this[hiddenStageNames[i]]._visible = false;
	}
}