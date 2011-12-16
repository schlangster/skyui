class Shared.CenteredScrollingList extends Shared.BSScrollingList
{
	var _filterer;
	var bRecenterSelection;
	var iMaxTextLength;
	var iDividerIndex;
	var iNumUnfilteredItems;
	var iNumTopHalfEntries;
	var EntriesA;
	var GetClipByIndex;
	var iScrollPosition;
	var iMaxScrollPosition;
	var iPlatform;
	var iSelectedIndex;
	var iListItemsShown;
	var iMaxItemsShown;
	var fListHeight;
	var bMouseDrivenNav;
	var doSetSelectedIndex;
	var border;
	var bDisableInput;
	var SetEntryText;
	
	var dispatchEvent:Function;
	
	function CenteredScrollingList()
	{
		super();
		_filterer = new Shared.ListFilterer();
		_filterer.addEventListener("filterChange", this, "onFilterChange");
		bRecenterSelection = false;
		iMaxTextLength = 256;
		iDividerIndex = -1;
		iNumUnfilteredItems = 0;
	}
	
	function get filterer()
	{
		return _filterer;
	}
	
	function set maxTextLength(aLength)
	{
		if (aLength > 3)
		{
			iMaxTextLength = aLength;
		}
	}
	
	function get numUnfilteredItems()
	{
		return iNumUnfilteredItems;
	}
	
	function get maxTextLength()
	{
		return iMaxTextLength;
	}
	
	function get numTopHalfEntries()
	{
		return iNumTopHalfEntries;
	}
	
	function set numTopHalfEntries(aiNum)
	{
		iNumTopHalfEntries = aiNum;
	}
	
	function get centeredEntry()
	{
		return (EntriesA[GetClipByIndex(iNumTopHalfEntries).itemIndex]);
	}
	
	function IsDivider(aEntry)
	{
		return (aEntry.divider == true || aEntry.flag == 0);
	}
	
	function IsSelectionAboveDivider()
	{
		return (iDividerIndex == -1 || selectedIndex < iDividerIndex);
	}
	
	function RestoreScrollPosition(aiNewPosition, abRecenterSelection)
	{
		iScrollPosition = aiNewPosition;
		if (iScrollPosition < 0)
		{
			iScrollPosition = 0;
		}
		
		if (iScrollPosition > iMaxScrollPosition)
		{
			iScrollPosition = iMaxScrollPosition;
		}
		
		bRecenterSelection = abRecenterSelection;
	}
	
	function UpdateList()
	{
		var _loc10 = GetClipByIndex(0)._y;
		var _loc6 = 0;
		var _loc2 = filterer.ClampIndex(0);
		iDividerIndex = -1;
		for (var _loc7 = 0; _loc7 < EntriesA.length; ++_loc7)
		{
			if (IsDivider(EntriesA[_loc7]))
			{
				iDividerIndex = _loc7;
			} // end if
		}
		
		if (bRecenterSelection || iPlatform != 0)
		{
			iSelectedIndex = -1;
		}
		else
		{
			iSelectedIndex = filterer.ClampIndex(iSelectedIndex);
		}
		
		for (var _loc9 = 0; _loc9 < iScrollPosition - iNumTopHalfEntries; ++_loc9)
		{
			EntriesA[_loc2].clipIndex = undefined;
			_loc2 = filterer.GetNextFilterMatch(_loc2);
		}
		
		iListItemsShown = 0;
		iNumUnfilteredItems = 0;
		for (var _loc4 = 0; _loc4 < iNumTopHalfEntries; ++_loc4)
		{
			var _loc5 = GetClipByIndex(_loc4);
			if (iScrollPosition - iNumTopHalfEntries + _loc4 >= 0)
			{
				SetEntry(_loc5, EntriesA[_loc2]);
				_loc5._visible = true;
				_loc5.itemIndex = IsDivider(EntriesA[_loc2]) != true ? (_loc2) : (undefined);
				EntriesA[_loc2].clipIndex = _loc4;
				_loc2 = filterer.GetNextFilterMatch(_loc2);
				++iNumUnfilteredItems;
			}
			else
			{
				_loc5._visible = false;
				_loc5.itemIndex = undefined;
			} // end else if
			_loc5._y = _loc10 + _loc6;
			_loc6 = _loc6 + _loc5._height;
			++iListItemsShown;
		}
		
		if (_loc2 != undefined && (bRecenterSelection || iPlatform != 0))
		{
			iSelectedIndex = _loc2;
		}
		
		while (_loc2 != undefined && _loc2 != -1 && _loc2 < EntriesA.length && iListItemsShown < iMaxItemsShown && _loc6 <= fListHeight)
		{
			_loc5 = GetClipByIndex(iListItemsShown);
			SetEntry(_loc5, EntriesA[_loc2]);
			EntriesA[_loc2].clipIndex = iListItemsShown;
			_loc5.itemIndex = IsDivider(EntriesA[_loc2]) != true ? (_loc2) : (undefined);
			_loc5._y = _loc10 + _loc6;
			_loc5._visible = true;
			_loc6 = _loc6 + _loc5._height;
			if (_loc6 <= fListHeight && iListItemsShown < iMaxItemsShown)
			{
				++iListItemsShown;
				++iNumUnfilteredItems;
			} // end if
			_loc2 = filterer.GetNextFilterMatch(_loc2);
		}
		
		for (var _loc8 = iListItemsShown; _loc8 < iMaxItemsShown; ++_loc8)
		{
			GetClipByIndex(_loc8)._visible = false;
			GetClipByIndex(_loc8).itemIndex = undefined;
		}
		
		if (bMouseDrivenNav && !bRecenterSelection)
		{
			for (var _loc3 = Mouse.getTopMostEntity(); _loc3 != undefined; _loc3 = _loc3._parent)
			{
				if (_loc3._parent == this && _loc3._visible && _loc3.itemIndex != undefined)
				{
					doSetSelectedIndex(_loc3.itemIndex, 0);
				} // end if
			} // end of for
		} // end if
		bRecenterSelection = false;
	}
	
	function InvalidateData()
	{
		filterer.filterArray = EntriesA;
		fListHeight = border._height;
		CalculateMaxScrollPosition();
		
		if (iScrollPosition > iMaxScrollPosition)
		{
			iScrollPosition = iMaxScrollPosition;
		}
		
		UpdateList();
	}
	
	function onFilterChange()
	{
		iSelectedIndex = filterer.ClampIndex(iSelectedIndex);
		CalculateMaxScrollPosition();
	}
	
	function moveSelectionUp()
	{
		var _loc4 = GetClipByIndex(iNumTopHalfEntries);
		var _loc2 = filterer.GetPrevFilterMatch(iSelectedIndex);
		var _loc3 = iScrollPosition;
		if (_loc2 != undefined && IsDivider(EntriesA[_loc2]) == true)
		{
			--iScrollPosition;
			_loc2 = filterer.GetPrevFilterMatch(_loc2);
		} // end if
		if (_loc2 != undefined)
		{
			iSelectedIndex = _loc2;
			if (iScrollPosition > 0)
			{
				--iScrollPosition;
			} // end if
			bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type: "listMovedUp", index: iSelectedIndex, scrollChanged: _loc3 != iScrollPosition});
		} // end if
	}
	
	function moveSelectionDown()
	{
		var _loc4 = GetClipByIndex(iNumTopHalfEntries);
		var _loc2 = filterer.GetNextFilterMatch(iSelectedIndex);
		var _loc3 = iScrollPosition;
		
		if (_loc2 != undefined && IsDivider(EntriesA[_loc2]) == true)
		{
			++iScrollPosition;
			_loc2 = filterer.GetNextFilterMatch(_loc2);
		}
		
		if (_loc2 != undefined)
		{
			iSelectedIndex = _loc2;
			if (iScrollPosition < iMaxScrollPosition)
			{
				++iScrollPosition;
			}
			
			bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type: "listMovedDown", index: iSelectedIndex, scrollChanged: _loc3 != iScrollPosition});
		}
	}
	
	function onMouseWheel(delta)
	{
		if (!bDisableInput)
		{
			for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined; _loc2 = _loc2._parent)
			{
				if (_loc2 == this)
				{
					if (delta < 0)
					{
						var _loc4 = GetClipByIndex(iNumTopHalfEntries + 1);
						if (_loc4._visible == true)
						{
							if (_loc4.itemIndex == undefined)
							{
								scrollPosition = scrollPosition + 2;
							}
							else
							{
								scrollPosition = scrollPosition + 1;
							}
						}
						continue;
					}
					
					if (delta > 0)
					{
						var _loc3 = GetClipByIndex(iNumTopHalfEntries - 1);
						if (_loc3._visible == true)
						{
							if (_loc3.itemIndex == undefined)
							{
								scrollPosition = scrollPosition - 2;
								continue;
							}
							scrollPosition = scrollPosition - 1;
						}
					}
				}
			}
			bMouseDrivenNav = true;
		}
	}
	
	function CalculateMaxScrollPosition()
	{
		iMaxScrollPosition = -1;
		for (var _loc2 = filterer.ClampIndex(0); _loc2 != undefined; _loc2 = filterer.GetNextFilterMatch(_loc2))
		{
			++iMaxScrollPosition;
		}
		
		if (iMaxScrollPosition == undefined || iMaxScrollPosition < 0)
		{
			iMaxScrollPosition = 0;
		}
	}
	
	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryClip != undefined)
		{
			if (IsDivider(aEntryObject) == true)
			{
				aEntryClip.gotoAndStop("Divider");
			}
			else
			{
				aEntryClip.gotoAndStop("Normal");
			}
			
			if (iPlatform == 0)
			{
				aEntryClip._alpha = aEntryObject == selectedEntry ? (100) : (60);
			}
			else
			{
				var _loc3 = 4;
				if (aEntryClip.clipIndex < iNumTopHalfEntries)
				{
					aEntryClip._alpha = 60 - _loc3 * (iNumTopHalfEntries - aEntryClip.clipIndex);
				}
				else if (aEntryClip.clipIndex > iNumTopHalfEntries)
				{
					aEntryClip._alpha = 60 - _loc3 * (aEntryClip.clipIndex - iNumTopHalfEntries);
				}
				else
				{
					aEntryClip._alpha = 100;
				} // end else if
			}
			SetEntryText(aEntryClip, aEntryObject);
		}
	}
}
