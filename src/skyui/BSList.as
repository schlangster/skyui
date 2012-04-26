/*
 *  Basic list API expected by the game.
 */

class skyui.BSList extends MovieClip
{
  /* PROPERTIES */
  
  	// Entries of the list, represented by dynamic objects.
	// When the internal representation of the entry list, changes are pushed directly into entryList.
	// As such, this list should be treated as read-only.
	// NOTE: To push the entryList, the game doesn't necessarily use the setter, so don't expect it to be executed.
	private var _entryList: Array;
	
	public function get entryList(): Array
	{
		return _entryList;
	}

	public function set entryList(a_newArray: Array)
	{
		_entryList = a_newArray;
	}

	// Indicates the selected index and is read by the game directly.
	private var _selectedIndex: Number;
	
	public function get selectedIndex(): Number
	{
		return _selectedIndex;
	}

	function set selectedIndex(a_newIndex: Number)
	{
		_selectedIndex = a_newIndex;
	}
	
	// The selected entry.
	public function get selectedEntry(): Object
	{
		return _entryList[_selectedIndex];
	}
	
	
  /* CONSTRUCTORS */
  
	public function BSList()
	{
		_entryList = new Array();
		_selectedIndex = -1;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// Indicates that entryList has been updated.
	public function InvalidateData(): Void
	{
		// abstract
	}
	
	// Redraws the list.
	public function UpdateList(): Void
	{
		// abstract
	}
}