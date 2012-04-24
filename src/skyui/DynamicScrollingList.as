import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.ScrollBar;

class skyui.DynamicScrollingList extends skyui.BasicList
{
	//tmpfix
	var border;
	var _indent;
	
	private var _scrollPosition:Number;
	private var _maxScrollPosition:Number;

	private var _listIndex:Number;
	private var _maxListIndex:Number;
	private var _listHeight:Number;
	
	private var _entryHeight:Number;

	// Children
	var scrollbar:MovieClip;

	// Constructor
	function DynamicScrollingList()
	{
		super();

		_scrollPosition = 0;
		_maxScrollPosition = 0;
		_listIndex = 0;

		_entryHeight = 28;
		_listHeight = border._height;
		_maxListIndex = Math.floor(_listHeight / _entryHeight);
	}

	function onLoad()
	{
		if (scrollbar != undefined) {
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll",this,"onScroll");
			scrollbar._y = _indent;
			scrollbar.height = _listHeight;
		}
	}

	function getClipByIndex(a_index:Number)
	{
		if (a_index < 0 || a_index >= _maxListIndex) {
			return undefined;
		}

		return _entryClipManager.getClipByIndex(a_index);
	}

	function handleInput(details, pathToFocus):Boolean
	{
		var processed = false;

		if (!_bDisableInput) {
			var entry = getClipByIndex(selectedIndex - scrollPosition);

			processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

			if (!processed && GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP) {
					moveSelectionUp(details.navEquivalent == NavigationCode.PAGE_UP);
					processed = true;
				} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN) {
					moveSelectionDown(details.navEquivalent == NavigationCode.PAGE_DOWN);
					processed = true;
				} else if (!_bDisableSelection && details.navEquivalent == NavigationCode.ENTER) {
					onItemPress();
					processed = true;
				}
			}
		}
		return processed;
	}

	function onMouseWheel(delta)
	{
		if (!_bDisableInput) {
			for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
				if (target == this) {
					if (delta < 0) {
						scrollPosition = scrollPosition + 1;
					} else if (delta > 0) {
						scrollPosition = scrollPosition - 1;
					}
				}
			}
			_bMouseDrivenNav = true;
		}
	}

	function doSetSelectedIndex(a_newIndex:Number, a_keyboardOrMouse:Number)
	{
		if (!_bDisableSelection && a_newIndex != _selectedIndex) {
			var oldIndex = _selectedIndex;
			_selectedIndex = a_newIndex;

			if (oldIndex != -1) {
				setEntry(getClipByIndex(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);
			}

			if (_selectedIndex != -1) {
				if (_platform != 0) {
					if (_selectedIndex < _scrollPosition) {
						scrollPosition = _selectedIndex;
					} else if (_selectedIndex >= _scrollPosition + _listIndex) {
						scrollPosition = Math.min(_selectedIndex - _listIndex + 1, _maxScrollPosition);
					} else {
						setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
					}
				} else {
					setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
				}
			}
			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function get scrollPosition()
	{
		return _scrollPosition;
	}

	function get maxScrollPosition()
	{
		return _maxScrollPosition;
	}

	function set scrollPosition(a_newPosition:Number)
	{
		if (a_newPosition != _scrollPosition && a_newPosition >= 0 && a_newPosition <= _maxScrollPosition) {
			if (scrollbar != undefined) {
				scrollbar.position = a_newPosition;
			} else {
				updateScrollPosition(a_newPosition);
			}
		}
	}

	function updateScrollPosition(a_position:Number)
	{
		_scrollPosition = a_position;
		UpdateList();
	}

	function updateScrollbar()
	{
		if (scrollbar != undefined) {
			scrollbar._visible = _maxScrollPosition > 0;
			scrollbar.setScrollProperties(_maxListIndex,0,_maxScrollPosition);
		}
	}

	function calculateMaxScrollPosition()
	{
		var t = _entryList.length - _maxListIndex;

		_maxScrollPosition = t > 0 ? t : 0;

		updateScrollbar();

		if (_scrollPosition > _maxScrollPosition) {
			scrollPosition = _maxScrollPosition;
		}
	}

	function UpdateList()
	{
		var yStart = _indent;
		var h = 0;

		for (var i = 0; i < _scrollPosition; i++) {
			_entryList[i].clipIndex = undefined;
		}

		_listIndex = 0;

		for (var pos = _scrollPosition; pos < _entryList.length && _listIndex < _maxListIndex; pos++) {
			var entry = getClipByIndex(_listIndex);

			setEntry(entry,_entryList[pos]);
			_entryList[pos].clipIndex = _listIndex;
			entry.itemIndex = pos;

			entry._y = yStart + h;
			entry._visible = true;

			h = h + _entryHeight;

			++_listIndex;
		}

		for (var i = _listIndex; i < _maxListIndex; i++) {
			getClipByIndex(i)._visible = false;
			getClipByIndex(i).itemIndex = undefined;
		}
	}

	function InvalidateData()
	{
		calculateMaxScrollPosition();
		super.InvalidateData();
	}

	function moveSelectionUp(a_bNextPage:Boolean)
	{
		var lastPosition = _scrollPosition;
		var d = a_bNextPage? _listIndex : 1;

		if (!_bDisableSelection) {
			if (selectedIndex == -1) {
				selectDefaultIndex();
			} else if (selectedIndex - d > -1) {
				selectedIndex = selectedIndex - d;
			}
		} else {
			scrollPosition = scrollPosition - d;
		}
		_bMouseDrivenNav = false;
		dispatchEvent({type:"listMovedUp", index:_selectedIndex, scrollChanged:lastPosition != _scrollPosition});
	}

	function moveSelectionDown(a_bNextPage:Boolean)
	{
		var lastPosition = _scrollPosition;

		if (!_bDisableSelection) {
			if (selectedIndex == -1) {
				selectDefaultIndex();
			} else if (selectedIndex < _entryList.length - 1) {
				selectedIndex = selectedIndex + 1;
			}
		} else {
			scrollPosition = scrollPosition + 1;
		}
		_bMouseDrivenNav = false;
		dispatchEvent({type:"listMovedDown", index:_selectedIndex, scrollChanged:lastPosition != _scrollPosition});
	}

	function selectDefaultIndex(a_bBottom:Boolean)
	{
		if (_listIndex > 0) {
			if (a_bBottom) {
				var firstClip = getClipByIndex(0);
				if (firstClip.itemIndex != undefined) {
					doSetSelectedIndex(firstClip.itemIndex, 0);
				}
			} else {
				var lastClip = getClipByIndex(_listIndex - 1);
				if (lastClip.itemIndex != undefined) {
					doSetSelectedIndex(lastClip.itemIndex, 0);
				}
			}
		}
	}

	function onScroll(event)
	{
		updateScrollPosition(Math.floor(event.position + 0.500000));
	}
}