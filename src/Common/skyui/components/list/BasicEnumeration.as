import skyui.components.list.IEntryEnumeration;


class skyui.components.list.BasicEnumeration implements IEntryEnumeration
{
  /* PROPERTIES */
  
	private var _entryData: Array;
	
	public function set entryData(a_data: Array)
	{
		_entryData = a_data;
	}
	
	public function get entryData(): Array
	{
		return _entryData;
	}
	
	
  /* CONSTRUCTORS */
	
	public function BasicEnumeration(a_data: Array)
	{
		_entryData = a_data;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override skyui.IEntryEnumeration
	public function size(): Number
	{
		return _entryData.length;
	}
	
	// @override skyui.IEntryEnumeration
	public function at(a_index: Number): Object
	{
		return _entryData[a_index];
	}
	
	// @override skyui.IEntryEnumeration
	public function lookupEntryIndex(a_enumIndex: Number): Number
	{
		return a_enumIndex;
	}
	
	// @override skyui.IEntryEnumeration
	public function lookupEnumIndex(a_entryIndex: Number): Number
	{
		return a_entryIndex;
	}
	
	// @override skyui.IEntryEnumeration
	public function invalidate(): Void
	{
		// Do nothing.
	}
}