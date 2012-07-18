import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;

import skyui.components.list.EntryClipManager;
import skyui.components.list.IEntryClipBuilder;
import skyui.components.list.BasicEntryFactory;
import skyui.components.list.IEntryEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.IEntryFormatter;
import skyui.components.list.IListProcessor;
import skyui.components.list.BSList;


// @abstract
class skyui.components.list.BasicList extends BSList
{
  /* CONSTANTS */
  
	public static var PLATFORM_PC = 0;

	public static var SELECT_MOUSE = 0;
	public static var SELECT_KEYBOARD = 1;

	
  /* STAGE ELEMENTS */

	public var background: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
  	private var _bUpdateRequested: Boolean = false;
	
	private var _entryClipManager: EntryClipManager;
	
	private var _dataProcessors: Array;
	

  /* PROPERTIES */
  
  	public var topBorder: Number = 0;
	public var bottomBorder: Number = 0;
	public var leftBorder: Number = 0;
	public var rightBorder: Number = 0;
	
	public function get width(): Number
	{
		return background._width;
	}
	
	public function set width(a_val: Number)
	{
		background._width = a_val;
	}
	
	public function get height(): Number
	{
		return background._height;
	}
	
	public function set height(a_val: Number)
	{
		background._height = a_val;
	}
  
	private var _platform: Number = PLATFORM_PC;
	
	public function get platform(): Number
	{
		return _platform;
	}
	
	public function set platform(a_platform: Number)
	{
		_platform = a_platform;
		isMouseDrivenNav = _platform == PLATFORM_PC;
	}
	
	public var isMouseDrivenNav: Boolean = false;
	
	public var isListAnimating: Boolean = false;
	
	public var disableInput: Boolean = false;
	
	public var disableSelection: Boolean = false;
	
	public var isAutoUnselect: Boolean = false;

	// @override BSList
	public function get selectedIndex(): Number
	{
		return _selectedIndex;
	}
	
	// @override BSList
	public function set selectedIndex(a_newIndex: Number)
	{
		doSetSelectedIndex(a_newIndex, SELECT_MOUSE);
	}
	
	public var entryRenderer: String;
	
	public var listEnumeration: IEntryEnumeration;
	
	public var entryFormatter: IEntryFormatter;
	
	public function get itemCount(): Number
	{
		return getListEnumSize();
	}
	
	// The selected entry.
	public function get selectedClip(): Object
	{
		return _entryClipManager.getClip(selectedEntry.clipIndex);
	}
	
	
  /* CONSTRUCTORS */
  
	public function BasicList()
	{
		super();
		
		_entryClipManager = new EntryClipManager(this);
		_dataProcessors = [];

		EventDispatcher.initialize(this);
		Mouse.addListener(this);
	}

	
  /* PUBLIC FUNCTIONS */
  
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	// Queue an update for the next frame to avoid multiple updates in this one.
	// If timing is imporant (like for scrolling), use UpdateList() directly.
	public function requestUpdate(): Void
	{
//		_bUpdateRequested = true;
// TODO optimize this later, for now lets get everything working
		UpdateList();
	}
	
	public function addDataProcessor(a_dataProcessor: IListProcessor): Void
	{
		_dataProcessors.push(a_dataProcessor);
	}
	
	public function clearList(): Void
	{
		_entryList.splice(0);
	}
	
	var updateCount = 0;
	
	// @override MovieClip
	public function onEnterFrame(): Void
	{
		if (updateCount > 0)
			skse.Log("Update count was " + updateCount);
		updateCount = 0;
		
		if (!_bUpdateRequested)
			return;
			
		_bUpdateRequested = false;
		UpdateList();
	}
	
	// @override BSList
	public function InvalidateData(): Void
	{
		for (var i = 0; i < _entryList.length; i++) {
			_entryList[i].itemIndex = i;
			_entryList[i].clipIndex = undefined;
		}
		
		for (var i=0; i<_dataProcessors.length; i++)
			_dataProcessors[i].processList(this);
		
		listEnumeration.invalidate();
		
		if (_selectedIndex >= listEnumeration.size())
			_selectedIndex = listEnumeration.size() - 1;

		requestUpdate();
	}

	// @override BSList
	// @abstract
	public function UpdateList(): Void { }
	
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1 || a_buttonIndex != 1)
			return;
		
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	public function onItemRollOver(a_index: Number): Void
	{
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(a_index, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}

	public function onItemRollOut(a_index: Number): Void
	{
		if (!isAutoUnselect)
			return;
		
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(-1, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableSelection || a_newIndex == _selectedIndex)
			return;
			
		// Selection is not contained in current entry enumeration, ignore
		if (a_newIndex != -1 && getListEnumIndex(a_newIndex) == undefined)
			return;
			
		var oldIndex = _selectedIndex;
		_selectedIndex = a_newIndex;

		if (oldIndex != -1)
			setEntry(_entryClipManager.getClip(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);

		if (_selectedIndex != -1)
			setEntry(_entryClipManager.getClip(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);

		dispatchEvent({type: "selectionChange", index: _selectedIndex, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function getClipByIndex(a_index: Number): MovieClip
	{
		return _entryClipManager.getClip(a_index);
	}
	
	private function setClipCount(a_count: Number)
	{
		_entryClipManager.clipCount = a_count;
	}
	
	private function setEntry(a_entryClip: MovieClip, a_entryObject: Object)
	{
		entryFormatter.setEntry(a_entryClip, a_entryObject);
	}
	
	private function getSelectedListEnumIndex(): Number
	{
		return listEnumeration.lookupEnumIndex(_selectedIndex);
	}
	
	private function getListEnumIndex(a_index: Number): Number
	{
		return listEnumeration.lookupEnumIndex(a_index);
	}
	
	private function getListEntryIndex(a_index: Number): Number
	{
		return listEnumeration.lookupEntryIndex(a_index);
	}
	
	private function getListEnumSize(): Number
	{
		return listEnumeration.size();
	}
	
	private function getListEnumEntry(a_index: Number): Object
	{
		return listEnumeration.at(a_index);
	}
	
	private function getListEnumPredecessorIndex(): Number
	{
		return listEnumeration.lookupEntryIndex(getSelectedListEnumIndex() - 1);
	}
	
	private function getListEnumSuccessorIndex(): Number
	{
		return listEnumeration.lookupEntryIndex(getSelectedListEnumIndex() + 1);
	}
	
	private function getListEnumFirstIndex(): Number
	{
		return listEnumeration.lookupEntryIndex(0);
	}
	
	private function getListEnumLastIndex(): Number
	{
		return listEnumeration.lookupEntryIndex(getListEnumSize() - 1);
	}
	
	private function getListEnumRelativeIndex(a_offset: Number): Number
	{
		return listEnumeration.lookupEntryIndex(getSelectedListEnumIndex() + a_offset);
	}
}