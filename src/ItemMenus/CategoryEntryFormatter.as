import skyui.components.list.IEntryFormatter;


class CategoryEntryFormatter implements IEntryFormatter
{
  /* PRIVATE VARIABLES */
  
	private var _list: CategoryList;
	
	
  /* CONSTRUCTORS */
	
	public function CategoryEntryFormatter(a_list: CategoryList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;
			
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