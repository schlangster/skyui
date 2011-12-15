import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import skyui.Config;

class skyui.DynamicList extends MovieClip
{
	static var TEXT_OPTION_NONE = 0;
	static var TEXT_OPTION_SHRINK_TO_FIT = 1;
	static var TEXT_OPTION_MULTILINE = 2;

	private var _entryList:Array;

	private var _platform:Number;
	private var _bDisableSelection:Boolean;
	private var _bDisableInput:Boolean;
	private var _bMouseDrivenNav:Boolean;
	private var _bListAnimating:Boolean;

	private var _selectedIndex:Number;
	private var _itemClipIndex:Number;
	
	private var _indent:Number;

	// Component settings
	private var _entryClassName:String;
	private var _textOption:Number;


	// Children
	var border:MovieClip;

	var onMousePress:Function;

	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;

	var debug;

	// Constructor
	function DynamicList()
	{
		_entryList = new Array();

		_bDisableSelection = false;
		_bDisableInput = false;
		_bMouseDrivenNav = false;

		EventDispatcher.initialize(this);
		Mouse.addListener(this);

		_selectedIndex = -1;
		_platform = 1;
		_indent = 0;
	}

	function set entryClassName(a_className:String)
	{
		_entryClassName = a_className;
	}

	function get entryClassName()
	{
		return _entryClassName;
	}

	function clearList()
	{
		_entryList.splice(0);
	}
	
	function createEntryClip(a_index:Number):MovieClip
	{
		return attachMovie(_entryClassName, "Entry" + a_index, getNextHighestDepth());
	}

	function getClipByIndex(a_index:Number)
	{
		if (a_index < 0) {
			return undefined;
		}
		
		var entryClip = this["Entry" + a_index];

		if (entryClip != undefined) {
			return entryClip;
		}
		
		// Create on-demand
		entryClip = createEntryClip(a_index);

		entryClip.clipIndex = a_index;

		entryClip.onRollOver = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined) {
				_parent.doSetSelectedIndex(this.itemIndex, 0);
				_parent._bMouseDrivenNav = true;
			}
		};

		entryClip.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (this.itemIndex != undefined) {
				_parent.onItemPress(a_keyboardOrMouse);
				
				if (!_parent._bDisableInput && onMousePress != undefined) {
					onMousePress();
				}
			}
		};

		entryClip.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (this.itemIndex != undefined) {
				_parent.onItemPressAux(a_keyboardOrMouse,a_buttonIndex);
			}
		};

		return entryClip;
	}

	function get selectedIndex()
	{
		return _selectedIndex;
	}

	function set selectedIndex(a_newIndex)
	{
		doSetSelectedIndex(a_newIndex);
	}

	function doSetSelectedIndex(a_newIndex:Number, a_keyboardOrMouse:Number)
	{
		if (!_bDisableSelection && a_newIndex != _selectedIndex) {
			var oldIndex = _selectedIndex;
			_selectedIndex = a_newIndex;

			if (oldIndex != -1) {
				setEntry(getClipByIndex(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);
			}

			if (_selectedIndex != -1) {
				setEntry(getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);
			}

			dispatchEvent({type:"selectionChange", index:_selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function get selectedEntry()
	{
		return _entryList[_selectedIndex];
	}

	function get listAnimating():Boolean
	{
		return _bListAnimating;
	}

	function set listAnimating(a_bFlag:Boolean)
	{
		_bListAnimating = a_bFlag;
	}

	function get entryList():Array
	{
		return _entryList;
	}

	function set entryList(a_newArray)
	{
		_entryList = a_newArray;
	}

	function get disableSelection():Boolean
	{
		return _bDisableSelection;
	}

	function set disableSelection(a_bFlag:Boolean)
	{
		_bDisableSelection = a_bFlag;
	}

	function get disableInput()
	{
		return _bDisableInput;
	}

	function set disableInput(a_bFlag:Boolean)
	{
		_bDisableInput = a_bFlag;
	}

	function get textOption():Number
	{
		return _textOption;
	}

	function set textOption(a_newOption:String)
	{
		if (a_newOption == "None") {
			_textOption = TEXT_OPTION_NONE;
		} else if (a_newOption == "Shrink To Fit") {
			_textOption = TEXT_OPTION_SHRINK_TO_FIT;
		} else if (a_newOption == "Multi-Line") {
			_textOption = TEXT_OPTION_MULTILINE;
		}
	}

	function InvalidateData()
	{
		if (_selectedIndex >= _entryList.length) {
			_selectedIndex = _entryList.length - 1;
		}

		UpdateList();
	}

	function UpdateList()
	{
		var yStart = _indent;
		var yOffset = 0;

		for (var i = 0; i < _entryList.length; ++i) {
			var entryClip = getClipByIndex(i);

			setEntry(entryClip,_entryList[i]);
			_entryList[i].clipIndex = i;
			entryClip.itemIndex = i;

			entryClip._y = yStart + yOffset;
			entryClip._visible = true;

			yOffset = yOffset + entryClip._height;
		}
	}

	function onItemPress(a_keyboardOrMouse)
	{
		if (!_bDisableInput && !_bDisableSelection && _selectedIndex != -1) {
			dispatchEvent({type:"itemPress", index:_selectedIndex, entry:_entryList[_selectedIndex], keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function onItemPressAux(a_keyboardOrMouse, a_buttonIndex)
	{
		if (!_bDisableInput && !_bDisableSelection && _selectedIndex != -1 && a_buttonIndex == 1) {
			dispatchEvent({type:"itemPressAux", index:_selectedIndex, entry:_entryList[_selectedIndex], keyboardOrMouse:a_keyboardOrMouse});
		}
	}

	function setEntry(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip != undefined) {
			if (a_entryObject == selectedEntry) {
				
				a_entryClip.selectArea._alpha = 40;
			} else {
				a_entryClip.selectArea._alpha = 0;
			}

			setEntryText(a_entryClip,a_entryObject);
		}
	}

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (a_entryClip.textField != undefined) {
			if (textOption == TEXT_OPTION_SHRINK_TO_FIT) {
				a_entryClip.textField.textAutoSize = "shrink";
			} else if (textOption == TEXT_OPTION_MULTILINE) {
				a_entryClip.textField.verticalAutoSize = "top";
			}

			if (a_entryObject.text != undefined) {
				a_entryClip.textField.SetText(a_entryObject.text);
			} else {
				a_entryClip.textField.SetText(" ");
			}

			if (a_entryObject.enabled != undefined) {
				a_entryClip.textField.textColor = a_entryObject.enabled == false ? (6316128) : (16777215);
			}

			if (a_entryObject.disabled != undefined) {
				a_entryClip.textField.textColor = a_entryObject.disabled == true ? (6316128) : (16777215);
			}
		}
	}

	function setPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		_platform = a_platform;
		_bMouseDrivenNav = _platform == 0;
	}
}