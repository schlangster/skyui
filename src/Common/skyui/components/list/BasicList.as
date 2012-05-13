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
import skyui.components.list.IDataFetcher;
import skyui.components.list.IListComponentInitializer;
import skyui.components.list.BSList;


// @abstract
class skyui.components.list.BasicList extends BSList
{
  /* CONSTANTS */
  
	public static var PLATFORM_PC = 0;

	public static var SELECT_MOUSE = 0;
	public static var SELECT_KEYBOARD = 1;

	
	
  /* STAGE ELEMENTS */

	public var anchorEntriesBegin: MovieClip;
	public var anchorEntriesEnd: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
  	private var _bUpdateRequested: Boolean = false;
	

  /* PROPERTIES */
  
	private var _platform: Number = PLATFORM_PC;
	
	public function get platform(): Number
	{
		return _platform;
	}
  
	public function set platform(a_platform: Number)
	{
		_platform = a_platform;
		_bMouseDrivenNav = _platform == PLATFORM_PC;
	}
	
	private var _bMouseDrivenNav: Boolean = false;
	
	function get isMouseDrivenNav(): Boolean
	{
		return _bMouseDrivenNav;
	}

	function set isMouseDrivenNav(a_bFlag: Boolean)
	{
		_bMouseDrivenNav = a_bFlag;
	}
	
	private var _bListAnimating: Boolean = false;
	
	function get listAnimating(): Boolean
	{
		return _bListAnimating;
	}

	function set listAnimating(a_bFlag: Boolean)
	{
		_bListAnimating = a_bFlag;
	}

	private var _bDisableInput: Boolean = false;

	function get disableInput()
	{
		return _bDisableInput;
	}

	function set disableInput(a_bFlag: Boolean)
	{
		_bDisableInput = a_bFlag;
	}
	
	private var _bDisableSelection: Boolean = false;
	
	function get disableSelection(): Boolean
	{
		return _bDisableSelection;
	}
	
	function set disableSelection(a_bFlag: Boolean)
	{
		_bDisableSelection = a_bFlag;
	}
	
	private var _entryRenderer: String;
	
	public function set entryRenderer(a_entryRenderer: String)
	{
		_entryRenderer = a_entryRenderer;
	}
	
	public function get entryRenderer(): String
	{
		return _entryRenderer;
	}

	// @override skyui.components.list.BSList
	public function get selectedIndex(): Number
	{
		return _selectedIndex;
	}
	
	// @override skyui.components.list.BSList
	public function set selectedIndex(a_newIndex: Number)
	{
		doSetSelectedIndex(a_newIndex, SELECT_MOUSE);
	}
	
	private var _entryClipManager: EntryClipManager;
	
	private var _listEnumeration: IEntryEnumeration;
	
	public function set listEnumeration(a_enumeration: IEntryEnumeration)
	{
		_listEnumeration = a_enumeration;
	}
	
	private var _entryFormatter: IEntryFormatter;
	
	public function set entryFormatter(a_entryFormatter: IEntryFormatter)
	{
		_entryFormatter = a_entryFormatter;
	}
	
	private var _dataFetcher: IDataFetcher;
	
	public function set dataFetcher(a_dataFetcher: IDataFetcher)
	{
		_dataFetcher = a_dataFetcher;
	}
	
	
  /* CONSTRUCTORS */
  
	public function BasicList()
	{
		super();
		
		_entryClipManager = new EntryClipManager(this);

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
	public function requestUpdate()
	{
		_bUpdateRequested = true;
	}
	
	var updateCount = 0;
	
	// @override MovieClip
	public function onEnterFrame(): Void
	{
		if (updateCount>0)
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
		if (_dataFetcher)
			_dataFetcher.processEntries(this);
		
		_listEnumeration.invalidate();
		
		if (_selectedIndex >= _listEnumeration.size())
			_selectedIndex = _listEnumeration.size() - 1;

		requestUpdate();
	}

	// @override BSList
	// @abstract
	public function UpdateList(): Void { }
	
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (_bDisableInput || _bDisableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (_bDisableInput || _bDisableSelection || _selectedIndex == -1 || a_buttonIndex != 1)
			return;
		
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	public function onItemRollOver(a_index: Number): Void
	{
		if (_bListAnimating || _bDisableSelection || _bDisableInput)
			return;
			
		doSetSelectedIndex(a_index, SELECT_MOUSE);
		_bMouseDrivenNav = true;
	}

	public function onItemRollOut(a_index: Number): Void
	{
		// empty
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (_bDisableSelection || a_newIndex == _selectedIndex)
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
		_entryFormatter.setEntry(a_entryClip, a_entryObject);
	}
	
	private function getSelectedListEnumIndex(): Number
	{
		return _listEnumeration.lookupEnumIndex(_selectedIndex);
	}
	
	private function getListEnumIndex(a_index: Number): Number
	{
		return _listEnumeration.lookupEnumIndex(a_index);
	}
	
	private function getListEntryIndex(a_index: Number): Number
	{
		return _listEnumeration.lookupEntryIndex(a_index);
	}
	
	private function getListEnumSize(): Number
	{
		return _listEnumeration.size();
	}
	
	private function getListEnumEntry(a_index: Number): Object
	{
		return _listEnumeration.at(a_index);
	}
	
	private function getListEnumPredecessorIndex(): Number
	{
		return _listEnumeration.lookupEntryIndex(getSelectedListEnumIndex() - 1);
	}
	
	private function getListEnumSuccessorIndex(): Number
	{
		return _listEnumeration.lookupEntryIndex(getSelectedListEnumIndex() + 1);
	}
	
	private function getListEnumFirstIndex(): Number
	{
		return _listEnumeration.lookupEntryIndex(0);
	}
	
	private function getListEnumLastIndex(): Number
	{
		return _listEnumeration.lookupEntryIndex(getListEnumSize() -1);
	}
}