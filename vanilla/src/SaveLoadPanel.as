dynamic class SaveLoadPanel extends MovieClip
{
    static var SCREENSHOT_DELAY: Number = 750;
    var List_mc;
    var PlayerInfoText;
    var SaveLoadList_mc;
    var ScreenshotHolder;
    var ScreenshotLoader;
    var ScreenshotRect;
    var bSaving;
    var dispatchEvent;
    var iBatchSize;
    var iPlatform;
    var iScreenshotTimerID;

    function SaveLoadPanel()
    {
        super();
        gfx.events.EventDispatcher.initialize(this);
        this.SaveLoadList_mc = this.List_mc;
        this.bSaving = true;
    }

    function onLoad()
    {
        this.ScreenshotLoader = new MovieClipLoader();
        this.ScreenshotLoader.addListener(this);
        gfx.io.GameDelegate.addCallBack("ConfirmOKToLoad", this, "onOKToLoadConfirm");
        gfx.io.GameDelegate.addCallBack("onSaveLoadBatchComplete", this, "onSaveLoadBatchComplete");
        gfx.io.GameDelegate.addCallBack("ScreenshotReady", this, "ShowScreenshot");
        this.SaveLoadList_mc.addEventListener("itemPress", this, "onSaveLoadItemPress");
        this.SaveLoadList_mc.addEventListener("selectionChange", this, "onSaveLoadItemHighlight");
        this.iBatchSize = this.SaveLoadList_mc.maxEntries;
        this.PlayerInfoText.createTextField("LevelText", this.PlayerInfoText.getNextHighestDepth(), 0, 0, 200, 30);
        this.PlayerInfoText.LevelText.text = "$Level";
        this.PlayerInfoText.LevelText._visible = false;
    }

    function get isSaving()
    {
        return this.bSaving;
    }

    function set isSaving(abFlag)
    {
        this.bSaving = abFlag;
    }

    function get selectedIndex()
    {
        return this.SaveLoadList_mc.selectedIndex;
    }

    function get platform()
    {
        return this.iPlatform;
    }

    function set platform(aiPlatform)
    {
        this.iPlatform = aiPlatform;
    }

    function get batchSize()
    {
        return this.iBatchSize;
    }

    function get numSaves()
    {
        return this.SaveLoadList_mc.entryList.length;
    }

    function onSaveLoadItemPress(event)
    {
        if (!this.bSaving) 
        {
            gfx.io.GameDelegate.call("IsOKtoLoad", [this.SaveLoadList_mc.selectedIndex]);
            return;
        }
        this.dispatchEvent({type: "saveGameSelected", index: this.SaveLoadList_mc.selectedIndex});
    }

    function onOKToLoadConfirm()
    {
        this.dispatchEvent({type: "loadGameSelected", index: this.SaveLoadList_mc.selectedIndex});
    }

    function onSaveLoadItemHighlight(event)
    {
        if (this.iScreenshotTimerID != undefined) 
        {
            clearInterval(this.iScreenshotTimerID);
            this.iScreenshotTimerID = undefined;
        }
        if (this.ScreenshotRect != undefined) 
        {
            this.ScreenshotRect.removeMovieClip();
            this.PlayerInfoText.textField.SetText(" ");
            this.PlayerInfoText.DateText.SetText(" ");
            this.PlayerInfoText.PlayTimeText.SetText(" ");
            this.ScreenshotRect = undefined;
        }
        if (event.index != -1) 
        {
            this.iScreenshotTimerID = setInterval(this, "PrepScreenshot", SaveLoadPanel.SCREENSHOT_DELAY);
        }
        this.dispatchEvent({type: "saveHighlighted", index: this.SaveLoadList_mc.selectedIndex});
    }

    function PrepScreenshot()
    {
        clearInterval(this.iScreenshotTimerID);
        this.iScreenshotTimerID = undefined;
        if (this.bSaving) 
        {
            gfx.io.GameDelegate.call("PrepSaveGameScreenshot", [this.SaveLoadList_mc.selectedIndex - 1, this.SaveLoadList_mc.selectedEntry]);
            return;
        }
        gfx.io.GameDelegate.call("PrepSaveGameScreenshot", [this.SaveLoadList_mc.selectedIndex, this.SaveLoadList_mc.selectedEntry]);
    }

    function ShowScreenshot()
    {
        this.ScreenshotRect = this.ScreenshotHolder.createEmptyMovieClip("ScreenshotRect", 0);
        this.ScreenshotLoader.loadClip("img://BGSSaveLoadHeader_Screenshot", this.ScreenshotRect);
        if (this.SaveLoadList_mc.selectedEntry.corrupt == true) 
        {
            this.PlayerInfoText.textField.SetText("$SAVE CORRUPT");
        }
        else if (this.SaveLoadList_mc.selectedEntry.obsolete == true) 
        {
            this.PlayerInfoText.textField.SetText("$SAVE OBSOLETE");
        }
        else if (this.SaveLoadList_mc.selectedEntry.name == undefined) 
        {
            this.PlayerInfoText.textField.SetText(" ");
        }
        else 
        {
            var __reg2 = this.SaveLoadList_mc.selectedEntry.name;
            var __reg3 = 20;
            if (__reg2.length > __reg3) 
            {
                __reg2 = __reg2.substr(0, __reg3 - 3) + "...";
            }
            if (this.SaveLoadList_mc.selectedEntry.raceName != undefined && this.SaveLoadList_mc.selectedEntry.raceName.length > 0) 
            {
                __reg2 = __reg2 + (", " + this.SaveLoadList_mc.selectedEntry.raceName);
            }
            if (this.SaveLoadList_mc.selectedEntry.level != undefined && this.SaveLoadList_mc.selectedEntry.level > 0) 
            {
                __reg2 = __reg2 + (", " + this.PlayerInfoText.LevelText.text + " " + this.SaveLoadList_mc.selectedEntry.level);
            }
            this.PlayerInfoText.textField.textAutoSize = "shrink";
            this.PlayerInfoText.textField.SetText(__reg2);
        }
        if (this.SaveLoadList_mc.selectedEntry.playTime == undefined) 
        {
            this.PlayerInfoText.PlayTimeText.SetText(" ");
        }
        else 
        {
            this.PlayerInfoText.PlayTimeText.SetText(this.SaveLoadList_mc.selectedEntry.playTime);
        }
        if (this.SaveLoadList_mc.selectedEntry.dateString != undefined) 
        {
            this.PlayerInfoText.DateText.SetText(this.SaveLoadList_mc.selectedEntry.dateString);
            return;
        }
        this.PlayerInfoText.DateText.SetText(" ");
    }

    function onLoadInit(aTargetClip)
    {
        aTargetClip._width = this.ScreenshotHolder.sizer._width;
        aTargetClip._height = this.ScreenshotHolder.sizer._height;
    }

    function onSaveLoadBatchComplete(abDoInitialUpdate)
    {
        var __reg2 = 20;
        for (var __reg3 in this.SaveLoadList_mc.entryList) 
        {
            if (this.SaveLoadList_mc.entryList[__reg3].text.length > __reg2) 
            {
                this.SaveLoadList_mc.entryList[__reg3].text = this.SaveLoadList_mc.entryList[__reg3].text.substr(0, __reg2 - 3) + "...";
            }
        }
        if (abDoInitialUpdate) 
        {
            var __reg4 = "$[NEW SAVE]";
            if (this.bSaving && this.SaveLoadList_mc.entryList[0].text != __reg4) 
            {
                var __reg5 = {name: " ", playTime: " ", text: __reg4};
                this.SaveLoadList_mc.entryList.unshift(__reg5);
            }
            else if (!this.bSaving && this.SaveLoadList_mc.entryList[0].text == __reg4) 
            {
                this.SaveLoadList_mc.entryList.shift();
            }
        }
        this.SaveLoadList_mc.InvalidateData();
        if (abDoInitialUpdate) 
        {
            if (this.iPlatform != 0) 
            {
                if (this.SaveLoadList_mc.selectedIndex == 0) 
                {
                    this.onSaveLoadItemHighlight({index: 0});
                }
                else 
                {
                    this.SaveLoadList_mc.selectedIndex = 0;
                }
            }
            this.dispatchEvent({type: "saveListPopulated"});
        }
    }

    function DeleteSelectedSave()
    {
        if (!this.bSaving || this.SaveLoadList_mc.selectedIndex != 0) 
        {
            if (this.bSaving) 
            {
                gfx.io.GameDelegate.call("DeleteSave", [this.SaveLoadList_mc.selectedIndex - 1]);
            }
            else 
            {
                gfx.io.GameDelegate.call("DeleteSave", [this.SaveLoadList_mc.selectedIndex]);
            }
            this.SaveLoadList_mc.entryList.splice(this.SaveLoadList_mc.selectedIndex, 1);
            this.SaveLoadList_mc.InvalidateData();
            this.onSaveLoadItemHighlight({index: this.SaveLoadList_mc.selectedIndex});
        }
    }

}
