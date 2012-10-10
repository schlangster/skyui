import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.BasicList;

/*
 *  A simple, general-purpose button list.
 */
class skyui.components.list.ButtonList extends BasicList
{
  /* CONSTANTS */
  
	public var ALIGN_LEFT = 0;
	public var ALIGN_RIGHT = 1;
	
	
  /* PROPERTIES */
	
	private var _bAutoScale: Boolean = true;
	
	public function get autoScale(): Boolean
	{
		return _bAutoScale;
	}
	
	public function set autoScale(a_bAutoScale: Boolean)
	{
		_bAutoScale = a_bAutoScale;
	}
	
	private var _minButtonWidth: Number = 10;
	
	public function get minButtonWidth(): Number
	{
		return _minButtonWidth;
	}
	
	public function set minButtonWidth(a_minButtonWidth: Number)
	{
		_minButtonWidth = a_minButtonWidth;
	}
	
	private var _buttonWidth: Number = 0;
	
	public function get buttonWidth(): Number
	{
		return _buttonWidth;
	}

	private var _align: Number = ALIGN_RIGHT;
	
	public function set align(a_align: String)
	{
		if (align == "LEFT")
			_align = ALIGN_LEFT;
		else if (align == "RIGHT")
			_align = ALIGN_RIGHT;
	}
	
	
  /* INITIALIZATION */
	
	public function ButtonList()
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
		
		var h = 0;

		_buttonWidth = 4;

		// Set entries
		for (var i = 0; i < getListEnumSize(); i++) {
			var entryClip = getClipByIndex(i);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = i;
			entryItem.clipIndex = i;
			
			entryClip.setEntry(entryItem, listState);

			entryClip._y = topBorder + h;
			entryClip._visible = true;
			
			entryClip.selectIndicator._width = 4;
			entryClip.background._width = 4;
			
			if (_buttonWidth < entryClip._width)
				_buttonWidth = entryClip._width + 4;

			h = h + entryClip._height;
		}
		
		for (var i = 0; i < getListEnumSize(); i++) {
			entryClip._x = (_align == ALIGN_LEFT) ? leftBorder : -(buttonWidth + rightBorder);
			
			var entryClip = getClipByIndex(i);
			entryClip.selectIndicator._width = _buttonWidth;
			entryClip.background._width = _buttonWidth;
		}
		
		background._width = leftBorder + _buttonWidth + rightBorder;
		background._height = topBorder + h + bottomBorder;

		background._x = (_align == ALIGN_LEFT) ? 0 : -background._width;
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
			dispatchEvent({type: "listMovedUp", index: _selectedIndex, scrollChanged: true});
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
			dispatchEvent({type: "listMovedDown", index: _selectedIndex, scrollChanged: true});
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