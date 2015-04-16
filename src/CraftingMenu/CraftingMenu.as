import gfx.managers.FocusHandler;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.components.ButtonPanel;
import skyui.util.ConfigManager;
import skyui.util.Debug;
import skyui.util.GlobalFunctions;

import skyui.defines.Input;


class CraftingMenu extends MovieClip
{
	#include "../version.as"
	
  /* CONSTANTS */
	
	static var LIST_OFFSET: Number = 20;
	static var SELECT_BUTTON: Number = 0;
	static var EXIT_BUTTON: Number = 1;
	static var AUX_BUTTON: Number = 2;
	static var CRAFT_BUTTON: Number = 3;
	
	static var SUBTYPE_NAMES = [ "ConstructibleObject", "Smithing", "EnchantConstruct", "EnchantDestruct", "Alchemy" ];
	
	
  /* STAGE ELEMENTS */
  
	// @API
	public var BottomBarInfo: MovieClip;
  
	public var ItemInfoHolder: MovieClip;
	public var MenuDescriptionHolder: MovieClip;
	public var MenuNameHolder: MovieClip;

	// Not API, but keeping the original name for compatiblity with vanilla.
	public var InventoryLists: CraftingLists;
	
	public var MouseRotationRect: MovieClip;
	public var ExitMenuRect: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
	private var _bCanCraft: Boolean = false;
	private var _bCanFadeItemInfo: Boolean = true;
	private var _bItemCardAdditionalDescription: Boolean = false;
	private var _platform: Number = 0;
	
	private var _searchKey: Number;
	
	private var _acceptControls: Object;
	private var _cancelControls: Object;
	private var _searchControls: Object;
	private var _sortColumnControls: Array;
	private var _sortOrderControls: Object;
	
	private var _config: Object;
	private var _subtypeName: String;
	
	
  /* PROPERTIES */

	public var AdditionalDescriptionHolder: MovieClip;

	// @API
	public var AdditionalDescription: TextField;

	// @API
	public var ButtonText: Array;
	
	// @API
	public var CategoryList: CraftingLists;

	// @API
	public var ItemInfo: MovieClip;

	// @API
	public var ItemList: TabularList;

	// @API
	public var MenuDescription: TextField;
	
	// @API
	public var MenuName: TextField;

	// @API
	public function get bCanCraft(): Boolean
	{
		return _bCanCraft;
	}

	// @API
	public function set bCanCraft(abCanCraft: Boolean): Void
	{
		_bCanCraft = abCanCraft;
		UpdateButtonText();
	}
	
	public function get bCanFadeItemInfo(): Boolean
	{
		GameDelegate.call("CanFadeItemInfo", [], this, "SetCanFadeItemInfo");
		return _bCanFadeItemInfo;
	}

	// @API (?)
	public function SetCanFadeItemInfo(abCanFade: Boolean): Void
	{
		_bCanFadeItemInfo = abCanFade;
	}

	public function get bItemCardAdditionalDescription(): Boolean
	{
		return _bItemCardAdditionalDescription;
	}

	public function set bItemCardAdditionalDescription(abItemCardDesc: Boolean): Void
	{
		_bItemCardAdditionalDescription = abItemCardDesc;
		if (abItemCardDesc) {
			AdditionalDescription.text = "";
		}
	}

	var SavedCategoryCenterText: String;
	var SavedCategoryScrollRatio: Number;
	var SavedCategorySelectedText: String;

	// @API
	public var bCanExpandPanel: Boolean;
	
	// @API
	public var bHideAdditionalDescription: Boolean;
	
	public var currentMenuType: String = "";
	
	public var navPanel: ButtonPanel;
	
	
	var dbgIntvl = 0;
	
	
  /* INITIALIZATION */

	public function CraftingMenu()
	{
		super();
		
		bCanExpandPanel = true;
		bHideAdditionalDescription = false;
		ButtonText = new Array("", "", "", "");
		
		CategoryList = InventoryLists;
		ItemInfo = ItemInfoHolder.ItemInfo;
		Mouse.addListener(this);
		
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		
		navPanel = BottomBarInfo.buttonPanel;
	}
	
	// @API
	public function Initialize(): Void
	{
		skse.ExtendData(true);
		skse.ExtendAlchemyCategories(true);
		
		_subtypeName = SUBTYPE_NAMES[_currentFrame-1];
		
		ItemInfoHolder = ItemInfoHolder;
		ItemInfoHolder.gotoAndStop("default");
		ItemInfo.addEventListener("endEditItemName", this, "onEndEditItemName");
		ItemInfo.addEventListener("subMenuAction", this, "onSubMenuAction");
		BottomBarInfo = BottomBarInfo;
		AdditionalDescriptionHolder = ItemInfoHolder.AdditionalDescriptionHolder;
		AdditionalDescription = AdditionalDescriptionHolder.AdditionalDescription;
		AdditionalDescription.textAutoSize = "shrink";
		
		// Naming FTW - gotta respect the API though.
		MenuName = MenuNameHolder.MenuName;
		MenuName.autoSize = "left";
		MenuNameHolder._visible = false;
		
		MenuDescription = MenuDescriptionHolder.MenuDescription;
		MenuDescription.autoSize = "center";

		CategoryList.InitExtensions(_subtypeName);

		FocusHandler.instance.setFocus(CategoryList, 0);
		
		CategoryList.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		CategoryList.addEventListener("showItemsList", this, "onShowItemsList");
		CategoryList.addEventListener("hideItemsList", this, "onHideItemsList");
		CategoryList.addEventListener("categoryChange", this, "onCategoryListChange");
		
		ItemList = CategoryList.itemList;
		ItemList.addEventListener("itemPress", this, "onItemSelect");
				
/*		BottomBarInfo["Button" + CraftingMenu.CRAFT_BUTTON].addEventListener("press", this, "onCraftButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].addEventListener("click", this, "onExitButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].disabled = false;
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].addEventListener("click", this, "onAuxButtonPress");
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].disabled = false;*/
		
		ExitMenuRect.onPress = function ()
		{
			GameDelegate.call("CloseMenu", []);
		};
		
		bCanCraft = false;
		positionFixedElements();
	}
	
  /* PUBLIC FUNCTIONS */
	
	// @API - Alchemy
	public function SetPartitionedFilterMode(a_bPartitioned: Boolean): Void
	{
		CategoryList.setPartitionedFilterMode(a_bPartitioned);
	}

	// @API - Alchemy
	public function GetNumCategories(): Number
	{
		return CategoryList.CategoriesList.entryList.length;
	}

	// @API
	public function UpdateButtonText(): Void
	{
		navPanel.clearButtons();
		
		if (getItemShown()) {
			navPanel.addButton({text: ButtonText[CraftingMenu.SELECT_BUTTON], controls: Input.Activate});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
		}
		
		if (bCanCraft && ButtonText[CraftingMenu.CRAFT_BUTTON] != "") {
			navPanel.addButton({text: ButtonText[CraftingMenu.CRAFT_BUTTON], controls: Input.XButton});
		}
		
		if (bCanCraft && ButtonText[CraftingMenu.AUX_BUTTON] != "") {
			navPanel.addButton({text: ButtonText[CraftingMenu.AUX_BUTTON], controls: Input.YButton});
		}
		
//		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].addEventListener("click", this, "onAuxButtonPress");
//		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].disabled = false;
		
		navPanel.updateButtons(true);
	}

	// @API
	public function UpdateItemList(abFullRebuild: Boolean): Void
	{		
		if (_subtypeName == "ConstructibleObject") {
			// After constructing an item, the native control flow is:
			//    (1) Call InvalidateListData directly and set some basic data
			//	  (2) Call UpdateItemList(false) to set more stuff
			//
			// The problem is that enabled is only set in (2), so we always do a full rebuild not to screw up our sorting.
			// For this menu, this is not a problem. For others it would be (recursive calls to UpdateItemList).
			abFullRebuild = true;
		}
		
		if (abFullRebuild == true) {
			CategoryList.InvalidateListData();
		} else {
			ItemList.UpdateList();
		}
	}

	// @API
	public function UpdateItemDisplay(): Void
	{
		var itemShown: Boolean = getItemShown();
		FadeInfoCard(!itemShown);
		SetSelectedItem(ItemList.selectedIndex);
		GameDelegate.call("ShowItem3D", [itemShown]);
	}

	// @API
	public function FadeInfoCard(abFadeOut: Boolean): Void
	{
		if (abFadeOut && bCanFadeItemInfo) {
			ItemInfo.FadeOutCard();
			if (bHideAdditionalDescription) {
				AdditionalDescriptionHolder._visible = false;
			}
			return;
		}
		if (abFadeOut) {
			return;
		}
		ItemInfo.FadeInCard();
		if (bHideAdditionalDescription) {
			AdditionalDescriptionHolder._visible = true;
		}
	}
	
	// @API
	public function SetSelectedItem(aSelection: Number): Void
	{
		GameDelegate.call("SetSelectedItem", [aSelection]);
	}
	
	// @API - Alchemy
	public function PreRebuildList(): Void
	{
//		SavedCategoryCenterText = CategoryList.CategoriesList.centeredEntry.text;
//		SavedCategorySelectedText = CategoryList.CategoriesList.selectedEntry.text;
//		SavedCategoryScrollRatio = CategoryList.CategoriesList.maxScrollPosition <= 0 ? 0 : CategoryList.CategoriesList.scrollPosition / CategoryList.CategoriesList.maxScrollPosition;
	}

	// @API - Alchemy
	public function PostRebuildList(abRestoreSelection: Boolean): Void
	{		
		/*if (abRestoreSelection) {
			var entryList: Array = CategoryList.CategoriesList.entryList;
			var centerIndex: Number = -1;
			var selectedIndex: Number = -1;
			for (var i: Number = 0; i < entryList.length; i++) {
				if (SavedCategoryCenterText == entryList[i].text) {
					centerIndex = i;
				}
				if (SavedCategorySelectedText == entryList[i].text) {
					selectedIndex = i;
				}
			}
			if (centerIndex == -1) {
				centerIndex = Math.floor(SavedCategoryScrollRatio * entryList.length);
			}
			centerIndex = Math.max(0, centerIndex);
			CategoryList.CategoriesList.RestoreScrollPosition(centerIndex, false);
			if (selectedIndex != -1) {
				CategoryList.CategoriesList.selectedIndex = selectedIndex;
			}
			CategoryList.CategoriesList.UpdateList();
			CategoryList.ItemsList.filterer.itemFilter = CategoryList.CategoriesList.selectedEntry.flag;
			CategoryList.ItemsList.UpdateList();
		}*/
	}
	
	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		if (a_platform == 0) {
			_acceptControls = Input.Enter;
			_cancelControls = Input.Tab;
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;
			
			// Defaults
			_sortColumnControls = Input.SortColumn;
			_sortOrderControls = Input.SortOrder;
		}
		
		// Defaults
		_searchControls = Input.Space;
		
		ItemInfo.SetPlatform(a_platform, a_bPS3Switch);
		
		BottomBarInfo.setPlatform(a_platform, a_bPS3Switch);
		CategoryList.setPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function UpdateIngredients(aLineTitle: String, aIngredients: Array, abShowPlayerCount: Boolean): Void
	{
		var itemTextField: TextField = bItemCardAdditionalDescription ? ItemInfo.GetItemName() : AdditionalDescription;
		itemTextField.text = aLineTitle != undefined && aLineTitle.length > 0 ? aLineTitle + ": " : "";
		var oldTextFormat: TextFormat = itemTextField.getNewTextFormat();
		var newTextFormat: TextFormat = itemTextField.getNewTextFormat();
		for (var i: Number = 0; i < aIngredients.length; i++) {
			var ingredient: Object = aIngredients[i];
			newTextFormat.color = ingredient.PlayerCount < ingredient.RequiredCount ? 0x777777 : 0xFFFFFF;
			itemTextField.setNewTextFormat(newTextFormat);
			var requiredCount = "";
			if (ingredient.RequiredCount > 1) {
				requiredCount = ingredient.RequiredCount + " ";
			}
			var itemCount: String = "";
			if (abShowPlayerCount && ingredient.PlayerCount >= 1) {
				itemCount = " (" + ingredient.PlayerCount + ")";
			}
			var ingredientString: String = requiredCount + ingredient.Name + itemCount + (i >= aIngredients.length - 1 ? "" : ", ");
			itemTextField.replaceText(itemTextField.length, itemTextField.length + 1, ingredientString);
		}
		itemTextField.setNewTextFormat(oldTextFormat);
	}

	// @API
	public function EditItemName(aInitialText: String, aMaxChars: Number): Void
	{
		ItemInfo.StartEditName(aInitialText, aMaxChars);
	}

	// @API
	public function ShowSlider(aiMaxValue: Number, aiMinValue: Number, aiCurrentValue: Number, aiSnapInterval: Number): Void
	{
		ItemInfo.ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue);
		ItemInfo.quantitySlider.snapping = true;
		ItemInfo.quantitySlider.snapInterval = aiSnapInterval;
		ItemInfo.quantitySlider.addEventListener("change", this, "onSliderChanged");
		onSliderChanged();
	}
	
	// @API
	public function SetSliderValue(aValue: Number): Void
	{
		ItemInfo.quantitySlider.value = aValue;
	}
	
	// @GFx
	public function handleInput(aInputEvent: Object, aPathToFocus: Array): Boolean
	{
		aPathToFocus[0].handleInput(aInputEvent, aPathToFocus.slice(1));
		
		return true;
	}
	
  /* PRIVATE FUNCTIONS */

	private function positionFixedElements(): Void
	{
		GlobalFunc.SetLockFunction();
		
		MovieClip(CategoryList).Lock("L");
		CategoryList._x = CategoryList._x - CraftingMenu.LIST_OFFSET;
		
		MenuNameHolder.Lock("L");
		MenuNameHolder._x = MenuNameHolder._x - CraftingMenu.LIST_OFFSET;
		MenuDescriptionHolder.Lock("TR");
		var leftOffset: Number = Stage.visibleRect.x + Stage.safeRect.x;
		var rightOffset: Number = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		var a = CategoryList.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = CategoryList._x + a[0] + a[2] + 25;
		
		MenuDescriptionHolder._x = 10 + panelEdge + ((rightOffset - panelEdge) / 2) + (MenuDescriptionHolder._width / 2);

		BottomBarInfo.positionElements(leftOffset, rightOffset);
	
		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - (Stage.safeRect.x + 10);
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
	}
	
	private function positionFloatingElements(): Void
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		
		var a = CategoryList.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = CategoryList._x + a[0] + a[2] + 25;

		var itemCardContainer = ItemInfo._parent;
		var itemcardPosition = _config.ItemInfo.itemcard;
		
		
		var itemCardWidth: Number;
		
		// For some reason 
		if (ItemInfo.background != undefined)
			itemCardWidth = ItemInfo.background._width;
		else
			itemCardWidth = ItemInfo._width;
		
		// For some reason the container is larger than the card
		// Card x is at 0 so we can use the inner width without adjustment
		var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;
		
		// Scale down if necessary
		if (scaleMult < 1.0) {
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemCardWidth *= scaleMult;
		}
		
		if (itemcardPosition.align == "left") {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset;
		} else if (itemcardPosition.align == "right") {
			itemCardContainer._x = rightEdge - itemCardWidth + itemcardPosition.xOffset;
		} else {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardWidth) / 2;
		}

		itemCardContainer._y += itemcardPosition.yOffset;

		MovieClip(MouseRotationRect).Lock("T");
		MouseRotationRect._x = ItemInfo._parent._x;
		MouseRotationRect._width = ItemInfo._parent._width;
		MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
			
//		_bItemCardPositioned = true;
		
		// Delayed fade in if positioned wasn't set
/*		if (_bItemCardFadedIn) {
			GameDelegate.call("UpdateItem3D",[true]);
			itemCard.FadeInCard();
		}*/
	}
	
	private function onConfigLoad(event: Object): Void
	{
		setConfig(event.config);
		
		CategoryList.showPanel();
	}
	
	private function setConfig(a_config: Object): Void
	{
		_config = a_config;
		ItemList.addDataProcessor(new CraftingDataSetter());
		ItemList.addDataProcessor(new CraftingIconSetter(a_config["Appearance"]));

		positionFloatingElements();
		
		var itemListState = CategoryList.itemList.listState;
		var appearance = a_config["Appearance"];
		
		itemListState.iconSource = appearance.icons.item.source;
		itemListState.showStolenIcon = appearance.icons.item.showStolen;
		
		itemListState.defaultEnabledColor = appearance.colors.text.enabled;
		itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
		itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
		itemListState.defaultDisabledColor = appearance.colors.text.disabled;
		itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
		itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;
		
		var layout: ListLayout;
		
		if (_subtypeName == "EnchantConstruct") {
			layout = ListLayoutManager.createLayout(a_config["ListLayout"], "EnchantListLayout");
			
		} else if (_subtypeName == "Smithing") {
			layout = ListLayoutManager.createLayout(a_config["ListLayout"], "SmithingListLayout");
			
		} else if (_subtypeName == "ConstructibleObject") {			
			layout = ListLayoutManager.createLayout(a_config["ListLayout"], "ConstructListLayout");
			
		} else /*if (_subtypeName == "Alchemy")*/ {
			layout = ListLayoutManager.createLayout(a_config["ListLayout"], "AlchemyListLayout");
			layout.entryWidth -= CraftingLists.SHORT_LIST_OFFSET;
		}
		
		ItemList.layout = layout;
		
		var previousColumnKey = a_config["Input"].controls.gamepad.prevColumn;
		var nextColumnKey = a_config["Input"].controls.gamepad.nextColumn;
		var sortOrderKey = a_config["Input"].controls.gamepad.sortOrder;
		_sortColumnControls = [{keyCode: previousColumnKey},
							   {keyCode: nextColumnKey}];
		_sortOrderControls = {keyCode: sortOrderKey};
		
		_searchKey = a_config["Input"].controls.pc.search;
		_searchControls = {keyCode: _searchKey};
	}

	private function onItemListPressed(event: Object): Void
	{
		GameDelegate.call("CraftSelectedItem", [ItemList.selectedIndex]);
		GameDelegate.call("SetSelectedItem", [ItemList.selectedIndex]);
	}

	private function onItemSelect(event: Object): Void
	{
		GameDelegate.call("ChooseItem", [event.index]);
		GameDelegate.call("ShowItem3D", [event.index != -1]);
		UpdateButtonText();
	}

	private function onItemHighlightChange(event: Object): Void
	{
		SetSelectedItem(event.index);
		FadeInfoCard(event.index == -1);
		UpdateButtonText();
		GameDelegate.call("ShowItem3D", [event.index != -1]);
	}

	private function onShowItemsList(event: Object): Void
	{
		if (_platform == 0) {
			GameDelegate.call("SetSelectedCategory", [CategoryList.CategoriesList.selectedIndex]);
		}
		
		onItemHighlightChange(event);
	}

	private function onHideItemsList(event: Object): Void
	{
		SetSelectedItem(event.index);
		FadeInfoCard(true);
		UpdateButtonText();
		GameDelegate.call("ShowItem3D", [false]);
	}

	private function onCategoryListChange(event: Object): Void
	{
		if (_platform != 0) 
		{
			GameDelegate.call("SetSelectedCategory", [event.index]);
		}
	}

	private function onSliderChanged(event: Object): Void
	{
		GameDelegate.call("CalculateCharge", [ItemInfo.quantitySlider.value], this, "SetChargeValues");
	}

	private function onSubMenuAction(event: Object): Void
	{
		if (event.opening == true) {
			ItemList.disableSelection = true;
			ItemList.disableInput = true;
			CategoryList.CategoriesList.disableSelection = true;
			CategoryList.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			ItemList.disableSelection = false;
			ItemList.disableInput = false;
			CategoryList.CategoriesList.disableSelection = false;
			CategoryList.CategoriesList.disableInput = false;
		}
		if (event.menu == "quantity") {
			if (event.opening) {
				return;
			}
			GameDelegate.call("SliderClose", [!event.canceled, event.value]);
		}
	}
	
	private function onCraftButtonPress(): Void
	{
		if (bCanCraft) {
			GameDelegate.call("CraftButtonPress", []);
		}
	}

	private function onExitButtonPress(): Void
	{
		GameDelegate.call("CloseMenu", []);
	}

	private function onAuxButtonPress(): Void
	{
		GameDelegate.call("AuxButtonPress", []);
	}
	
	private function onEndEditItemName(event: Object): Void
	{
		ItemInfo.EndEditName();
		GameDelegate.call("EndItemRename", [event.useNewName, event.newName]);
	}

	private function getItemShown(): Boolean
	{
		return ItemList.selectedIndex >= 0;
	}

	private function onMouseUp(): Void
	{
		if (ItemInfo.bEditNameMode && !ItemInfo.hitTest(_root._xmouse, _root._ymouse)) {
			onEndEditItemName({useNewName: false, newName: ""});
		}
	}

	private function onMouseRotationStart(): Void
	{
		GameDelegate.call("StartMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = true;
		ItemList.disableSelection = true;
	}

	private function onMouseRotationStop(): Void
	{
		GameDelegate.call("StopMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = false;
		ItemList.disableSelection = false;
	}

	private function onItemsListInputCatcherClick(): Void
	{
//		if (CategoryList.currentState == InventoryLists.TWO_PANELS && !ItemList.disableSelection && !ItemList.disableInput) {
//			onItemSelect({index: ItemList.selectedIndex});
//		}
	}

	private function onMouseRotationFastClick(aiMouseButton: Number): Void
	{
		if (aiMouseButton == 0) {
			onItemsListInputCatcherClick();
		}
	}
}
