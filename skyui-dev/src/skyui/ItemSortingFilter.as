import gfx.events.EventDispatcher;

class skyui.ItemSortingFilter implements skyui.IFilter
{
	private var _filterArray:Array;
	private var _sortAttributes:Array;
	private var _sortOptions:Array;

	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;

	function ItemSortingFilter()
	{
		EventDispatcher.initialize(this);
	}

	// Set both at once so we don't create 2 filter change events
	function setSortBy(a_sortAttributes:Array, a_sortOptions:Array)
	{
		var changed = _sortAttributes != a_sortAttributes || _sortOptions != a_sortOptions;
		_sortAttributes = a_sortAttributes;
		_sortOptions = a_sortOptions;

		if (changed) {
			dispatchEvent({type:"filterChange"});
		}
	}

	function process(a_filteredList:Array)
	{
//		if (_sortBy == SORT_BY_NAME) {
//			a_filteredList.sortOn(["equipState", attr], [Array.NUMERIC | Array.DESCENDING, opt]);
//		} else {
			a_filteredList.sortOn(_sortAttributes, _sortOptions);
//		}
	}
}