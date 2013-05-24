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
  
  	private static var GROUP_SIZE = 32;
	
  	private static var ITEM_SELECT = 0;
	private static var GROUP_ASSIGN = 1;
	private static var GROUP_CONFIG = 2;
	private static var WAIT_FOR_GROUP_DATA = 3;
	private static var WAIT_FOR_GROUP_USE = 4;
	private static var CLOSING = 5;
	
	
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	
	private var _typeFilter: ItemTypeFilter;
	private var _sortFilter: SortFilter;
	
	private var _entryLookup: EntryLookupHelper;
	
	private var _categoryButtonGroup: ButtonGroup;
	private var _groupButtonGroup: ButtonGroup;
	
	private var _leftKeycode: Number;
	private var _rightKeycode: Number;
	private var _favKeycode: Number;
	private var _readyKeycode: Number;
	private var _sprintKeycode: Number;
	private var _jumpKeycode: Number;
	
	private var _state: Number;
	
	private var _groupDataBuffer: Array;
	
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

		dbgIntvl = setInterval(this, "TestMenu", 1000);
		
		_typeFilter = new ItemTypeFilter();
		_sortFilter = new SortFilter();
		
		_categoryButtonGroup = new ButtonGroup("CategoryButtonGroup");
		_groupButtonGroup = new ButtonGroup("GroupButtonGroup");
		
		Mouse.addListener(this);
		
		_state = ITEM_SELECT;
		_groupDataBuffer = [];
	}
	
	
  /* PAPYRUS INTERFACE */
  
  	public function unlock(): Void
	{
		_state = ITEM_SELECT;
	}
	
	public function pushGroupData(/* formIds */): Void
	{
		for (var i=0; i<arguments.length; i++)
			_groupDataBuffer.push(arguments[i]);
	}
	
	public function commitGroupData(): Void
	{
		var c = 0;
		var filterFlag = FilterDataExtender.FILTERFLAG_GROUP_0;
		
		for (var i=0; i<_groupDataBuffer.length; i++, c++) {
			if (c == GROUP_SIZE) {
				filterFlag = filterFlag << 1;
				c = 0;
			}
			
			var formId = _groupDataBuffer[i];
			if (formId != null && formId > 0) {
				var e = _entryLookup.FormIdMap[formId];
				if (e != null)
					e.filterFlag |= filterFlag;
			}
		}
		

		_groupDataBuffer.splice(0);
		
		itemList.requestInvalidate();
		
		_waitingForGroupData = false;
		enableGroupButtons(true);
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
		
		_entryLookup = new EntryLookupHelper(); 
		itemList.addDataProcessor(_entryLookup);

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
		
		_categoryButtonGroup.setSelectedButton(btnAll);
		
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
			itemList.entryList.push({text: "test " + i, equipState: 0, filterFlag: 1, disabled: false});
		}
		itemList.InvalidateData();
		
		commitGroupData();
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
					endGroupAssignMode(true);
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
				
				} else if (_groupButtonFocus) {
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
					
				} else if (_groupButtonFocus) {
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

				return true;
				
			} else if (details.skseKeycode == _favKeycode || details.code == 70) {
				
				if (_state == ITEM_SELECT)
					startGroupAssignMode();
				else if (_state == GROUP_ASSIGN)
					endGroupAssignMode(true);
				
				return true;

			} else if (_state == GROUP_ASSIGN && details.navEquivalent == NavigationCode.ENTER) {
				if (_groupAssignIndex != -1)
					endGroupAssignMode();
				return true;
				
			} else if (details.skseKeycode == _readyKeycode || details.code == 82) {
				if (_state == ITEM_SELECT)
					requestGroupUse();
				return true;
				
			} else if (details.skseKeycode == _sprintKeycode || details.code == 18) {
				return true;
				
			} else if (details.skseKeycode == _jumpKeycode || details.code == 32) {
				if (_state == ITEM_SELECT)
					toggleGroupFocus();
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
				endGroupAssignMode();
			} else {
				navButton.setButtonData({text: (Translator.translate("$ADD TO") + " " + btn.text), controls: Input.Accept});
				_groupAssignIndex = index;				
			}
		} else {
			_groupIndex = index;
		}
	}
	
	private function toggleGroupFocus(): Void
	{
		_groupButtonFocus = !_groupButtonFocus;
		
		if (_groupButtonFocus)
			_groupButtonGroup.setSelectedButton(_groupButtonGroup.getButtonAt(_groupIndex));
		else
			_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
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
	
	private function startGroupAssignMode(): Void
	{
		var selectedEntry = itemList.selectedEntry;
		if (selectedEntry == null)
			return;
			
		_state = GROUP_ASSIGN;
		
		_groupAssignIndex = -1;
		
		var assignedEntry =  itemList.selectedEntry;
		itemList.listState.assignedEntry = assignedEntry;
		
		assignedEntry.filterFlag |= FilterDataExtender.FILTERFLAG_GROUP_ADD;
		
		itemList.listState.restoredSelectedIndex = itemList.selectedIndex;
		itemList.listState.restoredScrollPosition = itemList.scrollPosition;
		
		itemList.selectedIndex = -1;
		itemList.disableSelection = true;		
		itemList.requestUpdate();
		
		btnAll.disabled = true;
		btnGear.disabled = true;
		btnAid.disabled = true;
		btnMagic.disabled = true;
		
		btnAll.visible = false;
		btnGear.visible = false;
		btnAid.visible = false;
		btnMagic.visible = false;
		
		headerText._visible = false;
		
		navButton.visible = true;
		navButton.setButtonData({text: "$SELECT GROUP", controls: Input.LeftRight});
	}
	
	private function endGroupAssignMode(a_cancel: Boolean): Void
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
		
		var formId: Number = itemList.selectedEntry.formId;
		
		if (a_cancel || formId == null || _groupAssignIndex == -1) {
			_state = ITEM_SELECT;
		} else {
			_waitingForGroupData = true;
			skse.SendModEvent("SKIFM_groupAdded", "", _groupAssignIndex, formId);
		}
			
		_groupAssignIndex = -1;
		
		_categoryButtonGroup.setSelectedButton(_categoryButtonGroup.getButtonAt(_categoryIndex));
	}
	
	private function requestGroupUse(): Void
	{
		if (_groupButtonFocus && _groupIndex >= 0) {
			skse.SendModEvent("SKIFM_groupUsed", "", _groupIndex);
			startFadeOut();
		}
	}
	
	public function enableGroupButtons(a_enabled: Boolean): Void
	{
		if (!_groupButtonsShown) {
			_groupButtonsShown = true;
			groupButtonFader.gotoAndPlay("show");
		}
		var t = !a_enabled;
		for (var i=1; i<=8; i++)
			groupButtonFader.groupButtonHolder["btnGroup" + i].disabled = t;
	}
	
	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry(): Boolean
	{
		// only confirm when using mouse
		if (_platform != 0 || !_useMouseNavigation)
			return true;
		
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e.itemIndex == itemList.selectedIndex)
				return true;
				
		return false;
	}
}
