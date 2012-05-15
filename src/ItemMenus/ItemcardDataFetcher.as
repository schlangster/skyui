import gfx.io.GameDelegate;

import skyui.components.list.BasicList;
import skyui.components.list.IDataFetcher;


// @abstract
class ItemcardDataFetcher implements IDataFetcher
{
  /* PRIVATE VARIABLES */
  
	private var _itemInfo: Object;
	private var _requestItemInfo: Function;
	
	
  /* CONSTRUCTORS */
	
	public function ItemcardDataFetcher(a_list: BasicList)
	{
		_requestItemInfo = function(a_target: Object, a_index: Number): Void
		{
			var oldIndex = this._selectedIndex;
			this._selectedIndex = a_index;
			GameDelegate.call("RequestItemCardInfo", [], a_target, "updateItemInfo");
			this._selectedIndex = oldIndex;
		};
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function updateItemInfo(a_updateObj: Object): Void
	{
		_itemInfo = a_updateObj;
	}
	
  	// @override IDataFetcher
	public function processEntries(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			// Hack to retrieve itemcard info
			_requestItemInfo.apply(a_list, [this, i]);
			processEntry(entryList[i], _itemInfo);
		}
	}
	
	// @abstract
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void {}
}