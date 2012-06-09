import skyui.components.list.ButtonList;
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
  
	private var _list: ButtonList;
	
	
  /* CONSTRUCTORS */
	
	public function ButtonEntryFormatter(a_list: ButtonList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;

		a_entryClip.enabled = a_entryObject.enabled;

		if (a_entryObject.state != undefined)
			a_entryClip.gotoAndPlay(a_entryObject.state);
		
		if (a_entryClip.selectIndicator != undefined)
			a_entryClip.selectIndicator._visible = (a_entryObject == _list.selectedEntry);

		if (a_entryClip.textField != undefined) {
			a_entryClip.textField.autoSize = "left";
			a_entryClip.textField.textColor = a_entryObject.enabled ? 0xffffff : 0x4c4c4c;
			a_entryClip.textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
        }
	}
}