import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class dui.HorizontalList extends dui.DynamicList
{
	private var _spacing:Number = 50;

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
		var entry = this["Entry" + a_index];

		if (entry != undefined)
		{
			return entry;
		}
		
		// Create on-demand  
		entry = attachMovie(_entryClassName, "Entry" + a_index, a_index);

		entry.clipIndex = a_index;

		entry.buttonArea.onRollOver = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent._itemIndex != undefined)
			{
				_parent._parent.doSetSelectedIndex(_parent._itemIndex, 0);
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entry.buttonArea.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
		{
			if (_parent._itemIndex != undefined)
			{
				_parent._parent.onItemPress(aiKeyboardOrMouse);
				if (!_parent._parent._bDisableInput && _parent.onMousePress != undefined)
				{
					_parent.onMousePress();
				}
			}
		};

		entry.buttonArea.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
		{
			if (_parent._itemIndex != undefined)
			{
				_parent._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
			}
		};

		return entry;
	}

	function UpdateList()
	{
		var xOffset = this._x;

		for (var i = 0; i < _entryList.length; i++)
		{
			var item = getClipByIndex(i);

			setEntry(item,_entryList[i]);
			_entryList[i].clipIndex = i;
			item._itemIndex = i;

			item.textField.autoSize = "left";
			item.buttonArea._width = item.textField._width;

			item._x = xOffset;

			xOffset = xOffset + item.buttonArea._width + _spacing;
			item.visible = true;
			_listIndex++;
		}
	}
}