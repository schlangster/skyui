import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.BasicList;


class skyui.CategoryList extends BasicList
{
  /* CONSTANTS */
	
	public static var LEFT_SEGMENT = 0;
	public static var RIGHT_SEGMENT = 1;
	
	
  /* STAGE ELEMENTS */
	
	public var selectorCenter: MovieClip;
	public var selectorLeft: MovieClip;
	public var selectorRight: MovieClip;
	public var background: MovieClip;
	
	
  /* PRIVATE VARIABLES */
	
	private var _xOffset: Number;
	private var _contentWidth: Number;
	private var _totalWidth: Number;
	private var _selectorPos: Number;
	private var _targetSelectorPos: Number;
	private var _bFastSwitch: Boolean;
	private var _segmentOffset: Number;
	private var _segmentLength: Number;


  /* PROPERTIES */
	
	// Distance from border to start icon.
	public var iconIndent: Number;
	
	// Size of the icon.
	public var iconSize: Number;
	
	// Name of movie that contains icons, i.e. skyui_icons_curved.swf.
	public var iconSource: String;
	
	// Array that contains the icon label for category at position i.
	// The category list uses fixed lengths/icons, so this is assigned statically.
	public var iconArt: Array;
	
	// For segmented lists, this is in the index of the divider that seperates player and container/vendor inventory.
	public var dividerIndex: Number;
	
	// The active segment for divided lists (left or right).
	private var _activeSegment: Number;
	
	public function set activeSegment(a_segment: Number)
	{
		if (a_segment == _activeSegment)
			return;
		
		_activeSegment = a_segment;
		
		calculateSegmentParams();
		
		if (a_segment == LEFT_SEGMENT && _selectedIndex > dividerIndex)
			doSetSelectedIndex(_selectedIndex - dividerIndex - 1, SELECT_MOUSE);
		else if (a_segment == RIGHT_SEGMENT && _selectedIndex < dividerIndex)
			doSetSelectedIndex(_selectedIndex + dividerIndex + 1, SELECT_MOUSE);
		
		UpdateList();
	}
	
	public function get activeSegment(): Number
	{
		return _activeSegment;
	}
	
	
  /* CONSTRUCTORS */
	
	public function CategoryList()
	{
		super();
		
		_selectorPos = 0;
		_targetSelectorPos = 0;
		_bFastSwitch = false;

		_activeSegment = LEFT_SEGMENT;
		dividerIndex = -1;
		_segmentOffset = 0;
		_segmentLength = 0;
		
		if (iconSize == undefined)
			iconSize = 32;
		
		// Not needed for a category list
		_dataFetcher = null;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// Clears the list. For the category list, that's ok since the entryList isn't manipulated directly.
	function clearList()
	{
		dividerIndex = -1;
		_entryList.splice(0);
	}
	
	// Switch to given category index to restore the last selection.
	public function restoreCategory(a_newIndex: Number)
	{
		onItemPress(a_newIndex, SELECT_KEYBOARD);
	}
	
	// @override skyui.BasicList
	function InvalidateData()
	{
		_listEnumeration.invalidate();
		calculateSegmentParams();
		
		if (_selectedIndex >= _listEnumeration.size())
			_selectedIndex = _listEnumeration.size() - 1;

		UpdateList();
	}
	
	// @override skyui.BasicList
	public function UpdateList()
	{
		var cw = 0;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);

			setEntry(entryClip, _listEnumeration.at(i + _segmentOffset));

			_listEnumeration.at(i + _segmentOffset).clipIndex = i;
			entryClip.itemIndex = i + _segmentOffset;

			cw = cw + iconSize;
		}

		_contentWidth = cw;
		_totalWidth = background._width;

		var spacing = (_totalWidth - _contentWidth) / (_segmentLength + 1);

		var xPos = anchorEntriesBegin._x + spacing;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;

			xPos = xPos + iconSize + spacing;
			entryClip._visible = true;
		}
		
		updateSelector();
	}
	
	// Moves the selection left to the next element. Wraps around.
	public function moveSelectionLeft()
	{
		if (_bDisableSelection)
			return;

		var curIndex = _selectedIndex;
		var startIndex = _selectedIndex;
			
		do {
			if (curIndex > _segmentOffset) {
				curIndex--;
			} else {
				_bFastSwitch = true;
				curIndex = _segmentOffset + _segmentLength - 1;					
			}
		} while (curIndex != startIndex && _listEnumeration.at(curIndex).filterFlag == 0 && !_listEnumeration.at(curIndex).bDontHide);
			
		onItemPress(curIndex, 0);
	}

	// Moves the selection right to the next element. Wraps around.
	public function moveSelectionRight()
	{
		if (_bDisableSelection)
			return;
			
		var curIndex = _selectedIndex;
		var startIndex = _selectedIndex;
			
		do {
			if (curIndex < _segmentOffset + _segmentLength - 1) {
				curIndex++;
			} else {
				_bFastSwitch = true;
				curIndex = _segmentOffset;
			}
		} while (curIndex != startIndex && _listEnumeration.at(curIndex).filterFlag == 0 && !_listEnumeration.at(curIndex).bDontHide);
			
		onItemPress(curIndex, 0);
	}
	
	// GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var processed = false;

		if (!_bDisableInput) {
			var entry = getClipByIndex(selectedIndex);

			processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

			if (!processed && GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.LEFT) {
					moveSelectionLeft();
					processed = true;
				} else if (details.navEquivalent == NavigationCode.RIGHT) {
					moveSelectionRight();
					processed = true;
				} else if (!_bDisableSelection && details.navEquivalent == NavigationCode.ENTER) {
					onItemPress(0);
					processed = true;
				}
			}
		}
		return processed;
	}
	
	// @override MovieClip
	public function onEnterFrame()
	{
		if (_bFastSwitch && _selectorPos != _targetSelectorPos) {
			_selectorPos = _targetSelectorPos;
			_bFastSwitch = false;
			refreshSelector();
			
		} else  if (_selectorPos < _targetSelectorPos) {
			_selectorPos = _selectorPos + (_targetSelectorPos - _selectorPos) * 0.2 + 1;
			
			refreshSelector();
			
			if (_selectorPos > _targetSelectorPos)
				_selectorPos = _targetSelectorPos;
			
		} else if (_selectorPos > _targetSelectorPos) {
			_selectorPos = _selectorPos - (_selectorPos - _targetSelectorPos) * 0.2 - 1;
			
			refreshSelector();
			
			if (_selectorPos < _targetSelectorPos)
				_selectorPos = _targetSelectorPos;
		}
	}
	
	// @override skyui.BasicList
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (_bDisableInput || _bDisableSelection || a_index == -1)
			return;
			
		doSetSelectedIndex(a_index, a_keyboardOrMouse);
		updateSelector();
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	// @override skyui.BasicList
	public function onItemRollOver(a_index: Number): Void
	{
		if (_bDisableInput || _bDisableSelection)
			return;
			
		_bMouseDrivenNav = true;
		
		if (a_index == _selectedIndex)
			return;
			
		var entryClip = getClipByIndex(a_index);
		entryClip._alpha = 75;
	}

	// @override skyui.BasicList
	public function onItemRollOut(a_index: Number): Void
	{
		if (_bDisableInput || _bDisableSelection)
			return;
			
		_bMouseDrivenNav = true;
		
		if (a_index == _selectedIndex)
			return;
			
		var entryClip = getClipByIndex(a_index);
		entryClip._alpha = 50;
	}


  /* PRIVATE FUNCTIONS */
  
  	// @override skyui.BasicList
	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (_bDisableSelection || a_newIndex == _selectedIndex)
			return;
			
		var oldIndex = _selectedIndex;
		_selectedIndex = a_newIndex;

		if (oldIndex != -1)
			setEntry(_entryClipManager.getClipByIndex(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);

		if (_selectedIndex != -1)
			setEntry(_entryClipManager.getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);

		dispatchEvent({type: "selectionChange", index: _selectedIndex, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function calculateSegmentParams(): Void
	{
		// Divided
		if (dividerIndex != undefined && dividerIndex != -1) {
			if (_activeSegment == LEFT_SEGMENT) {
				_segmentOffset = 0;
				_segmentLength = dividerIndex;
			} else {
				_segmentOffset = dividerIndex + 1;
				_segmentLength = _listEnumeration.size() - _segmentOffset;
			}
		
		// Default for non-divided lists
		} else {
			_segmentOffset = 0;
			_segmentLength = _listEnumeration.size();
		}
	}
	
	private function updateSelector(): Void
	{
		if (selectorCenter == undefined) {
			return;
		}
			
		if (_selectedIndex == -1) {
			selectorCenter._visible = false;

			if (selectorLeft != undefined) {
				selectorLeft._visible = false;
			}
			if (selectorRight != undefined) {
				selectorRight._visible = false;
			}

			return;
		}

		var selectedClip = _entryClipManager.getClipByIndex(_selectedIndex - _segmentOffset);

		_targetSelectorPos = selectedClip._x + (selectedClip.buttonArea._width - selectorCenter._width) / 2;
		
		selectorCenter._visible = true;
		selectorCenter._y = selectedClip._y + selectedClip.buttonArea._height;
		
		if (selectorLeft != undefined) {
			selectorLeft._visible = true;
			selectorLeft._x = 0;
			selectorLeft._y = selectorCenter._y;
		}

		if (selectorRight != undefined) {
			selectorRight._visible = true;
			selectorRight._y = selectorCenter._y;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}

	private function refreshSelector(): Void
	{
		selectorCenter._visible = true;
		var selectedClip = _entryClipManager.getClipByIndex(_selectedIndex - _segmentOffset);

		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined) {
			selectorLeft._width = selectorCenter._x;
		}

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}
}