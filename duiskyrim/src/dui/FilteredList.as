import Shared.ListFilterer;
import dui.IFilter;

class dui.FilteredList extends dui.DynamicScrollingList
{
	private var _maxTextLength;

	private var _filterChain:Array;
	private var _indexMap:Array;

	function FilteredList()
	{
		super();
		_indexMap = new Array();
		_filterChain = new Array();
		_maxTextLength = 256;
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

	function getMappedEntry(a_index:Number):Object
	{
		return _entryList[_indexMap[a_index]];
	}

	function getMappedIndex(a_index:Number):Object
	{
		return _indexMap[a_index];
	}

	function get numUnfilteredItems()
	{
		return _indexMap.length;
	}

	function get maxTextLength()
	{
		return _maxTextLength;
	}

	function updateIndexMap()
	{
		_indexMap.splice(0);

		for (var i = 0; i < _entryList.length; i++) {
			_indexMap[i] = i;
		}

		for (var i = 0; i < _filterChain.length; i++) {
			_filterChain[i].process(_entryList,_indexMap);
		}
	}

	function UpdateList()
	{
		var yStart = _indent;
		var h = 0;

		for (var i = 0; i < _indexMap.length; i++) {
			if (i < scrollPosition) {
				getMappedEntry(i).clipIndex = undefined;
			}
			getMappedEntry(i).mapIndex = i;
		}

		_listIndex = 0;

		for (var i = _scrollPosition; i < _indexMap.length && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);

			setEntry(entryClip,getMappedEntry(i));

			// clipEntry -> listEntry
			// listEntry -> clipIndex
			// listEntry -> mapIndex
			entryClip.itemIndex = getMappedIndex(i);
			getMappedEntry(i).clipIndex = _listIndex;
			getMappedEntry(i).mapIndex = i;


			entryClip._y = yStart + h;
			entryClip._visible = true;

			h = h + entryClip._height;

			_listIndex++;
		}

		for (var i = _listIndex; i < _maxListIndex; i++) {
			getClipByIndex(i)._visible = false;
			getClipByIndex(i).itemIndex = undefined;
		}

		if (ScrollUp != undefined) {
			ScrollUp._visible = scrollPosition > 0;
		}

		if (ScrollDown != undefined) {
			ScrollDown._visible = scrollPosition < _maxScrollPosition;
		}
		
		scrollBar.setParameters(h, _listIndex, _scrollPosition, _maxListIndex);
	}

	function InvalidateData()
	{
		updateIndexMap();
		super.InvalidateData();
	}

	function calculateMaxScrollPosition()
	{
		var t = _indexMap.length - _maxListIndex;
		_maxScrollPosition = (t > 0) ? t : 0;
	}

	function moveSelectionUp()
	{
		if (!_bDisableSelection) {
			if (selectedEntry.mapIndex > 0) {
				//debug.textField.SetText("moving from " + selectedEntry.mapIndex + " (" + selectedIndex + ") to " + (selectedEntry.mapIndex - 1) + " (" + getMappedIndex(selectedEntry.mapIndex - 1) + ")");
				selectedIndex = getMappedIndex(selectedEntry.mapIndex - 1);
			}
		} else {
			scrollPosition = scrollPosition - 1;
		}
	}

	function moveSelectionDown()
	{
		if (!_bDisableSelection) {
			if (selectedEntry.mapIndex < _indexMap.length - 1) {
				selectedIndex = getMappedIndex(selectedEntry.mapIndex + 1);
			}
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
				//debug.textField.SetText("comparing " + selectedEntry.mapIndex + " vs " + _scrollPosition + "(+ " + _listIndex + ")");

				if (selectedEntry.mapIndex < _scrollPosition) {
					scrollPosition = selectedEntry.mapIndex;
				} else if (selectedEntry.mapIndex >= _scrollPosition + _listIndex) {
					scrollPosition = Math.min(selectedEntry.mapIndex - _listIndex + 1, _maxScrollPosition);
				} else {
					setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
				}
			}

			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function onFilterChange()
	{
		updateIndexMap();
		calculateMaxScrollPosition();
		UpdateList();
	}
}