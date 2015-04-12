import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.BasicList;

class ButtonGrid extends BasicList
{
  /* CONSTANTS */	
	
  /* PROPERTIES */
	
	public var columnCount: Number = 1;
	
	
  /* INITIALIZATION */
	
	public function ButtonGrid()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override BasicList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		
		setClipCount(getListEnumSize());
		
		var xOffset = leftBorder;
		var yOffset = topBorder;

		// Set entries
		for (var i = 0; i < getListEnumSize(); i++) {
			var entryClip = getClipByIndex(i);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = i;
			entryItem.clipIndex = i;
			
			entryClip.setEntry(entryItem, listState);
			
			entryClip._x = xOffset;
			entryClip._y = yOffset;
			entryClip._visible = true;
			
			if (i % columnCount == (columnCount-1)) {
				xOffset = leftBorder;
				yOffset += entryClip._height;
			} else {
				xOffset += entryClip._width;
			}
		}
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var processed = false;

		if (disableInput)
			return false;

		var entry = getClipByIndex(_selectedIndex);
		var processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

		if (!processed && GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP) {
				moveSelectionUp();
				processed = true;
			} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN) {
				moveSelectionDown();
				processed = true;
			} else if (!disableSelection && details.navEquivalent == NavigationCode.ENTER) {
				onItemPress();
				processed = true;
			}
		}
		return processed;
	}
	
	public function moveSelectionUp(): Void
	{
		if (disableSelection)
			return;
			
		if (_selectedIndex == -1) {
			doSetSelectedIndex(getListEnumLastIndex(), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		} else if (getSelectedListEnumIndex() > 0) {
			doSetSelectedIndex(getListEnumRelativeIndex(-1), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}

	public function moveSelectionDown(): Void
	{
		if (disableSelection)
			return;
			
		if (_selectedIndex == -1) {
			doSetSelectedIndex(getListEnumFirstIndex(), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		} else if (getSelectedListEnumIndex() < getListEnumSize() - 1) {
			doSetSelectedIndex(getListEnumRelativeIndex(+1), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}


  /* PRIVATE FUNCTIONS */

	// @GFx
	private function onMouseWheel(delta)
	{
		if (disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (delta < 0)
					moveSelectionDown();
				else if (delta > 0)
					moveSelectionUp();
			}
		}
		
		isMouseDrivenNav = true;
	}
}