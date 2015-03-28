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
	
	public var isPressOnMove: Boolean = false;

	private var _scrollPosition: Number = 0;
	
	public function get scrollPosition(): Number
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

	// @override BasicList
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.setPlatform(a_platform,a_bPS3Switch);
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
				// TODO: See gfx.managers.InputDelegate.inputToNav(); stop it from converting numberpad -> navEquivalent
				// Fix for numberpad 0 being handled as ENTER
				if (details.code == 96 && _platform == PLATFORM_PC)
					return false;

				onItemPress();
				return true;

			}
		}
		return false;
	}

	// @override BasicList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		
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
			
			entryClip.setEntry(entryItem, listState);

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
			
		if (listEnumeration.lookupEnumIndex(_selectedIndex) == null)
			_selectedIndex = -1;
		
		calculateMaxScrollPosition();		
		UpdateList();
		
		// Restore selection
		if (_curClipIndex != undefined && _curClipIndex != -1 && _listIndex > 0) {
			if (_curClipIndex >= _listIndex)
				_curClipIndex = _listIndex - 1;
			
			var entryClip = getClipByIndex(_curClipIndex);
			doSetSelectedIndex(entryClip.itemIndex, SELECT_MOUSE);
		}
		
		if (onInvalidate)
			onInvalidate();
	}
	
	public function moveSelectionUp(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(false);
			} else if (getSelectedListEnumIndex() >= scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(-scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				
				if (isPressOnMove)
					onItemPress();
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
			} else if (getSelectedListEnumIndex() < getListEnumSize() - scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
				
				if (isPressOnMove)
					onItemPress();
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition + scrollDelta;
		}
	}

	public function selectDefaultIndex(a_bTop: Boolean): Void
	{
		if (_listIndex <= 0)
			return;
			
		if (a_bTop) {
			var firstClip = getClipByIndex(0);
			if (firstClip.itemIndex != undefined)
				doSetSelectedIndex(firstClip.itemIndex, SELECT_KEYBOARD);
		} else {
			var lastClip = getClipByIndex(_listIndex - 1);
			if (lastClip.itemIndex != undefined)
				doSetSelectedIndex(lastClip.itemIndex, SELECT_KEYBOARD);
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	// @GFx
	private function onMouseWheel(a_delta: Number): Void
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

	private function onScroll(event: Object): Void
	{
		updateScrollPosition(Math.floor(event.position + 0.5));
	}
  
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
		if (oldEntry.clipIndex != undefined) {
			var clip = getClipByIndex(oldEntry.clipIndex);
			clip.setEntry(oldEntry, listState);
		}
			
			
		// Select valid entry
		if (_selectedIndex != -1) {
			
			var enumIndex = getSelectedListEnumIndex();
			
			// New entry before visible portion, move scroll window up
			if (enumIndex < _scrollPosition) {
				scrollPosition = enumIndex;
				
			// New entry below visible portion, move scroll window down
			} else if (enumIndex >= _scrollPosition + _listIndex) {
				scrollPosition = Math.min(enumIndex - _listIndex + scrollDelta, _maxScrollPosition);
				
			// No need to change the scroll window, just select new entry
			} else {
				var clip = getClipByIndex(selectedEntry.clipIndex);
				clip.setEntry(selectedEntry, listState);
			}
				
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