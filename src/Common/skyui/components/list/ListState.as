import skyui.components.list.BasicList;

/*
 * Used to dynamically add additional properties to a list that are passed
 * along to IListEntry.setData(), i.e. activeEntry.
 */

dynamic class skyui.components.list.ListState
{
	public function ListState(a_list: BasicList)
	{
		list = a_list;
	}
	
	// Parent list
	public var list: BasicList;

	// ...
}