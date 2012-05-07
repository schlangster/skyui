import Shared.GlobalFunc;
import gfx.ui.NavigationCode;

import skyui.util.ConfigLoader;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.components.list.ListLayout;
import skyui.components.list.SortedListHeader;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.ScrollingList;
import skyui.filter.IFilter;


class skyui.components.list.TabularList extends ScrollingList
{
  /* STAGE ELEMENTS */
  
	public var header: SortedListHeader;
	
	
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


  /* CONSTRUCTORS */

	public function TabularList()
	{
		super();
	}
	
	public function onLoad()
	{
		super.onLoad();
		
		if (header != 0)
			header.addEventListener("columnPress", this, "onColumnPress");
	}


  /* PUBLIC FUNCTIONS */
	
	public function onColumnPress(event)
	{
		if (event.index != undefined)
			_layout.selectColumn(event.index);
	}
	
	public function onLayoutChange(event)
	{
		_entryHeight = _layout.entryHeight;
		_maxListIndex = Math.floor((_listHeight / _entryHeight) + 0.05);
		
		if (header)
			updateHeader();
		
		UpdateList();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var processed = super.handleInput(details, pathToFocus);;

		if (!_bDisableInput && !processed && _platform != 0) {

			if (GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.GAMEPAD_L1) {
					_layout.selectColumn(_layout.activeColumnIndex - 1);
					processed = true;					
				} else if (details.navEquivalent == NavigationCode.GAMEPAD_R1) {
					_layout.selectColumn(_layout.activeColumnIndex + 1);
					processed = true;
				} else if (details.navEquivalent == NavigationCode.GAMEPAD_L3) {
					_layout.selectColumn(_layout.activeColumnIndex);
					processed = true;
				}
			}
		}
		return processed;
	}
	
	private function updateHeader(): Void
	{
		header.clearColumns();
		header.activeColumnIndex = _layout.activeColumnIndex;
// TODO
//		if (columns[_activeColumnIndex].label.arrowDown == true)
//			header.isArrowDown = true;
//		else
//			header.isArrowDown = false;
			
		for (var i = 0; i < _layout.columnCount; i++) {
			var columnLayoutData = _layout.columnLayoutData[i];
			var btn = header.addColumn(i);

			btn.label._x = 0;

			btn._x = columnLayoutData.labelX;
			
			btn.label._width = columnLayoutData.labelWidth;
			btn.label.setTextFormat(columnLayoutData.labelTextFormat);
			
			btn.label.SetText(Translator.translate(columnLayoutData.labelValue));
		}
		
		header.positionButtons();
	}
}