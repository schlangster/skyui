import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class dui.HorizontalList extends dui.DynamicList
{
	private var _spacing:Number = 50;
	
	// Component settings
	private var _entryClassName:String;
	private var _textOption:Number;

	// Children
	var border:MovieClip;

	var onMousePress:Function;
	var dispatchEvent:Function;

	function HorizontalList()
	{
		super();
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

		return entryClip;
	}

	function UpdateList()
	{
		var xOffset = 50;
		var contentWidth = 100;

		for (var i = 0; i < _entryList.length; i++)
		{
			var entryClip = getClipByIndex(i);

			setEntry(entryClip, _entryList[i]);
			
			_entryList[i].clipIndex = i;
			entryClip.itemIndex = i;

			entryClip.textField.autoSize = "left";
			entryClip.buttonArea._width = entryClip.textField._width + 20;
			
			contentWidth = contentWidth + entryClip.buttonArea._width;
		}
		
		var spacing = (Stage.visibleRect.width - contentWidth) / _entryList.length;
		
		for (var i = 0; i < _entryList.length; i++)
		{
			var entryClip = getClipByIndex(i);
			entryClip._x = xOffset;

			xOffset = xOffset + entryClip.buttonArea._width + spacing;
			entryClip.visible = true;
		}
	}
}