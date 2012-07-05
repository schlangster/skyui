import gfx.events.EventDispatcher;

class Shared.ListFilterer
{
	var EntryMatchesFunc: Function;
	var _filterArray: Array;
	var dispatchEvent: Function;
	var addEventListener: Function;
	var iItemFilter: Number;

	function ListFilterer()
	{
		iItemFilter = 0xFFFFFFFF;
		EntryMatchesFunc = EntryMatchesFilter;
		EventDispatcher.initialize(this);
	}

	function get itemFilter(): Number
	{
		return iItemFilter;
	}

	function set itemFilter(aiNewFilter: Number): Void
	{
		var bfilterChanged: Boolean = iItemFilter != aiNewFilter;
		iItemFilter = aiNewFilter;
		if (bfilterChanged == true) 
			dispatchEvent({type: "filterChange"});
	}

	function get filterArray(): Array
	{
		return _filterArray;
	}

	function set filterArray(aNewArray: Array): Void
	{
		_filterArray = aNewArray;
	}

	function SetPartitionedFilterMode(abPartition: Boolean): Void
	{
		EntryMatchesFunc = abPartition ? EntryMatchesPartitionedFilter : EntryMatchesFilter;
	}

	function EntryMatchesFilter(aEntry: Object): Boolean
	{
		return aEntry != undefined && (aEntry.filterFlag == undefined || (aEntry.filterFlag & iItemFilter) != 0);
	}

	function EntryMatchesPartitionedFilter(aEntry: Object): Boolean
	{
		var bmatchFound = false;
		if (aEntry != undefined) {
			if (iItemFilter == 0xFFFFFFFF) {
				bmatchFound = true;
			} else {
				var ifilterFlag: Number = aEntry.filterFlag;
				var byte0: Number = (ifilterFlag & 0x000000FF);
				var byte1: Number = (ifilterFlag & 0x0000FF00) >>> 8;
				var byte2: Number = (ifilterFlag & 0x00FF0000) >>> 16;
				var byte3: Number = (ifilterFlag & 0xFF000000) >>> 24;
				bmatchFound = byte0 == iItemFilter || byte1 == iItemFilter || byte2 == iItemFilter || byte3 == iItemFilter;
			}
		}
		return bmatchFound;
	}

	function GetPrevFilterMatch(aiStartIndex: Number): Number
	{
		var iPrevMatch: Number = undefined;
		if (aiStartIndex != undefined) 
			for (var i = aiStartIndex - 1; i >=0 && iPrevMatch == undefined; i--)
				if (EntryMatchesFunc(_filterArray[i]))
					iPrevMatch = i;
		return iPrevMatch;
	}

	function GetNextFilterMatch(aiStartIndex: Number): Number
	{
		var iNextMatch: Number = undefined;
		if (aiStartIndex != undefined) 
			for (var i = aiStartIndex + 1; i < _filterArray.length && iNextMatch == undefined; i++)
				if (EntryMatchesFunc(_filterArray[i])) 
					iNextMatch = i;
		return iNextMatch;
	}

	function ClampIndex(aiStartIndex: Number): Number
	{
		var iClampIndex = aiStartIndex;
		if (aiStartIndex != undefined && !EntryMatchesFunc(_filterArray[iClampIndex])) {
			var iNextMatch: Number = GetNextFilterMatch(iClampIndex);
			var iPrevMatch: Number = GetPrevFilterMatch(iClampIndex);
			if (iNextMatch == undefined) {
				if (iPrevMatch == undefined) 
					iClampIndex = -1;
				else
					iClampIndex = iPrevMatch;
			} else {
				iClampIndex = iNextMatch;
			}
			if (iNextMatch != undefined && iPrevMatch != undefined && iPrevMatch != iNextMatch && iClampIndex == iNextMatch && _filterArray[iPrevMatch].text == _filterArray[aiStartIndex].text)
				iClampIndex = iPrevMatch;
		}
		return iClampIndex;
	}

}
