/*
 *  Basic list API expected by the game.
 */

// @abstract
class skyui.components.list.BSList extends MovieClip
{
  /* PROPERTIES */
  
  	// Entries of the list, represented by dynamic objects.
	// When the internal representation of the entry list, changes are pushed directly into entryList.
	// As such, the order of this array should not be modified for certain lists.
	private var _entryList: Array;
	
	public function get entryList(): Array
	{
		return _entryList;
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
	// @abstract
	public function InvalidateData(): Void { }
	
	// Redraws the list.
	// @abstract
	public function UpdateList(): Void { }
}