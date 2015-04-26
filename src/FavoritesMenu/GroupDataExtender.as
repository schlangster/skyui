import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


class GroupDataExtender implements IListProcessor
{ 
  /* CONSTANTS */
  
  	public static var GROUP_SIZE = 32;
	

  /* PRIVATE VARIABLES */
  
	private var _itemIdMap: Object;
	
	private var _groupButtons: Array;
	
	private var _invalidItems: Array;


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
		
		_itemIdMap = {};
		
		_invalidItems = [];
		
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
		
		// Create map for itemid->entry, clear group filter flags
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			e.filterFlag &= ~clearFlag;
			e.mainHandFlag = 0;
			e.offHandFlag = 0;
			
			if (e.itemId != undefined)
				_itemIdMap[e.itemId] = e;
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
			
			var itemId: Number = groupData[i];
			if (itemId) {
				var t = _itemIdMap[itemId];
				if (t != null)
					t.filterFlag |= curFilterFlag;
				// Lookup failed? We help Papyrus with the cleanup by notifying it about the invalid item
				else
					reportInvalidItem(itemId);
			}
		}
	}
  
	private function processMainHandData(): Void
	{
		// Set filterFlags for group membership
		for (var i=0; i<mainHandData.length; i++) {
			var itemId: Number = mainHandData[i];
			if (itemId) {
				var t = _itemIdMap[itemId];
				if (t != null)
					t.mainHandFlag |= 1 << i;
				else
					reportInvalidItem(itemId);
			}
		}
	}
	
	private function processOffHandData(): Void
	{
		// Set filterFlags for group membership
		for (var i=0; i<offHandData.length; i++) {
			var itemId: Number = offHandData[i];
			if (itemId) {
				var t = _itemIdMap[itemId];
				if (t != null)
					t.offHandFlag |= 1 << i;
				else
					reportInvalidItem(itemId);
			}
		}
	}

	private function processIconData(): Void
	{
		// Set icons (assumes iconDataExtender already set iconLabel)
		for (var i=0; i<iconData.length; i++) {
			var iconLabel: String;
			var itemId: Number = iconData[i];
			if (itemId) {
				var t = _itemIdMap[itemId];
				if (t != null) {
					iconLabel = t.iconLabel ? t.iconLabel : "misc_default";
				} else {
					iconLabel = "misc_default";
					reportInvalidItem(itemId);
				}
			} else {
				iconLabel = "none";
			}
			_groupButtons[i].itemIcon.gotoAndStop(iconLabel);
		}
	}
	
	private function reportInvalidItem(a_itemId: Number): Void
	{
		for (var i=0; i<_invalidItems.length; i++)
			if (_invalidItems[i] == a_itemId)
					return;
		
		_invalidItems.push(a_itemId);
		skse.SendModEvent("SKIFM_foundInvalidItem", String(a_itemId));
	}
}