import Shared.ListFilterer;

class dui.FilteredList extends dui.DynamicScrollingList
{
	private var _filterer;
	private var _maxTextLength;
	private var _numUnfilteredItems;

	function FilteredList()
	{
		super();
		_filterer = new Shared.ListFilterer();
		_filterer.addEventListener("filterChange",this,"onFilterChange");

		_maxTextLength = 256;
		_numUnfilteredItems = 0;
	}

	function get filterer()
	{
		return _filterer;
	}

	function set maxTextLength(a_length)
	{
		if (a_length > 3)
		{
			_maxTextLength = a_length;
		}
	}

	function get numUnfilteredItems()
	{
		return _numUnfilteredItems;
	}

	function get maxTextLength()
	{
		return _maxTextLength;
	}

	function UpdateList()
	{
		var yStart = _y;
		var yOffset = 0;
		
		var index = filterer.ClampIndex(0);

		if (_platform != 0)
		{
			_selectedIndex = -1;
		}
		else
		{
			_selectedIndex = filterer.ClampIndex(_selectedIndex);
		}

		_listIndex = 0;
		_numUnfilteredItems = 0;
		_listIndex = 0;


		while (index != undefined && index != -1 && index < _entryList.length && _listIndex < _maxListIndex && yOffset <= _listHeight)
		{
			var item = getClipByIndex(_listIndex);

			setEntry(item, _entryList[index]);

			_entryList[index].clipIndex = _listIndex;
			item.itemIndex = index;
			item._y = yStart + yOffset;
			item._visible = true;
			yOffset = yOffset + item._height;

			if (yOffset <= _listHeight && _listIndex < _maxListIndex)
			{
				++_listIndex;
				++_numUnfilteredItems;
			}
			index = filterer.GetNextFilterMatch(index);
		}

		for (var pos = _listIndex; pos < _maxListIndex; ++pos)
		{
			getClipByIndex(pos)._visible = false;
			getClipByIndex(pos).itemIndex = undefined;
		}
	}

	function InvalidateData()
	{
		filterer.filterArray = _entryList;

		super.InvalidateData();
	}

	function onFilterChange()
	{
		_selectedIndex = filterer.ClampIndex(_selectedIndex);
		
		CalculateMaxScrollPosition();
	}

	function moveSelectionUp()
	{
		var index = filterer.GetPrevFilterMatch(_selectedIndex);
		var oldScrollPosition = _scrollPosition;

		if (index != undefined)
		{
			_selectedIndex = index;

			if (_scrollPosition > 0)
			{
				--_scrollPosition;
			}

			_bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type:"listMovedUp", index:_selectedIndex, scrollChanged:oldScrollPosition != _scrollPosition});
		}
	}

	function moveSelectionDown()
	{
		var index = filterer.GetNextFilterMatch(_selectedIndex);
		var oldScrollPosition = _scrollPosition;

		if (index != undefined)
		{
			_selectedIndex = index;
			if (_scrollPosition < _maxScrollPosition)
			{
				++_scrollPosition;
			}

			_bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type:"listMovedDown", index:_selectedIndex, scrollChanged:oldScrollPosition != _scrollPosition});
		}
	}

	function CalculateMaxScrollPosition()
	{
		_maxScrollPosition = -1;
		
		for (var _loc2 = filterer.ClampIndex(0); _loc2 != undefined; _loc2 = filterer.GetNextFilterMatch(_loc2))
		{
			++_maxScrollPosition;
		}

		if (_maxScrollPosition == undefined || _maxScrollPosition < 0)
		{
			_maxScrollPosition = 0;
		}
	}
}