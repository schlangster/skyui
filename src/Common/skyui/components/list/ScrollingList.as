import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicList;
import skyui.filter.IFilter;


class skyui.components.list.ScrollingList extends BasicList
{
  /* PRIVATE VARIABLES */  

	// This serves as the actual size of the list as its incremented during updating
	private var _listIndex: Number = 0;
	
	private var _entryHeight: Number = 28;
	
	private var _curClipIndex: Number = -1;
	
	// The maximum allowed size. Actual size might be smaller if the list is not filled completely.
	private var _maxListIndex: Number;
	
	
  /* STAGE ELEMENTS */
  
	public var scrollbar: MovieClip;


  /* PROPERTIES */

	private var _scrollPosition: Number = 0;
	
	public function get scrollPosition()
	{
		return _scrollPosition;
	}

	public function set scrollPosition(a_newPosition: Number)
	{
		if (a_newPosition == _scrollPosition || a_newPosition < 0 || a_newPosition > _maxScrollPosition)
			return;
			
		if (scrollbar != undefined)
			scrollbar.position = a_newPosition;
		else
			updateScrollPosition(a_newPosition);
	}
	
	private var _maxScrollPosition: Number = 0;

	public function get maxScrollPosition(): Number
	{
		return _maxScrollPosition;
	}
	
	private var _listHeight: Number;
	
	public function get listHeight(): Number
	{
		return _listHeight;
	}
	
  	public function set listHeight(a_height: Number): Void
	{
		_listHeight = background._height = a_height;
		
		if (scrollbar != undefined)
			scrollbar.height = _listHeight;
	}
	
	// @override BasicList
	public var listEnumeration: FilteredEnumeration;


  /* CONSTRUCTORS */
	
	public function ScrollingList()
	{
		super();
		
		_listHeight = background._height;
		
		_maxListIndex = Math.floor(_listHeight / _entryHeight);
	}
	
	
  /* PUBLIC FUNCTIONS */
  


	// @override MovieClip
	public function onLoad(): Void
	{
		if (scrollbar != undefined) {
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll", this, "onScroll");
			scrollbar._y = background._x;
			scrollbar.height = _listHeight;
		}
	}

	// GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var processed = false;

		if (disableInput)
			return false;

		var entry = getClipByIndex(selectedIndex - scrollPosition);
		var processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

		if (!processed && GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP) {
				moveSelectionUp(details.navEquivalent == NavigationCode.PAGE_UP);
				processed = true;
			} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN) {
				moveSelectionDown(details.navEquivalent == NavigationCode.PAGE_DOWN);
				processed = true;
			} else if (!disableSelection && details.navEquivalent == NavigationCode.ENTER) {
				onItemPress();
				processed = true;
			}
		}
		return processed;
	}

	// GFx
	public function onMouseWheel(delta: Number): Void
	{
		if (disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (delta < 0)
					scrollPosition = scrollPosition + 1;
				else if (delta > 0)
					scrollPosition = scrollPosition - 1;
			}
		}
		
		isMouseDrivenNav = true;
	}

	// @override BasicList
	public function UpdateList(): Void
	{
		updateCount++;
		
		// Prepare clips
		setClipCount(_maxListIndex);
		
		var yStart = background._y;
		var h = 0;

		// Clear clipIndex for everything before the selected list portion
		for (var i = 0; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		
		// Display the selected list portion of the list
		for (var i = _scrollPosition; i < getListEnumSize() && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.unfilteredIndex;
			entryItem.clipIndex = _listIndex;
			
			setEntry(entryClip, entryItem);
			
			entryClip._y = yStart + h;
			entryClip._visible = true;

			h = h + _entryHeight;

			++_listIndex;
		}
		
		// Clear clipIndex for everything after the selected list portion
		for (var i = _scrollPosition + _listIndex; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;
		
		// Select entry under the cursor for mouse-driven navigation
		if (isMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
	}

	// @override BasicList
	public function InvalidateData(): Void
	{
		invalidateFilterData();
		
		calculateMaxScrollPosition();		
		
		super.InvalidateData();
		
		// TODO: This might be a problem when doing delayed updating.
		
		// Restore selection
		if (_curClipIndex != undefined && _curClipIndex != -1 && _listIndex > 0) {
			if (_curClipIndex >= _listIndex)
				_curClipIndex = _listIndex - 1;
			
			var entryClip = getClipByIndex(_curClipIndex);
			
			doSetSelectedIndex(entryClip.itemIndex, SELECT_KEYBOARD);
		}
	}
	
	public function moveSelectionUp(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(false);
			} else if (getSelectedListEnumIndex() > 0) {
				doSetSelectedIndex(getListEnumPredecessorIndex(), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				dispatchEvent({type: "listMovedUp", index: _selectedIndex, scrollChanged: true});
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition - _listIndex;
			scrollPosition = t > 0 ? t : 0;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition - 1;
		}
	}

	public function moveSelectionDown(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(true);
			} else if (getSelectedListEnumIndex() < getListEnumSize() - 1) {
				doSetSelectedIndex(getListEnumSuccessorIndex(), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				dispatchEvent({type: "listMovedDown", index: _selectedIndex, scrollChanged: true});
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition + 1;
		}
	}

	public function selectDefaultIndex(a_bBottom: Boolean): Void
	{
		if (_listIndex <= 0)
			return;
			
		if (a_bBottom) {
			var firstClip = getClipByIndex(0);
			if (firstClip.itemIndex != undefined)
				selectedIndex = firstClip.itemIndex;
		} else {
			var lastClip = getClipByIndex(_listIndex - 1);
			if (lastClip.itemIndex != undefined)
				selectedIndex = lastClip.itemIndex;
		}
	}

	public function onScroll(event: Object): Void
	{
		updateScrollPosition(Math.floor(event.position + 0.500000));
	}
	
	public function onFilterChange(): Void
	{
		invalidateFilterData();
		calculateMaxScrollPosition();
		UpdateList();
	}
	
	public function get filteredItemsCount(): Number
	{
		return getListEnumSize();
	}
	
	public function addFilter(a_filter: IFilter): Void
	{
		listEnumeration.addFilter(a_filter);
	}
	
	
  /* PRIVATE FUNCTIONS */
  
  	// @override BasicList
	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableSelection || a_newIndex == _selectedIndex)
			return;
			
		// Selection is not contained in current entry enumeration, ignore
		if (a_newIndex != -1 && getListEnumIndex(a_newIndex) == undefined)
			return;
			
		var oldEntry = selectedEntry;
		
		_selectedIndex = a_newIndex;

		// Old entry was mapped to a clip? Then clear with setEntry now that selectedIndex has been updated
		if (oldEntry.clipIndex != undefined)
			setEntry(getClipByIndex(oldEntry.clipIndex), oldEntry);
			
			
		// Select valid entry
		if (_selectedIndex != -1) {
			
			var enumIndex = getSelectedListEnumIndex();
			
			// New entry before visible portion, move scroll window up
			if (enumIndex < _scrollPosition)
				scrollPosition = enumIndex;
				
			// New entry below visible portion, move scroll window down
			else if (enumIndex >= _scrollPosition + _listIndex)
				scrollPosition = Math.min(enumIndex - _listIndex + 1, _maxScrollPosition);
				
			// No need to change the scroll window, just select new entry
			else
				setEntry(getClipByIndex(selectedEntry.clipIndex), selectedEntry);
				
			_curClipIndex = selectedEntry.clipIndex;
			
		// Unselect
		} else {
			_curClipIndex = -1;
		}

		dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
	}
	
	private function calculateMaxScrollPosition(): Void
 	{
		var t = getListEnumSize() - _maxListIndex;
		_maxScrollPosition = (t > 0) ? t : 0;

		updateScrollbar();

		if (_scrollPosition > _maxScrollPosition)
			scrollPosition = _maxScrollPosition;
	}
	
	private function updateScrollPosition(a_position: Number): Void
	{
		_scrollPosition = a_position;
		UpdateList();
	}

	private function updateScrollbar(): Void
	{
		if (scrollbar != undefined) {
			scrollbar._visible = _maxScrollPosition > 0;
			scrollbar.setScrollProperties(_maxListIndex,0,_maxScrollPosition);
		}
	}
	
	private function invalidateFilterData(): Void
	{
		// Set up helper attributes for easy mapping between original list, filtered list and entry clips
		for (var i = 0; i < _entryList.length; i++)
			_entryList[i].clipIndex = undefined;
		
		listEnumeration.invalidate();

		if (listEnumeration.lookupEnumIndex(_selectedIndex) == undefined)
			_selectedIndex = -1;
	}
	
	// @override BasicList
	private function getClipByIndex(a_index: Number): MovieClip
	{
		if (a_index < 0 || a_index >= _maxListIndex)
			return undefined;

		return _entryClipManager.getClip(a_index);
	}
}