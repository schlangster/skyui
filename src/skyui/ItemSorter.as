import gfx.events.EventDispatcher;

class skyui.ItemSorter
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
  
    // mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
    // mixin by gfx.events.EventDispatcher
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

	// override skyui.IFilter
	public function process(a_filteredList: Array)
	{
		a_filteredList.sortOn(_sortAttributes, _sortOptions);
	}
}