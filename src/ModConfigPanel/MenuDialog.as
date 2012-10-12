import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.util.DialogManager;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;


class MenuDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
  
  	private var _selectButton: MovieClip;
  	private var _defaultButton: MovieClip;
  	private var _closeButton: MovieClip;
	

  /* STAGE ELEMENTS */
	
	public var menuList: ScrollingList;


  /* PUBLIC VARIABLES */
	public var focusTarget;

	
  /* PROPERTIES */
	
	public var menuOptions: Array;
	public var menuStartIndex: Number;
	public var menuDefaultIndex: Number;
	
	
  /* INITIALIZATION */
  
	public function MenuDialog()
	{
		super();
		focusTarget = menuList;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// @override OptionDialog
	private function initButtons(): Void
	{
		var selectControls: Object;
		var closeControls: Object;
		
		if (platform == 0) {
			selectControls = InputDefines.Enter;
			closeControls = InputDefines.Escape;
		} else {
			selectControls = InputDefines.Accept;
			closeControls = InputDefines.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		_selectButton = leftButtonPanel.addButton({text: "$Select", controls: selectControls});
		_defaultButton = leftButtonPanel.addButton({text: "$Default", controls: InputDefines.ReadyWeapon});
		_defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		_closeButton = rightButtonPanel.addButton({text: "$Exit", controls: closeControls});
		_closeButton.addEventListener("press", this, "onExitPress");
		rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	private function initContent(): Void
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
	}
	
	public function onDefaultPress(): Void
	{
		setActiveMenuIndex(menuDefaultIndex);
	}
	
	public function onExitPress(): Void
	{
		skse.SendModEvent("SKICP_menuAccepted", null, getActiveMenuIndex());
//		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
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
			} else if (details.control == InputDefines.ReadyWeapon.name) {
				onDefaultPress();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	public function onMenuListPress(a_event: Object): Void
	{
		var e = a_event.entry;
		if (e == undefined)
			return;
		
		menuList.listState.activeEntry = e;
		menuList.UpdateList();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
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