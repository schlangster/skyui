import skyui.components.list.ButtonList;
import skyui.components.list.IEntryFormatter;


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
			
		a_entryClip.gotoAndPlay(a_entryObject.state);
		a_entryClip.enabled = a_entryObject.enabled;
		
		a_entryClip.selectIndicator._visible = (a_entryObject == _list.selectedEntry);

		var buttonWidth = 0;

		if (a_entryClip.textField != undefined) {
			a_entryClip.textField.autoSize = "left";
			a_entryClip.textField.textColor = a_entryObject.enabled ? 0xffffff : 0x4c4c4c;
			a_entryClip.textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
        }
	}
}