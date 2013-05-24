import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


class EntryLookupHelper implements IListProcessor
{ 
  /* PROPERTIES */
  
	public var FormIdMap: Object;
	
	
  /* INITIALIZATION */
	
	public function EntryLookupHelper()
	{
		FormIdMap = {};
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.formId == null)
				continue;
			
		
			FormIdMap[e.formId] = e;
		}
	}
}