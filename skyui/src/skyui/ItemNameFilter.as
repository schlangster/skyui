import gfx.events.EventDispatcher;


class skyui.ItemNameFilter implements skyui.IFilter
{
	private var _filterText:String;

	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function ItemNameFilter()
	{
		EventDispatcher.initialize(this);
		_filterText = "";
	}

	function EntryMatchesFunc(a_entry):Boolean
	{
		var searchStr = a_entry.text.toLowerCase();

		var seekIndex = 0;
		var seek = false;

		for (var i = 0; i < searchStr.length; i++) {
			if (searchStr.charAt(i) == _filterText.charAt(seekIndex)) {
				if (!seek) {
					seek = true;
				}
				seekIndex++;

				if (seekIndex >= _filterText.length) {
					return true;
				}
			} else if (seek) {
				seek = false;
				seekIndex = 0;
			}
		}
		return false;
	}

	function get filterText():String
	{
		return _filterText;
	}

	function set filterText(a_filterText:String)
	{
		a_filterText = a_filterText.toLowerCase();
		
		var changed = a_filterText != _filterText;
		_filterText = a_filterText;

		if (changed == true) {
			dispatchEvent({type:"filterChange"});
		}

	}

	function process(a_filteredList:Array)
	{
		if (_filterText == undefined || _filterText == "") {
			return;
		}

		for (var i = 0; i < a_filteredList.length; i++) {
			if (!EntryMatchesFunc(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
}