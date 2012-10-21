import skyui.components.list.ScrollingList;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;


class MultiColumnScrollingList extends ScrollingList
{
  /* PRIVATE VARIABLES */ 
	
	private var _separators: Array;
	
	
  /* PROPERTIES */
	
	public var columnSpacing: Number = 0;
	
	public var separatorRenderer: String;
	
	private var _columnCount: Number = 1;
	
	public function get columnCount(): Number
	{
		return _columnCount;
	}
	
	public function set columnCount(a_value: Number)
	{
		_columnCount = a_value;
		
		refreshSeparators();
	}
	

  /* INITIALIZATION */

	public function MultiColumnScrollingList()
	{
		super();
		
		scrollDelta = columnCount;
		_maxListIndex *= columnCount;
		
		if (_separators == null)
			_separators = [];
	}

	public function onLoad(): Void
	{
		super.onLoad();

		if(scrollbar != undefined) {
			scrollbar.scrollDelta = scrollDelta;
		}
	}
	
	
  /* PUBLIC FUNCTIONS */
	
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
		var columnWidth = (background._width - leftBorder - rightBorder - (columnCount-1) * columnSpacing) / columnCount;

		// Clear clipIndex for everything before the selected list part
		for (var i = 0; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		
		// Display the selected part of the list
		for (var i = _scrollPosition; i < getListEnumSize() && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			entryClip.width = columnWidth;
			entryClip.setEntry(entryItem, listState);

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
		
		// Clear clipIndex for everything after the selected list part
		for (var i = _scrollPosition + _listIndex; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;
		
		// Select entry under the cursor for mouse-driven navigation
		if (isMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
					
		var bShowSeparators = _listIndex > 0;
		for (var i=0; i<_separators.length; i++)
			_separators[i]._visible = bShowSeparators;
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;
			
		if (super.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.LEFT) {
				moveSelectionLeft();
				return true;
			} else if (details.navEquivalent == NavigationCode.RIGHT) {
				moveSelectionRight();
				return true;
			}
		}
		return false;
	}
	
	public function moveSelectionLeft(): Void
	{
		if (disableSelection)
			return;

		if (_selectedIndex == -1) {
			selectDefaultIndex(false);
		} else if ((getSelectedListEnumIndex() % columnCount) > 0) {
			doSetSelectedIndex(getListEnumRelativeIndex(-1), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}

	public function moveSelectionRight(): Void
	{
		if (disableSelection)
			return;

		if (_selectedIndex == -1) {
			selectDefaultIndex(false);
		} else if ((getSelectedListEnumIndex() % columnCount) < (columnCount - 1)) {
			doSetSelectedIndex(getListEnumRelativeIndex(1), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function refreshSeparators()
	{
		if (_separators == null)
			_separators = [];
		
		while (_separators.length > 0) {
			var e = _separators.pop();
			e.removeMovieClip();
		}
		
		// Create separators
		if (!separatorRenderer)
			return;
			
		var columnWidth = (background._width - leftBorder - rightBorder - (columnCount-1) * columnSpacing) / columnCount;
		var t = background._x + leftBorder;
		var d = columnSpacing/2;
		
		for (var i=0; i < columnCount-1; i++) {
			var e = attachMovie(separatorRenderer, separatorRenderer + i, getNextHighestDepth());
			t += columnWidth + d;
			e._x = t;
			e._y = background._y;
			e._height = background._height;
			e._alpha = 50;
			_separators.push(e);
			t += d;
		}
	}
}