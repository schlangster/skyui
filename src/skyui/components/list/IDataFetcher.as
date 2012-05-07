import skyui.components.list.BasicList;


interface skyui.components.list.IDataFetcher
{
	function processEntries(a_list: BasicList): Void;
}