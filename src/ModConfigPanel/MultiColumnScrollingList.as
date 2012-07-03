import skyui.components.list.ScrollingList;

class MultiColumnScrollingList extends ScrollingList
{
	public var columnCount = 2;
	public var columnWidth;
	public var columnSpacing = 0;
	

	public function MultiColumnScrollingList()
	{
		super();
		
		scrollDelta = columnCount;
		_maxListIndex *= columnCount;
	}
	
	// @override ScrollingList
	public function UpdateList(): Void
	{
		// Prepare clips
		setClipCount(_maxListIndex);

		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;
		var w = 0;
		var lastColumnIndex = columnCount - 1;
		var columnWidth = (background._width - (columnCount-1) * columnSpacing) / columnCount;

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

			entryClip._x = xStart + w;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			if (i % columnCount == lastColumnIndex) {
				w = 0;
				h = h + entryHeight;
			} else {
				w = w + columnWidth + columnSpacing;
			}

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
}