import gfx.events.EventDispatcher;
import skyui.IFilter;

class skyui.ItemSorter implements skyui.IFilter
{
  /* PRIVATE VARIABLES */
  
	private var _sortAttributes: Array;
	private var _sortOptions: Array;


  /* CONSTRUCTORS */

	public function ItemSortingFilter()
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
	public function setSortBy(a_sortAttributes: Array, a_sortOptions: Array)
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
		a_filteredList.sortOn(_sortAttributes, _sortOptions);
	}
}