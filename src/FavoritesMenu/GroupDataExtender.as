import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


class GroupDataExtender implements IListProcessor
{ 
  /* CONSTANTS */
  
  	public static var GROUP_SIZE = 32;
	

  /* PROPERTIES */

	public var groupData: Array;

	public var formIdMap: Object;
	
	
  /* INITIALIZATION */
	
	public function GroupDataExtender()
	{
		groupData = [];
		formIdMap = {};
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		// Create map for formid->entry
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.formId == null)
				continue;
			
		
			formIdMap[e.formId] = e;
		}
		
		var c = 0;
		var filterFlag = FilterDataExtender.FILTERFLAG_GROUP_0;
		
		for (var i=0; i<groupData.length; i++, c++) {
			if (c == GROUP_SIZE) {
				filterFlag = filterFlag << 1;
				c = 0;
			}
			
			var formId: Number = groupData[i].formId;
			if (formId) {
				var t = formIdMap[formId];
				if (t != null)
					t.filterFlag |= filterFlag;
			}
		}
	}
}