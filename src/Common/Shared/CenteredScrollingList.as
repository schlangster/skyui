import Shared.ListFilterer;

class Shared.CenteredScrollingList extends Shared.BSScrollingList
{
	var EntriesA: Array;
	
	var _filterer: ListFilterer;
	
	var bDisableInput: Boolean;
	var bMouseDrivenNav: Boolean;
	var bRecenterSelection: Boolean;
	var border: MovieClip;
	
	var dispatchEvent: Function;
	var doSetSelectedIndex: Function;
	var GetClipByIndex: Function;
	var SetEntryText: Function;
	
	var fListHeight: Number;
	var iDividerIndex: Number;
	var iListItemsShown: Number;
	var iMaxItemsShown: Number;
	var iMaxScrollPosition: Number;
	var iMaxTextLength: Number;
	var iNumTopHalfEntries: Number;
	var iNumUnfilteredItems: Number;
	var iPlatform: Number;
	var iScrollPosition: Number;
	var iSelectedIndex: Number;

	function CenteredScrollingList()
	{
		super();
		_filterer = new ListFilterer();
		_filterer.addEventListener("filterChange", this, "onFilterChange");
		bRecenterSelection = false;
		iMaxTextLength = 256;
		iDividerIndex = -1;
		iNumUnfilteredItems = 0;
	}

	function get filterer(): ListFilterer
	{
		return _filterer;
	}

	function set maxTextLength(aLength: Number): Void
	{
		if (aLength > 3) 
			iMaxTextLength = aLength;
	}

	function get numUnfilteredItems(): Number
	{
		return iNumUnfilteredItems;
	}

	function get maxTextLength(): Number
	{
		return iMaxTextLength;
	}

	function get numTopHalfEntries(): Number
	{
		return iNumTopHalfEntries;
	}

	function set numTopHalfEntries(aiNum: Number): Void
	{
		iNumTopHalfEntries = aiNum;
	}

	function get centeredEntry(): Object
	{
		return EntriesA[GetClipByIndex(iNumTopHalfEntries).itemIndex];
	}

	function IsDivider(aEntry: Object): Boolean
	{
		return aEntry.divider == true || aEntry.flag == 0;
	}
	
	// No longer needed? 20120615
	/* function IsSelectionAboveDivider(): Boolean
	{
		return iDividerIndex == -1 || selectedIndex < iDividerIndex;
	} */

	function get dividerIndex(): Number
	{
		return iDividerIndex;
	}

	function RestoreScrollPosition(aiNewPosition: Number, abRecenterSelection: Boolean): Void
	{
		iScrollPosition = aiNewPosition;
		if (iScrollPosition < 0)
			iScrollPosition = 0;
		if (iScrollPosition > iMaxScrollPosition)
			iScrollPosition = iMaxScrollPosition;
		bRecenterSelection = abRecenterSelection;
	}

	function UpdateList(): Void
	{
		var iItemHeight: Number = GetClipByIndex(0)._y;
		var iHeightSum: Number = 0;
		var iEntryIndex: Number = filterer.ClampIndex(0);
		iDividerIndex = -1;
		
		
		for (var i: Number = 0; i < EntriesA.length; i++)
			if (IsDivider(EntriesA[i]))
				iDividerIndex = i;
		
		
		if (bRecenterSelection || iPlatform != 0)
			iSelectedIndex = -1;
		else
			iSelectedIndex = filterer.ClampIndex(iSelectedIndex);
		
		for (var i: Number = 0; i < iScrollPosition - iNumTopHalfEntries; i++) {
			EntriesA[iEntryIndex].clipIndex = undefined;
			iEntryIndex = filterer.GetNextFilterMatch(iEntryIndex);
		}

		iListItemsShown = 0;
		iNumUnfilteredItems = 0;
		
		
		for (var i: Number = 0; i < iNumTopHalfEntries; i++) {
			var item: MovieClip = GetClipByIndex(i);
			
			if (iScrollPosition - iNumTopHalfEntries + i >= 0) {
				SetEntry(item, EntriesA[iEntryIndex]);
				item._visible = true;
				item.itemIndex = IsDivider(EntriesA[iEntryIndex]) == true ? undefined : iEntryIndex;
				EntriesA[iEntryIndex].clipIndex = i;
				iEntryIndex = filterer.GetNextFilterMatch(iEntryIndex);
				++iNumUnfilteredItems;
			} else {
				item._visible = false;
				item.itemIndex = undefined;
			}
			item._y = iItemHeight + iHeightSum;
			iHeightSum = iHeightSum + item._height;
			++iListItemsShown;
		}
		
		if (iEntryIndex != undefined && (bRecenterSelection || iPlatform != 0))
			iSelectedIndex = iEntryIndex;
		
		
		for (iEntryIndex; iEntryIndex != undefined && iEntryIndex != -1 && iEntryIndex < EntriesA.length && iListItemsShown < iMaxItemsShown && iHeightSum <= fListHeight; iEntryIndex = filterer.GetNextFilterMatch(iEntryIndex)) {
			var item: MovieClip = GetClipByIndex(iListItemsShown);
			SetEntry(item, EntriesA[iEntryIndex]);
			EntriesA[iEntryIndex].clipIndex = iListItemsShown;
			item.itemIndex = IsDivider(EntriesA[iEntryIndex]) == true ? undefined : iEntryIndex;
			item._y = iItemHeight + iHeightSum;
			item._visible = true;
			iHeightSum = iHeightSum + item._height;
			if (iHeightSum <= fListHeight && iListItemsShown < iMaxItemsShown) {
				++iListItemsShown;
				++iNumUnfilteredItems;
			}
		}
		
		
		for (var i: Number = iListItemsShown; i < iMaxItemsShown; i++) {
			GetClipByIndex(i)._visible = false;
			GetClipByIndex(i).itemIndex = undefined;
		}
		
		if (bMouseDrivenNav && !bRecenterSelection)
			for (var item: Object = Mouse.getTopMostEntity(); item != undefined; item = item._parent)
					if (item._parent == this && item._visible && item.itemIndex != undefined)
						doSetSelectedIndex(item.itemIndex, 0);
						
		bRecenterSelection = false;
	}

	function InvalidateData(): Void
	{
		filterer.filterArray = EntriesA;
		fListHeight = border._height;
		CalculateMaxScrollPosition();
		
		if (iScrollPosition > iMaxScrollPosition)
			iScrollPosition = iMaxScrollPosition;
			
		UpdateList();
	}

	function onFilterChange(): Void
	{
		iSelectedIndex = filterer.ClampIndex(iSelectedIndex);
		CalculateMaxScrollPosition();
	}

	function moveSelectionUp(): Void
	{
		var itemIndex: Number = filterer.GetPrevFilterMatch(iSelectedIndex);
		var iInitialScrollPos: Number = iScrollPosition;
		
		if (itemIndex != undefined && IsDivider(EntriesA[itemIndex]) == true) {
			--iScrollPosition;
			itemIndex = filterer.GetPrevFilterMatch(itemIndex);
		}
		
		if (itemIndex != undefined) {
			iSelectedIndex = itemIndex;
			if (iScrollPosition > 0)
				--iScrollPosition;
			bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type: "listMovedUp", index: iSelectedIndex, scrollChanged: iInitialScrollPos != iScrollPosition});
		}
	}

	function moveSelectionDown(): Void
	{
		var itemIndex: Number = filterer.GetNextFilterMatch(iSelectedIndex);
		var iInitialScrollPos: Number = iScrollPosition;
		if (itemIndex != undefined && IsDivider(EntriesA[itemIndex]) == true) {
			++iScrollPosition;
			itemIndex = filterer.GetNextFilterMatch(itemIndex);
		}
		if (itemIndex != undefined) {
			iSelectedIndex = itemIndex;
			if (iScrollPosition < iMaxScrollPosition)
				++iScrollPosition;
			bMouseDrivenNav = false;
			UpdateList();
			dispatchEvent({type: "listMovedDown", index: iSelectedIndex, scrollChanged: iInitialScrollPos != iScrollPosition});
		}
	}

	function onMouseWheel(delta: Number): Void
	{
		if (bDisableInput)
			return;
			
		for (var item: Object = Mouse.getTopMostEntity(); item && item != undefined; item = item._parent) {
			if (item == this) {
				if (delta < 0) {
					var newItem: MovieClip = GetClipByIndex(iNumTopHalfEntries + 1);
					if (newItem._visible == true) {
						if (newItem.itemIndex == undefined)
							scrollPosition = scrollPosition + 2;
						else
							scrollPosition = scrollPosition + 1;
					}
				} else if (delta > 0) {
					var newItem = GetClipByIndex(iNumTopHalfEntries - 1);
					if (newItem._visible == true) {
						if (newItem.itemIndex == undefined)
							scrollPosition = scrollPosition - 2;
						else
							scrollPosition = scrollPosition - 1;
					}
				}
			}
		}
		bMouseDrivenNav = true;
	}

	function CalculateMaxScrollPosition(): Void
	{
		iMaxScrollPosition = -1;
		for (var itemIndex: Number = filterer.ClampIndex(0); itemIndex != undefined; itemIndex = filterer.GetNextFilterMatch(itemIndex))
			++iMaxScrollPosition;
		
		if (iMaxScrollPosition == undefined || iMaxScrollPosition < 0)
			iMaxScrollPosition = 0;
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		if (aEntryClip != undefined) {
			if (IsDivider(aEntryObject) == true)
				aEntryClip.gotoAndStop("Divider");
			else
				aEntryClip.gotoAndStop("Normal");
				
			if (iPlatform == 0) {
				aEntryClip._alpha = aEntryObject == selectedEntry ? 100 : 60;
			} else {
				var iAlphaMulti: Number = 4;
				if (aEntryClip.clipIndex < iNumTopHalfEntries)
					aEntryClip._alpha = 60 - iAlphaMulti * (iNumTopHalfEntries - aEntryClip.clipIndex);
				else if (aEntryClip.clipIndex > iNumTopHalfEntries)
					aEntryClip._alpha = 60 - iAlphaMulti * (aEntryClip.clipIndex - iNumTopHalfEntries);
				else
					aEntryClip._alpha = 100;
			}
			SetEntryText(aEntryClip, aEntryObject);
		}
	}

}
