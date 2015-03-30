import skyui.components.list.BasicList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


/*
 *  A generic entry.
 *  Sets selectIndicator visible for the selected entry, if defined.
 *  Sets textField to obj.text.
 *  Forwards to label obj.state, if defined.
 */
class skyui.components.list.ButtonListEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */
	
	
  /* STAGE ELEMENTS */

	public var activeIndicator: MovieClip;
	public var selectIndicator: MovieClip;
	public var textField: TextField;
	public var icon: MovieClip;
	
	
  /* PROPERTIES */
  
	public static var defaultTextColor: Number = 0xffffff;
	public static var activeTextColor: Number = 0xffffff;
	public static var selectedTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x505050;
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		// Not using "enabled" directly, because we still want to be able to receive onMouseX events,
		// even if we chose not to process them.
		isEnabled = a_entryObject.enabled;
		
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var isActive = (a_state.activeEntry != undefined && a_entryObject == a_state.activeEntry);

		if (a_entryObject.state != undefined)
			gotoAndPlay(a_entryObject.state);

		if (textField != undefined) {
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			
			if (!a_entryObject.enabled)
				textField.textColor = disabledTextColor;
			else if (isActive)
				textField.textColor = activeTextColor;
			else if (isSelected)
				textField.textColor = selectedTextColor;
			else
				textField.textColor = defaultTextColor;
				
			textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
		
		if (selectIndicator != undefined)
			selectIndicator._visible = isSelected;
			
		if (activeIndicator != undefined) {
			activeIndicator._visible = isActive;
			activeIndicator._x = textField._x - activeIndicator._width - 5;
		}
		
		if (icon != undefined && a_entryObject.iconLabel != undefined) {
			icon.gotoAndStop(a_entryObject.iconLabel);
		}
	}
}