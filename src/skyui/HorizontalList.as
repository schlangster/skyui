import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class skyui.HorizontalList extends skyui.DynamicList
{
	static var FILL_BORDER = 0;
	static var FILL_PARENT = 1;
	static var FILL_STAGE = 2;

	private var _bNoIcons:Boolean;
	private var _bNoText:Boolean;
	private var _xOffset:Number;
	private var _fillType:Number;
	private var _contentWidth:Number;
	private var _totalWidth:Number;
	private var _selectorPos:Number;
	private var _targetSelectorPos:Number;

	// Component settings
	var buttonOption:String;
	var fillOption:String;
	var borderWidth:Number;
	// iconX holds label name for iconX

	// Children
	var selectorCenter:MovieClip;
	var selectorLeft:MovieClip;
	var selectorRight:MovieClip;
	

	function HorizontalList()
	{
		super();
		
		_selectorPos = 0;
		_targetSelectorPos = 0;

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
	}
	
	function restoreSelectedEntry(a_newIndex:Number)
	{
		doSetSelectedIndex(a_newIndex,0);
		onItemPress(1);
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

		// How about proper closures? :(
		entryClip.buttonArea.onRollOver = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined) {

				if (_parent.itemIndex != _parent._parent._selectedIndex) {
					_parent._alpha = 75;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.buttonArea.onRollOut = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined) {

				if (_parent.itemIndex != _parent._parent._selectedIndex) {
					_parent._alpha = 50;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entryClip.buttonArea.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
		{
			if (_parent.itemIndex != undefined && !_parent._parent.listAnimating && !_parent._parent._bDisableInput) {

				_parent._parent.doSetSelectedIndex(_parent.itemIndex,0);
				_parent._parent.onItemPress(aiKeyboardOrMouse);

				if (!_parent._parent._bDisableInput && _parent.onMousePress != undefined) {
					_parent.onMousePress();
				}
			}
		};

		entryClip.buttonArea.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
		{
			if (_parent.itemIndex != undefined) {
				_parent._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
			}
		};

		if (!_bNoIcons && this["icon" + a_index] != undefined) {
			entryClip.icon.gotoAndStop(this["icon" + a_index]);

			if (_bNoText) {
				entryClip.textField._visible = false;
			}
		} else {
			entryClip.icon._visible = false;
			entryClip.textField._x = 0;
		}

		return entryClip;
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

		for (var i = 0; i < _entryList.length; i++) {
			var entryClip = getClipByIndex(i);

			setEntry(entryClip,_entryList[i]);

			_entryList[i].clipIndex = i;
			entryClip.itemIndex = i;

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

		var spacing = (_totalWidth - _contentWidth) / (_entryList.length + 1);

		var xPos = xOffset + _indent + spacing;

		for (var i = 0; i < _entryList.length; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;

			xPos = xPos + entryClip.buttonArea._width + spacing;
			entryClip._visible = true;
		}
		
		updateSelector();
	}
	
	function onEnterFrame()
	{
		if (_selectorPos < _targetSelectorPos) {
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

		var selectedClip = getClipByIndex(_selectedIndex);

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
		var selectedClip = getClipByIndex(_selectedIndex);

		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined) {
			selectorLeft._width = selectorCenter._x;
		}

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}

	function onItemPress(a_keyboardOrMouse)
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
			if (selectedIndex > 0) {
				selectedIndex = selectedIndex - 1;
				onItemPress(0);
			}
		}
	}

	function moveSelectionRight()
	{
		if (!_bDisableSelection) {
			if (selectedIndex < _entryList.length - 1) {
				selectedIndex = selectedIndex + 1;
				onItemPress(0);
			}
		}
	}
	
	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip != undefined) {
			if (a_entryObject == selectedEntry) {
				a_entryClip._alpha = 100;
			} else {
				a_entryClip._alpha = 50;
			}

			setEntryText(a_entryClip,a_entryObject);
		}
	}
}