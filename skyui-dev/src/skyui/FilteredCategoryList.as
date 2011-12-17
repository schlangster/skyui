import Shared.ListFilterer;
import skyui.IFilter;
import skyui.Defines;

class skyui.FilteredCategoryList extends skyui.DynamicList
{
	private var _filteredList:Array;
	private var _filterChain:Array;
	static var FILL_BORDER = 0;
	static var FILL_PARENT = 1;
	static var FILL_STAGE = 2;

	private var _bNoIcons:Boolean;
	private var _bNoText:Boolean;
	private var _xOffset:Number;
	private var _fillType:Number;
	private var _bSetInitialIndex:Boolean;
	private var _contentWidth:Number;
	private var _totalWidth:Number;

	function FilteredCategoryList()
	{
		super();
		_filteredList = new Array();
		_filterChain = new Array();
	}

	function addFilter(a_filter:IFilter)
	{
		_global.skse.Log("addFilter " + a_filter);
		_filterChain.push(a_filter);
	}

	function getFilteredEntry(a_index:Number):Object
	{
		return _filteredList[a_index];
	}

	// Did you mean: numFilteredItems() ?
	function get numUnfilteredItems():Number
	{
		return _filteredList.length;
	}

	function generateFilteredList()
	{
		_global.skse.Log("generateFilteredList()");
		_filteredList.splice(0);

		_global.skse.Log("generateFilteredList() copy entrylist into filteredlist");
		for (var i = 0; i < _entryList.length; i++)
		{
			_entryList[i].unfilteredIndex = i;
			_entryList[i].filteredIndex = undefined;
			_filteredList[i] = _entryList[i];
		}

		_global.skse.Log("generateFilteredList() process");
		for (var i = 0; i < _filterChain.length; i++)
		{
			_filterChain[i].process(_filteredList);
		}

		_global.skse.Log("generateFilteredList() set filtered indexes");
		for (var i = 0; i < _filteredList.length; i++)
		{
			_filteredList[i].filteredIndex = i;
		}

		if (selectedEntry.filteredIndex == undefined)
		{
			_selectedIndex = -1;
		}
	}


	// Gets a clip, or if it doesn't exist, creates it.
	function getClipByIndex(a_index):MovieClip
	{
		_global.skse.Log("getClipByIndex " + a_index);
		var entryClip = this["Entry" + a_index];

		if (entryClip != undefined)
		{
			return entryClip;
		}
		// Create on-demand      
		entryClip = attachMovie(_entryClassName, "Entry" + a_index, a_index);

		entryClip.clipIndex = a_index;

		// How about proper closures? :(
		entryClip.buttonArea.onRollOver = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined)
			{

				if (_parent.itemIndex != _parent._parent._selectedIndex)
				{
					_parent._alpha = 75;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entryClip.buttonArea.onRollOut = function()
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput && _parent.itemIndex != undefined)
			{

				if (_parent.itemIndex != _parent._parent._selectedIndex)
				{
					_parent._alpha = 50;
				}
				_parent._parent._bMouseDrivenNav = true;
			}
		};

		entryClip.buttonArea.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
		{
			if (_parent.itemIndex != undefined && !_parent._parent.listAnimating && !_parent._parent._bDisableInput)
			{

				_parent._parent.doSetSelectedIndex(_parent.itemIndex,0);
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
		_global.skse.Log("UpdateList()");
		var cw = _indent * 2;
		var tw = 0;
		var xOffset = 0;
		var _listIndex = 0;

		if (_fillType == FILL_PARENT)
		{
			xOffset = _parent._x;
			tw = _parent._width;
		}
		else if (_fillType == FILL_STAGE)
		{
			xOffset = 0;
			tw = Stage.visibleRect.width;
		}
		else
		{
			xOffset = border._x;
			tw = border._width;
		}

		for (var i = 0; i < _filteredList.length; i++)
		{
			_filteredList[i].clipIndex = undefined;
		}

		_global.skse.Log("filteredList length = " + _filteredList.length);
		for (var i = 0; i < _filteredList.length; i++)
		{
			_global.skse.Log("UpdateList() getClipByIndex " + _listIndex + " for entry " + _filteredList[i]);
			var entryClip = getClipByIndex(_listIndex);
			setCategoryIcons(entryClip,_filteredList[i]);
			_global.skse.Log("Setting entry " + _filteredList[i].text);
			setEntry(entryClip,_filteredList[i]);
			_global.skse.Log("Setting clip " + entryClip + " itemIndex = " + _filteredList[i].unfilteredIndex);
			entryClip.itemIndex = _filteredList[i].unfilteredIndex;
			_filteredList[i].clipIndex = _listIndex;

			entryClip.textField.autoSize = "left";

			var w = 0;
			if (entryClip.icon._visible)
			{
				w = w + entryClip.icon._width;
			}
			if (entryClip.textField._visible)
			{
				w = w + entryClip.textField._width;
			}
			entryClip.buttonArea._width = w;
			cw = cw + w;
			_listIndex++;
			var catInfo = _filteredList[i];
			_global.skse.Log("reading category info for " + _filteredList[i].text);
			for(var key:String in catInfo);
			{
				_global.skse.Log(key + ": " + catInfo[key]);
			}
		}

		_global.skse.Log("filteredList length = " + _filteredList.length + " , size = " + _listIndex);
		_contentWidth = cw;
		_totalWidth = tw;

		var spacing = (_totalWidth - _contentWidth) / (_filteredList.length + 1);
		var spacing = (_totalWidth - _contentWidth) / (_filteredList.length + 1);

		var xPos = xOffset + _indent + spacing;

		for (var i = 0; i < _filteredList.length; i++)
		{
			_global.skse.Log("_filteredList[i] = " + _filteredList[i]);
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;
			_global.skse.Log("clip index in pos " + i + " = " + entryClip.itemIndex);
			xPos = xPos + entryClip.buttonArea._width + spacing;
			//_global.skse.Log("setting clip " + entryList[_indexMap[i]] + " visible to true");
			entryClip._visible = true;

		}


	}

	function setCategoryIcons(entryClip, entry)
	{
		_global.skse.Log("flag = " + entry.flag + " , Setting category icon for clip " + entryClip);
		if (_bNoText || entry.flag == 0)
		{
			entryClip.textField._visible = false;
		}
		if (!_bNoIcons)
		{
			switch (entry.flag)
			{
				case Defines.FLAG_ITEM_FAVORITES :
					entryClip.icon.gotoAndStop(this["icon0"]);
					break;
				case Defines.FLAG_BARTER_ALL :
				case Defines.FLAG_ITEM_ALL :
					entryClip.icon.gotoAndStop(this["icon1"]);
					break;
				case Defines.FLAG_BARTER_WEAPONS :
				case Defines.FLAG_ITEM_WEAPONS :
					entryClip.icon.gotoAndStop(this["icon2"]);
					break;
				case Defines.FLAG_BARTER_ARMOR :
				case Defines.FLAG_ITEM_ARMOR :
					entryClip.icon.gotoAndStop(this["icon3"]);
					break;
				case Defines.FLAG_BARTER_POTIONS :
				case Defines.FLAG_ITEM_POTIONS :
					entryClip.icon.gotoAndStop(this["icon4"]);
					break;
				case Defines.FLAG_BARTER_SCROLLS :
				case Defines.FLAG_ITEM_SCROLLS :
					entryClip.icon.gotoAndStop(this["icon5"]);
					break;
				case Defines.FLAG_BARTER_FOOD :
				case Defines.FLAG_ITEM_FOOD :
					entryClip.icon.gotoAndStop(this["icon6"]);
					break;
				case Defines.FLAG_ENCHANTING_SOULGEM :
				case Defines.FLAG_BARTER_INGREDIENTS :
				case Defines.FLAG_ITEM_INGREDIENTS :
					if (entry.text == "Soul Gem")
					{
						entryClip.icon._visible = false;// temp until we get icon
						entryClip.textField._visible = true;
						break;
					}
					else
					{
						entryClip.icon.gotoAndStop(this["icon7"]);
						break;
					}
				case Defines.FLAG_BARTER_BOOKS :
				case Defines.FLAG_ITEM_BOOKS :
					entryClip.icon.gotoAndStop(this["icon8"]);
					break;
				case Defines.FLAG_BARTER_KEYS :
				case Defines.FLAG_ITEM_KEYS :
					entryClip.icon.gotoAndStop(this["icon9"]);
					break;
				case Defines.FLAG_BARTER_MISC :
				case Defines.FLAG_ITEM_MISC :
					entryClip.icon.gotoAndStop(this["icon10"]);
					break;
				case Defines.FLAG_ENCHANTING_DISENCHANT :
					entryClip.icon._visible = false;// temp until we get icon
					entryClip.textField._visible = true;
					break;
				case Defines.FLAG_ENCHANTING_ITEM :
					entryClip.icon._visible = false;// temp until we get icon
					entryClip.textField._visible = true;
					break;
				case Defines.FLAG_ENCHANTING_ENCHANTMENT :
					entryClip.icon._visible = false;// temp until we get icon
					entryClip.textField._visible = true;
					break;
				default :
					entryClip.icon.gotoAndStop(this["icon10"]);
					break;
			}
		}
		else
		{
			entryClip.icon._visible = false;
			entryClip.textField._x = 0;
		}
	}

	function InvalidateData()
	{
		_global.skse.Log("FilteredCategoryList InvalidateData() calling generateFilteredList()");
		generateFilteredList();
		super.InvalidateData();
	}

	function moveSelectionLeft()
	{
		_global.skse.Log("FilteredCategoryList moveSelectionLeft()");
		_global.skse.Log("current selectedindex = " + selectedIndex);
		if (!_bDisableSelection)
		{
			if (isDivider(_filteredList[selectedEntry.filteredIndex - 1]))
			{
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex - 2].unfilteredIndex,1);
				onItemPress(0);
			}
			else if (selectedEntry.filteredIndex > 0)
			{
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex - 1].unfilteredIndex,1);
				_global.skse.Log("move left to selectedIndex " + selectedIndex);
				onItemPress(0);
			}
		}
	}
	function moveSelectionRight()
	{
		_global.skse.Log("FilteredCategoryList moveSelectionRight()");
		_global.skse.Log("current selectedindex = " + selectedIndex);
		if (!_bDisableSelection)
		{
			if (isDivider(_filteredList[selectedEntry.filteredIndex + 1]))
			{
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex + 2].unfilteredIndex,1);
				onItemPress(0);
			}
			else if (selectedEntry.filteredIndex < _filteredList.length - 1 && !isDivider(selectedEntry))
			{
				doSetSelectedIndex(_filteredList[selectedEntry.filteredIndex + 1].unfilteredIndex,1);
				_global.skse.Log("move right to selectedIndex " + selectedIndex);
				onItemPress(0);
			}
		}
	}

	function doSetSelectedIndex(a_newIndex:Number, a_keyboardOrMouse:Number)
	{
		_global.skse.Log("doSetSelectedIndex a_newIndex = " + a_newIndex);
		if (!_bDisableSelection && a_newIndex != _selectedIndex)
		{
			var oldIndex = _selectedIndex;
			_selectedIndex = a_newIndex;

			if (oldIndex != -1)
			{
				_global.skse.Log("old getClipByIndex(" + oldIndex + ") = " + getClipByIndex(_entryList[oldIndex].filteredIndex) + " , entry = " + _entryList[oldIndex].text);
				setEntry(getClipByIndex(_entryList[oldIndex].filteredIndex),_entryList[oldIndex]);
			}

			if (_selectedIndex != -1)
			{
				_global.skse.Log("new getClipByIndex(" + _selectedIndex + ") = " + getClipByIndex(_entryList[_selectedIndex].filteredIndex) + " , entry = " + _entryList[_selectedIndex].text);
				setEntry(getClipByIndex(_entryList[_selectedIndex].filteredIndex),_entryList[_selectedIndex]);
			}

			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		_global.skse.Log("setEntry " + a_entryObject.text);
		if (a_entryClip != undefined)
		{
			if (a_entryObject == selectedEntry)
			{
				a_entryClip._alpha = 100;
			}
			else
			{
				a_entryClip._alpha = 50;
			}

			setEntryText(a_entryClip,a_entryObject);
		}
	}


	function isDivider(a_entryObject)
	{
		return (a_entryObject.divider == true || a_entryObject.entry.flag == 0);
	}

	function onFilterChange()
	{
		_global.skse.Log("onFilterChange()");
		generateFilteredList();
		UpdateList();
	}
}