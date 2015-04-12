import skyui.components.list.BasicList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;

class ButtonGridEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */
	
	
  /* STAGE ELEMENTS */

	public var textField: TextField;
	public var icon: MovieClip;
	
	
  /* PROPERTIES */
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		isEnabled = true;
		
		var isSelected = a_entryObject == a_state.list.selectedEntry;

		gotoAndStop(isSelected ? "selected" : "normal");

		textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";				
		textField.SetText(a_entryObject.name ? a_entryObject.name : " ");		
		
		icon.gotoAndStop(a_entryObject.iconLabel);
	}
}