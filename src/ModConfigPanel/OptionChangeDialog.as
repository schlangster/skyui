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
import skyui.util.GlobalFunctions;


class OptionChangeDialog extends BasicDialog
{	
  /* CONSTANTS */
	
	public static var MODE_SLIDER = 0;
	public static var MODE_MENU = 1;
	

  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var confirmButton: CrossPlatformButtons;
	public var cancelButton: CrossPlatformButtons;
	public var defaultButton: CrossPlatformButtons;
	
	public var titleTextField: TextField;
	public var sliderPanel: MovieClip;
	public var menuList: ScrollingList;

	
  /* PROPERTIES */
	
	public var optionMode: Number;
	public var titleText: String;
	
	public var sliderValue: Number;
	public var sliderDefault: Number;
	public var sliderMax: Number;
	public var sliderMin: Number;
	public var sliderInterval: Number;
	public var sliderFormatString: String;
	
	public var menuOptions: Array;
	public var menuStartIndex: Number;
	public var menuDefaultIndex: Number;
	
	
  /* INITIALIZATION */
  
	public function OptionChangeDialog()
	{
		super();
	}
	
	public function onLoad(): Void
	{
		initButtons();

		titleTextField.textAutoSize = "shrink";
		titleTextField.SetText(titleText.toUpperCase());
		
		if (optionMode == MODE_SLIDER) {
			menuList._visible = false;
			initSlider();
		}  else {
			sliderPanel._visible = false;
			initMenu();
		}
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
	
	public function onScroll(event: Object): Void
	{
		sliderValue = event.position * sliderInterval;
		var t = sliderFormatString	? GlobalFunctions.format(sliderFormatString, sliderValue)
									: t = Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
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
	
	private function initSlider(): Void
	{
		var d = sliderInterval;
		sliderPanel.slider.setScrollProperties(((sliderMax - sliderMin) / d) / 10, sliderMin / d, sliderMax / d);
		sliderPanel.slider.addEventListener("scroll", this, "onScroll");
		sliderPanel.slider.position = sliderValue / d;
	}
	
	private function initMenu(): Void
	{
		menuList.addEventListener("itemPress", this, "onMenuListPress");
		
		menuList.listEnumeration = new BasicEnumeration(menuList.entryList);
		menuList.entryFormatter = new ButtonEntryFormatter(menuList);
		
		for (var i=0; i<menuOptions.length; i++) {
			var entry = {text: menuOptions[i], align: "center", enabled: true, state: "normal"};
			menuList.entryList.push(entry);
			if (i == menuStartIndex)
				ButtonEntryFormatter(menuList.entryFormatter).activeEntry = entry;
		}
		
		menuList.InvalidateData();
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
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}
	
	private function onConfirmPress(): Void
	{
		if (optionMode == MODE_SLIDER)
			skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
		else
			skse.SendModEvent("SKICP_menuAccepted", null, getActiveMenuIndex());
		DialogManager.close();
	}
	
	private function onDefaultPress(): Void
	{
		if (optionMode == MODE_SLIDER)
			sliderPanel.slider.position = sliderDefault / sliderInterval;
		else
			setActiveMenuIndex(menuDefaultIndex);
	}
	
	// Not so great...
	private function setActiveMenuIndex(a_index: Number): Void
	{
		var e = menuList.entryList[a_index];
		ButtonEntryFormatter(menuList.entryFormatter).activeEntry = e;
		menuList.UpdateList();
	}
	
	private function getActiveMenuIndex(): Number
	{
		var index = ButtonEntryFormatter(menuList.entryFormatter).activeEntry.itemIndex
		return (index ? index : -1);
	}
}