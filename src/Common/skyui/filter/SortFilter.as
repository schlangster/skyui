import gfx.events.EventDispatcher;

import skyui.filter.IFilter;


class skyui.filter.SortFilter implements skyui.filter.IFilter
{
  /* PRIVATE VARIABLES */
  
	private var _sortAttributes: Array;
	private var _sortOptions: Array;


  /* INITIALIZATION */

	public function SortFilter()
	{
		EventDispatcher.initialize(this);
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

	// Change the filter attributes and options and trigger an update if necessary.
	public function setSortBy(a_sortAttributes: Array, a_sortOptions: Array): Void
	{
		if (_sortAttributes == a_sortAttributes && _sortOptions == a_sortOptions)
			return;
			
		_sortAttributes = a_sortAttributes;
		_sortOptions = a_sortOptions;
		
		dispatchEvent({type: "filterChange"});
	}

	// @override skyui.IFilter
	public function applyFilter(a_filteredList: Array): Void
	{
		var primaryAttribute = _sortAttributes[0];
		
		for (var i=0; i<a_filteredList.length; i++) {
			var t = a_filteredList[i][primaryAttribute];
			if (t == null)
				a_filteredList[i]._sortFlag = 1;
			else
				a_filteredList[i]._sortFlag = 0;
		}

		_sortAttributes.unshift("enabled");
		_sortOptions.unshift(Array.NUMERIC | Array.DESCENDING);

		_sortAttributes.unshift("_sortFlag");
		_sortOptions.unshift(Array.NUMERIC);
		
		a_filteredList.sortOn(_sortAttributes, _sortOptions);
		
		_sortAttributes.shift();
		_sortOptions.shift();
		
		_sortAttributes.shift();
		_sortOptions.shift();
	}
}