import gfx.events.EventDispatcher;


class skyui.ItemNameFilter implements skyui.IFilter
{
	private var _nameFilter:String;

	var dispatchEvent:Function;
	var addEventListener:Function;

	function ItemNameFilter()
	{
		EventDispatcher.initialize(this);
		_nameFilter = "";
	}

	function EntryMatchesFunc(a_entry):Boolean
	{
		var searchStr = a_entry.text.toLowerCase();

		var seekIndex = 0;
		var seek = false;

		for (var i = 0; i < searchStr.length; i++) {
			if (searchStr.charAt(i) == _nameFilter.charAt(seekIndex)) {
				if (!seek) {
					seek = true;
				}
				seekIndex++;

				if (seekIndex >= _nameFilter.length) {
					return true;
				}
			} else if (seek) {
				return false;
			}
		}
		return false;
	}

	function get nameFilter():String
	{
		return _nameFilter;
	}

	function set nameFilter(a_nameFilter:String)
	{
		var changed = a_nameFilter != _nameFilter;
		_nameFilter = a_nameFilter;

		if (changed == true) {
			dispatchEvent({type:"filterChange"});
		}

	}

	function process(a_entryList:Array, a_indexMap:Array)
	{
		if (_nameFilter == undefined || _nameFilter == "") {
			return;
		}

		for (var i = 0; i < a_indexMap.length; i++) {
			if (!EntryMatchesFunc(a_entryList[a_indexMap[i]])) {
				a_indexMap.splice(i,1);
				i--;
			}
		}
	}
}