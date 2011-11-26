import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class Shared.BSScrollingList extends MovieClip
{
	static var TEXT_OPTION_NONE = 0;
	static var TEXT_OPTION_SHRINK_TO_FIT = 1;
	static var TEXT_OPTION_MULTILINE = 2;

	var EntriesA;
	var bDisableSelection;
	var bDisableInput;
	var bMouseDrivenNav;
	var iSelectedIndex;
	var iScrollPosition;
	var iMaxScrollPosition;
	var iListItemsShown;
	var iPlatform;
	var border;
	var fListHeight;
	var scrollbar;
	var ListScrollbar;
	var iMaxItemsShown;
	var onMousePress;
	var bListAnimating;
	var iTextOption;
	var ScrollUp;
	var ScrollDown;
	var iScrollbarDrawTimerID;

	var dispatchEvent:Function;


	function BSScrollingList()
	{
		super();
		EntriesA = new Array();
		bDisableSelection = false;
		bDisableInput = false;
		bMouseDrivenNav = false;
		EventDispatcher.initialize(this);
		Mouse.addListener(this);

		iSelectedIndex = -1;
		iScrollPosition = 0;
		iMaxScrollPosition = 0;
		iListItemsShown = 0;
		iPlatform = 1;
		fListHeight = border._height;
		ListScrollbar = scrollbar;
		iMaxItemsShown = 0;

		for (var item = GetClipByIndex(iMaxItemsShown); item != undefined; item = GetClipByIndex(++iMaxItemsShown)) {
			item.clipIndex = iMaxItemsShown;
			item.onRollOver = function()
			{
				if (!_parent.listAnimating && !_parent.bDisableInput && this.itemIndex != undefined) {
					_parent.doSetSelectedIndex(this.itemIndex,0);
					_parent.bMouseDrivenNav = true;
				}
			};
			item.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
			{
				if (this.itemIndex != undefined) {
					_parent.onItemPress(aiKeyboardOrMouse);
					if (!_parent.bDisableInput && onMousePress != undefined) {
						onMousePress();
					}
				}
			};
			item.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
			{
				if (this.itemIndex != undefined) {
					_parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
				}
			};
		}
	}

	function onLoad()
	{
		if (ListScrollbar != undefined) {
			ListScrollbar.position = 0;
			ListScrollbar.addEventListener("scroll",this,"onScroll");
		}
	}

	function ClearList()
	{
		EntriesA.splice(0,EntriesA.length);
	}

	function GetClipByIndex(aiIndex)
	{
		return this["Entry" + aiIndex];
	}

	function handleInput(details, pathToFocus):Boolean
	{
		var _loc2 = false;
		if (!bDisableInput) {
			var _loc4 = GetClipByIndex(selectedIndex - scrollPosition);
			_loc2 = _loc4 != undefined && _loc4.handleInput != undefined && _loc4.handleInput(details, pathToFocus.slice(1));
			if (!_loc2 && GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.UP) {
					moveSelectionUp();
					_loc2 = true;
				} else if (details.navEquivalent == NavigationCode.DOWN) {
					moveSelectionDown();
					_loc2 = true;
				} else if (!bDisableSelection && details.navEquivalent == NavigationCode.ENTER) {
					onItemPress();
					_loc2 = true;
				}
			}
		}
		return (_loc2);
	}

	function onMouseWheel(delta)
	{
		if (!bDisableInput) {
			for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
				if (target == this) {
					doSetSelectedIndex(-1,0);
					if (delta < 0) {
						scrollPosition = scrollPosition + 1;
						continue;
					}
					if (delta > 0) {
						scrollPosition = scrollPosition - 1;
					}
				}
			}
		}
	}

	function get selectedIndex()
	{
		return iSelectedIndex;
	}

	function set selectedIndex(aiNewIndex)
	{
		doSetSelectedIndex(aiNewIndex);
	}

	function get listAnimating()
	{
		return bListAnimating;
	}

	function set listAnimating(abFlag)
	{
		bListAnimating = abFlag;
	}

	function doSetSelectedIndex(aiNewIndex:Number, aiKeyboardOrMouse)
	{
		if (!bDisableSelection && aiNewIndex != iSelectedIndex) {
			var _loc2 = iSelectedIndex;
			iSelectedIndex = aiNewIndex;
			
			if (_loc2 != -1) {
				SetEntry(GetClipByIndex(EntriesA[_loc2].clipIndex),EntriesA[_loc2]);
			}

			if (iSelectedIndex != -1) {
				if (iPlatform != 0) {
					if (iSelectedIndex < iScrollPosition) {
						scrollPosition = iSelectedIndex;
					} else if (iSelectedIndex >= iScrollPosition + iListItemsShown) {
						scrollPosition = Math.min(iSelectedIndex - iListItemsShown + 1, iMaxScrollPosition);
					} else {
						SetEntry(GetClipByIndex(EntriesA[iSelectedIndex].clipIndex),EntriesA[iSelectedIndex]);
					}
				} else {
					SetEntry(GetClipByIndex(EntriesA[iSelectedIndex].clipIndex),EntriesA[iSelectedIndex]);
				}
			}
			dispatchEvent({type:"selectionChange", index:iSelectedIndex, keyboardOrMouse:aiKeyboardOrMouse});
		}
	}

	function get scrollPosition()
	{
		return iScrollPosition;
	}

	function get maxScrollPosition()
	{
		return iMaxScrollPosition;
	}

	function set scrollPosition(aiNewPosition)
	{
		if (aiNewPosition != iScrollPosition && aiNewPosition >= 0 && aiNewPosition <= iMaxScrollPosition) {
			if (ListScrollbar != undefined) {
				ListScrollbar.position = aiNewPosition;
			} else {
				updateScrollPosition(aiNewPosition);
			}
		}
	}

	function updateScrollPosition(aiPosition)
	{
		iScrollPosition = aiPosition;
		UpdateList();
	}

	function get selectedEntry()
	{
		return EntriesA[iSelectedIndex];
	}

	function get entryList()
	{
		return EntriesA;
	}

	function set entryList(anewArray)
	{
		EntriesA = anewArray;
	}

	function get disableSelection()
	{
		return bDisableSelection;
	}

	function set disableSelection(abFlag)
	{
		bDisableSelection = abFlag;
	}

	function get disableInput()
	{
		return bDisableInput;
	}

	function set disableInput(abFlag)
	{
		bDisableInput = abFlag;
	}

	function get maxEntries()
	{
		return iMaxItemsShown;
	}

	function get textOption()
	{
		return iTextOption;
	}

	function set textOption(strNewOption:String)
	{
		if (strNewOption == "None") {
			iTextOption = TEXT_OPTION_NONE;
		} else if (strNewOption == "Shrink To Fit") {
			iTextOption = TEXT_OPTION_SHRINK_TO_FIT;
		} else if (strNewOption == "Multi-Line") {
			iTextOption = TEXT_OPTION_MULTILINE;
		}
	}

	function UpdateList()
	{
		var _loc6 = GetClipByIndex(0)._y;
		var _loc5 = 0;

		for (var i = 0; i < iScrollPosition; ++i) {
			EntriesA[i].clipIndex = undefined;
		}

		iListItemsShown = 0;

		for (var pos = iScrollPosition; pos < EntriesA.length && iListItemsShown < iMaxItemsShown && _loc5 <= fListHeight; ++pos) {
			var _loc3 = GetClipByIndex(iListItemsShown);
			SetEntry(_loc3,EntriesA[pos]);
			EntriesA[pos].clipIndex = iListItemsShown;
			_loc3.itemIndex = pos;
			_loc3._y = _loc6 + _loc5;
			_loc3._visible = true;
			_loc5 = _loc5 + _loc3._height;
			if (_loc5 <= fListHeight && iListItemsShown < iMaxItemsShown) {
				++iListItemsShown;
			}
		}

		for (var _loc4 = iListItemsShown; _loc4 < iMaxItemsShown; ++_loc4) {
			GetClipByIndex(_loc4)._visible = false;
		}

		if (ScrollUp != undefined) {
			ScrollUp._visible = scrollPosition > 0;
		}

		if (ScrollDown != undefined) {
			ScrollDown._visible = scrollPosition < iMaxScrollPosition;
		}

	}

	function InvalidateData()
	{
		var _loc2 = iMaxScrollPosition;
		fListHeight = border._height;
		CalculateMaxScrollPosition();
		if (ListScrollbar != undefined) {
			if (_loc2 != iMaxScrollPosition) {
				ListScrollbar._visible = false;
				ListScrollbar.setScrollProperties(iMaxItemsShown,0,iMaxScrollPosition);
				if (iScrollbarDrawTimerID != undefined) {
					clearInterval(iScrollbarDrawTimerID);
				}
				iScrollbarDrawTimerID = setInterval(this, "SetScrollbarVisibility", 50);
			} else {
				SetScrollbarVisibility();
			}
		}

		if (iSelectedIndex >= EntriesA.length) {
			iSelectedIndex = EntriesA.length - 1;
		}

		if (iScrollPosition > iMaxScrollPosition) {
			iScrollPosition = iMaxScrollPosition;
		}
		UpdateList();
	}

	function SetScrollbarVisibility()
	{
		clearInterval(iScrollbarDrawTimerID);
		iScrollbarDrawTimerID = undefined;
		ListScrollbar._visible = iMaxScrollPosition > 0;
	}

	function CalculateMaxScrollPosition()
	{
		var _loc3 = 0;
		for (var _loc2 = EntriesA.length - 1; _loc2 >= 0 && _loc3 <= fListHeight; --_loc2) {
			_loc3 = _loc3 + GetEntryHeight(_loc2);
			if (_loc3 <= fListHeight) {
			}
		}
		iMaxScrollPosition = _loc2 + 1;
	}

	function GetEntryHeight(aiEntryIndex)
	{
		var _loc2 = GetClipByIndex(0);
		SetEntry(_loc2,EntriesA[aiEntryIndex]);
		return _loc2._height;
	}

	function moveSelectionUp()
	{
		if (!bDisableSelection) {
			if (selectedIndex > 0) {
				selectedIndex = selectedIndex - 1;
			}
		} else {
			scrollPosition = scrollPosition - 1;
		}
	}

	function moveSelectionDown()
	{
		if (!bDisableSelection) {
			if (selectedIndex < EntriesA.length - 1) {
				selectedIndex = selectedIndex + 1;
			}
		} else {
			scrollPosition = scrollPosition + 1;
		}
	}

	function onItemPress(aiKeyboardOrMouse)
	{
		if (!bDisableInput && !bDisableSelection && iSelectedIndex != -1) {
			dispatchEvent({type:"itemPress", index:iSelectedIndex, entry:EntriesA[iSelectedIndex], keyboardOrMouse:aiKeyboardOrMouse});
		} else {
			dispatchEvent({type:"listPress"});
		}
	}

	function onItemPressAux(aiKeyboardOrMouse, aiButtonIndex)
	{
		if (!bDisableInput && !bDisableSelection && iSelectedIndex != -1 && aiButtonIndex == 1) {
			dispatchEvent({type:"itemPressAux", index:iSelectedIndex, entry:EntriesA[iSelectedIndex], keyboardOrMouse:aiKeyboardOrMouse});
		}
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryClip != undefined) {
			if (aEntryObject == selectedEntry) {
				aEntryClip.gotoAndStop("Selected");
			} else {
				aEntryClip.gotoAndStop("Normal");
			}

			SetEntryText(aEntryClip,aEntryObject);
		}
	}

	function SetEntryText(aEntryClip, aEntryObject)
	{
		if (aEntryClip.textField != undefined) {
			if (textOption == Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT) {
				aEntryClip.textField.textAutoSize = "shrink";
			} else if (textOption == Shared.BSScrollingList.TEXT_OPTION_MULTILINE) {
				aEntryClip.textField.verticalAutoSize = "top";
			}

			if (aEntryObject.text != undefined) {
				aEntryClip.textField.SetText(aEntryObject.text);
			} else {
				aEntryClip.textField.SetText(" ");
			}

			if (aEntryObject.enabled != undefined) {
				aEntryClip.textField.textColor = aEntryObject.enabled == false ? (6316128) : (16777215);
			}

			if (aEntryObject.disabled != undefined) {
				aEntryClip.textField.textColor = aEntryObject.disabled == true ? (6316128) : (16777215);
			}
		}
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		iPlatform = aiPlatform;
		bMouseDrivenNav = iPlatform == 0;
	}

	function onScroll(event)
	{
		updateScrollPosition(Math.floor(event.position + 0.500000));
	}
}