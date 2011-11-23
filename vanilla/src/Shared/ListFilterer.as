import gfx.events.EventDispatcher;

class Shared.ListFilterer
{
	private var _itemFilter;
	private var _filterArray:Array;

	var EntryMatchesFunc:Function;
	var dispatchEvent:Function;

	function ListFilterer()
	{
		_itemFilter = 4294967295;
		EntryMatchesFunc = EntryMatchesFilter;
		EventDispatcher.initialize(this);
	}

	function get itemFilter()
	{
		return _itemFilter;
	}

	function set itemFilter(a_newFilter)
	{
		var changed = _itemFilter != a_newFilter;
		_itemFilter = a_newFilter;

		if (changed == true) {
			dispatchEvent({type:"filterChange"});
		}
	}

	function get filterArray()
	{
		return _filterArray;
	}

	function set filterArray(a_newArray)
	{
		_filterArray = a_newArray;
	}

	function SetPartitionedFilterMode(a_bPartition)
	{
		EntryMatchesFunc = a_bPartition ? EntryMatchesPartitionedFilter : EntryMatchesFilter;
	}

	function EntryMatchesFilter(a_entry)
	{
		return a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & _itemFilter) != 0);
	}

	function EntryMatchesPartitionedFilter(a_entry)
	{
		var _loc3 = false;
		if (a_entry != undefined) {
			if (_itemFilter == 4294967295) {
				_loc3 = true;
			} else {
				var _loc2 = a_entry.filterFlag;
				var _loc4 = _loc2 & 255;
				var _loc7 = (_loc2 & 65280) >>> 8;
				var _loc6 = (_loc2 & 16711680) >>> 16;
				var _loc5 = (_loc2 & 4278190080) >>> 24;
				_loc3 = _loc4 == _itemFilter || _loc7 == _itemFilter || _loc6 == _itemFilter || _loc5 == _itemFilter;
			}
		}
		return (_loc3);
	}

	function GetPrevFilterMatch(a_startIndex)
	{
		var _loc3;
		if (a_startIndex != undefined) {
			for (var _loc2 = a_startIndex - 1; _loc2 >= 0 && _loc3 == undefined; --_loc2) {
				if (EntryMatchesFunc(_filterArray[_loc2])) {
					_loc3 = _loc2;
				}
			}
		}
		return (_loc3);
	}

	function GetNextFilterMatch(a_startIndex)
	{
		var _loc3;
		if (a_startIndex != undefined) {
			for (var _loc2 = a_startIndex + 1; _loc2 < _filterArray.length && _loc3 == undefined; ++_loc2) {
				if (EntryMatchesFunc(_filterArray[_loc2])) {
					_loc3 = _loc2;
				}
			}
		}

		return (_loc3);
	}

	function ClampIndex(a_startIndex)
	{
		var index = a_startIndex;

		if (index != undefined && !EntryMatchesFunc(_filterArray[index])) {
			var nextIndex = GetNextFilterMatch(index);

			if (nextIndex == undefined) {
				nextIndex = GetPrevFilterMatch(index);
			}

			if (nextIndex == undefined) {
				nextIndex = -1;
			}
			index = nextIndex;
		}
		return index;
	}
}