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
import skyui.defines.Form;

import skyui.components.ButtonPanel;
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
	private static var GROUP_REMOVE_SYNC = 3;
	private static var CLOSING = 4;
	private static var SET_MAIN_HAND_SYNC = 5;
	private static var SET_ICON_SYNC = 6;
	
	
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	
	private var _typeFilter: ItemTypeFilter;
	private var _sortFilter: SortFilter;
	
	private var _groupDataExtender: GroupDataExtender;
	
	private var _categoryButtonGroup: ButtonGroup;
	private var _groupButtonGroup: ButtonGroup;
	
	private var _leftKeycode: Number = -1;
	private var _rightKeycode: Number = -1;
	private var _groupAddKey: Number = -1;
	private var _groupUseKey: Number = -1;
	private var _setIconKey: Number = -1;
	private var _setMainHandKey: Number = -1;
	private var _toggleFocusKey: Number = -1;
	
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
	
	private var _isInitialized: Boolean = false;
	
	private var _navPanelEnabled: Boolean = false;
	
	
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

	public var navPanel: MovieClip;
//	public var navPanels: ButtonPanel;
	
	
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

		Mouse.addListener(this);
	}
	
	
  /* PAPYRUS INTERFACE */
  
	public function enableNavigationHelp(a_enabled: Boolean): Void
	{
		_navPanelEnabled = a_enabled;
		updateNavButtons();
	}
	
	public function pushGroupForms(/* formIds[] */): Void
	{
		for (var i=0; i<arguments.length; i++)
			_groupDataExtender.groupData.push(arguments[i]);
	}
	
	public function finishGroupData(a_groupCount: Number /*, mainHandFormIds[], groupIconFormIds[] */): Void
	{
		var offset = 1;
		var i: Number;
		
		for (i=0; i<a_groupCount; i++, offset++)
			_groupDataExtender.mainHandData.push(arguments[offset]);
		for (i=0; i<a_groupCount; i++, offset++)
			_groupDataExtender.iconData.push(arguments[offset]);
		
		if (_isInitialized)
			itemList.InvalidateData();
		
		_waitingForGroupData = false;
		enableGroupButtons(true);
	}
	
	public function updateGroupData(a_groupIndex: Number, a_mainHandFormId: Number, a_iconFormId: Number /*, formId[] */): Void
	{
		var startIndex = a_groupIndex * GroupDataExtender.GROUP_SIZE;
		
		_groupDataExtender.mainHandData[a_groupIndex] = a_mainHandFormId;
		_groupDataExtender.iconData[a_groupIndex] = a_iconFormId;
		
		for (var i=3, j=startIndex ; i<arguments.length; i++, j++)
			_groupDataExtender.groupData[j] = arguments[i];
		
		if (_isInitialized)
			itemList.InvalidateData();
		
		// Received group data as result of group assignment?
		if (_state == GROUP_ASSIGN_SYNC)
			endGroupAssignment();
		else if (_state == GROUP_REMOVE_SYNC)
			endGroupRemoval();
		else if (_state == SET_ICON_SYNC)
			endSetGroupIcon();
		else if (_state == SET_MAIN_HAND_SYNC)
			endSetMainHand();
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function InitExtensions(): Void
	{
		skse.ExtendData(true);
		
		btnAll.group = _categoryButtonGroup;
		btnGear.group = _categoryButtonGroup;
		btnAid.group = _categoryButtonGroup;
		btnMagic.group = _categoryButtonGroup;
		
		var groupButtons: Array = [];
		for (var i=1; i<=8; i++) {
			var btn = groupButtonFader.groupButtonHolder["btnGroup" + i];
			btn.text
			groupButtons.push(btn);
			btn.group = _groupButtonGroup
		}
		
		_categoryButtonGroup.addEventListener("change", this, "onCategorySelect");
		_groupButtonGroup.addEventListener("change", this, "onGroupSelect");
		
		itemList.addDataProcessor(new FilterDataExtender());
		itemList.addDataProcessor(new FavoritesIconSetter());
		
		_groupDataExtender = new GroupDataExtender(groupButtons); 
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
		
		_state = ITEM_SELECT;
		
		// Wait for initial group data
		_waitingForGroupData = true;
		
		navButton.visible = false;
		
		restoreIndices();
		
		setGroupFocus(false);
		
		// We avoid any invalidates before this point.
		// After it, the next invalidate should be triggered from game code after filling list data.
		// That is when we can restore selectedIndex and scroll position
		_isInitialized = true;
		
		updateNavButtons();
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
		SetPlatform(0);

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
				
			} else if (details.skseKeycode == _groupAddKey || details.code == 70) {
				
				if (_state == ITEM_SELECT) {
					if (!_groupButtonFocus)
						startGroupAssignment();
					else
						startGroupRemoval();
				} else if (_state == GROUP_ASSIGN) {
					endGroupAssignment();
				}
				
				return true;

			} else if (_state == GROUP_ASSIGN && details.navEquivalent == NavigationCode.ENTER) {
				if (_groupAssignIndex != -1)
					applyGroupAssignment();
				return true;
				
			} else if (details.skseKeycode == _groupUseKey || details.code == 82) {
				if (_state == ITEM_SELECT)
					requestGroupUse();
				return true;
				
			} else if (details.skseKeycode == _setIconKey || details.code == 18) {
				if (_state == ITEM_SELECT)
					startSetGroupIcon();
					
			} else if (details.skseKeycode == _setMainHandKey || details.code == 18) {
				if (_state == ITEM_SELECT)
					startSetMainHand();
				
			} else if (details.skseKeycode == _toggleFocusKey || details.code == 32) {
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
		// We use skse.Store/LoadIndices to restore the selected item on our terms
		return;
		/*
		for (var i = 0; i < itemList.entryList.length; i++) {
			if (itemList.entryList[i].index == a_index) {
				itemList.selectedIndex = i;
				//itemList.RestoreScrollPosition(i);
				itemList.UpdateList();
				return;
			}
		}*/
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		var isGamepad = _platform != 0;
		
		_leftKeycode = GlobalFunctions.getMappedKey("Left", Input.CONTEXT_MENUMODE, isGamepad);
		_rightKeycode = GlobalFunctions.getMappedKey("Right", Input.CONTEXT_MENUMODE, isGamepad);
		_groupAddKey = GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, isGamepad);
		_groupUseKey = GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, isGamepad);
		
		_setIconKey = GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, isGamepad);
		_setMainHandKey = GlobalFunctions.getMappedKey("Wait", Input.CONTEXT_GAMEPLAY, isGamepad);
		
		_toggleFocusKey = GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, isGamepad);
		
		navButton.setPlatform(a_platform);
		
		navPanel.row1.setPlatform(a_platform,a_bPS3Switch);
		navPanel.row2.setPlatform(a_platform,a_bPS3Switch);
		
		updateNavButtons();
	}
	

  /* PRIVATE FUNCTIONS */
  
	private function onFilterChange(a_event: Object): Void
	{
		if (_isInitialized)
			itemList.InvalidateData();
			
		updateNavButtons();
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
		updateNavButtons();
	}
	
	private function onCategorySelect(a_event: Object): Void
	{
		var btn = a_event.item;
		if (btn == null)
			return;
			
		_categoryIndex = _categoryButtonGroup.indexOf(btn);
			
		_groupButtonFocus = false;
		_groupButtonGroup.setSelectedButton(null);
		itemList.listState.activeGroupIndex = -1;
		
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
		itemList.listState.activeGroupIndex = index;
		
		_typeFilter.changeFilterFlag(btn.filterFlag);
		
		if (_state == GROUP_ASSIGN) {
			if (_groupAssignIndex == index) {
				applyGroupAssignment();
			} else {
				navButton.setButtonData({text: "$Confirm Group", controls: Input.Accept});
				_groupAssignIndex = index;				
			}
		} else {
			_groupIndex = index;
		}
	}

	private function startFadeOut(): Void
	{
		_state = CLOSING;
		updateNavButtons();
		_parent.gotoAndPlay("startFadeOut");
	}
	
	private function onFadeOutCompletion(): Void
	{
		saveIndices();
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
		navButton.setButtonData({text: "$Select Group", controls: Input.LeftRight});
		
		btnAll.disabled = true;
		btnGear.disabled = true;
		btnAid.disabled = true;
		btnMagic.disabled = true;
		
		btnAll.visible = false;
		btnGear.visible = false;
		btnAid.visible = false;
		btnMagic.visible = false;
		
		updateNavButtons();
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
		
		itemList.onInvalidate = function()
		{
			this.scrollPosition = this.listState.restoredScrollPosition;
			this.selectedIndex = this.listState.restoredSelectedIndex;
			delete this.onInvalidate;
		};

		itemList.disableSelection = false;
		itemList.requestInvalidate();
		itemList.suspended = false;
		
		_state = ITEM_SELECT;
			
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
	
	private function startGroupRemoval(): Void
	{
		var formId: Number = itemList.selectedEntry.formId;
		if (_groupButtonFocus && _groupIndex >= 0 && formId) {
			_state = GROUP_REMOVE_SYNC;
			skse.SendModEvent("SKIFM_groupRemoved", "", _groupIndex, formId);
		}
	}
	
	private function endGroupRemoval(): Void
	{
		_state = ITEM_SELECT;
	}
	
	private function requestGroupUse(): Void
	{
		if (_groupButtonFocus && _groupIndex >= 0) {
			skse.SendModEvent("SKIFM_groupUsed", "", _groupIndex);
			startFadeOut();
		}
	}
	
	private function startSetMainHand(): Void
	{
		var selectedEntry = itemList.selectedEntry;
		if (_groupButtonFocus && _groupIndex >= 0 && selectedEntry.formId) {
			var equipSlot = selectedEntry.equipSlot;
			if (allowAsMainHand(selectedEntry)) {
				_state = SET_MAIN_HAND_SYNC;
				skse.SendModEvent("SKIFM_setMainHand", "", _groupIndex, selectedEntry.formId);
			}
		}
	}
	
	private function endSetMainHand(): Void
	{
		_state = ITEM_SELECT;
	}
	
	private function startSetGroupIcon(): Void
	{
		var formId: Number = itemList.selectedEntry.formId;
		if (_groupButtonFocus && _groupIndex >= 0 && formId) {
			_state = SET_ICON_SYNC;
			skse.SendModEvent("SKIFM_setGroupIcon", "", _groupIndex, formId);
		}
	}
	
	private function endSetGroupIcon(): Void
	{
		_state = ITEM_SELECT;
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
				_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(_groupIndex));
			}
		} else {
			_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
		}
	}
	
	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry(): Boolean
	{
		// only allow item selection while in item select state
		if (_state != ITEM_SELECT)
			return false;
		
		// only confirm when using mouse
		if (_platform != 0 || !_useMouseNavigation)
			return true;
		
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e.itemIndex == itemList.selectedIndex)
				return true;
				
		return false;
	}
	
	private function saveIndices(): Void
	{
		var indicesIn: Array = [_categoryIndex, _groupIndex, itemList.selectedIndex, itemList.scrollPosition];
		skse.StoreIndices("SKI_FavoritesMenuState", indicesIn);
	}
	
	private function restoreIndices(): Void
	{
		var indicesOut: Array = [];
		skse.LoadIndices("SKI_FavoritesMenuState", indicesOut);
		
		if (indicesOut.length != 4)
			return;
		
		_categoryIndex = indicesOut[0];
		_groupIndex = indicesOut[1];

		itemList.listState.restoredSelectedIndex = indicesOut[2];
		itemList.listState.restoredScrollPosition = indicesOut[3];
		
		itemList.onInvalidate = function()
		{
			this.scrollPosition = this.listState.restoredScrollPosition;
			this.selectedIndex = this.listState.restoredSelectedIndex;
			delete this.onInvalidate;
		};
	}
	
	private function updateNavButtons(): Void
	{
		if (_state != ITEM_SELECT || !_navPanelEnabled) {
			navPanel._visible = false;
			return;
		}
		
		navPanel._visible = true;
		
		var row1: ButtonPanel = navPanel.row1;
		var row2: ButtonPanel = navPanel.row2;
		var twoRows = false;
		
		row1.clearButtons();
		row1.addButton({text: "$Toggle Focus", controls: Input.Jump});
		if (_groupButtonFocus) {
			row1.addButton({text: "$Ungroup", controls: Input.TogglePOV});
		} else {
			row1.addButton({text: "$Group", controls: Input.TogglePOV});
		}
		row1.updateButtons(true);
		
		row2.clearButtons();
		if (_groupButtonFocus) {
			var selectedEntry = itemList.selectedEntry;
			twoRows = true;
			row2.addButton({text: "$Group Use", controls: Input.ReadyWeapon});
			if (selectedEntry != null) {
				row2.addButton({text: "$Set Group Icon", controls: Input.Sprint});
				if (allowAsMainHand(selectedEntry))
					row2.addButton({text: "$Set Main Hand", controls: Input.Wait});
			}
		}
		row2.updateButtons(true);
		
		row1._x = -(row1._width / 2);
		row1._y = twoRows ? 10 : 35;
		row2._x = -(row2._width / 2);
		row2._y = 65;
	}
	
	private static function allowAsMainHand(a_entry: Object): Boolean
	{
		var equipSlot = a_entry.equipSlot;
		if (equipSlot)
			return (equipSlot == Form.EQUIP_RIGHT_HAND || equipSlot == Form.EQUIP_BOTH_HANDS || equipSlot == Form.EQUIP_EITHER_HAND);
		else
			return false;
	}
}
