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
import skyui.util.ConfigManager;


class skyui.components.list.TabularList extends ScrollingList
{
  /* PRIVATE VARIABLES */

	private var _previousColumnKey: Number = -1;
	private var _nextColumnKey: Number = -1;
	private var _sortOrderKey: Number = -1;

	private var _columnOpRequested: Number = 0;

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
		
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
	}


  /* PUBLIC FUNCTIONS */
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		

		if (!disableInput && _platform != 0) {
			if (GlobalFunc.IsKeyPressed(details)) {

				// VR specific behavior
				//
				// While look at a specific category, we want to be able to both:
				// - switch column
				// - switch column sort direction
				// We only have swipe events to work with in VR at the moment.
				// We can't use the the right/left swiping motions because they cause changes to the columns.
				// So, we can only overload the up/down swipes.
				if (Shared.GlobalFunc.IsKeyPressed(details) &&
						(details.navEquivalent == NavigationCode.UP &&
							(selectedIndex == -1 || 							// Nothing is selected (just switched category)
					 	 	 getSelectedListEnumIndex() == 0)) 		// Selected item is the first item in current view of the list
			 	 	 ){

					var inputWindow = 250;
					if(_platform == Shared.Platforms.CONTROLLER_OCULUS) {
						inputWindow = 400;
					}

					// Has no column operation is currently pending...
					if(_columnOpRequested == 0)	{
						// Schedule an operation to be performed in the near future.
						var _this = this;
						setTimeout(function() {
								if(_this._columnOpRequested == 1) {
									_this.layout.nextColumn();
								} else {
									_this.layout.nextActiveColumnState();
								}
								_this._columnOpRequested = 0;
						}, inputWindow);
					}

					// While we're waiting for the column operation to be performed in the near future,
					// record the number of times the operation is requested.
					_columnOpRequested++;
					return true;
				}
			}
		}

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
  
  	private function onConfigLoad(event: Object): Void
	{
		var config = event.config;
		
		if (_platform != 0) {
			_previousColumnKey = config["Input"].controls.gamepad.prevColumn;
			_nextColumnKey = config["Input"].controls.gamepad.nextColumn;
			_sortOrderKey = config["Input"].controls.gamepad.sortOrder;
		}
	}
	
	private function onLayoutChange(event: Object): Void
	{
		entryHeight = _layout.entryHeight;

		header._x = leftBorder;
		
		_maxListIndex = Math.floor((_listHeight / entryHeight) + 0.05);
		
		if (_layout.sortAttributes && _layout.sortOptions)
			dispatchEvent({type:"sortChange", attributes: _layout.sortAttributes, options:  _layout.sortOptions});
		
		requestUpdate();
	}
}