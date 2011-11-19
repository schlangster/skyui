class Shared.CenteredList extends MovieClip
{
    var TopHalf;
	var SelectedEntry;
	var BottomHalf;
	var EntriesA;
	var iSelectedIndex;
	var fCenterY;
	var bRepositionEntries;
	var iMaxEntriesTopHalf;
	var iMaxEntriesBottomHalf;
	var dispatchEvent:Function;
	var bMultilineList;
	var bToFitList;
	
    function CenteredList()
    {
        super();
        TopHalf = TopHalf;
        SelectedEntry = SelectedEntry;
        BottomHalf = BottomHalf;
        EntriesA = new Array();
        gfx.events.EventDispatcher.initialize(this);
        Mouse.addListener(this);
        iSelectedIndex = 0;
        fCenterY = SelectedEntry._y + SelectedEntry._height / 2;
        bRepositionEntries = true;
        for (iMaxEntriesTopHalf = 0; TopHalf["Entry" + iMaxEntriesTopHalf] != undefined; iMaxEntriesTopHalf++)
        {
        } // end of for
        for (iMaxEntriesBottomHalf = 0; BottomHalf["Entry" + iMaxEntriesBottomHalf] != undefined; iMaxEntriesBottomHalf++)
        {
        } // end of for
    } // End of the function
    function ClearList()
    {
        EntriesA.splice(0, EntriesA.length);
    } // End of the function
    function handleInput(details, pathToFocus)
    {
        var _loc2 = false;
        if (Shared.GlobalFunc.IsKeyPressed(details))
        {
            if (details.navEquivalent == gfx.ui.NavigationCode.UP)
            {
                this.moveListDown();
                _loc2 = true;
            }
            else if (details.navEquivalent == gfx.ui.NavigationCode.DOWN)
            {
                this.moveListUp();
                _loc2 = true;
            }
            else if (details.navEquivalent == gfx.ui.NavigationCode.ENTER && iSelectedIndex != -1)
            {
                this.dispatchEvent({type: "itemPress", index: iSelectedIndex, entry: EntriesA[iSelectedIndex]});
                _loc2 = true;
            } // end else if
        } // end else if
        return (_loc2);
    }
	
    function onMouseWheel(delta)
    {
        for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined && gfx.managers.FocusHandler.instance.getFocus(0) == this; _loc2 = _loc2._parent)
        {
            if (_loc2 == this)
            {
                if (delta < 0)
                {
                    this.moveListUp();
                    continue;
                } // end if
                if (delta > 0)
                {
                    this.moveListDown();
                } // end if
            } // end if
        } // end of for
    }
	
    function onPress(aiMouseIndex, aiKeyboardOrMouse)
    {
        for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined; _loc2 = _loc2._parent)
        {
            if (_loc2 == SelectedEntry)
            {
                this.dispatchEvent({type: "itemPress", index: iSelectedIndex, entry: EntriesA[iSelectedIndex], keyboardOrMouse: aiKeyboardOrMouse});
            } // end if
        } // end of for
    }
	
    function onPressAux(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
    {
        if (aiButtonIndex == 1)
        {
            for (var _loc2 = Mouse.getTopMostEntity(); _loc2 && _loc2 != undefined; _loc2 = _loc2._parent)
            {
                if (_loc2 == SelectedEntry)
                {
                    this.dispatchEvent({type: "itemPressAux", index: iSelectedIndex, entry: EntriesA[iSelectedIndex], keyboardOrMouse: aiKeyboardOrMouse});
                } // end if
            } // end of for
        } // end if
    }
	
    function get selectedTextString()
    {
        return EntriesA[iSelectedIndex].text;
    }
	
    function get selectedIndex()
    {
        return iSelectedIndex;
    }
	
    function set selectedIndex(aiNewIndex)
    {
        iSelectedIndex = aiNewIndex;
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
	
    function moveListUp()
    {
        if (iSelectedIndex < EntriesA.length - 1)
        {
            ++iSelectedIndex;
            UpdateList();
            dispatchEvent({type: "listMovedUp"});
        }
    }
    function moveListDown()
    {
        if (iSelectedIndex > 0)
        {
            --iSelectedIndex;
            UpdateList();
            dispatchEvent({type: "listMovedDown"});
        }
    }
	
    function UpdateList()
    {
        var _loc2;
        iSelectedIndex = Math.min(Math.max(iSelectedIndex, 0), EntriesA.length - 1);
        if (iSelectedIndex > 0)
        {
            this.UpdateTopHalf(EntriesA.slice(0, iSelectedIndex));
        }
        else
        {
            this.UpdateTopHalf(_loc2);
        } // end else if
        this.SetEntry(SelectedEntry, EntriesA[iSelectedIndex]);
        if (iSelectedIndex < EntriesA.length - 1)
        {
            this.UpdateBottomHalf(EntriesA.slice(iSelectedIndex + 1));
        }
        else
        {
            this.UpdateBottomHalf(_loc2);
        } // end else if
        this.RepositionEntries();
    } // End of the function
    function UpdateTopHalf(aEntryArray)
    {
        for (var _loc2 = iMaxEntriesTopHalf - 1; _loc2 >= 0; --_loc2)
        {
            var _loc3 = _loc2 - (iMaxEntriesTopHalf - aEntryArray.length);
            if (_loc3 >= 0 && _loc3 < aEntryArray.length)
            {
                this.SetEntry(TopHalf["Entry" + _loc2], aEntryArray[_loc3]);
                continue;
            } // end if
            this.SetEntry(TopHalf["Entry" + _loc2]);
        } // end of for
    } // End of the function
    function UpdateBottomHalf(aTextArray)
    {
        for (var _loc2 = 0; _loc2 < iMaxEntriesBottomHalf; ++_loc2)
        {
            if (_loc2 < aTextArray.length)
            {
                this.SetEntry(BottomHalf["Entry" + _loc2], aTextArray[_loc2]);
                continue;
            } // end if
            this.SetEntry(BottomHalf["Entry" + _loc2]);
        } // end of for
    } // End of the function
    function SetEntry(aEntryClip, aEntryObject)
    {
        if (bMultilineList == true)
        {
            aEntryClip.textField.verticalAutoSize = "top";
        } // end if
        if (bToFitList == true)
        {
            aEntryClip.textField.textAutoSize = "shrink";
        } // end if
        if (aEntryObject.text != undefined)
        {
            if (aEntryObject.count > 1)
            {
                aEntryClip.textField.SetText(aEntryObject.text + " (" + aEntryObject.count + ")");
            }
            else
            {
                aEntryClip.textField.SetText(aEntryObject.text);
            } // end else if
        }
        else
        {
            aEntryClip.textField.SetText(" ");
        } // end else if
    } // End of the function
    function SetupMultilineList()
    {
        bMultilineList = true;
        for (var _loc2 = 0; _loc2 < iMaxEntriesTopHalf; ++_loc2)
        {
            TopHalf["Entry" + _loc2].textField.verticalAutoSize = "top";
        } // end of for
        for (var _loc2 = 0; _loc2 < iMaxEntriesBottomHalf; ++_loc2)
        {
            BottomHalf["Entry" + _loc2].textField.verticalAutoSize = "top";
        } // end of for
        if (SelectedEntry != undefined)
        {
            SelectedEntry.textField.verticalAutoSize = "top";
        } // end if
    } // End of the function
    function SetupToFitList()
    {
        bToFitList = true;
        for (var _loc2 = 0; _loc2 < iMaxEntriesTopHalf; ++_loc2)
        {
            TopHalf["Entry" + _loc2].textField.textAutoSize = "shrink";
        } // end of for
        for (var _loc2 = 0; _loc2 < iMaxEntriesBottomHalf; ++_loc2)
        {
            BottomHalf["Entry" + _loc2].textField.textAutoSize = "shrink";
        } // end of for
        if (SelectedEntry != undefined)
        {
            SelectedEntry.textField.textAutoSize = "shrink";
        } // end if
    } // End of the function
    function RepositionEntries()
    {
        if (bRepositionEntries)
        {
            var _loc3 = 0;
            for (var _loc2 = 0; _loc2 < iMaxEntriesTopHalf; ++_loc2)
            {
                TopHalf["Entry" + _loc2]._y = _loc3;
                _loc3 = _loc3 + TopHalf["Entry" + _loc2]._height;
            } // end of for
            _loc3 = 0;
            for (var _loc2 = 0; _loc2 < iMaxEntriesBottomHalf; ++_loc2)
            {
                BottomHalf["Entry" + _loc2]._y = _loc3;
                _loc3 = _loc3 + BottomHalf["Entry" + _loc2]._height;
            } // end of for
            SelectedEntry._y = fCenterY - SelectedEntry._height / 2;
            TopHalf._y = SelectedEntry._y - TopHalf._height;
            BottomHalf._y = SelectedEntry._y + SelectedEntry._height;
        } // end if
    } // End of the function
} // End of Class
