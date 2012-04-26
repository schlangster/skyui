class skyui.BasicEnumeration implements skyui.IEntryEnumeration
{
  /* PROPERTIES */
  
	private var _entryData: Array;
	
	public function set entryData(a_data: Array)
	{
		_entryData = a_data;
		invalidate();
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
	public function lookupEntryIndex(a_enumIndex: Number)
	{
		return a_enumIndex;
	}
	
	// @override skyui.IEntryEnumeration
	public function lookupEnumIndex(a_entryIndex: Number)
	{
		return a_entryIndex;
	}
	
	// The underlying entryData has been modified externally, so regenerate the enumeration.
	public function invalidate(): Void
	{
		// Abstract
	}
}