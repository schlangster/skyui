/*
 *  An enumeration of list entries.
 *
 *  This is meant to provide an abstraction over a list of things
 *  so we have the opporunity to provide a filtered or remapped
 *  view of a list without having to actually reorder the
 *  elements.
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
