import gfx.events.EventDispatcher;

class dui.ItemSortingFilter implements dui.IFilter
{
	static var SORT_BY_NAME = 0;
	static var SORT_BY_VALUE = 1;
	static var SORT_BY_WEIGHT = 2;
	static var SORT_BY_STAT = 3;

	private var _sortBy = 1;
	private var _bAscending = false;
	private var _filterArray:Array;

	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;

	function ItemSortingFilter()
	{
		EventDispatcher.initialize(this);
		
		var tmp = new Array();
		var idx = new Array();
		var names = [ "one", "two", "three", "four", "five" ];
		
		for (var i = 0; i < 5; i++) {
			tmp[i] = {text: names[i], _infoValue: i*10};
			idx[i] = i;
		}

		process(tmp, idx);
		

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

	function process(a_entryList:Array, a_indexMap:Array)
	{
		var a = new Array();
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

		for (var i = 0; i < a_indexMap.length; i++) {
			a[i] = {pos:a_indexMap[i], attr:a_entryList[a_indexMap[i]][attr]};
		}
				
		for (var i = 0; i < a_indexMap.length; i++) {
			trace(i + ": "+ a[i]["pos"] + ", " + a[i]["attr"]);
		}
		
		a.sortOn("attr", opt);
		
		for (var i = 0; i < a_indexMap.length; i++) {
			trace(i + ": "+ a[i]["pos"] + ", " + a[i]["attr"]);
		}
		
		for (var i = 0; i < a_indexMap.length; i++) {
			a_indexMap[i] = a[i].pos;
		}
	}
}