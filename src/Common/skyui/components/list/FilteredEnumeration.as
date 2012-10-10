import skyui.filter.IFilter;
import skyui.components.list.BasicEnumeration;


class skyui.components.list.FilteredEnumeration extends BasicEnumeration
{
  /* PRIVATE VARIABLES */
  
	private var _filteredData: Array;
	private var _filterChain:Array;
	
	
  /* INITIALIZATION */
	
	public function FilteredEnumeration(a_data: Array)
	{
		super(a_data);
		
		_filterChain = [];
		_filteredData = [];
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function addFilter(a_filter:IFilter)
	{
		_filterChain.push(a_filter);
	}
	
	// @override skyui.BasicEnumeration
	public function size(): Number
	{
		return _filteredData.length;
	}
	
	// @override skyui.BasicEnumeration
	public function at(a_index: Number): Object
	{
		return _filteredData[a_index];
	}
	
	// @override skyui.IEntryEnumeration
	public function lookupEntryIndex(a_enumIndex: Number)
	{
		return _filteredData[a_enumIndex].itemIndex;
	}
	
	// @override skyui.IEntryEnumeration
	public function lookupEnumIndex(a_entryIndex: Number)
	{
		return _entryData[a_entryIndex].filteredIndex;
	}
	
	// The underlying entryData has been modified externally, so regenerate the enumeration.
	public function invalidate(): Void
	{
		applyFilters();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function applyFilters(): Void
	{
		_filteredData.splice(0);
		
		// Copy the original list, add some helper attributes for easy mapping
		for (var i = 0; i < _entryData.length; i++) {
			_entryData[i].filteredIndex = undefined;
			_filteredData[i] = _entryData[i];
		}

		// Apply filters
		for (var i = 0; i < _filterChain.length; i++)
			_filterChain[i].applyFilter(_filteredData);

		for (var i = 0; i < _filteredData.length; i++)
			_filteredData[i].filteredIndex = i;
	}
}