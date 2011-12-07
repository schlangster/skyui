import Shared.ListFilterer;
import skyui.IFilter;

class skyui.FilteredList extends skyui.DynamicScrollingList
{
	private var _maxTextLength:Number;
	private var _filteredList:Array;
	private var _filterChain:Array;


	function FilteredList()
	{
		super();
		_filteredList = new Array();
		_filterChain = new Array();
		_maxTextLength = 512;
	}

	function addFilter(a_filter:IFilter)
	{
		_filterChain.push(a_filter);
	}

	function set maxTextLength(a_length)
	{
		if (a_length > 3) {
			_maxTextLength = a_length;
		}
	}

	function getFilteredEntry(a_index:Number):Object
	{
		return _filteredList[a_index];
	}

	// Did you mean: numFilteredItems() ?
	function get numUnfilteredItems():Number
	{
		return _filteredList.length;
	}

	function get maxTextLength():Number
	{
		return _maxTextLength;
	}

	function generateFilteredList()
	{
		_filteredList.splice(0);

		for (var i = 0; i < _entryList.length; i++) {
			_entryList[i].unfilteredIndex = i;
			_entryList[i].filteredIndex = undefined;
			_filteredList[i] = _entryList[i];
		}

		for (var i = 0; i < _filterChain.length; i++) {
			_filterChain[i].process(_filteredList);
		}

		for (var i = 0; i < _filteredList.length; i++) {
			_filteredList[i].filteredIndex = i;
		}

		if (selectedEntry.filteredIndex == undefined) {
			_selectedIndex = -1;
		}
	}

	function UpdateList()
	{
		var yStart = _indent;
		var h = 0;

		for (var i = 0; i < _filteredList.length && i < _scrollPosition; i++) {
			_filteredList[i].clipIndex = undefined;
		}

		_listIndex = 0;

		for (var i = _scrollPosition; i < _filteredList.length && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);

			setEntry(entryClip,_filteredList[i]);
			entryClip.itemIndex = _filteredList[i].unfilteredIndex;
			_filteredList[i].clipIndex = _listIndex;

			entryClip._y = yStart + h;
			entryClip._visible = true;

			h = h + _entryHeight;

			_listIndex++;
		}

		for (var i = _listIndex; i < _maxListIndex; i++) {
			getClipByIndex(i)._visible = false;
			getClipByIndex(i).itemIndex = undefined;
		}

		// Select entry under the cursor
		if (_bMouseDrivenNav) {
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent) {
				if (e._parent == this && e._visible && e.itemIndex != undefined) {
					doSetSelectedIndex(e.itemIndex,0);
				}
			}
		}
	}

	function InvalidateData()
	{
		generateFilteredList();
		super.InvalidateData();
	}

	function calculateMaxScrollPosition()
	{
		var t = _filteredList.length - _maxListIndex;
		_maxScrollPosition = (t > 0) ? t : 0;

		if (_scrollPosition > _maxScrollPosition) {
			scrollPosition = _maxScrollPosition;
		}

		updateScrollbar();
	}

	function moveSelectionUp(a_bScrollPage:Boolean)
	{
		if (!_bDisableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(false);
			} else if (selectedEntry.filteredIndex > 0) {
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex - 1].unfilteredIndex,1);
				_bMouseDrivenNav = false;
				dispatchEvent({type:"listMovedUp", index:_selectedIndex, scrollChanged:true});
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition - _listIndex;
			scrollPosition = t > 0 ? t : 0;
			doSetSelectedIndex(-1, 0);
		} else {
			scrollPosition = scrollPosition - 1;
		}
	}

	function moveSelectionDown(a_bScrollPage:Boolean)
	{
		if (!_bDisableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(true);
			} else if (selectedEntry.filteredIndex < _filteredList.length - 1) {
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex + 1].unfilteredIndex,1);
				_bMouseDrivenNav = false;
				dispatchEvent({type:"listMovedDown", index:_selectedIndex, scrollChanged:true});
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, 0);
		} else {
			scrollPosition = scrollPosition + 1;
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
				if (selectedEntry.filteredIndex < _scrollPosition) {
					scrollPosition = selectedEntry.filteredIndex;
				} else if (selectedEntry.filteredIndex >= _scrollPosition + _listIndex) {
					scrollPosition = Math.min(selectedEntry.filteredIndex - _listIndex + 1, _maxScrollPosition);
				} else {
					setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
				}
			}

			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function onFilterChange()
	{
		generateFilteredList();
		calculateMaxScrollPosition();
		UpdateList();
	}
}