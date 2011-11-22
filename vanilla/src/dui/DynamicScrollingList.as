import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;

class dui.DynamicScrollingList extends dui.DynamicList
{
	private var _scrollPosition:Number;
	private var _maxScrollPosition:Number;

	private var _maxListIndex:Number;
	private var _listHeight:Number;

	private var _scrollbarDrawTimerID;

	private var _itemInfo:Object;

	// Children
	var scrollbar:MovieClip;
	var ScrollUp:MovieClip;
	var ScrollDown:MovieClip;

	var debug;

	// Constructor
	function DynamicScrollingList()
	{
		super();
		
		_scrollPosition = 0;
		_maxScrollPosition = 0;
		_listHeight = border._height;
		_maxListIndex = Math.floor(_listHeight / 50);
	}

	function onLoad()
	{
		if (scrollbar != undefined)
		{
			scrollbar.position = 0;
			scrollbar.addEventListener("scroll",this,"onScroll");
		}
	}

	function handleInput(details, pathToFocus):Boolean
	{
		var processed = false;
		
		if (!_bDisableInput)
		{
			var entry = getClipByIndex(selectedIndex - scrollPosition);

			processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

			if (!processed && GlobalFunc.IsKeyPressed(details))
			{
				if (details.navEquivalent == NavigationCode.UP)
				{
					moveSelectionUp();
					processed = true;
				}
				else if (details.navEquivalent == NavigationCode.DOWN)
				{
					moveSelectionDown();
					processed = true;
				}
				else if (!_bDisableSelection && details.navEquivalent == NavigationCode.ENTER)
				{
					onItemPress();
					processed = true;
				}
			}
		}
		return processed;
	}

	function onMouseWheel(delta)
	{

		if (!_bDisableInput)
		{
			for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent)
			{
				if (target == this)
				{
					doSetSelectedIndex(-1,0);

					if (delta < 0)
					{
						scrollPosition = scrollPosition + 1;
					}
					else if (delta > 0)
					{
						scrollPosition = scrollPosition - 1;
					}
				}
			}
		}
	}

	function doSetSelectedIndex(a_newIndex:Number, a_keyboardOrMouse:Number)
	{
		if (!_bDisableSelection && a_newIndex != _selectedIndex)
		{
			var oldIndex = _selectedIndex;
			_selectedIndex = a_newIndex;

			if (oldIndex != -1)
			{
				setEntry(getClipByIndex(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);
			}

			if (_selectedIndex != -1)
			{
				if (_platform != 0)
				{
					if (_selectedIndex < _scrollPosition)
					{
						scrollPosition = _selectedIndex;
					}
					else if (_selectedIndex >= _scrollPosition + _listIndex)
					{
						scrollPosition = Math.min(_selectedIndex - _listIndex + 1, _maxScrollPosition);
					}
					else
					{
						setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
					}
				}
				else
				{
					setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
				}
			}
			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function get scrollPosition()
	{
		return _scrollPosition;
	}

	function get maxScrollPosition()
	{
		return _maxScrollPosition;
	}

	function set scrollPosition(a_newPosition)
	{
		if (a_newPosition != _scrollPosition && a_newPosition >= 0 && a_newPosition <= _maxScrollPosition)
		{

			if (scrollbar != undefined)
			{
				scrollbar.position = a_newPosition;
			}
			else
			{
				updateScrollPosition(a_newPosition);
			}
		}
	}

	function updateScrollPosition(a_position)
	{
		_scrollPosition = a_position;
		UpdateList();
	}

	function UpdateList()
	{
		var yStart = 100;
		var yOffset = 0;

		for (var i = 0; i < _scrollPosition; i++)
		{
			_entryList[i].clipIndex = undefined;
		}

		_listIndex = 0;

		for (var pos = _scrollPosition; pos < _entryList.length && _listIndex < _maxListIndex && yOffset <= _listHeight; pos++)
		{
			var entry = getClipByIndex(_listIndex);

			setEntry(entry,_entryList[pos]);
			_entryList[pos].clipIndex = _listIndex;
			entry._itemIndex = pos;

			entry._y = yStart + yOffset;
			entry._visible = true;

			yOffset = yOffset + entry._height;

			if (yOffset <= _listHeight && _listIndex < _maxListIndex)
			{
				++_listIndex;
			}
		}

		for (var i = _listIndex; i < _maxListIndex; i++)
		{
			getClipByIndex(i)._visible = false;
			getClipByIndex(i)._itemIndex = undefined;
		}

		if (ScrollUp != undefined)
		{
			ScrollUp._visible = scrollPosition > 0;
		}

		if (ScrollDown != undefined)
		{
			ScrollDown._visible = scrollPosition < _maxScrollPosition;
		}
	}

	var counter = 0;

	function InvalidateData()
	{
		debug.textField.SetText("Invalidated" + counter++);
		
		for (var i = 0; i < _entryList.length; i++)
		{
			requestItemInfo(i);
			
			switch (_itemInfo.type)
	        {
				case InventoryDefines.ICT_ARMOR:
				{
					_entryList[i]._infoStat = _itemInfo.armor;
					break;
				} 
				case InventoryDefines.ICT_WEAPON:
				{
					_entryList[i]._infoStat = _itemInfo.damage;
					break;
				} 
				case InventoryDefines.ICT_SPELL:
				case InventoryDefines.ICT_SHOUT:
				{
					_entryList[i]._infoStat = _itemInfo.spellCost.toString();
					break;
				} 
				case InventoryDefines.ICT_SOUL_GEMS:
				{
					_entryList[i]._infoStat = _itemInfo.soulLVL;
					break;
				} 
				default:
				{
					_entryList[i]._infoStat = undefined;
				} 
			}

			_entryList[i]._infoValue = _itemInfo.value;
			_entryList[i]._infoWeight = _itemInfo.weight;
		}
		
		var lastPosition = _maxScrollPosition;

		_listHeight = border._height;
		calculateMaxScrollPosition();

		if (scrollbar != undefined)
		{
			if (lastPosition != _maxScrollPosition)
			{
				scrollbar._visible = false;
				scrollbar.setScrollProperties(_maxListIndex,0,_maxScrollPosition);
				if (_scrollbarDrawTimerID != undefined)
				{
					clearInterval(_scrollbarDrawTimerID);
				}
				_scrollbarDrawTimerID = setInterval(this, "setScrollbarVisibility", 50);
			}
			else
			{
				setScrollbarVisibility();
			}
		}

		if (_selectedIndex >= _entryList.length)
		{
			_selectedIndex = _entryList.length - 1;
		}

		if (_scrollPosition > _maxScrollPosition)
		{
			_scrollPosition = _maxScrollPosition;
		}

		UpdateList();
	}

	function setScrollbarVisibility()
	{
		clearInterval(_scrollbarDrawTimerID);
		_scrollbarDrawTimerID = undefined;
		scrollbar._visible = _maxScrollPosition > 0;
	}

	function calculateMaxScrollPosition()
	{
		var t = _entryList.length - _maxListIndex;
		_maxScrollPosition = (t > 0)? t : 0;
	}

	function moveSelectionUp()
	{
		if (!_bDisableSelection)
		{
			if (selectedIndex > 0)
			{
				selectedIndex = selectedIndex - 1;
			}
		}
		else
		{
			scrollPosition = scrollPosition - 1;
		}
	}

	function moveSelectionDown()
	{
		if (!_bDisableSelection)
		{
			if (selectedIndex < _entryList.length - 1)
			{
				selectedIndex = selectedIndex + 1;
			}
		}
		else
		{
			scrollPosition = scrollPosition + 1;
		}
	}

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip.textField != undefined)
		{
			if (textOption == Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT)
			{
				a_entryClip.textField.textAutoSize = "shrink";
			}
			else if (textOption == Shared.BSScrollingList.TEXT_OPTION_MULTILINE)
			{
				a_entryClip.textField.verticalAutoSize = "top";
			}

			if (a_entryObject.text != undefined)
			{
				a_entryClip.textField.SetText(a_entryObject.text);
				a_entryClip.weightField.SetText(a_entryObject._infoWeight);
				a_entryClip.valueField.SetText(a_entryObject._infoValue);

				if (a_entryObject._infoStat != undefined)
				{
					a_entryClip.statField.SetText(a_entryObject._infoStat);
				}
				else
				{
					a_entryClip.statField.SetText(" ");
				}
			}
			else
			{
				a_entryClip.textField.SetText(" ");
			}

			if (a_entryObject.enabled != undefined)
			{
				a_entryClip.textField.textColor = a_entryObject.enabled == false ? (6316128) : (16777215);
			}

			if (a_entryObject.disabled != undefined)
			{
				a_entryClip.textField.textColor = a_entryObject.disabled == true ? (6316128) : (16777215);
			}
		}
	}

	function updateItemInfo(a_updateObj:Object)
	{
		this._itemInfo = a_updateObj;
	}

	function requestItemInfo(a_index:Number)
	{
		var oldIndex = _selectedIndex;
		_selectedIndex = a_index;
		GameDelegate.call("RequestItemCardInfo",[],this,"updateItemInfo");
		_selectedIndex = oldIndex;
	}

	function onScroll(event)
	{
		updateScrollPosition(Math.floor(event.position + 0.500000));
	}
}