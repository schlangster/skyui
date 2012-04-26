import gfx.events.EventDispatcher;
import skyui.Util;


class skyui.ItemNameFilter implements skyui.IFilter
{
  /* PROPERTIES */
  
	private var _filterText: String;

	public function get filterText(): String
	{
		return _filterText;
	}

	public function set filterText(a_filterText: String)
	{
		a_filterText = a_filterText.toLowerCase();
		
		var changed = a_filterText != _filterText;
		_filterText = a_filterText;

		if (changed == true) {
			dispatchEvent({type:"filterChange"});
		}

	}
	
	
  /* CONSTRUCTORS */
	
	public function ItemNameFilter()
	{
		EventDispatcher.initialize(this);
		_filterText = "";
	}
	

  /* PUBLIC FUNCTIONS */

	// @override skyui.IFilter
	public function applyFilter(a_filteredList:Array): Void
	{
		if (_filterText == undefined || _filterText == "")
			return;

		for (var i = 0; i < a_filteredList.length; i++) {
			if (!isMatch(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
  
	// mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
	// mixin by gfx.events.EventDispatcher
	public var addEventListener: Function;


  /* PRIVATE FUNCTIONS */

	private function isMatch(a_entry: Object): Boolean
	{
		var searchStr = a_entry.text.toLowerCase();

		var seekIndex = 0;
		var seek = false;

		for (var i = 0; i < searchStr.length; i++) {
			var charCode = Util.mapUnicodeChar(_filterText.charCodeAt(seekIndex));
			
			if (searchStr.charCodeAt(i) == charCode) {
				if (!seek)
					seek = true;
					
				seekIndex++;

				if (seekIndex >= _filterText.length)
					return true;
					
			} else if (seek) {
				seek = false;
				seekIndex = 0;
			}
		}
		return false;
	}
}