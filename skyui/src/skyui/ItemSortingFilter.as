import gfx.events.EventDispatcher;

class skyui.ItemSortingFilter implements skyui.IFilter
{
	static var SORT_BY_NAME = 0;
	static var SORT_BY_VALUE = 1;
	static var SORT_BY_WEIGHT = 2;
	static var SORT_BY_STAT = 3;

	private var _sortBy = 0;
	private var _bAscending = true;
	private var _filterArray:Array;

	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;

	function ItemSortingFilter()
	{
		EventDispatcher.initialize(this);
	}

	function setSortBy(a_sortBy:Number, a_bAscending:Boolean)
	{
		var changed = _sortBy != a_sortBy || _bAscending != a_bAscending;
		_sortBy = a_sortBy;
		_bAscending = a_bAscending;

		if (changed == true) {
			dispatchEvent({type:"filterChange"});
		}
	}

	function process(a_filteredList:Array)
	{
		var attr;
		var opt = 0;
		if (!_bAscending) {
			opt = opt | Array.DESCENDING;
		}

		switch (_sortBy) {
			case SORT_BY_NAME :
				attr = "text";
				opt = opt | Array.CASEINSENSITIVE;
				break;
			case SORT_BY_VALUE :
				attr = "_infoValue";
				opt = opt | Array.NUMERIC;
				break;
			case SORT_BY_WEIGHT :
				attr = "_infoWeight";
				opt = opt | Array.NUMERIC;
				break;
			case SORT_BY_STAT :
				attr = "_infoStat";
				opt = opt | Array.NUMERIC;
				break;
			default :
				attr = "text";
				opt = opt | Array.CASEINSENSITIVE;
		}
		
		if (_sortBy == SORT_BY_NAME) {
			a_filteredList.sortOn(["equipState", attr], [Array.NUMERIC | Array.DESCENDING, opt]);
		} else {
			a_filteredList.sortOn(attr, opt);
		}
	}
}