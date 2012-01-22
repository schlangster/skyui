import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;


class skyui.CategoryList extends skyui.DynamicList
{
	static var FILL_BORDER = 0;
	static var FILL_PARENT = 1;
	static var FILL_STAGE = 2;
	
	static var LEFT_SEGMENT = 0;
	static var RIGHT_SEGMENT = 1;

	private var _bNoIcons:Boolean;
	private var _bNoText:Boolean;
	private var _xOffset:Number;
	private var _fillType:Number;
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
	var buttonOption:String;
	var fillOption:String;
	var borderWidth:Number;
	// iconX holds label name for iconX

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

		if (borderWidth != undefined) {
			_indent = borderWidth;
		}

		if (buttonOption == "text and icons") {
			_bNoIcons = false;

			_bNoText = false;
		} else if (buttonOption == "icons only") {
			_bNoIcons = false;
			_bNoText = true;
		} else {
			_bNoIcons = true;
			_bNoText = false;
		}

		if (fillOption == "parent") {
			_fillType = FILL_PARENT;
		} else if (fillOption == "stage") {
			_fillType = FILL_STAGE;
		} else {
			_fillType = FILL_BORDER;
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

	// Gets a clip, or if it doesn't exist, creates it.
	function getClipByIndex(a_index):MovieClip
	{
		var entryClip = this["Entry" + a_index];

		if (entryClip != undefined) {
			return entryClip;
		}
		
		// Create on-demand	 
		entryClip = attachMovie(_entryClassName, "Entry" + a_index, a_index);

		entryClip.clipIndex = a_index;

		entryClip.buttonArea.onRollOver = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined && _parent.enabled) {

				if (_parent.itemIndex != _parent._parent._selectedIndex) {
					_parent._alpha = 75;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.buttonArea.onRollOut = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined && _parent.enabled) {

				if (_parent.itemIndex != _parent._parent._selectedIndex) {
					_parent._alpha = 50;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entryClip.buttonArea.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
		{
			if (_parent.itemIndex != undefined && !_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.enabled) {

				_parent._parent.doSetSelectedIndex(_parent.itemIndex,0);
				_parent._parent.onItemPress(aiKeyboardOrMouse);

				if (!_parent._parent._bDisableInput && _parent.onMousePress != undefined) {
					_parent.onMousePress();
				}
			}
		};

		entryClip.buttonArea.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
		{
			if (_parent.itemIndex != undefined && _parent.enabled) {
				_parent._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
			}
		};

		if (!_bNoIcons && _iconArt[a_index] != undefined) {
			entryClip.icon.gotoAndStop(_iconArt[a_index]);

			if (_bNoText) {
				entryClip.textField._visible = false;
			}
		} else {
			entryClip.icon._visible = false;
			entryClip.textField._x = 0;
		}

		return entryClip;
	}
	
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

	function UpdateList()
	{
		var cw = _indent * 2;
		var tw = 0;
		var xOffset = 0;

		if (_fillType == FILL_PARENT) {
			xOffset = _parent._x;
			tw = _parent._width;
		} else if (_fillType == FILL_STAGE) {
			xOffset = 0;
			tw = Stage.visibleRect.width;
		} else {
			xOffset = border._x;
			tw = border._width;
		}

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);

			setEntry(entryClip,_entryList[i + _segmentOffset]);

			_entryList[i + _segmentOffset].clipIndex = i;
			entryClip.itemIndex = i + _segmentOffset;

			entryClip.textField.autoSize = "left";

			var w = 0;
			if (entryClip.icon._visible) {
				w = w + entryClip.icon._width;
			}
			if (entryClip.textField._visible) {
				w = w + entryClip.textField._width;
			}
			entryClip.buttonArea._width = w;
			cw = cw + w;
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