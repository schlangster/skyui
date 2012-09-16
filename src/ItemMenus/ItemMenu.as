import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.util.ConfigManager;


class ItemMenu extends MovieClip
{
  /* CONSTANTS */
  
	private var SKSE_REQ_RELEASE_IDX = 9;


  /* PRIVATE VARIABLES */
  
	private var _platform: Number;
	private var _bItemCardFadedIn: Boolean = false;
	private var _bItemCardPositioned: Boolean = false;
	
	private var _config: Object;
	
	private var _tabToggleKey: Number;
	
	private var _bPlayBladeSound: Boolean;
	
	
  /* STAGE ELEMENTS */
	
	public var inventoryLists: InventoryLists;
	
	public var itemCardFadeHolder: MovieClip;

	public var bottomBar: MovieClip;
	
	public var mouseRotationRect: MovieClip;
	public var exitMenuRect: MovieClip;
	public var skseWarning: MovieClip;
	
	
  /* PROPERTIES */
	
	public var itemCard: MovieClip;
	
	// @override ItemMenu
	public var bEnableTabs: Boolean = false;
	
	// @Mysterious GFx
	public var bPCControlsReady: Boolean = true;
	
	public var bFadedIn: Boolean = true;
	
	
  /* INITIALIZATION */

	public function ItemMenu()
	{
		super();
		
		itemCard = itemCardFadeHolder.ItemCard_mc;
		
		Mouse.addListener(this);
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		
		bFadedIn = true;
		_bItemCardFadedIn = false;
	}
	
	// @API
	public function InitExtensions(a_bPlayBladeSound): Void
	{
		skse.ExtendData(true);
		skse.ForceContainerCategorization(true);
		
		var test: Number = 10101.10000000149012;
		skse.Log("#1 Number: " + test);
		var rounded: Number = Math.round(test);
		skse.Log("#1 Rounded: " + rounded);
		var div: Number = rounded / 10;
		skse.Log("#1 Div: " + div);
		
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
		bottomBar.HideButtons();
		
		exitMenuRect.onMouseDown = function()
		{
			if (_parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
				_parent.onExitMenuRectClick();
		};
		
		if (skseWarning != undefined) {
			
			// Default message
			if (_global.skse == undefined) {
				skseWarning._visible = true;
				skseWarning.message.text = "SkyUI could not detect the Skyrim Script Extender (SKSE).\n"
					+ "SkyUI will not work correctly!\n"
					+ "\n"
					+ "This message may also appear if a new Skyrim Patch has been released.\n"
					+ "In this case, wait until SKSE has been updated, then install the new version.\n"
					+ "\n"
					+ "For more information, see the mod description.";
					
			} else if (_global.skse.version.releaseIdx < SKSE_REQ_RELEASE_IDX) {
				skseWarning._visible = true;
				skseWarning.message.text = "Your Skyrim Script Extender (SKSE) is outdated.\n"
					+ "SkyUI will not work correctly!\n"
					+ "\n"
					+ "Installed version: " + _global.skse.version.major + "." + _global.skse.version.minor + "." + _global.skse.version.beta + "\n"
					+ "Required version: 1.4.8\n"
					+ "\n"
					+ "For more information, see the mod description.";
					
			} else {
				skseWarning._visible = false;
			}
		}
	}


  /* PUBLIC FUNCTIONS */
	
	var tmpID: Number;
	
	public function onConfigLoad(event: Object): Void
	{
		var test: Number = 10101.10000000149012;
		skse.Log("#2 Number: " + test);
		var rounded: Number = Math.round(test);
		skse.Log("#2 Rounded: " + rounded);
		var div: Number = rounded / 10;
		skse.Log("#2 Div: " + div);
		
		setConfig(event.config);
		inventoryLists.showPanel(_bPlayBladeSound);
		
		tmpID = setInterval(this, "testFunc", 1);
	}
	
	public function testFunc(): Void
	{
		clearInterval(tmpID);
		delete(tmpID);
	}
	
	public function setConfig(a_config: Object): Void
	{
		_config = a_config;
		_tabToggleKey = a_config.Input.hotkey.tabToggle;
		
		positionFloatingElements();
		
		var itemListState = inventoryLists.itemList.listState;
		var categoryListState = inventoryLists.categoryList.listState;
		var section = a_config["Appearance"];
		
		categoryListState.iconSource = section.icons.source;
		
		itemListState.iconSource = section.icons.source;
		itemListState.showStolenIcon = section.icons.showStolen;
		itemListState.defaultEnabledColor = section.colors.enabled.text;
		itemListState.negativeEnabledColor = section.colors.enabled.negative;
		itemListState.stolenEnabledColor = section.colors.enabled.stolen;
		itemListState.defaultDisabledColor = section.colors.disabled.text;
		itemListState.negativeDisabledColor = section.colors.disabled.negative;
		itemListState.stolenDisabledColor = section.colors.disabled.stolen;
		
		skyui.util.Debug.log("Init'ed list state");
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		inventoryLists.setPlatform(a_platform,a_bPS3Switch);
		itemCard.SetPlatform(a_platform,a_bPS3Switch);
		bottomBar.SetPlatform(a_platform,a_bPS3Switch);
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
			
		if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB)
			GameDelegate.call("CloseMenu",[]);

		return true;
	}

	public function onMouseWheel(delta: Number): Void
	{
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent) {
			if (e == mouseRotationRect && shouldProcessItemsListInput(false) || !bFadedIn && delta == -1) {
				GameDelegate.call("ZoomItemModel",[delta]);
				break;
			}
		}
	}

	public function onExitMenuRectClick(): Void
	{
		GameDelegate.call("CloseMenu",[]);
	}

	public function onCategoryChange(event: Object): Void
	{
	}
	
	public function onItemHighlightChange(event: Object): Void
	{
		super.onItemHighlightChange(event);
		
		if (event.index != -1) {
			if (!_bItemCardFadedIn) {
				_bItemCardFadedIn = true;
				
				if (_bItemCardPositioned)
					itemCard.FadeInCard();
				bottomBar.ShowButtons();
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

	public function onShowItemsList(event: Object): Void
	{
		onItemHighlightChange(event);
	}

	public function onHideItemsList(event: Object): Void
	{
		GameDelegate.call("UpdateItem3D",[false]);
		itemCard.FadeOutCard();
		bottomBar.HideButtons();
	}

	public function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled) {
			if (event.entry.count > InventoryDefines.QUANTITY_MENU_COUNT_LIMIT)
				itemCard.ShowQuantityMenu(event.entry.count);
			else
				onQuantityMenuSelect({amount:1});
		} else {
			GameDelegate.call("DisabledItemSelect",[]);
		}
	}

	public function onQuantityMenuSelect(event: Object): Void
	{
		GameDelegate.call("ItemSelect",[event.amount]);
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
		bottomBar.UpdatePerItemInfo(aUpdateObj);
	}

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

	public function onMouseRotationStart(): Void
	{
		GameDelegate.call("StartMouseRotation",[]);
		inventoryLists.categoryList.disableSelection = true;
		inventoryLists.itemList.disableSelection = true;
	}

	public function onMouseRotationStop(): Void
	{
		GameDelegate.call("StopMouseRotation",[]);
		inventoryLists.categoryList.disableSelection = false;
		inventoryLists.itemList.disableSelection = false;
	}

	public function onMouseRotationFastClick(): Void
	{
		if (shouldProcessItemsListInput(false))
			onItemSelect({entry:inventoryLists.itemList.selectedEntry, keyboardOrMouse:0});
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
		if (arguments[0] != undefined && arguments[0] != -1 && arguments.length == 3) {
			inventoryLists.categoryList.restoreCategory(arguments[0]);
			inventoryLists.itemList.scrollPosition = arguments[2];
			inventoryLists.itemList.selectedIndex = arguments[1];
		} else {
			inventoryLists.categoryList.restoreCategory(1); // ALL
		}
		
		inventoryLists.categoryList.UpdateList();
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function saveIndices(): Void
	{
		var a = new Array();
		
		// Save selected category, selected item and relative scroll position
		a.push(inventoryLists.categoryList.selectedIndex);
		a.push(inventoryLists.itemList.selectedIndex);
		a.push(inventoryLists.itemList.scrollPosition);
		
		GameDelegate.call("SaveIndices", [a]);
	}
	
	private function positionFixedElements(): Void
	{
		GlobalFunc.SetLockFunction();
		
		inventoryLists.Lock("L");
		inventoryLists._x = inventoryLists._x - 20;
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		bottomBar.PositionElements(leftEdge, rightEdge);
		
		MovieClip(exitMenuRect).Lock("TL");
		exitMenuRect._x = exitMenuRect._x - Stage.safeRect.x;
		exitMenuRect._y = exitMenuRect._y - Stage.safeRect.y;
		
		if (skseWarning != undefined)
			skseWarning.Lock("TR");
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
}