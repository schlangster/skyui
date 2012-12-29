import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.defines.Input;
import skyui.util.ConfigLoader;
import skyui.util.GlobalFunctions;
import skyui.components.list.ListLayout;
import skyui.components.list.SortedListHeader;
import skyui.components.list.ScrollingList;
import skyui.filter.IFilter;


class skyui.components.list.TabularList extends ScrollingList
{
  /* PRIVATE VARIABLES */

	private var _previousColumnKey: Number;
	private var _nextColumnKey: Number;
	private var _sortOrderKey: Number;

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
		
		if (header)
			header.layout = a_layout;
	}


  /* INITIALIZATION */

	public function TabularList()
	{
		super();
	}


  /* PUBLIC FUNCTIONS */

	// @override BasicList
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.setPlatform(a_platform,a_bPS3Switch);

		if (_platform != 0) {
			_previousColumnKey = GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, true);
			_nextColumnKey = GlobalFunctions.getMappedKey("Shout", Input.CONTEXT_GAMEPLAY, true);
			_sortOrderKey = GlobalFunctions.getMappedKey("Sneak", Input.CONTEXT_GAMEPLAY, true);
		}
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (super.handleInput(details, pathToFocus))
			return true;

		if (!disableInput && _platform != 0) {
			if (GlobalFunc.IsKeyPressed(details)) {
				if (details.skseKeycode == _previousColumnKey) {
					_layout.selectColumn(_layout.activeColumnIndex - 1);
					return true;
				} else if (details.skseKeycode == _nextColumnKey) {
					_layout.selectColumn(_layout.activeColumnIndex + 1);
					return true;
				} else if (details.skseKeycode == _sortOrderKey) {
					_layout.selectColumn(_layout.activeColumnIndex);
					return true;
				}
			}
		}
		return false;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function onLayoutChange(event: Object): Void
	{
		entryHeight = _layout.entryHeight;
		
		_maxListIndex = Math.floor((_listHeight / entryHeight) + 0.05);
		
		if (_layout.sortAttributes && _layout.sortOptions)
			dispatchEvent({type:"sortChange", attributes: _layout.sortAttributes, options:  _layout.sortOptions});
		
		requestUpdate();
	}
}