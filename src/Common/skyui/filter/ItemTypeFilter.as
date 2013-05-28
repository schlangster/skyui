import gfx.events.EventDispatcher;

import skyui.filter.IFilter;


class skyui.filter.ItemTypeFilter implements IFilter
{
  /* PRIVATE VARIABLES */

	private var _filterArray:Array;
	private var _matcherFunc:Function;
	
	
  /* PROPERTIES */

	private var _itemFilter: Number = 0xFFFFFFFF;

	function get itemFilter():Number
	{
		return _itemFilter;
	}


  /* INITIALIZATION */

	public function ItemTypeFilter()
	{
		EventDispatcher.initialize(this);
		
		_matcherFunc = entryMatchesFilter;
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function changeFilterFlag(a_newFilter:Number, a_bDoNotUpdate: Boolean): Void
	{
		if (a_bDoNotUpdate == undefined)
			a_bDoNotUpdate = false;
		
		_itemFilter = a_newFilter;
		
		if (!a_bDoNotUpdate)
			dispatchEvent({type:"filterChange"});
	}

	public function setPartitionedFilterMode(a_bPartition: Boolean): Void
	{
		_matcherFunc = a_bPartition ? entryMatchesPartitionedFilter : entryMatchesFilter;
	}
	
	// @override skyui.IFilter
	public function applyFilter(a_filteredList: Array): Void
	{
		for (var i = 0; i < a_filteredList.length; i++) {
			if (!_matcherFunc(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function entryMatchesFilter(a_entry:Object): Boolean
	{
		return (a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & _itemFilter) != 0));
	}

	private function entryMatchesPartitionedFilter(a_entry:Object): Boolean
	{
		var matched = false;
		if (a_entry != undefined) {
			if (_itemFilter == 0xFFFFFFFF) {
				matched = true;
			} else {
				var flag = a_entry.filterFlag;
				matched = (flag & 0xFF) == _itemFilter || ((flag & 0xFF00) >>> 8) == _itemFilter
							|| ((flag & 0xFF0000) >>> 16) == _itemFilter || ((flag & 0xFF000000) >>> 24) == _itemFilter;
			}
		}
		return matched;
	}
}