import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;

class SaveLoadPanel extends MovieClip
{
	static var SCREENSHOT_DELAY: Number = 200; //750
	
	
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

	function SaveLoadPanel()
	{
		super();
		EventDispatcher.initialize(this);
		SaveLoadList_mc = List_mc;
		bSaving = true;
	}

	function onLoad(): Void
	{
		ScreenshotLoader = new MovieClipLoader();
		ScreenshotLoader.addListener(this);
		GameDelegate.addCallBack("ConfirmOKToLoad", this, "onOKToLoadConfirm");
		GameDelegate.addCallBack("onSaveLoadBatchComplete", this, "onSaveLoadBatchComplete");
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

	function onSaveLoadItemPress(event: Object): Void
	{
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

	function onSaveLoadItemHighlight(event: Object): Void
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

	function onSaveLoadBatchComplete(abDoInitialUpdate: Boolean): Void
	{
		var iSaveNameMaxLength: Number = 20;
		
		for (var i: Number = 0; i < SaveLoadList_mc.entryList.length; i++)
			if (SaveLoadList_mc.entryList[i].text.length > iSaveNameMaxLength) 
				SaveLoadList_mc.entryList[i].text = SaveLoadList_mc.entryList[i].text.substr(0, iSaveNameMaxLength - 3) + "...";
		
		if (abDoInitialUpdate) {
			var strNewSave: String = "$[NEW SAVE]";
			if (bSaving && SaveLoadList_mc.entryList[0].text != strNewSave) {
				var newSaveObj: Object = {name: " ", playTime: " ", text: strNewSave};
				SaveLoadList_mc.entryList.unshift(newSaveObj);
			} else if (!bSaving && SaveLoadList_mc.entryList[0].text == strNewSave) {
				SaveLoadList_mc.entryList.shift();
			}
		}
		SaveLoadList_mc.InvalidateData();
		
		if (abDoInitialUpdate) {
			if (iPlatform != 0) {
				if (SaveLoadList_mc.selectedIndex == 0) 
					onSaveLoadItemHighlight({index: 0});
				else 
					SaveLoadList_mc.selectedIndex = 0;
			}
			dispatchEvent({type: "saveListPopulated"});
		}
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

}
