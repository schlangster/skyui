import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;
import skyui.util.GlobalFunctions;

// Entry objects are the actual markers
class Map.LocationListEntry extends BasicListEntry
{
  /* STAGE ELMENTS */

	public var selectIndicator: MovieClip;

	public var icon: MovieClip;
	public var textField: TextField;
	
	
  /* PROPERTIES */
	
	public function get width(): Number
	{
		return background._width;
	}

	public function set width(a_val: Number)
	{
		background._width = a_val;
		selectIndicator._width = a_val;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var entryWidth = background._width;
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		selectIndicator._visible = isSelected;
		
		icon.gotoAndStop(a_entryObject.iconType+1);
		textField.SetText(a_entryObject.label);
	}
}