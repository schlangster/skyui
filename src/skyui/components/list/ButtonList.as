import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.BasicList;

/*
 *  A simple, general-purpose button list.
 */

class skyui.components.list.ButtonList extends BasicList
{
  /* PRIVATE VARIABLES */
  
	private var _listIndex:Number = 0;
	
	
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
	
	
  /* CONSTRUCTORS */
	
	public function ButtonList()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override BasicList
	public function UpdateList(): Void
	{
		var yStart = 0;
		var h = 0;
		var listIndex = 0;
		
		// Display the selected list portion of the list
		for (var i = 0; i < getListEnumSize(); i++) {
			var entryClip = getClipByIndex(i);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.unfilteredIndex;
			entryItem.clipIndex = i;
			
			setEntry(entryClip, entryItem);
			
			entryClip._y = yStart + h;
			entryClip._visible = true;

			h = h + entryClip._height;
			
			listIndex++;
		}
		
		// If the list is not completely filled, hide unused entries.
		for (var i = listIndex; i <= _entryClipManager.maxIndex; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._visible = false;
			entryClip.itemIndex = undefined;
		}
		
		// Select entry under the cursor for mouse-driven navigation
		if (_bMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var processed = false;

		if (_bDisableInput)
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
			} else if (!_bDisableSelection && details.navEquivalent == NavigationCode.ENTER) {
				onItemPress();
				processed = true;
			}
		}
		return processed;
	}

	// @GFx
	public function onMouseWheel(delta)
	{
		if (_bDisableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (delta < 0)
					moveSelectionUp();
				else if (delta > 0)
					moveSelectionDown();
			}
		}
		
		_bMouseDrivenNav = true;
	}
	
	public function moveSelectionUp(): Void
	{
		if (_bDisableSelection)
			return;
			
		if (_selectedIndex == -1) {
			doSetSelectedIndex(getListEnumLastIndex(), SELECT_KEYBOARD);
			_bMouseDrivenNav = false;
		} else if (getSelectedListEnumIndex() > 0) {
			doSetSelectedIndex(getListEnumPredecessorIndex(), SELECT_KEYBOARD);
			_bMouseDrivenNav = false;
			dispatchEvent({type: "listMovedUp", index: _selectedIndex, scrollChanged: true});
		}
	}

	public function moveSelectionDown(): Void
	{
		if (_bDisableSelection)
			return;
			
		if (_selectedIndex == -1) {
			doSetSelectedIndex(getListEnumFirstIndex(), SELECT_KEYBOARD);
			_bMouseDrivenNav = false;
		} else if (getSelectedListEnumIndex() < getListEnumSize() - 1) {
			doSetSelectedIndex(getListEnumSuccessorIndex(), SELECT_KEYBOARD);
			_bMouseDrivenNav = false;
			dispatchEvent({type: "listMovedDown", index: _selectedIndex, scrollChanged: true});
		}
	}
}