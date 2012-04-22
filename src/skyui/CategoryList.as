import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;


class skyui.CategoryList extends skyui.DynamicList
{
	static var LEFT_SEGMENT = 0;
	static var RIGHT_SEGMENT = 1;
	
	private var _xOffset:Number;
	private var _contentWidth:Number;
	private var _totalWidth:Number;
	private var _selectorPos:Number;
	private var _targetSelectorPos:Number;
	private var _bFastSwitch:Boolean;
	
	private var _iconArt:Array;
	
	private var _dividerIndex:Number;

	private var _activeSegment:Number;
	private var _segmentOffset:Number;
	private var _segmentLength:Number;

	// Component settings
	var iconIndent:Number;
	var iconSize:Number;

	// Children
	var selectorCenter:MovieClip;
	var selectorLeft:MovieClip;
	var selectorRight:MovieClip;
	

	function CategoryList()
	{
		super();
		
		_selectorPos = 0;
		_targetSelectorPos = 0;
		_bFastSwitch = false;

		if (iconIndent != undefined) {
			_indent = iconIndent;
		}

		_activeSegment = LEFT_SEGMENT;
		_dividerIndex = -1;
		_segmentOffset = 0;
		_segmentLength = 0;
	}
	
	function set dividerIndex(a_index:Number)
	{
		_dividerIndex = a_index;
	}
	
	function get dividerIndex():Number
	{
		return _dividerIndex;
	}
	
	function set activeSegment(a_segment:Number)
	{
		if (a_segment == _activeSegment) {
			return;
		}
		
		_activeSegment = a_segment;
		
		calculateSegmentParams();
		
		if (a_segment == LEFT_SEGMENT && _selectedIndex > _dividerIndex) {
			doSetSelectedIndex(_selectedIndex - _dividerIndex - 1, 0);
		} else if (a_segment == RIGHT_SEGMENT && _selectedIndex < _dividerIndex) {
			doSetSelectedIndex(_selectedIndex + _dividerIndex + 1, 0);
		}
		
		UpdateList();
	}
	
	function get activeSegment():Number
	{
		return _activeSegment;
	}
	
	function clearList()
	{
		super.clearList();
		_dividerIndex = -1;
	}
	
	function restoreCategory(a_newIndex:Number)
	{
		doSetSelectedIndex(a_newIndex,1);
		onItemPress(1);
	}
	
	function setIconArt(a_iconArt:Array)
	{
		_iconArt = a_iconArt;
	}
	
	// override skyui.DynamicList
	function createEntryClip(a_index:Number):MovieClip
	{
		var entryClip = attachMovie(_entryClassName, "Entry" + a_index, getNextHighestDepth());
		
		if (_iconArt[a_index] != undefined) {
			entryClip.iconLabel = _iconArt[a_index];
			entryClip.icon.loadMovie("skyui_icons_celtic.swf");
		}
		
		entryClip.onRollOver = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined && this.enabled) {

				if (this.itemIndex != _parent._selectedIndex) {
					this._alpha = 75;
				}
				_parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.onRollOut = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined && this.enabled) {

				if (this.itemIndex != _parent._selectedIndex) {
					this._alpha = 50;
				}
				_parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (this.itemIndex != undefined && !_parent.listAnimating && !_parent._bDisableInput && this.enabled) {

				_parent.doSetSelectedIndex(this.itemIndex,0);
				_parent.onItemPress(a_keyboardOrMouse);

				if (!_parent._bDisableInput && this.onMousePress != undefined) {
					onMousePress();
				}
			}
		};
		
		entryClip.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (this.itemIndex != undefined && this.enabled) {
				_parent.onItemPressAux(a_keyboardOrMouse, a_buttonIndex);
			}
		};
		
		return entryClip;
	}
	
	// override skyui.DynamicList
	function InvalidateData()
	{
		calculateSegmentParams();
		super.InvalidateData();
	}
	
	function calculateSegmentParams()
	{
		// Divided
		if (_dividerIndex != undefined && _dividerIndex != -1) {
			if (_activeSegment == LEFT_SEGMENT) {
				_segmentOffset = 0;
				_segmentLength = _dividerIndex;
			} else {
				_segmentOffset = _dividerIndex + 1;
				_segmentLength = _entryList.length - _segmentOffset;
			}
		
		// Default for non-divided lists
		} else {
			_segmentOffset = 0;
			_segmentLength = _entryList.length;
		}
	}

	// override skyui.DynamicList
	function UpdateList()
	{
		var cw = _indent * 2;
		var tw = border._width;
		var xOffset = border._x;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);

			setEntry(entryClip,_entryList[i + _segmentOffset]);

			_entryList[i + _segmentOffset].clipIndex = i;
			entryClip.itemIndex = i + _segmentOffset;

			cw = cw + iconSize;
		}

		_contentWidth = cw;
		_totalWidth = tw;

		var spacing = (_totalWidth - _contentWidth) / (_segmentLength + 1);

		var xPos = xOffset + _indent + spacing;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;

			xPos = xPos + entryClip.buttonArea._width + spacing;
			entryClip._visible = true;
		}
		
		updateSelector();
	}
	
	function onEnterFrame()
	{
		if (_bFastSwitch && _selectorPos != _targetSelectorPos) {
			_selectorPos = _targetSelectorPos;
			_bFastSwitch = false;
			refreshSelector();
			
		} else  if (_selectorPos < _targetSelectorPos) {
			_selectorPos = _selectorPos + (_targetSelectorPos - _selectorPos) * 0.2 + 1;
			
			refreshSelector();
			
			if (_selectorPos > _targetSelectorPos) {
				_selectorPos = _targetSelectorPos;
			}
			
		} else if (_selectorPos > _targetSelectorPos) {
			_selectorPos = _selectorPos - (_selectorPos - _targetSelectorPos) * 0.2 - 1;
			
			refreshSelector();
			
			if (_selectorPos < _targetSelectorPos) {
				_selectorPos = _targetSelectorPos;
			}
		}
	}
	
	function updateSelector()
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

		var selectedClip = getClipByIndex(_selectedIndex - _segmentOffset);

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

	function refreshSelector()
	{
		selectorCenter._visible = true;
		var selectedClip = getClipByIndex(_selectedIndex - _segmentOffset);

		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined) {
			selectorLeft._width = selectorCenter._x;
		}

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}

	// override skyui.DynamicList
	function onItemPress(a_keyboardOrMouse:Number)
	{
		if (!_bDisableInput && !_bDisableSelection && _selectedIndex != -1) {
			updateSelector();
			dispatchEvent({type:"itemPress", index:_selectedIndex, entry:_entryList[_selectedIndex], keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function handleInput(details, pathToFocus):Boolean
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

	function moveSelectionLeft()
	{
		if (!_bDisableSelection) {
			var curIndex = _selectedIndex;
			var startIndex = _selectedIndex;
			
			do {
				if (curIndex > _segmentOffset) {
					curIndex--;
				} else {
					_bFastSwitch = true;
					curIndex = _segmentOffset + _segmentLength - 1;
					
				}
			} while (curIndex != startIndex && _entryList[curIndex].filterFlag == 0 && !_entryList[curIndex].bDontHide);
			
			doSetSelectedIndex(curIndex, 0);
			onItemPress(0);
		}
	}

	function moveSelectionRight()
	{
		if (!_bDisableSelection) {
			var curIndex = _selectedIndex;
			var startIndex = _selectedIndex;
			
			do {
				if (curIndex < _segmentOffset + _segmentLength - 1) {
					curIndex++;
				} else {
					_bFastSwitch = true;
					curIndex = _segmentOffset;
				}
			} while (curIndex != startIndex && _entryList[curIndex].filterFlag == 0 && !_entryList[curIndex].bDontHide);
			
			doSetSelectedIndex(curIndex, 0);
			onItemPress(0);
		}
	}
	
	// override skyui.DynamicList
	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip != undefined) {
			if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
				a_entryClip._alpha = 15;
				a_entryClip.enabled = false;
			} else if (a_entryObject == selectedEntry) {
				a_entryClip._alpha = 100;
				a_entryClip.enabled = true;
			} else {
				a_entryClip._alpha = 50;
				a_entryClip.enabled = true;
			}

			setEntryText(a_entryClip,a_entryObject);
		}
	}
}