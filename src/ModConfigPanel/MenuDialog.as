import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.util.DialogManager;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.defines.Input;


class MenuDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */

  	private var _defaultControls: Object;
  	private var _closeControls: Object;
	

  /* STAGE ELEMENTS */
	
	public var menuList: ScrollingList;

	
  /* PROPERTIES */
	
	public var menuOptions: Array;
	public var menuStartIndex: Number;
	public var menuDefaultIndex: Number;
	
	
  /* INITIALIZATION */
  
	public function MenuDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// @override OptionDialog
	public function initButtons(): Void
	{
		if (platform == 0) {
			_defaultControls = Input.ReadyWeapon;
			_closeControls = Input.Tab;
		} else {
			_defaultControls = Input.YButton;
			_closeControls = Input.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		var closeButton = rightButtonPanel.addButton({text: "$Exit", controls: _closeControls});
		closeButton.addEventListener("press", this, "onExitPress");
		rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	public function initContent(): Void
	{
		menuList.addEventListener("itemPress", this, "onMenuListPress");

		menuList.listEnumeration = new BasicEnumeration(menuList.entryList);

		for (var i=0; i<menuOptions.length; i++) {
			var entry = {text: menuOptions[i], align: "center", enabled: true, state: "normal"};
			menuList.entryList.push(entry);
		}

		var e = menuList.entryList[menuStartIndex];
		menuList.listState.activeEntry = e;
		menuList.selectedIndex = menuStartIndex;

		menuList.InvalidateData();

		FocusHandler.instance.setFocus(menuList, 0);
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				onExitPress();
				return true;
			} else if (details.control == _defaultControls.name) {
				onDefaultPress();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onMenuListPress(a_event: Object): Void
	{
		var e = a_event.entry;
		if (e == undefined)
			return;
		
		menuList.listState.activeEntry = e;
		menuList.UpdateList();
	}
  
	private function onDefaultPress(): Void
	{
		setActiveMenuIndex(menuDefaultIndex);
		menuList.selectedIndex = menuDefaultIndex;
	}
	
	private function onExitPress(): Void
	{
		skse.SendModEvent("SKICP_menuAccepted", null, getActiveMenuIndex());
		DialogManager.close();
	}
	
	private function setActiveMenuIndex(a_index: Number): Void
	{
		var e = menuList.entryList[a_index];
		menuList.listState.activeEntry = e;
		menuList.UpdateList();
	}
	
	private function getActiveMenuIndex(): Number
	{
		var index = menuList.listState.activeEntry.itemIndex;
		return (index != undefined ? index : -1);
	}
}