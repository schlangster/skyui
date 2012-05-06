import skyui.ConfigLoader;
import skyui.Util;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import skyui.Translator;
import skyui.ListLayout;
import skyui.SortedListHeader;
import skyui.FilteredEnumeration;
import skyui.IFilter;


class skyui.TabularList extends skyui.ScrollingList
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
		
		skse.Log("_entryHeight: " + _entryHeight);
		skse.Log("_maxListIndex: " + _maxListIndex);
		
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
}