import gfx.events.EventDispatcher;

class Shared.ListFilterer
{
    var iItemFilter;
	var EntryMatchesFunc;
	var _filterArray;
	
	var dispatchEvent:Function;
	
    function ListFilterer()
    {
        iItemFilter = 4294967295.000000;
        EntryMatchesFunc = EntryMatchesFilter;
        EventDispatcher.initialize(this);
    }
	
    function get itemFilter()
    {
        return iItemFilter;
    }
	
    function set itemFilter(aiNewFilter)
    {
        var changed = iItemFilter != aiNewFilter;
        iItemFilter = aiNewFilter;
		
        if (changed == true)
        {
            dispatchEvent({type: "filterChange"});
        }
    }
	
    function get filterArray()
    {
        return _filterArray;
    }
	
    function set filterArray(aNewArray)
    {
        _filterArray = aNewArray;
    }
	
    function SetPartitionedFilterMode(abPartition)
    {
        EntryMatchesFunc = abPartition ? (EntryMatchesPartitionedFilter) : (EntryMatchesFilter);
    }
	
    function EntryMatchesFilter(aEntry)
    {
        return (aEntry != undefined && (aEntry.filterFlag == undefined || (aEntry.filterFlag & iItemFilter) != 0));
    }
	
    function EntryMatchesPartitionedFilter(aEntry)
    {
        var _loc3 = false;
        if (aEntry != undefined)
        {
            if (iItemFilter == 4294967295.000000)
            {
                _loc3 = true;
            }
            else
            {
                var _loc2 = aEntry.filterFlag;
                var _loc4 = _loc2 & 255;
                var _loc7 = (_loc2 & 65280) >>> 8;
                var _loc6 = (_loc2 & 16711680) >>> 16;
                var _loc5 = (_loc2 & 4278190080.000000) >>> 24;
                _loc3 = _loc4 == iItemFilter || _loc7 == iItemFilter || _loc6 == iItemFilter || _loc5 == iItemFilter;
            }
        }
        return (_loc3);
    }
	
    function GetPrevFilterMatch(aiStartIndex)
    {
        var _loc3;
        if (aiStartIndex != undefined)
        {
            for (var _loc2 = aiStartIndex - 1; _loc2 >= 0 && _loc3 == undefined; --_loc2)
            {
                if (this.EntryMatchesFunc(_filterArray[_loc2]))
                {
                    _loc3 = _loc2;
                }
            }
        }
        return (_loc3);
    }
	
    function GetNextFilterMatch(aiStartIndex)
    {
        var _loc3;
        if (aiStartIndex != undefined)
        {
            for (var _loc2 = aiStartIndex + 1; _loc2 < _filterArray.length && _loc3 == undefined; ++_loc2)
            {
                if (this.EntryMatchesFunc(_filterArray[_loc2]))
                {
                    _loc3 = _loc2;
                }
            }
        }
		
        return (_loc3);
    }
	
    function ClampIndex(aiStartIndex)
    {
        var _loc2 = aiStartIndex;
        if (aiStartIndex != undefined && !this.EntryMatchesFunc(_filterArray[_loc2]))
        {
            var _loc3 = this.GetNextFilterMatch(_loc2);
            if (_loc3 == undefined)
            {
                _loc3 = this.GetPrevFilterMatch(_loc2);
            }
			
            if (_loc3 == undefined)
            {
                _loc3 = -1;
            }
            _loc2 = _loc3;
        }
        return (_loc2);
    }
}
