import skyui.components.list.BasicList;
import skyui.components.list.IEntryFormatter;


class skyui.components.list.AlphaEntryFormatter implements IEntryFormatter
{
  /* PRIVATE VARIABLES */
  
	private var _list: BasicList;
	
	
  /* CONSTRUCTORS */
	
	public function AlphaEntryFormatter(a_list: BasicList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip != undefined) {
			if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
				a_entryClip._alpha = 15;
				a_entryClip.enabled = false;
			} else if (a_entryObject == _list.selectedEntry) {
				a_entryClip._alpha = 100;
				a_entryClip.enabled = true;
			} else {
				a_entryClip._alpha = 50;
				a_entryClip.enabled = true;
			}
		}
	}
}