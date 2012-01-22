import gfx.events.EventDispatcher;

class skyui.ItemTypeFilter implements skyui.IFilter
{
	private var _itemFilter;
	private var _filterArray:Array;

	private var _matcherFunc:Function;

	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function ItemTypeFilter()
	{
		_itemFilter = 0xFFFFFFFF;
		_matcherFunc = entryMatchesFilter;
		
		EventDispatcher.initialize(this);
	}

	function get itemFilter():Number
	{
		return _itemFilter;
	}
	
	function changeFilterFlag(a_newFilter:Number, a_bDoNotUpdate:Boolean)
	{
		if (a_bDoNotUpdate == undefined) {
			a_bDoNotUpdate = false;
		}
		
		_itemFilter = a_newFilter;
		
		if (!a_bDoNotUpdate) {
			dispatchEvent({type:"filterChange"});
		}
	}

	function setPartitionedFilterMode(a_bPartition:Boolean)
	{
		_matcherFunc = a_bPartition ? entryMatchesPartitionedFilter : entryMatchesFilter;
	}

	function entryMatchesFilter(a_entry:Object):Boolean
	{
		return (a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & _itemFilter) != 0));
	}

	function entryMatchesPartitionedFilter(a_entry:Object):Boolean
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

	function process(a_filteredList:Array)
	{
		for (var i = 0; i < a_filteredList.length; i++) {
			if (!_matcherFunc(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
}