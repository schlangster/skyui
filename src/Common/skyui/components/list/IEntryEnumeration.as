/*
 *  An enumeration of list entries.
 */
interface skyui.components.list.IEntryEnumeration
{
	// Returns the number of entries the enumeration contains.
	public function size(): Number;
	
	// Returns the ith element of the enumeration.
	public function at(index: Number): Object;
	
	// Get the entry index associated with a given enum index for a given enum index.
	public function lookupEntryIndex(enumIndex: Number): Number;
	
	// Get the entry index associated with a given enum index for a given entry index.
	public function lookupEnumIndex(entryIndex: Number): Number;
	
	// The underlying data has been modified.
	public function invalidate(): Void;
}