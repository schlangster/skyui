import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;

import skyui.components.list.EntryClipManager;
import skyui.components.list.IEntryClipBuilder;
import skyui.components.list.BasicEntryFactory;
import skyui.components.list.IEntryEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.IListProcessor;
import skyui.components.list.BSList;
import skyui.components.list.ListState


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

  	private var _bRequestInvalidate: Boolean = false;
  	private var _bRequestUpdate: Boolean = false;
	private var _invalidateRequestID: Number;
	private var _updateRequestID: Number;
	
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
	
	/*
	// Removed 2012/12/18, use setPlatform()
	public function set platform(a_platform: Number)
	{
		_platform = a_platform;
		isMouseDrivenNav = _platform == PLATFORM_PC;
	}
	*/
	
	public var isMouseDrivenNav: Boolean = false;
	
	public var isListAnimating: Boolean = false;
	
	public var disableInput: Boolean = false;
	
	public var disableSelection: Boolean = false;
	
	public var isAutoUnselect: Boolean = false;
	
	public var canSelectDisabled: Boolean = false;

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
	
	public var listState: ListState;
	
	public function get itemCount(): Number
	{
		return getListEnumSize();
	}
	
	// The selected entry.
	public function get selectedClip(): Object
	{
		return _entryClipManager.getClip(selectedEntry.clipIndex);
	}
	
	
	private var _bSuspended: Boolean = false;
	
	public function get suspended(): Boolean
	{
		return _bSuspended;
	}
	
	public function set suspended(a_flag: Boolean)
	{
		if (_bSuspended == a_flag)
			return;
		
		// Lock
		if (a_flag) {
			_bSuspended = true;
		} else {
			_bSuspended = false;
			
			if (_bRequestInvalidate)
				InvalidateData();
			else if(_bRequestUpdate)
				UpdateList();

			_bRequestInvalidate = false;
			_bRequestUpdate = false;
			
			// Allow custom handlers
			if (onUnsuspend != undefined)
				onUnsuspend();
		}
	}
	
	
  /* INITIALIZATION */
  
	public function BasicList()
	{
		super();
		
		_entryClipManager = new EntryClipManager(this);
		_dataProcessors = [];
		listState = new ListState(this);

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

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		isMouseDrivenNav = _platform == PLATFORM_PC;
	}
	
	// Custom handlers
	public var onUnsuspend: Function;
	public var onInvalidate: Function;
	
	public function addDataProcessor(a_dataProcessor: IListProcessor): Void
	{
		_dataProcessors.push(a_dataProcessor);
	}
	
	public function clearList(): Void
	{
		_entryList.splice(0);
	}
	
	public function requestInvalidate(): Void
	{
		_bRequestInvalidate = true;
		
		// Invalidate request replaces update request
		if (_updateRequestID) {
			_bRequestUpdate = false;
			clearInterval(_updateRequestID);
			delete _updateRequestID;
		}
		
		// If suspsend, the unsuspend will trigger the requested invaliate.
		if (!_bSuspended && !_invalidateRequestID)
			_invalidateRequestID = setInterval(this, "commitInvalidate", 1);
	}
	
	public function requestUpdate(): Void
	{
		_bRequestUpdate = true;
		
		// Invalidate already requested? Includes update
		if (_invalidateRequestID)
			return;
			
		// If suspsend, the unsuspend will trigger the requested invaliate.
		if (!_bSuspended && !_invalidateRequestID)
			_updateRequestID = setInterval(this, "commitUpdate", 1);
	}
	
	public function commitInvalidate(): Void
	{
		clearInterval(_invalidateRequestID);
		delete _invalidateRequestID;
		
		// Invalidate request replaces update request
		if (_updateRequestID) {
			_bRequestUpdate = false;
			clearInterval(_updateRequestID);
			delete _updateRequestID;
		}
		
		_bRequestInvalidate = false;
		InvalidateData();
	}
	
	public function commitUpdate(): Void
	{
		clearInterval(_updateRequestID);
		delete _updateRequestID;
		
		_bRequestUpdate = false;
		UpdateList();
	}
	
	// @override BSList
	public function InvalidateData(): Void
	{
		if (_bSuspended) {
			_bRequestInvalidate = true;
			return;
		}
		
		for (var i = 0; i < _entryList.length; i++) {
			_entryList[i].itemIndex = i;
			_entryList[i].clipIndex = undefined;
		}
		
		for (var i=0; i<_dataProcessors.length; i++)
			_dataProcessors[i].processList(this);
		
		listEnumeration.invalidate();
		
		if (_selectedIndex >= listEnumeration.size())
			_selectedIndex = listEnumeration.size() - 1;

		UpdateList();
		
		if (onInvalidate)
			onInvalidate();
	}

	// @override BSList
	// @abstract
	public function UpdateList(): Void { }
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		if (a_keyboardOrMouse == undefined)
			a_keyboardOrMouse = SELECT_KEYBOARD;
			
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1 || a_buttonIndex != 1)
			return;
			
		if (a_keyboardOrMouse == undefined)
			a_keyboardOrMouse = SELECT_KEYBOARD;
		
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemRollOver(a_index: Number): Void
	{
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(a_index, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}

	private function onItemRollOut(a_index: Number): Void
	{
		if (!isAutoUnselect)
			return;
		
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(-1, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableSelection || a_newIndex == _selectedIndex)
			return;
			
		// Selection is not contained in current entry enumeration, ignore
		if (a_newIndex != -1 && getListEnumIndex(a_newIndex) == undefined)
			return;
			
		var oldIndex = _selectedIndex;
		_selectedIndex = a_newIndex;

		if (oldIndex != -1) {
			var clip = _entryClipManager.getClip(_entryList[oldIndex].clipIndex);
			clip.setEntry(_entryList[oldIndex], listState);
		}

		if (_selectedIndex != -1) {
			var clip = _entryClipManager.getClip(_entryList[_selectedIndex].clipIndex);
			clip.setEntry(_entryList[_selectedIndex], listState);
		}

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