import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.controls.ButtonGroup;
import gfx.controls.Button;

import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.defines.Input;

import skyui.components.MappedButton;
import skyui.components.list.ScrollingList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.FilteredEnumeration;

import skyui.filter.ItemTypeFilter;
import skyui.filter.SortFilter;


class FavoritesMenu extends MovieClip
{
	var dbgIntvl;
	
  /* CONSTANTS */
	
  	private static var ITEM_SELECT = 0;
	private static var GROUP_ASSIGN = 1;
	private static var GROUP_ASSIGN_SYNC = 2;
	private static var GROUP_CONFIG = 3;
	private static var CLOSING = 4;
	
	
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	
	private var _typeFilter: ItemTypeFilter;
	private var _sortFilter: SortFilter;
	
	private var _groupDataExtender: GroupDataExtender;
	
	private var _categoryButtonGroup: ButtonGroup;
	private var _groupButtonGroup: ButtonGroup;
	
	private var _leftKeycode: Number;
	private var _rightKeycode: Number;
	private var _favKeycode: Number;
	private var _readyKeycode: Number;
	private var _sprintKeycode: Number;
	private var _jumpKeycode: Number;
	
	private var _state: Number;
	
	// A workaround to prevent bla blablabla
	private var _useMouseNavigation: Boolean = false;

	private var _categoryIndex: Number = 0;
	private var _groupIndex: Number = 0;
	
	private var _groupButtonFocus: Boolean = false;
	
	private var _groupAssignIndex: Number = -1;
	
	private var _savedIndex: Number = -1;
	private var _savedScrollPosition: Number = 0;
	
	private var _groupButtonsShown: Boolean = false;
	private var _waitingForGroupData: Boolean = true;
	
	private var _groupDataFormCounter: Number = 0;
	private var _groupDataFlagsCounter: Number = 0;
	
	
  /* STAGE ELEMENTS */
	
	public var itemList: ScrollingList;
	public var background: MovieClip;
	
	public var btnAll: Button;
	public var btnGear: Button;
	public var btnAid: Button;
	public var btnMagic: Button;
	
	public var groupButtonFader: MovieClip;
	
	public var navButton: MappedButton;
	
	public var headerText: TextField;
	
	
  /* PROPERTIES */
	
	// @API
	public var bPCControlsReady: Boolean = true;
	

  /* INITIALIZATION */

	public function FavoritesMenu()
	{
		super();

		//dbgIntvl = setInterval(this, "TestMenu", 1000);
		
		_typeFilter = new ItemTypeFilter();
		_sortFilter = new SortFilter();
		
		_categoryButtonGroup = new ButtonGroup("CategoryButtonGroup");
		_groupButtonGroup = new ButtonGroup("GroupButtonGroup");

		_groupDataExtender = new GroupDataExtender(); 

		Mouse.addListener(this);
	}
	
	
  /* PAPYRUS INTERFACE */
	
	public function setGroupNames(/* string[] */): Void
	{
		for (var i=0; i<8; i++)
			groupButtonFader.groupButtonHolder["btnGroup" + (i+1)].text = arguments[i];
	}
	
	public function setGroupFlags(/* int[] */): Void
	{
	}
	
	public function pushGroupForms(/* formIds[] */): Void
	{
		var j = _groupDataFormCounter;
		for (var i=0; i<arguments.length; i++, j++)
			_groupDataExtender.groupData[j] = {formId: arguments[i]};
		_groupDataFormCounter = j;
	}
	
	public function pushGroupFlags(/* flags[] */): Void
	{
		var j = _groupDataFlagsCounter;
		for (var i=0; i<arguments.length; i++, j++)
			_groupDataExtender.groupData[j].flags = arguments[i];
		_groupDataFlagsCounter = j;
	}
	
	public function finishGroupData(): Void
	{
		itemList.requestInvalidate();
		
		_waitingForGroupData = false;
		enableGroupButtons(true);
	}
	
	public function updateGroupData(a_groupIndex: Number /*, (formId,flag)[] */): Void
	{
		var startIndex = a_groupIndex * GroupDataExtender.GROUP_SIZE;
		
		for (var i=1, j=startIndex ; i<arguments.length; i=i+2, j++) {
			var e = _groupDataExtender.groupData[j];
			e.formId = arguments[i];
			e.flags  = arguments[i+1];
			
			skse.Log(j + " " + e.formId + " " + e.flags);
		}
		
		itemList.requestInvalidate();
		
		// Received group data as result of group assignment?
		if (_state == GROUP_ASSIGN_SYNC)
			endGroupAssignment();
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function InitExtensions(): Void
	{
		skse.ExtendData(true);
		
		_leftKeycode = GlobalFunctions.getMappedKey("Left", Input.CONTEXT_MENUMODE, false);
		_rightKeycode = GlobalFunctions.getMappedKey("Right", Input.CONTEXT_MENUMODE, false);
		_favKeycode = GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, false);
		_readyKeycode = GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, false);
		
		_sprintKeycode = GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, false);
		_jumpKeycode = GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, false);
		
		btnAll.group = _categoryButtonGroup;
		btnGear.group = _categoryButtonGroup;
		btnAid.group = _categoryButtonGroup;
		btnMagic.group = _categoryButtonGroup;
		
		for (var i=1; i<=8; i++)
			groupButtonFader.groupButtonHolder["btnGroup" + i].group = _groupButtonGroup
		
		_categoryButtonGroup.addEventListener("change", this, "onCategorySelect");
		_groupButtonGroup.addEventListener("change", this, "onGroupSelect");
		
		itemList.addDataProcessor(new FilterDataExtender());
		itemList.addDataProcessor(new FavoritesIconSetter());
		itemList.addDataProcessor(_groupDataExtender);

		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_sortFilter);
		
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");
		
		itemList.listEnumeration = listEnumeration;

		GlobalFunc.SetLockFunction();
		_parent.Lock("BL");
		
		GameDelegate.addCallBack("PopulateItems", this, "populateItemList");
		GameDelegate.addCallBack("SetSelectedItem", this, "setSelectedItem");
		GameDelegate.addCallBack("StartFadeOut", this, "startFadeOut");
		
		itemList.addEventListener("itemPress", this, "onItemPress");
		itemList.addEventListener("selectionChange", this, "onItemSelectionChange");
		FocusHandler.instance.setFocus(itemList, 0);
		
		_parent.gotoAndPlay("startFadeIn");
		
		_sortFilter.setSortBy(["text"], [], false);
		
		setGroupFocus(false);
		
		_state = ITEM_SELECT;
		
		// Wait for initial group data
		_waitingForGroupData = true;
		
		navButton.visible = false;
	}
	
	// @API
	public function get ItemList(): MovieClip
	{
		return itemList;
	}
	
	function TestMenu(): Void
	{
		clearInterval(dbgIntvl);
		
		InitExtensions();

		itemList.clearList();
		for (var i=0; i<100; i++) {
			itemList.entryList.push({text: "test " + i, equipState: 0, filterFlag: 1, disabled: false, formId: i+100});
		}
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_state == CLOSING)
			return true;
		
		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;
			
			trace(details.code);
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				if (_state == GROUP_ASSIGN) {
					endGroupAssignment();
				} else {
					startFadeOut();
				}
				return true;
				
			} else if(details.navEquivalent == NavigationCode.LEFT || details.skseKeycode == _leftKeycode) {
				if (_state == GROUP_ASSIGN) {
					
					// Don't change the index here, leave it to onGroupSelect so it can detect assignment confirmation
					var idx = _groupAssignIndex;
					
					if (idx == -1)
						idx = _groupButtonGroup.length - 1;
					else
						idx--
						
					if (idx < 0)
						idx = _groupButtonGroup.length - 1;
					_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(idx));
					
				} else if (_state == ITEM_SELECT) {
				
					if (_groupButtonFocus) {
						_groupIndex--;
						if (_groupIndex < 0)
							_groupIndex = _groupButtonGroup.length - 1;
						_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(_groupIndex));
					} else {
						_categoryIndex--;
						if (_categoryIndex < 0)
							_categoryIndex = _categoryButtonGroup.length - 1;
						_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
					}
				}

				return true;
				
			} else if (details.navEquivalent == NavigationCode.RIGHT || details.skseKeycode == _rightKeycode) {
				if (_state == GROUP_ASSIGN) {
					// Don't change the index here, leave it to onGroupSelect so it can detect assignment confirmation
					var idx = _groupAssignIndex;
					
					if (idx == -1)
						idx = 0;
					else
						idx++
						
					if (idx >= _groupButtonGroup.length)
						idx = 0;
					_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(idx));
					
				} else if (_state == ITEM_SELECT) {
					if (_groupButtonFocus) {
						_groupIndex++;
						if (_groupIndex >= _groupButtonGroup.length)
							_groupIndex = 0;
						_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(_groupIndex));
					} else {
						_categoryIndex++;
						if (_categoryIndex >= _categoryButtonGroup.length)
							_categoryIndex = 0;
						_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
					}
				}

				return true;
				
			} else if (details.skseKeycode == _favKeycode || details.code == 70) {
				
				if (_state == ITEM_SELECT && !_groupButtonFocus) {
					startGroupAssignment();					
				} else if (_state == GROUP_ASSIGN) {
					endGroupAssignment();
				}
				
				return true;

			} else if (_state == GROUP_ASSIGN && details.navEquivalent == NavigationCode.ENTER) {
				if (_groupAssignIndex != -1)
					applyGroupAssignment();
				return true;
				
			} else if (details.skseKeycode == _readyKeycode || details.code == 82) {
				if (_state == ITEM_SELECT && _groupButtonFocus)
					requestGroupUse();
				return true;
				
			} else if (details.skseKeycode == _sprintKeycode || details.code == 18) {
				return true;
				
			} else if (details.skseKeycode == _jumpKeycode || details.code == 32) {
				if (_state == ITEM_SELECT)
					setGroupFocus(!_groupButtonFocus); // toggle
				return true;
			}
		}
		
		return true;
	}

	// @API
	public function get selectedIndex(): Number
	{
		return confirmSelectedEntry() ? itemList.selectedEntry.index : -1;
	}

	// @API
	public function setSelectedItem(a_index: Number): Void
	{
		for (var i = 0; i < itemList.entryList.length; i++) {
			if (itemList.entryList[i].index == a_index) {
				itemList.selectedIndex = i;
//				itemList.RestoreScrollPosition(i);
				itemList.UpdateList();
				return;
			}
		}
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		navButton.setPlatform(a_platform);
	}
	

  /* PRIVATE FUNCTIONS */
  
	private function onFilterChange(a_event: Object): Void
	{
		itemList.requestInvalidate();
	}

	private function onItemPress(a_event: Object): Void
	{
		if (_state != ITEM_SELECT)
			return;
		
		// Only handles keyboard input, mouse is done internally
		if (a_event.keyboardOrMouse != 0) {
			_useMouseNavigation = false;
			GameDelegate.call("ItemSelect", []);
		} else {
			_useMouseNavigation = true;
		}
	}
	
	private function onItemSelectionChange(a_event: Object): Void
	{
		_useMouseNavigation = a_event.keyboardOrMouse == 0;
	}
	
	private function onCategorySelect(a_event: Object): Void
	{
		var btn = a_event.item;
		if (btn == null)
			return;
			
		_categoryIndex = _categoryButtonGroup.indexOf(btn);
			
		_groupButtonFocus = false;
		_groupButtonGroup.setSelectedButton(null);
		
		headerText.SetText(btn.text);
		_typeFilter.changeFilterFlag(btn.filterFlag);
	}
	
	private function onGroupSelect(a_event: Object): Void
	{
		var btn = a_event.item;
		if (btn == null)
			return;

		var index = _groupButtonGroup.indexOf(btn);
		_groupButtonFocus = true;
		
		_categoryButtonGroup.setSelectedButton(null);
		
		headerText.SetText(btn.text);
		
		_typeFilter.changeFilterFlag(btn.filterFlag);
		
		if (_state == GROUP_ASSIGN) {
			if (_groupAssignIndex == index) {
				applyGroupAssignment();
			} else {
				navButton.setButtonData({text: (Translator.translate("$ADD TO") + " " + btn.text), controls: Input.Accept});
				_groupAssignIndex = index;				
			}
		} else {
			_groupIndex = index;
		}
	}

	private function startFadeOut(): Void
	{
		_state = CLOSING;
		_parent.gotoAndPlay("startFadeOut");
	}
	
	private function onFadeOutCompletion(): Void
	{
		GameDelegate.call("FadeDone", [itemList.selectedIndex]);
	}
	
	private function onMouseDown(): Void
	{
		_useMouseNavigation = true;
	}
	
	private function onMouseMove(): Void
	{
		_useMouseNavigation = true;
	}
	
	private function startGroupAssignment(): Void
	{
		var selectedEntry = itemList.selectedEntry;
		if (selectedEntry == null)
			return;
			
		_state = GROUP_ASSIGN;
		
		headerText._visible = false;
		
		_groupAssignIndex = -1;
		
		var assignedEntry =  itemList.selectedEntry;
		itemList.listState.assignedEntry = assignedEntry;
		
		assignedEntry.filterFlag |= FilterDataExtender.FILTERFLAG_GROUP_ADD;
		
		itemList.listState.restoredSelectedIndex = itemList.selectedIndex;
		itemList.listState.restoredScrollPosition = itemList.scrollPosition;
		
		itemList.selectedIndex = -1;
		itemList.disableSelection = true;		
		itemList.requestUpdate();

		navButton.visible = true;
		navButton.setButtonData({text: "$SELECT GROUP", controls: Input.LeftRight});
		
		btnAll.disabled = true;
		btnGear.disabled = true;
		btnAid.disabled = true;
		btnMagic.disabled = true;
		
		btnAll.visible = false;
		btnGear.visible = false;
		btnAid.visible = false;
		btnMagic.visible = false;
	}
	
	private function applyGroupAssignment(): Void
	{
		var formId: Number = itemList.listState.assignedEntry.formId;
		
		if (formId == null || formId == 0 || _groupAssignIndex == -1) {
			endGroupAssignment();
		} else {
			// Suspend list to avoid redundant invalidate before new synced group data arrives
			itemList.suspended = true
			enableGroupButtons(false);
			_state = GROUP_ASSIGN_SYNC;
			skse.SendModEvent("SKIFM_groupAdded", "", _groupAssignIndex, formId);
		}
	}
	
	private function endGroupAssignment(): Void
	{
		itemList.listState.assignedEntry.filterFlag &= ~FilterDataExtender.FILTERFLAG_GROUP_ADD;
		itemList.listState.assignedEntry = null;
		
		itemList.disableSelection = false;
		itemList.requestInvalidate();
		
		itemList.onInvalidate = function()
		{
			this.scrollPosition = this.listState.restoredScrollPosition;
			this.selectedIndex = this.listState.restoredSelectedIndex;
			delete this.onInvalidate;
		};
		
		_state = ITEM_SELECT;
				
		itemList.suspended = false;
		itemList.disableSelection = false;
		itemList.requestInvalidate();
			
		_groupAssignIndex = -1;
		
		btnAll.disabled = false;
		btnGear.disabled = false;
		btnAid.disabled = false;
		btnMagic.disabled = false;
		
		btnAll.visible = true;
		btnGear.visible = true;
		btnAid.visible = true;
		btnMagic.visible = true

		headerText._visible = true;
		navButton.visible = false;
		
		setGroupFocus(false);
		enableGroupButtons(true);
	}
	
	private function requestGroupUse(): Void
	{
		if (_groupButtonFocus && _groupIndex >= 0) {
			skse.SendModEvent("SKIFM_groupUsed", "", _groupIndex);
			startFadeOut();
		}
	}
	
	private function enableGroupButtons(a_enabled: Boolean): Void
	{
		if (a_enabled && !_groupButtonsShown) {
			_groupButtonsShown = true;
			groupButtonFader.gotoAndPlay("show");
		}
		var t = !a_enabled;
		for (var i=1; i<=8; i++)
			groupButtonFader.groupButtonHolder["btnGroup" + i].disabled = t;
	}
	
	private function setGroupFocus(a_focus: Boolean): Void
	{
		if (a_focus) {
			if (_groupButtonsShown) {
				_groupButtonFocus = true;
				_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(_groupIndex));
			}
		} else {
			_groupButtonFocus = false;
			_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
		}
	}
	
	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry(): Boolean
	{
		// only confirm when using mouse
		if (_platform != 0 || !_useMouseNavigation || _state != ITEM_SELECT)
			return true;
		
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e.itemIndex == itemList.selectedIndex)
				return true;
				
		return false;
	}
}
