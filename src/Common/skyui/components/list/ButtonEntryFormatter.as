import skyui.components.list.BasicList;
import skyui.components.list.IEntryFormatter;


/*
 *  A generic entry formatter.
 *  Sets selectIndicator visible for the selected entry, if defined.
 *  Sets textField to obj.text.
 *  Forwards to label obj.state, if defined.
 */
class skyui.components.list.ButtonEntryFormatter implements IEntryFormatter
{
  /* PRIVATE VARIABLES */
  
	private var _list: BasicList;
	
	
  /* INITIALIZATION */
	
	public function ButtonEntryFormatter(a_list: BasicList)
	{
		_list = a_list;
	}
	
	
  /* PROPERTIES */
  
	public var defaultTextColor: Number = 0xffffff;
	public var activeTextColor: Number = 0xffffff;
	public var selectedTextColor: Number = 0xffffff;
	public var disabledTextColor: Number = 0x4c4c4c;

	// Selected entry is controlled by list itself, but active entry is based on context.
	public var activeEntry: Object;
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;

		a_entryClip.enabled = a_entryObject.enabled;
		var isSelected = a_entryObject == _list.selectedEntry;
		var isActive = (activeEntry != undefined && a_entryObject == activeEntry);

		var activeIndicator = a_entryClip.activeIndicator;
		var selectIndicator = a_entryClip.selectIndicator;

		if (a_entryObject.state != undefined)
			a_entryClip.gotoAndPlay(a_entryObject.state);

		if (a_entryClip.textField != undefined) {
			a_entryClip.textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			
			if (!a_entryObject.enabled)
				a_entryClip.textField.textColor = disabledTextColor;
			else if (isActive)
				a_entryClip.textField.textColor = activeTextColor;
			else if (isSelected)
				a_entryClip.textField.textColor = selectedTextColor;
			else
				a_entryClip.textField.textColor = defaultTextColor;
				
			a_entryClip.textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
		
		if (selectIndicator != undefined)
			selectIndicator._visible = isSelected;
			
		if (activeIndicator != undefined) {
			activeIndicator._visible = isActive;
			activeIndicator._x = a_entryClip.textField._x - activeIndicator._width - 5;
		}
	}
}