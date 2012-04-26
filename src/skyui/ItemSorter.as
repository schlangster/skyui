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
  
    // @mixin gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
    // @mixin gfx.events.EventDispatcher
	public var addEventListener: Function;

	// Change the filter attributes and options and trigger an update if necessary (and not supressed).
	public function setSortBy(a_sortAttributes: Array, a_sortOptions: Array, a_bNoUpdate: Boolean)
	{
		if (a_bNoUpdate == undefined) {
			a_bNoUpdate = false;
		}

		// Set attributes and options at once so we don't create 2 filter change events.
		var changed = _sortAttributes != a_sortAttributes || _sortOptions != a_sortOptions;
		_sortAttributes = a_sortAttributes;
		_sortOptions = a_sortOptions;

		if (changed && !a_bNoUpdate) {
			dispatchEvent({type: "filterChange"});
		}
	}

	// @override skyui.IFilter
	public function applyFilter(a_filteredList: Array): Void
	{
		a_filteredList.sortOn(_sortAttributes, _sortOptions);
	}
}