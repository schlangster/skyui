import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicList;
import skyui.filter.IFilter;


class skyui.components.list.ScrollingList extends BasicList
{
  /* PRIVATE VARIABLES */ 

	// This serves as the actual size of the list as its incremented during updating
	private var _listIndex: Number = 0;
	
	private var _curClipIndex: Number = -1;
	
	// The maximum allowed size. Actual size might be smaller if the list is not filled completely.
	private var _maxListIndex: Number;
	
	
  /* STAGE ELEMENTS */
  
	public var scrollbar: MovieClip;
	
	public var scrollUpButton: MovieClip;
	public var scrollDownButton: MovieClip;


  /* PROPERTIES */

	public var entryHeight: Number = 28;
	
	public var scrollDelta: Number = 1;

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


  /* INITIALIZATION */
	
	public function ScrollingList()
	{
		super();
		
		_listHeight = background._height - topBorder - bottomBorder;
		
		_maxListIndex = Math.floor(_listHeight / entryHeight);
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// @override MovieClip
	public function onLoad(): Void
	{
		if (scrollbar != undefined) {
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll", this, "onScroll");
			scrollbar._y = background._x + topBorder;
			scrollbar.height = _listHeight;
		}
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;

		// That makes no sense, does it?
		var entry = getClipByIndex(selectedIndex);
		var bHandled = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));
		if (bHandled)
			return true;

		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP) {
				moveSelectionUp(details.navEquivalent == NavigationCode.PAGE_UP);
				return true;
			} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN) {
				moveSelectionDown(details.navEquivalent == NavigationCode.PAGE_DOWN);
				return true;
			} else if (!disableSelection && details.navEquivalent == NavigationCode.ENTER) {
				onItemPress();
				return true;
			}
		}
		return false;
	}

	// @GFx
	public function onMouseWheel(a_delta: Number): Void
	{
		if (disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (a_delta < 0)
					scrollPosition = scrollPosition + scrollDelta;
				else if (a_delta > 0)
					scrollPosition = scrollPosition - scrollDelta;
			}
		}
		
		isMouseDrivenNav = true;
	}


	var updateCount = 0;
	var invalidateCount = 0;

	public function onEnterFrame()
	{
		if (updateCount > 0) {
			skyui.util.Debug.log("Update count was " + updateCount);
			updateCount = 0;
		}
		
		if (invalidateCount > 0) {
			skyui.util.Debug.log("Invalidate count was " + invalidateCount);
			invalidateCount = 0;
		}
	}

	// @override BasicList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			skyui.util.Debug.log("Ignored update while suspended");
			_bRequestUpdate = true;
			return;
		}
		
		updateCount++;
		
		skyui.util.Debug.log("EXECUTING UPDATE, caller: " + skyui.util.Debug.getFunctionName(arguments.caller));
		
		// Prepare clips
		setClipCount(_maxListIndex);
		
		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;

		// Clear clipIndex for everything before the selected list portion
		for (var i = 0; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		
		// Display the selected list portion of the list
		for (var i = _scrollPosition; i < getListEnumSize() && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			setEntry(entryClip, entryItem);

			entryClip._x = xStart;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			h = h + entryHeight;

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
					
		if (scrollUpButton != undefined)
			scrollUpButton._visible = _scrollPosition > 0;
		if (scrollDownButton != undefined) 
			scrollDownButton._visible = _scrollPosition < _maxScrollPosition;
	}

	// @override BasicList
	public function InvalidateData(): Void
	{
		if (_bSuspended) {
			skyui.util.Debug.log("Delay invalidate while suspended");
			_bRequestInvalidate = true;
			return;
		}
		
		invalidateCount++;

		skyui.util.Debug.log("EXECUTING INVALIDATE, caller: " + skyui.util.Debug.getFunctionName(arguments.caller));
		
		for (var i = 0; i < _entryList.length; i++) {
			_entryList[i].itemIndex = i;
			_entryList[i].clipIndex = undefined;
		}
			
		for (var i=0; i<_dataProcessors.length; i++)
			_dataProcessors[i].processList(this);
		
		if (_selectedIndex >= listEnumeration.size())
			_selectedIndex = listEnumeration.size() - 1;
			
		if (listEnumeration.lookupEnumIndex(_selectedIndex) == undefined)
			_selectedIndex = -1;
		
		listEnumeration.invalidate();
		
		calculateMaxScrollPosition();		
		UpdateList();
		
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
			scrollPosition = scrollPosition - scrollDelta;
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
			scrollPosition = scrollPosition + scrollDelta;
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
		updateScrollPosition(Math.floor(event.position + 0.5));
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
	
	// @override BasicList
	private function getClipByIndex(a_index: Number): MovieClip
	{
		if (a_index < 0 || a_index >= _maxListIndex)
			return undefined;

		return _entryClipManager.getClip(a_index);
	}
}