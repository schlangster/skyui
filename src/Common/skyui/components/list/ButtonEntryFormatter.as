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
	public var selectedTextColor: Number = 0xffffff;
	public var disabledTextColor: Number = 0x4c4c4c;
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;

		a_entryClip.enabled = a_entryObject.enabled;
		var isSelected = a_entryObject == _list.selectedEntry;

		if (a_entryObject.state != undefined)
			a_entryClip.gotoAndPlay(a_entryObject.state);
		
		if (a_entryClip.selectIndicator != undefined)
			a_entryClip.selectIndicator._visible = isSelected;

		if (a_entryClip.textField != undefined) {
			a_entryClip.textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			if (!a_entryObject.enabled)
				a_entryClip.textField.textColor = disabledTextColor;
			else
				a_entryClip.textField.textColor = isSelected ?  selectedTextColor : defaultTextColor;
			a_entryClip.textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
	}
}