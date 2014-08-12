import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

import skyui.components.ButtonPanel;
import skyui.defines.Input;

import skyui.util.GlobalFunctions;
import skyui.util.Translator;


class ListDialog extends MovieClip
{
  /* PRIVATE VARIABLES */

	private var defaultIndex_: Number;
	private var requestDataId_: Number;
	
	private var closeControls_: Object;
	private var defaultControls_: Object;
	
	private var defaultKey_: Number = -1;

  /* STAGE ELEMENTS */
	
	public var menuList: ScrollingList;
	public var titleTextField: TextField;
	public var leftButtonPanel: ButtonPanel;
	public var rightButtonPanel: ButtonPanel;
	
  /* PROPERTIES */
  
  /* INITIALIZATION */

	public function ListDialog()
	{
		super();
	}
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoad()
	{
		super.onLoad();
		
		// Initially hidden
		_visible = false;
		
		Mouse.addListener(this);
		Key.addListener(this);
		
		// SKSE functions not yet available and there's no InitExtensions...
		// This should do the trick.
		requestDataId_ = setInterval(this, "requestData", 1);
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.TAB) {
				exitMenu();
				bHandledInput = true;
			} else if (details.skseKeycode == defaultKey_) {
				onDefaultPress();
				bHandledInput = true;
			}
		}
		
		if(bHandledInput) {
			return bHandledInput;
		} else {
			var nextClip = pathToFocus.shift();
			if (nextClip.handleInput(details, pathToFocus)) {
				return true;
			}
		}
		
		return false;
	}
	
  /* PRIVATE FUNCTIONS */
  
	private function requestData(): Void
	{
		clearInterval(requestDataId_);
		
		skse.SendModEvent("UILIB_1_listMenuOpen");		
	}

	private function setupButtons(platform: Number): Void
	{		
		defaultControls_ = Input.ReadyWeapon;
	
		if (platform == 0) {
			closeControls_ = Input.Tab;
		} else {
			closeControls_ = Input.Cancel;
		}
		
		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: defaultControls_});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();
		
		rightButtonPanel.clearButtons();
		var closeButton = rightButtonPanel.addButton({text: "$Exit", controls: closeControls_});
		closeButton.addEventListener("press", this, "onExitPress");
		rightButtonPanel.updateButtons();
	}
	
	private function onExitPress(): Void
	{
		exitMenu();
	}

	private function exitMenu(): Void
	{
		skse.SendModEvent("UILIB_1_listMenuClose", null, getActiveMenuIndex());
		skse.CloseMenu("CustomMenu");
	}
  
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
		setActiveMenuIndex(defaultIndex_);
		menuList.selectedIndex = defaultIndex_;
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
	
  /* PAPYRUS INTERFACE */
  
	public function setPlatform(platform: Number): Void
	{
		var isGamepad = platform != 0;
		
		defaultKey_ = GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, isGamepad);
		
		leftButtonPanel.setPlatform(platform, false);
		rightButtonPanel.setPlatform(platform, false);
		setupButtons(platform);
	}
	
	public function initListData(/* values */): Void
	{
		// List setup stuff
		menuList.addEventListener("itemPress", this, "onMenuListPress");
		menuList.listEnumeration = new BasicEnumeration(menuList.entryList);
		
		// Get options and translate them
		var menuOptions = [];
		
		for (var i=0; i<arguments.length; i++) {
			var s = arguments[i];
			
			// Cut off rest of the buffer once the first emtpy string was found
			if (s.toLowerCase() == "none" || s == "")
				break;
				
			menuOptions.push(Translator.translateNested(s));
		}

		// Put options into list
		for (var i=0; i<menuOptions.length; i++) {
			var entry = {text: menuOptions[i], align: "center", enabled: true, state: "normal"};
			menuList.entryList.push(entry);
		}
	}

	public function initListParams(titleText: String, startIndex: Number, defaultIndex: Number): Void
	{
		// Title text
		titleTextField.textAutoSize = "shrink";
		titleText = Translator.translate(titleText);
		titleTextField.SetText(titleText.toUpperCase());
		
		// Store default index
		defaultIndex_ = defaultIndex;
		
		// Select initial index
		var e = menuList.entryList[startIndex];
		menuList.listState.activeEntry = e;
		menuList.selectedIndex = startIndex;

		// Redraw
		menuList.InvalidateData();

		// Focus
		FocusHandler.instance.setFocus(menuList, 0);
		
		// And show the menu
		_visible = true;
	}
}