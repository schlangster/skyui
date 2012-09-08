import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import Components.CrossPlatformButtons

import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.dialog.BasicDialog;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;


class OptionChangeDialog extends BasicDialog
{	
  /* CONSTANTS */
	
	public var MODE_SLIDER = 0;
	public var MODE_MENU = 1;
	

  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var confirmButton: CrossPlatformButtons;
	public var cancelButton: CrossPlatformButtons;
	public var defaultButton: CrossPlatformButtons;
	
	public var sliderPanel: MovieClip;
	public var menuList: ScrollingList;

	
  /* PROPERTIES */
	
	public var optionMode: Number;
	
	
  /* INITIALIZATION */
  
	public function OptionChangeDialog()
	{
		super();
	}
	
	public function onLoad(): Void
	{

		initButtons();
		
		sliderPanel.slider.setScrollProperties(1, 0, 20);
		sliderPanel.slider.addEventListener("scroll", this, "onScroll");
		sliderPanel.slider.position = 50;
		
		menuList.addEventListener("itemPress", this, "onMenuListPress");
		
		trace("MNEU LIST 11: " + menuList);
		
		menuList.listEnumeration = new BasicEnumeration(menuList.entryList);
		menuList.entryFormatter = new ButtonEntryFormatter(menuList);
		
		trace("MNEU LIST 22: " + menuList);
		
		for (var i=0; i<10; i++)
			menuList.entryList.push({text: "Menu option " + i, align: "center", enabled: true, state: "normal"});
		
		menuList.InvalidateData();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onDialogOpening(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}
	
	public function onDialogClosing(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
				
			if (details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT) {
				DialogManager.close();
				bCaught = true;
			}

			if (!bCaught)
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		
		return bCaught;
	}
	
	public function onMenuListPress(a_event: Object): Void
	{
		var e = a_event.entry;
		if (e == undefined)
			return;
		
		ButtonEntryFormatter(menuList.entryFormatter).activeEntry = e;
		menuList.UpdateList();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function initButtons(): Void
	{
		var platform = _global.skyui.platform;
		confirmButton.SetPlatform(platform, false);
		cancelButton.SetPlatform(platform, false);
		defaultButton.SetPlatform(platform, false);

		confirmButton.addEventListener("press", this, "onConfirmPress");
		cancelButton.addEventListener("press", this, "onCancelPress");
		defaultButton.addEventListener("press", this, "onDefaultPress");

		_updateButtonID = setInterval(this, "updateButtonPositions", 1);
	}
	
	private function updateButtonPositions(): Void
	{
		clearInterval(_updateButtonID);
		delete _updateButtonID;
		
		confirmButton._x = (background._width / 2) - confirmButton.textField.textWidth - 30;
		cancelButton._x = confirmButton._x - cancelButton.textField.textWidth - 50;
		defaultButton._x = -(background._width / 2) + 55;
	}
	
	private function onCancelPress(): Void
	{
		DialogManager.close();
	}
	
	private function onConfirmPress(): Void
	{
		DialogManager.close();
	}
	
	private function onDefaultPress(): Void
	{
		DialogManager.close();
	}
}