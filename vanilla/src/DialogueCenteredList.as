class DialogueCenteredList extends Shared.CenteredScrollingList
{
	var iNumTopHalfEntries;
	var GetClipByIndex;
	var fCenterY;
	var iScrollPosition;
	var iListItemsShown;
	var EntriesA;
	var SetEntry;
	var bRecenterSelection;
	var iPlatform;
	var iSelectedIndex;
	var iMaxItemsShown;
	var fListHeight;
	var doSetSelectedIndex;
	var bDisableInput;
	
	
	function DialogueCenteredList()
	{
		super();
		fCenterY = GetClipByIndex(iNumTopHalfEntries)._y + GetClipByIndex(iNumTopHalfEntries)._height / 2;
	}
	
	function SetEntryText(aEntryClip, aEntryObject)
	{
		super.SetEntryText(aEntryClip, aEntryObject);
		if (aEntryClip.textField != undefined)
		{
			aEntryClip.textField.textColor = aEntryObject.topicIsNew == undefined || aEntryObject.topicIsNew ? (16777215) : (6316128);
		}
	}
	
	function UpdateList()
	{
		var _loc8 = 0;
		var _loc6 = 0;
		for (var _loc2 = 0; _loc2 < iScrollPosition - iNumTopHalfEntries; ++_loc2)
		{
		}
		iListItemsShown = 0;
		
		for (var _loc4 = 0; _loc4 < iNumTopHalfEntries; ++_loc4)
		{
			var _loc5 = GetClipByIndex(_loc4);
			if (iScrollPosition - iNumTopHalfEntries + _loc4 >= 0)
			{
				SetEntry(_loc5, EntriesA[_loc2]);
				_loc5._visible = true;
				_loc5.itemIndex = _loc2;
				EntriesA[_loc2].clipIndex = _loc4;
				++_loc2;
			}
			else
			{
				SetEntry(_loc5, {text: " "});
				_loc5._visible = false;
				_loc5.itemIndex = undefined;
			}
			
			_loc5._y = _loc8 + _loc6;
			_loc6 = _loc6 + _loc5._height;
			++iListItemsShown;
		}
		
		if (bRecenterSelection || iPlatform != 0)
		{
			iSelectedIndex = _loc2;
		}
		
		while (_loc2 < EntriesA.length && iListItemsShown < iMaxItemsShown && _loc6 <= fListHeight)
		{
			_loc5 = GetClipByIndex(iListItemsShown);
			SetEntry(_loc5, EntriesA[_loc2]);
			EntriesA[_loc2].clipIndex = iListItemsShown;
			_loc5.itemIndex = _loc2;
			_loc5._y = _loc8 + _loc6;
			_loc5._visible = true;
			_loc6 = _loc6 + _loc5._height;
			
			if (_loc6 <= fListHeight && iListItemsShown < iMaxItemsShown)
			{
				++iListItemsShown;
			}
			
			++_loc2;
		}
		
		for (var _loc7 = iListItemsShown; _loc7 < iMaxItemsShown; ++_loc7)
		{
			GetClipByIndex(_loc7)._visible = false;
			GetClipByIndex(_loc7).itemIndex = undefined;
		}
		
		if (!bRecenterSelection)
		{
			for (var _loc3 = Mouse.getTopMostEntity(); _loc3 != undefined; _loc3 = _loc3._parent)
			{
				if (_loc3._parent == this && _loc3._visible && _loc3.itemIndex != undefined)
				{
					doSetSelectedIndex(_loc3.itemIndex, 0);
				}
			}
		}
		bRecenterSelection = false;
		RepositionEntries();
		
		var _loc10 = 3;
		_parent.ScrollIndicators.Up._visible = scrollPosition > iNumTopHalfEntries;
		_parent.ScrollIndicators.Down._visible = EntriesA.length - scrollPosition - 1 > _loc10 || _loc6 > fListHeight;
	}
	
	function RepositionEntries()
	{
		var _loc4 = GetClipByIndex(iNumTopHalfEntries)._y + GetClipByIndex(iNumTopHalfEntries)._height / 2;
		var _loc3 = fCenterY - _loc4;
		for (var _loc2 = 0; _loc2 < iMaxItemsShown; ++_loc2)
		{
			GetClipByIndex(_loc2)._y = GetClipByIndex(_loc2)._y + _loc3;
		}
	}
	
	function onMouseWheel(delta)
	{
		if (!bDisableInput)
		{
			var _loc2 = Mouse.getTopMostEntity();
			iSelectedIndex = -1;
			bRecenterSelection = true;
			while (_loc2 != undefined)
			{
				if (_loc2 == this)
				{
					bRecenterSelection = false;
				}
				_loc2 = _loc2._parent;
			}
			
			if (delta < 0)
			{
				var _loc4 = GetClipByIndex(iNumTopHalfEntries + 1);
				if (_loc4._visible == true)
				{
					scrollPosition = scrollPosition + 1;
				}
			}
			else if (delta > 0)
			{
				var _loc3 = GetClipByIndex(iNumTopHalfEntries - 1);
				if (_loc3._visible == true)
				{
					scrollPosition = scrollPosition - 1;
				}
			}
		}
	}
	
	function SetSelectedTopic(aiTopicIndex)
	{
		iSelectedIndex = 0;
		iScrollPosition = 0;
		
		for (var _loc2 = 0; _loc2 < EntriesA.length; ++_loc2)
		{
			if (EntriesA[_loc2].topicIndex == aiTopicIndex)
			{
				iScrollPosition = _loc2;
			}
		}
	}
}
