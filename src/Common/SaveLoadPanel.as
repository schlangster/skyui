import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;

class SaveLoadPanel extends MovieClip
{
	static var SCREENSHOT_DELAY: Number = 200; //750
  static var CONTROLLER_PC = 0;
  static var CONTROLLER_PC_GAMEPAD = 1;
  static var CONTROLLER_DURANGO = 2;
  static var CONTROLLER_ORBIS = 3;

	var List_mc: MovieClip;
	var SaveLoadList_mc: MovieClip;
	var ScreenshotHolder: MovieClip;
	var ScreenshotRect: MovieClip;

	var ScreenshotLoader: MovieClipLoader;

	var PlayerInfoText: TextField;

	var dispatchEvent: Function;

	var bSaving: Boolean;

	var iBatchSize: Number;
	var iPlatform: Number;
	var iScreenshotTimerID: Number;
	var showCharacterBackHint;
	var showingCharacterList;
	var lastSelectedIndexMemory;

	var uiSaveLoadManagerProcessedElements;
	var uiSaveLoadManagerNumElementsToLoad;
	var isForceStopping;

	function SaveLoadPanel()
	{
		super();
		EventDispatcher.initialize(this);
		SaveLoadList_mc = List_mc;
		bSaving = true;

    showCharacterBackHint = false;
    showingCharacterList = false;
    lastSelectedIndexMemory = 0;
    uiSaveLoadManagerProcessedElements = 0;
    uiSaveLoadManagerNumElementsToLoad = 0;
    isForceStopping = false;
	}

	function onLoad(): Void
	{
		ScreenshotLoader = new MovieClipLoader();
		ScreenshotLoader.addListener(this);
		GameDelegate.addCallBack("ConfirmOKToLoad", this, "onOKToLoadConfirm");
		GameDelegate.addCallBack("onSaveLoadBatchComplete", this, "onSaveLoadBatchComplete");
    GameDelegate.addCallBack("onFillCharacterListComplete",this,"onFillCharacterListComplete");
		GameDelegate.addCallBack("ScreenshotReady", this, "ShowScreenshot");
		SaveLoadList_mc.addEventListener("itemPress", this, "onSaveLoadItemPress");
		SaveLoadList_mc.addEventListener("selectionChange", this, "onSaveLoadItemHighlight");
		iBatchSize = SaveLoadList_mc.maxEntries; //max = 0x7FFFFFFF;
		PlayerInfoText.createTextField("LevelText", PlayerInfoText.getNextHighestDepth(), 0, 0, 200, 30);
		PlayerInfoText.LevelText.text = "$Level";
		PlayerInfoText.LevelText._visible = false;
	}

	function get isSaving(): Boolean
	{
		return bSaving;
	}

	function set isSaving(abFlag: Boolean): Void
	{
		bSaving = abFlag;
	}

  function get isShowingCharacterList()
  {
  	return showingCharacterList;
  }

  function set isShowingCharacterList(abFlag)
  {
    showingCharacterList = abFlag;
    if(iPlatform != SaveLoadPanel.CONTROLLER_ORBIS)
    {
      ScreenshotHolder._visible = !showingCharacterList;
    }
    PlayerInfoText._visible = !showingCharacterList;
  }

	function get selectedIndex(): Number
	{
		return SaveLoadList_mc.selectedIndex;
	}

	function get platform(): Number
	{
		return iPlatform;
	}

	function set platform(aiPlatform: Number): Void
	{
		iPlatform = aiPlatform;
	}

	function get batchSize(): Number
	{
		return iBatchSize;
	}

	function get numSaves(): Number
	{
		return SaveLoadList_mc.entryList.length;
	}

	function get selectedEntry()
	{
		return SaveLoadList_mc.entryList[SaveLoadList_mc.selectedIndex];
	}

	function get LastSelectedIndexMemory()
	{
		if(lastSelectedIndexMemory > SaveLoadList_mc.entryList.length -1) {
			lastSelectedIndexMemory = Math.max(0, SaveLoadList_mc.entryList.length - 1);
		}
		return lastSelectedIndexMemory;
	}

	function onSaveLoadItemPress(event: Object): Void
	{
    lastSelectedIndexMemory = SaveLoadList_mc.selectedIndex;
    if(this.isShowingCharacterList)
    {
      var selected = this.SaveLoadList_mc.entryList[this.SaveLoadList_mc.selectedIndex];
      if(selected != undefined)
      {
        if(this.iPlatform != 0)
        {
          SaveLoadList_mc.selectedIndex = 0;
        }
        var flags = selected.flags;
        if(flags == undefined)
        {
         	flags = 0;
        }
        var id = selected.id;
        if(id == undefined)
        {
          flags = 4294967295;
        }
        gfx.io.GameDelegate.call("CharacterSelected",[id, flags, bSaving, SaveLoadList_mc.entryList, iBatchSize]);
        this.dispatchEvent({type:"OnCharacterSelected"});
        return;
      }
    }
		if (!bSaving) {
			GameDelegate.call("IsOKtoLoad", [SaveLoadList_mc.selectedIndex]);
			return;
		}
		dispatchEvent({type: "saveGameSelected", index: SaveLoadList_mc.selectedIndex});
	}

	function onOKToLoadConfirm(): Void
	{
		dispatchEvent({type: "loadGameSelected", index: SaveLoadList_mc.selectedIndex});
	}

	function ForceStopLoading()
	{
    isForceStopping = true;
    if(uiSaveLoadManagerProcessedElements < uiSaveLoadManagerNumElementsToLoad)
    {
      GameDelegate.call("ForceStopSaveListLoading",[]);
    }
	}

	function RemoveScreenshot()
	{
		if (iScreenshotTimerID != undefined) {
			clearInterval(iScreenshotTimerID);
			iScreenshotTimerID = undefined;
		}
		if (ScreenshotRect != undefined) {
			ScreenshotRect.removeMovieClip();
			PlayerInfoText.textField.SetText(" ");
			PlayerInfoText.DateText.SetText(" ");
			PlayerInfoText.PlayTimeText.SetText(" ");
			ScreenshotRect = undefined;
		}
	}

	function onSaveLoadItemHighlight(event: Object): Void
	{
		if(isForceStopping)
			return;

		RemoveScreenshot();

		if(isShowingCharacterList)
			return;

		if (event.index != -1)
			iScreenshotTimerID = setInterval(this, "PrepScreenshot", SaveLoadPanel.SCREENSHOT_DELAY);
		dispatchEvent({type: "saveHighlighted", index: SaveLoadList_mc.selectedIndex});
	}

	function PrepScreenshot(): Void
	{
		clearInterval(iScreenshotTimerID);
		iScreenshotTimerID = undefined;
		if (bSaving) {
			GameDelegate.call("PrepSaveGameScreenshot", [SaveLoadList_mc.selectedIndex - 1, SaveLoadList_mc.selectedEntry]);
			return;
		}
		GameDelegate.call("PrepSaveGameScreenshot", [SaveLoadList_mc.selectedIndex, SaveLoadList_mc.selectedEntry]);
	}

	function ShowScreenshot(): Void
	{
		ScreenshotRect = ScreenshotHolder.createEmptyMovieClip("ScreenshotRect", 0);
		ScreenshotLoader.loadClip("img://BGSSaveLoadHeader_Screenshot", ScreenshotRect);

		if (SaveLoadList_mc.selectedEntry.corrupt == true) {
			PlayerInfoText.textField.SetText("$SAVE CORRUPT");
		} else if (SaveLoadList_mc.selectedEntry.obsolete == true) {
			PlayerInfoText.textField.SetText("$SAVE OBSOLETE");
		} else if (SaveLoadList_mc.selectedEntry.name == undefined) {
			PlayerInfoText.textField.SetText(" ");
		} else {
			var strSaveName: String = SaveLoadList_mc.selectedEntry.name;
			var iSaveNameMaxLength: Number = 20;
			if (strSaveName.length > iSaveNameMaxLength)
				strSaveName = strSaveName.substr(0, iSaveNameMaxLength - 3) + "...";
			if (SaveLoadList_mc.selectedEntry.raceName != undefined && SaveLoadList_mc.selectedEntry.raceName.length > 0)
				strSaveName = strSaveName + (", " + SaveLoadList_mc.selectedEntry.raceName);
			if (SaveLoadList_mc.selectedEntry.level != undefined && SaveLoadList_mc.selectedEntry.level > 0)
				strSaveName = strSaveName + (", " + PlayerInfoText.LevelText.text + " " + SaveLoadList_mc.selectedEntry.level);
			PlayerInfoText.textField.textAutoSize = "shrink";
			PlayerInfoText.textField.SetText(strSaveName);
		}

		if (SaveLoadList_mc.selectedEntry.playTime == undefined)
			PlayerInfoText.PlayTimeText.SetText(" ");
		else
			PlayerInfoText.PlayTimeText.SetText(SaveLoadList_mc.selectedEntry.playTime);

		if (SaveLoadList_mc.selectedEntry.dateString != undefined) {
			PlayerInfoText.DateText.SetText(SaveLoadList_mc.selectedEntry.dateString);
			return;
		}
		PlayerInfoText.DateText.SetText(" ");
	}

	function onLoadInit(aTargetClip: MovieClip): Void
	{
		aTargetClip._width = ScreenshotHolder.sizer._width;
		aTargetClip._height = ScreenshotHolder.sizer._height;
	}

	function onFillCharacterListComplete(abDoInitialUpdate: Boolean): Void
	{
		// FIXME? Is this a no-op by mistake?
		isShowingCharacterList(true);
		var iSaveNameMaxLength: Number = 20;

		for (var i: Number = 0; i < SaveLoadList_mc.entryList.length; i++)
			if (SaveLoadList_mc.entryList[i].text.length > iSaveNameMaxLength)
				SaveLoadList_mc.entryList[i].text = SaveLoadList_mc.entryList[i].text.substr(0, iSaveNameMaxLength - 3) + "...";

		SaveLoadList_mc.InvalidateData();

		if(iPlatform != 0) {
			onSaveLoadItemHighlight({index:LastSelectedIndexMemory});
			SaveLoadList_mc.selectedIndex = LastSelectedIndexMemory;
			SaveLoadList_mc.UpdateList();
		}
		dispatchEvent({type: "saveListCharactersPopulated"});
	}

	function onSaveLoadBatchComplete(abDoInitialUpdate: Boolean, aNumProcessed: Number, aSaveCount: Number): Void
	{
		var iSaveNameMaxLength: Number = 20;
		uiSaveLoadManagerProcessedElements = aNumProcessed;
		uiSaveLoadManagerNumElementsToLoad = aSaveCount;

		var cursor = 0;
		while(cursor < SaveLoadList_mc.entryList.length) {
			if(iPlatform == SaveLoadPanel.CONTROLLER_ORBIS)
			{
				if(SaveLoadList_mc.entryList[cursor].text == undefined)
				{
					SaveLoadList_mc.entryList.splice(cursor, 1);
				}
			}
			if(SaveLoadList_mc.entryList[cursor].text.length > iSaveNameMaxLength)
			{
				SaveLoadList_mc.entryList[cursor].text = SaveLoadList_mc.entryList[cursor].text.substr(0, iSaveNameMaxLength - 3) + "...";
			}
			cursor++;
		}

		var strNewSave: String = "$[NEW SAVE]";
		if (bSaving && SaveLoadList_mc.entryList[0].text != strNewSave) {
			var newSaveObj: Object = {name: " ", playTime: " ", text: strNewSave};
			SaveLoadList_mc.entryList.unshift(newSaveObj);
		} else if (!bSaving && SaveLoadList_mc.entryList[0].text == strNewSave) {
			SaveLoadList_mc.entryList.shift();
		}

		SaveLoadList_mc.InvalidateData();
		if(iPlatform == SaveLoadPanel.CONTROLLER_ORBIS)
		{
			lastSelectedIndexMemory = 0;
		}

		if (abDoInitialUpdate) {
			isForceStopping = false;
			isShowingCharacterList = false;
			onSaveLoadItemHighlight({index: LastSelectedIndexMemory});
			SaveLoadList_mc.selectedIndex(LastSelectedIndexMemory);
			SaveLoadList_mc.UpdateList();
			dispatchEvent({type:"saveListPopulated"});
			return;
		}

		if(isForceStopping)
			return;

		dispatchEvent({type: "saveListPopulated"});
	}

	function DeleteSelectedSave(): Void
	{
		if (!bSaving || SaveLoadList_mc.selectedIndex != 0) {
			if (bSaving)
				GameDelegate.call("DeleteSave", [SaveLoadList_mc.selectedIndex - 1]);
			else
				GameDelegate.call("DeleteSave", [SaveLoadList_mc.selectedIndex]);
			SaveLoadList_mc.entryList.splice(SaveLoadList_mc.selectedIndex, 1);
			SaveLoadList_mc.InvalidateData();
			onSaveLoadItemHighlight({index: SaveLoadList_mc.selectedIndex});
		}
	}

	function PopulateEmptySaveList()
	{
		SaveLoadList_mc.ClearList();
		SaveLoadList_mc.entryList.push(new Object());
		onSaveLoadBatchComplete(true, 0, 0);
	}

	function OnSelectClicked()
	{
		onSaveLoadItemPress(null);
	}

	function OnBackClicked()
	{
		dispatchEvent({type:"OnSaveLoadPanelBackClicked"});
	}
}
