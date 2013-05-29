import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


class GroupDataExtender implements IListProcessor
{ 
  /* CONSTANTS */
  
  	public static var GROUP_SIZE = 32;
	

  /* PRIVATE VARIABLES */
  
	private var _formIdMap: Object;
	
	private var _groupButtons: Array;
	
	private var _invalidForms: Array;


  /* PROPERTIES */
  
	public var groupData: Array;
	public var mainHandData: Array;
	public var offHandData: Array;
	public var iconData: Array;
	
	
  /* INITIALIZATION */
	
	public function GroupDataExtender(a_groupButtons: Array)
	{
		groupData = [];
		mainHandData = [];
		offHandData = [];
		iconData = [];
		
		_formIdMap = {};
		
		_invalidForms = [];
		
		_groupButtons = a_groupButtons;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var groupCount = int(groupData.length / GROUP_SIZE);
		
		var clearFlag = 0;
		for (var c=0; c<groupCount; c++)
			clearFlag |= FilterDataExtender.FILTERFLAG_GROUP_0 << c;
		
		var entryList = a_list.entryList;
		
		// Create map for formid->entry, clear group filter flags
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			e.filterFlag &= ~clearFlag;
			e.mainHandFlag = 0;
			e.offHandFlag = 0;
			
			if (e.formId != null)
				_formIdMap[e.formId] = e;
		}
		
		processGroupData();
		processMainHandData();
		processOffHandData();
		processIconData();
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function processGroupData(): Void
	{
		// Set filterFlags for group membership
		var c = 0;
		var curFilterFlag = FilterDataExtender.FILTERFLAG_GROUP_0;
		
		for (var i=0; i<groupData.length; i++, c++) {
			if (c == GROUP_SIZE) {
				curFilterFlag = curFilterFlag << 1;
				c = 0;
			}
			
			var formId: Number = groupData[i];
			if (formId) {
				var t = _formIdMap[formId];
				if (t != null)
					t.filterFlag |= curFilterFlag;
				// Lookup failed? We help Papyrus with the cleanup by notifying it about the invalid item
				else
					reportInvalidItem(formId);
			}
		}
	}
  
	private function processMainHandData(): Void
	{
		// Set filterFlags for group membership
		for (var i=0; i<mainHandData.length; i++) {
			var formId: Number = mainHandData[i];
			if (formId) {
				var t = _formIdMap[formId];
				if (t != null)
					t.mainHandFlag |= 1 << i;
				else
					reportInvalidItem(formId);
			}
		}
	}
	
	private function processOffHandData(): Void
	{
		// Set filterFlags for group membership
		for (var i=0; i<offHandData.length; i++) {
			var formId: Number = offHandData[i];
			if (formId) {
				var t = _formIdMap[formId];
				if (t != null)
					t.offHandFlag |= 1 << i;
				else
					reportInvalidItem(formId);
			}
		}
	}

	private function processIconData(): Void
	{
		// Set icons (assumes iconDataExtender already set iconLabel)
		for (var i=0; i<iconData.length; i++) {
			var iconLabel: String;
			var formId: Number = iconData[i];
			if (formId) {
				var t = _formIdMap[formId];
				if (t != null) {
					iconLabel = t.iconLabel ? t.iconLabel : "misc_default";
				} else {
					iconLabel = "misc_default";
					reportInvalidItem(formId);
				}
			} else {
				iconLabel = "none";
			}
			_groupButtons[i].itemIcon.gotoAndStop(iconLabel);
		}
	}
	
	private function reportInvalidItem(a_formId: Number): Void
	{
		for (var i=0; i<_invalidForms.length; i++)
			if (_invalidForms[i] == a_formId)
					return;
		
		_invalidForms.push(a_formId);
		skse.SendModEvent("SKIFM_foundInvalidItem", "", 0, a_formId);
	}
}