import gfx.events.EventDispatcher;

class dui.ItemTypeFilter implements dui.IFilter
{
    private var _itemFilter;
	private var _filterArray:Array;
	
	var EntryMatchesFunc:Function;
	var dispatchEvent:Function;
	
	
		var debug;
		
	function ItemTypeFilter()
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
		
        if (changed == true)
        {
            dispatchEvent({type: "filterChange"});
        }
    }
	
    function setPartitionedFilterMode(a_bPartition)
    {
        EntryMatchesFunc = a_bPartition ? EntryMatchesPartitionedFilter : EntryMatchesFilter;
    }
	
    function EntryMatchesFilter(a_entry)
    {
        return (a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & _itemFilter) != 0));
    }
	
    function EntryMatchesPartitionedFilter(a_entry)
    {
        var _loc3 = false;
        if (a_entry != undefined)
        {
            if (_itemFilter == 4294967295)
            {
                _loc3 = true;
            }
            else
            {
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

	
	function process(a_entryList:Array, a_indexMap:Array, a_debug)
	{
		
		debug = a_debug;
		
		var size = a_indexMap.length;
		
		for (var i = 0; i < a_indexMap.length; i++)
		{
			if (! EntryMatchesFunc(a_entryList[a_indexMap[i]]))
			{
				a_indexMap.splice(i, 1);
				i--;
			}
		}
		
		debug.textField.SetText("filter chain " + _itemFilter + " " + size + " " + a_indexMap.length);
	}
}
