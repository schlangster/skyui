import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.defines.Input;
import skyui.util.GlobalFunctions;
import skyui.util.ConfigManager;
import skyui.components.ButtonPanel;

import skyui.defines.Inventory;
import skyui.defines.Item;


class ItemMenu extends MovieClip
{
  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	private var _bItemCardFadedIn: Boolean = false;
	private var _bItemCardPositioned: Boolean = false;
	
	private var _quantityMinCount: Number = 5;
	
	private var _config: Object;
	
	private var _bPlayBladeSound: Boolean;
	
	private var _searchKey: Number;
	private var _switchTabKey: Number;
	
	private var _acceptControls: Object;
	private var _cancelControls: Object;
	private var _searchControls: Object;
	private var _switchControls: Object;
	private var _sortColumnControls: Array;
	private var _sortOrderControls: Object;
	
	
  /* STAGE ELEMENTS */
	
	public var inventoryLists: InventoryLists;
	
	public var itemCardFadeHolder: MovieClip;

	public var bottomBar: BottomBar;
	
	public var mouseRotationRect: MovieClip;
	public var exitMenuRect: MovieClip;
	
	
  /* PROPERTIES */
	
	public var itemCard: MovieClip;
	
	public var navPanel: ButtonPanel;
	
	public var bEnableTabs: Boolean = false;
	
	// @GFx
	public var bPCControlsReady: Boolean = true;
	
	public var bFadedIn: Boolean = true;
	
	
  /* INITIALIZATION */

	public function ItemMenu()
	{
		super();
		
		itemCard = itemCardFadeHolder.ItemCard_mc;
		navPanel = bottomBar.buttonPanel;
		
		Mouse.addListener(this);
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		
		bFadedIn = true;
		_bItemCardFadedIn = false;
	}

  /* PUBLIC FUNCTIONS */
  
	// @API
	public function InitExtensions(a_bPlayBladeSound): Void
	{
		skse.ExtendData(true);
		skse.ForceContainerCategorization(true);
		
		_bPlayBladeSound = a_bPlayBladeSound
		
		inventoryLists.InitExtensions();
		
		if (bEnableTabs)
			inventoryLists.enableTabBar();
		
		GameDelegate.addCallBack("UpdatePlayerInfo",this,"UpdatePlayerInfo");
		GameDelegate.addCallBack("UpdateItemCardInfo",this,"UpdateItemCardInfo");
		GameDelegate.addCallBack("ToggleMenuFade",this,"ToggleMenuFade");
		GameDelegate.addCallBack("RestoreIndices",this,"RestoreIndices");
		
		inventoryLists.addEventListener("categoryChange",this,"onCategoryChange");
		inventoryLists.addEventListener("itemHighlightChange",this,"onItemHighlightChange");
		inventoryLists.addEventListener("showItemsList",this,"onShowItemsList");
		inventoryLists.addEventListener("hideItemsList",this,"onHideItemsList");
		
		inventoryLists.itemList.addEventListener("itemPress", this ,"onItemSelect");
		
		itemCard.addEventListener("quantitySelect",this,"onQuantityMenuSelect");
		itemCard.addEventListener("subMenuAction",this,"onItemCardSubMenuAction");
		
		positionFixedElements();
		
		itemCard._visible = false;
		navPanel.hideButtons();
		
		exitMenuRect.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
				_parent.onExitMenuRectClick();
		};
	}
	
	public function setConfig(a_config: Object): Void
	{
		_config = a_config;
		
		positionFloatingElements();
		
		var itemListState = inventoryLists.itemList.listState;
		var categoryListState = inventoryLists.categoryList.listState;
		var appearance = a_config["Appearance"];
		
		categoryListState.iconSource = appearance.icons.category.source;
		
		itemListState.iconSource = appearance.icons.item.source;
		itemListState.showStolenIcon = appearance.icons.item.showStolen;
		
		itemListState.defaultEnabledColor = appearance.colors.text.enabled;
		itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
		itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
		itemListState.defaultDisabledColor = appearance.colors.text.disabled;
		itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
		itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;

		_quantityMinCount = a_config["ItemList"].quantityMenu.minCount;
		
		if (_platform == 0) {
			_switchTabKey = a_config["Input"].controls.pc.switchTab;
		} else {
			_switchTabKey = a_config["Input"].controls.gamepad.switchTab;
			
			var previousColumnKey = a_config["Input"].controls.gamepad.prevColumn;
			var nextColumnKey = a_config["Input"].controls.gamepad.nextColumn;
			var sortOrderKey = a_config["Input"].controls.gamepad.sortOrder;
			_sortColumnControls = [{keyCode: previousColumnKey},
								   {keyCode: nextColumnKey}];
			_sortOrderControls = {keyCode: sortOrderKey};
		}
		
		_switchControls = {keyCode: _switchTabKey};
		
		_searchKey = a_config["Input"].controls.pc.search;
		_searchControls = {keyCode: _searchKey};
		
		updateBottomBar(false);
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		if (a_platform == 0) {
			_acceptControls = Input.Enter;
			_cancelControls = Input.Tab;
			
			// Defaults
			_switchControls = Input.Alt;
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;
			
			// Defaults
			_switchControls = Input.GamepadBack;
			_sortColumnControls = Input.SortColumn;
			_sortOrderControls = Input.SortOrder;
		}
		
		// Defaults
		_searchControls = Input.Space;
		
		inventoryLists.setPlatform(a_platform,a_bPS3Switch);
		itemCard.SetPlatform(a_platform,a_bPS3Switch);
		bottomBar.setPlatform(a_platform,a_bPS3Switch);
	}

	// @API
	public function GetInventoryItemList(): MovieClip
	{
		return inventoryLists.itemList;
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (!bFadedIn)
			return true;
			
		var nextClip = pathToFocus.shift();
			
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.SHIFT_TAB))
			GameDelegate.call("CloseMenu",[]);

		return true;
	}

	// @API
	public function UpdatePlayerInfo(aUpdateObj: Object): Void
	{
		bottomBar.UpdatePlayerInfo(aUpdateObj,itemCard.itemInfo);
	}

	// @API
	public function UpdateItemCardInfo(aUpdateObj: Object): Void
	{
		itemCard.itemInfo = aUpdateObj;
		bottomBar.updatePerItemInfo(aUpdateObj);
	}

	// @API
	public function ToggleMenuFade(): Void
	{
		if (bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
			inventoryLists.itemList.disableSelection = true;
			inventoryLists.itemList.disableInput = true;
			inventoryLists.categoryList.disableSelection = true;
			inventoryLists.categoryList.disableInput = true;
		} else {
			_parent.gotoAndPlay("fadeIn");
		}
	}

	// @API
	public function SetFadedIn(): Void
	{
		bFadedIn = true;
		inventoryLists.itemList.disableSelection = false;
		inventoryLists.itemList.disableInput = false;
		inventoryLists.categoryList.disableSelection = false;
		inventoryLists.categoryList.disableInput = false;
	}
	
	// @API
	public function RestoreIndices(): Void
	{
		var categoryList = inventoryLists.categoryList;
		var itemList = inventoryLists.itemList;
		
		if (arguments[0] != undefined && arguments[0] != -1 && arguments.length == 5) {
			categoryList.listState.restoredItem = arguments[0];
			categoryList.onUnsuspend = function()
			{
				this.onItemPress(this.listState.restoredItem, 0);
				delete this.onUnsuspend;
			};
			
			itemList.listState.restoredScrollPosition = arguments[2];
			itemList.listState.restoredSelectedIndex = arguments[1];
			itemList.listState.restoredActiveColumnIndex = arguments[3];
			itemList.listState.restoredActiveColumnState = arguments[4];

			itemList.onUnsuspend = function()
			{
				this.onInvalidate = function()
				{
					this.scrollPosition = this.listState.restoredScrollPosition;
					this.selectedIndex = this.listState.restoredSelectedIndex;
					delete this.onInvalidate;
				};
				
				this.layout.restoreColumnState(this.listState.restoredActiveColumnIndex, this.listState.restoredActiveColumnState);
				delete this.onUnsuspend;
			};
		} else {
			
			categoryList.onUnsuspend = function()
			{
				this.onItemPress(1, 0); // ALL
				delete this.onUnsuspend;
			};
		}
	}
	
	
  /* PRIVATE FUNCTIONS */

	public function onItemCardSubMenuAction(event: Object): Void
	{
		if (event.opening == true) {
			inventoryLists.itemList.disableSelection = true;
			inventoryLists.itemList.disableInput = true;
			inventoryLists.categoryList.disableSelection = true;
			inventoryLists.categoryList.disableInput = true;
		} else if (event.opening == false) {
			inventoryLists.itemList.disableSelection = false;
			inventoryLists.itemList.disableInput = false;
			inventoryLists.categoryList.disableSelection = false;
			inventoryLists.categoryList.disableInput = false;
		}
	}
	
	private function onConfigLoad(event: Object): Void
	{
		setConfig(event.config);

		inventoryLists.showPanel(_bPlayBladeSound);
	}

	private function onMouseWheel(delta: Number): Void
	{
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent) {
			if (e == mouseRotationRect && shouldProcessItemsListInput(false) || !bFadedIn && delta == -1) {
				GameDelegate.call("ZoomItemModel",[delta]);
				break;
			}
		}
	}

	private function onExitMenuRectClick(): Void
	{
		GameDelegate.call("CloseMenu",[]);
	}

	private function onCategoryChange(event: Object): Void
	{
	}
	
	private function onItemHighlightChange(event: Object): Void
	{		
		if (event.index != -1) {
			if (!_bItemCardFadedIn) {
				_bItemCardFadedIn = true;
				
				if (_bItemCardPositioned)
					itemCard.FadeInCard();
			}
			
			if (_bItemCardPositioned)
				GameDelegate.call("UpdateItem3D",[true]);
				
			GameDelegate.call("RequestItemCardInfo",[], this, "UpdateItemCardInfo");
			
		} else {
			if (!bFadedIn)
				resetMenu();
			
			if (_bItemCardFadedIn) {
				_bItemCardFadedIn = false;
				onHideItemsList();
			}
		}
	}

	private function onShowItemsList(event: Object): Void
	{
		onItemHighlightChange(event);
	}

	private function onHideItemsList(event: Object): Void
	{
		GameDelegate.call("UpdateItem3D",[false]);
		itemCard.FadeOutCard();
	}

	private function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled) {
			if (_quantityMinCount < 1 || (event.entry.count < _quantityMinCount))
				onQuantityMenuSelect({amount:1});
			else
				itemCard.ShowQuantityMenu(event.entry.count);
		} else {
			GameDelegate.call("DisabledItemSelect",[]);
		}


	}

	private function onQuantityMenuSelect(event: Object): Void
	{
		GameDelegate.call("ItemSelect",[event.amount]);
	}

	private function onMouseRotationStart(): Void
	{
		GameDelegate.call("StartMouseRotation",[]);
		inventoryLists.categoryList.disableSelection = true;
		inventoryLists.itemList.disableSelection = true;
	}

	private function onMouseRotationStop(): Void
	{
		GameDelegate.call("StopMouseRotation",[]);
		inventoryLists.categoryList.disableSelection = false;
		inventoryLists.itemList.disableSelection = false;
	}

	private function onMouseRotationFastClick(): Void
	{
		if (shouldProcessItemsListInput(false))
			onItemSelect({entry:inventoryLists.itemList.selectedEntry, keyboardOrMouse:0});
	}

	private function saveIndices(): Void
	{
		var a = new Array();
		
		// Save selected category, selected item and relative scroll position
		a.push(inventoryLists.categoryList.selectedIndex);
		a.push(inventoryLists.itemList.selectedIndex);
		a.push(inventoryLists.itemList.scrollPosition);
		a.push(inventoryLists.itemList.layout.activeColumnIndex);
		a.push(inventoryLists.itemList.layout.activeColumnState);
		
		GameDelegate.call("SaveIndices", [a]);
	}
	
	private function positionFixedElements(): Void
	{
		GlobalFunc.SetLockFunction();
		
		inventoryLists.Lock("L");
		inventoryLists._x = inventoryLists._x - 20;
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		bottomBar.positionElements(leftEdge, rightEdge);
		
		MovieClip(exitMenuRect).Lock("TL");
		exitMenuRect._x = exitMenuRect._x - Stage.safeRect.x;
		exitMenuRect._y = exitMenuRect._y - Stage.safeRect.y;
	}
	
	private function positionFloatingElements(): Void
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		var a = inventoryLists.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = inventoryLists._x + a[0] + a[2] + 25;

		var itemCardContainer = itemCard._parent;
		var itemcardPosition = _config.ItemInfo.itemcard;
		var itemiconPosition = _config.ItemInfo.itemicon;
		
		var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;
		
		// Scale down if necessary
		if (scaleMult < 1.0) {
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemiconPosition.scale *= scaleMult;
		}
		
		if (itemcardPosition.align == "left")
			itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
		else if (itemcardPosition.align == "right")
			itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
		else
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;

		itemCardContainer._y = itemCardContainer._y + itemcardPosition.yOffset;

		if (mouseRotationRect != undefined) {
			MovieClip(mouseRotationRect).Lock("T");
			mouseRotationRect._x = itemCard._parent._x;
			mouseRotationRect._width = itemCardContainer._width;
			mouseRotationRect._height = 0.55 * Stage.visibleRect.height;
		}
			
		_bItemCardPositioned = true;
		
		// Delayed fade in if positioned wasn't set
		if (_bItemCardFadedIn) {
			GameDelegate.call("UpdateItem3D",[true]);
			itemCard.FadeInCard();
		}
	}
	
	private function shouldProcessItemsListInput(abCheckIfOverRect: Boolean): Boolean
	{
		var process = bFadedIn == true && inventoryLists.currentState == InventoryLists.SHOW_PANEL && inventoryLists.itemList.itemCount > 0 && !inventoryLists.itemList.disableSelection && !inventoryLists.itemList.disableInput;

		if (process && _platform == 0 && abCheckIfOverRect) {
			var e = Mouse.getTopMostEntity();
			var found = false;
			
			while (!found && e != undefined) {
				if (e == inventoryLists.itemList)
					found = true;
					
				e = e._parent;
			}
			
			process = process && found;
		}
		return process;
	}
	
	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry(): Boolean
	{
		// only confirm when using mouse
		if (_platform != 0)
			return true;
		
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e.itemIndex == inventoryLists.itemList.selectedIndex)
				return true;
				
		return false;
	}
	
	/*
		This method is only used for the InventoryMenu Favorites Category.
		It prevents a lockup when unfavoriting the last item from favorites list by
		resetting the menu.
	 */
	private function resetMenu(): Void
	{
		saveIndices();
		GameDelegate.call("CloseMenu",[]);
		skse.OpenMenu("Inventory Menu");
	}

	/*
		This method is only used in InventoryMenu and ContainerMenu.
		It it allows determination of read books.
		Item list isn't re-sent when you activate a book, unlike other items,
		 so the flags don't get updated.
		If the item is a book, we apply the book read flag and invalidate locally
	*/
	private function checkBook(a_entryObject: Object): Boolean
	{

		if (a_entryObject.type != Inventory.ICT_BOOK || _global.skse == null)
			return false;

		a_entryObject.flags |= Item.BOOKFLAG_READ;
		a_entryObject.skyui_itemDataProcessed = false;
		
		inventoryLists.itemList.requestInvalidate();

		return true;
	}
	
	private function getEquipButtonData(a_itemType: Number, a_bAlwaysEquip: Boolean): Object
	{
		var btnData = {};
		
		var useControls = Input.Activate;
		var equipControls = Input.Equip;
		
		switch (a_itemType) {
			case Inventory.ICT_ARMOR :
				btnData.text = "$Equip";
				btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
				break;
			case Inventory.ICT_BOOK :
				btnData.text = "$Read";
				btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
				break;
			case Inventory.ICT_FOOD :
			case Inventory.ICT_INGREDIENT :
				btnData.text = "$Eat";
				btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
				break;
			case Inventory.ICT_WEAPON :
				btnData.text = "$Equip";
				btnData.controls = equipControls;
				break;

			default :
				btnData.text = "$Use";
				btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
		}
		
		return btnData;
	}
	
	private function updateBottomBar(a_bSelected: Boolean): Void {}
}