import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class dui.HorizontalList extends dui.DynamicList
{
	// Component settings
	private var _bUseIcons;
	// iconX holds label name of iconX

	// Children
	var border:MovieClip;

	var onMousePress:Function;
	var dispatchEvent:Function;

	function HorizontalList()
	{
		super();
		_indent = 5;

		if (_bUseIcons == undefined) {
			_bUseIcons = false;
		}
	}
	
	function set useIcons(a_bFlag:Boolean)
	{
		_bUseIcons = a_bFlag;
	}
	
	function get useIcons():Boolean
	{
		return _bUseIcons;
	}

	function getClipByIndex(a_index)
	{
		var entryClip = this["Entry" + a_index];

		if (entryClip != undefined)
		{
			return entryClip;
		}
		
		// Create on-demand  
		entryClip = attachMovie(_entryClassName, "Entry" + a_index, a_index);

		entryClip.clipIndex = a_index;

		entryClip.buttonArea.onRollOver = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined)
			{
				_parent._parent.doSetSelectedIndex(_parent.itemIndex, 0);
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entryClip.buttonArea.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
		{
			if (_parent.itemIndex != undefined)
			{				
				
				_parent._parent.onItemPress(aiKeyboardOrMouse);
				if (!_parent._parent._bDisableInput && _parent.onMousePress != undefined)
				{
					_parent.onMousePress();
				}
			}
		};

		entryClip.buttonArea.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
		{
			if (_parent.itemIndex != undefined)
			{
				_parent._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
			}
		};
		
		if (_bUseIcons) {
			if (this["icon" + a_index] != undefined) {
				entryClip.icon.gotoAndStop(this["icon" + a_index]);
			} else {
				entryClip.icon._visible = false;
				entryClip.textField._x = 0;
			}
		}

		return entryClip;
	}

	function UpdateList()
	{
		var xOffset = _indent;
		var contentWidth = _indent * 2;

		for (var i = 0; i < _entryList.length; i++)
		{
			var entryClip = getClipByIndex(i);

			setEntry(entryClip, _entryList[i]);
			
			_entryList[i].clipIndex = i;
			entryClip.itemIndex = i;

			entryClip.textField.autoSize = "left";
			
			if (_bUseIcons && entryClip.icon._visible) {
				entryClip.buttonArea._width = entryClip.textField._width + entryClip.icon._width + 5;				
			} else {
				entryClip.buttonArea._width = entryClip.textField._width + 5;				
			}
			
			contentWidth = contentWidth + entryClip.buttonArea._width;
		}
		
		var spacing = (Stage.visibleRect.width - contentWidth) / _entryList.length;
		
		for (var i = 0; i < _entryList.length; i++)
		{
			var entryClip = getClipByIndex(i);
			entryClip._x = xOffset;

			xOffset = xOffset + entryClip.buttonArea._width + spacing;
			entryClip._visible = true;
		}
	}
}