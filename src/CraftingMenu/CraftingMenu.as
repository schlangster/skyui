import gfx.managers.FocusHandler;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.util.ConfigManager;

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
	public var RestoreCategoryRect: MovieClip;

	public var ItemsListInputCatcher: MovieClip;

	// Not API, but keeping the original name for compatiblity with vanilla.
	public var InventoryLists: CraftingLists;
	
	public var MouseRotationRect: MovieClip;
	public var ExitMenuRect: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
	private var _bCanCraft: Boolean = false;
	private var _bCanFadeItemInfo: Boolean = true;
	private var _bItemCardAdditionalDescription: Boolean = false;
	private var _platform: Number = 0;
	
	
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
	var bCanExpandPanel: Boolean;
	
	// @API
	var bHideAdditionalDescription: Boolean;
	
	public var currentMenuType: String = "";
	
	
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
	}
	
	public function onLoad()
	{
		//Initialize();		
	}
	
	private function onConfigLoad(event: Object): Void
	{
		setConfig(event.config);
		
		CategoryList.showPanel();
	}
	
	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		var itemList: TabularList = InventoryLists.itemList;		
//		itemList.addDataProcessor(new BarterDataSetter(_buyMult, _sellMult));
//		itemList.addDataProcessor(new InventoryIconSetter(a_config["Appearance"]));
//		itemList.addDataProcessor(new PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
//		if (InventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(0);
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function Initialize(): Void
	{
		skse.Log("Initialize");
		
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
		
		BottomBarInfo.SetButtonsArt([{PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"}, {PCArt: "Tab", XBoxArt: "360_B", PS3Art: "PS3_B"}, {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}]);

		FocusHandler.instance.setFocus(CategoryList, 0);
//		CategoryList.ShowCategoriesList();
		CategoryList.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		CategoryList.addEventListener("showItemsList", this, "onShowItemsList");
		CategoryList.addEventListener("hideItemsList", this, "onHideItemsList");
		CategoryList.addEventListener("categoryChange", this, "onCategoryListChange");
		
		ItemList = CategoryList.itemList;
		ItemList.addEventListener("itemPress", this, "onItemSelect");
				
		BottomBarInfo["Button" + CraftingMenu.CRAFT_BUTTON].addEventListener("press", this, "onCraftButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].addEventListener("click", this, "onExitButtonPress");
		BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].disabled = false;
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].addEventListener("click", this, "onAuxButtonPress");
		BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].disabled = false;
		
		ItemsListInputCatcher.onMouseDown = function ()
		{
			if (Mouse.getTopMostEntity() == this) {
				_parent.onItemsListInputCatcherClick();
			}
		};
		
		RestoreCategoryRect.onRollOver = function ()
		{
			if (_parent.CategoryList.currentState == InventoryLists.TWO_PANELS) {
				_parent.CategoryList.RestoreCategoryIndex();
			}
		};
		
		ExitMenuRect.onPress = function ()
		{
			GameDelegate.call("CloseMenu", []);
		};
		
		bCanCraft = false;
		positionElements();
		
		SetPlatform(_platform);
		
		CategoryList.setSubtype(SUBTYPE_NAMES[_currentFrame-1]);
	}
	
	// @API
	public function SetPartitionedFilterMode(a_bPartitioned: Boolean): Void
	{
		// True for alchemy, false otherwise
		skse.Log("Set partitioned filter mode " + a_bPartitioned);
//		CategoryList.itemList.filterer.SetPartitionedFilterMode(a_bPartitioned);
	}

	// @API
	public function GetNumCategories(): Number
	{
//		return CategoryList != undefined && CategoryList.CategoriesList != undefined ? CategoryList.CategoriesList.entryList.length : 0;
		return 0;
	}

	// @API
	public function UpdateButtonText(): Void
	{
		var buttonText: Array = ButtonText.concat();
		if (!bCanCraft) {
			buttonText[CraftingMenu.CRAFT_BUTTON] = "";
		}
		if (!getItemShown()) {
			buttonText[CraftingMenu.SELECT_BUTTON] = "";
		}
		BottomBarInfo.SetButtonsText.apply(BottomBarInfo, buttonText);
	}

	// @API
	public function UpdateItemList(abFullRebuild: Boolean): Void
	{
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
	
	// @API
	public function PreRebuildList(): Void
	{
		skse.Log("PreRebuildList");
		
//		SavedCategoryCenterText = CategoryList.CategoriesList.centeredEntry.text;
//		SavedCategorySelectedText = CategoryList.CategoriesList.selectedEntry.text;
//		SavedCategoryScrollRatio = CategoryList.CategoriesList.maxScrollPosition <= 0 ? 0 : CategoryList.CategoriesList.scrollPosition / CategoryList.CategoriesList.maxScrollPosition;
	}

	// @API
	public function PostRebuildList(abRestoreSelection: Boolean): Void
	{
		skse.Log("PostRebuildList");
		
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
		
		BottomBarInfo.SetPlatform(a_platform, a_bPS3Switch);
		ItemInfo.SetPlatform(a_platform, a_bPS3Switch);
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
		if (bCanExpandPanel && aPathToFocus.length > 0) {
			aPathToFocus[0].handleInput(aInputEvent, aPathToFocus.slice(1));
		} else if (aPathToFocus.length > 1) {
			aPathToFocus[1].handleInput(aInputEvent, aPathToFocus.slice(2));
		}
		return true;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function positionElements(): Void
	{
		GlobalFunc.SetLockFunction();
		
		MovieClip(CategoryList).Lock("L");
		CategoryList._x = CategoryList._x - CraftingMenu.LIST_OFFSET;
		
		MenuNameHolder.Lock("L");
		MenuNameHolder._x = MenuNameHolder._x - CraftingMenu.LIST_OFFSET;
		MenuDescriptionHolder.Lock("TR");
		var leftOffset: Number = Stage.visibleRect.x + Stage.safeRect.x;
		var rightOffset: Number = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		BottomBarInfo.PositionElements(leftOffset, rightOffset);
		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x = ExitMenuRect._x - (Stage.safeRect.x + 10);
		ExitMenuRect._y = ExitMenuRect._y - Stage.safeRect.y;
//		RestoreCategoryRect._x = ExitMenuRect._x + CategoryList.CategoriesList._parent._width + 25;
		ItemsListInputCatcher._x = RestoreCategoryRect._x + RestoreCategoryRect._width;
		ItemsListInputCatcher._width = _root._width - ItemsListInputCatcher._x;
		MovieClip(MouseRotationRect).Lock("T");
		MouseRotationRect._x = ItemInfo._parent._x;
		MouseRotationRect._width = ItemInfo._parent._width;
		MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
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
//			GameDelegate.call("SetSelectedCategory", [CategoryList.CategoriesList.selectedIndex]);
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
//			CategoryList.CategoriesList.disableSelection = true;
//			CategoryList.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			ItemList.disableSelection = false;
			ItemList.disableInput = false;
//			CategoryList.CategoriesList.disableSelection = false;
//			CategoryList.CategoriesList.disableInput = false;
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
	
	private function OnEndEditItemName(event: Object): Void
	{
		ItemInfo.EndEditName();
		GameDelegate.call("EndItemRename", [event.useNewName, event.newName]);
	}

	private function getItemShown(): Boolean
	{
//		return ItemList.selectedIndex >= 0 && (CategoryList == undefined || CategoryList.currentState == InventoryLists.TWO_PANELS || CategoryList.currentState == InventoryLists.TRANSITIONING_TO_TWO_PANELS);
		return false;
	}

	private function onMouseUp(): Void
	{
		if (ItemInfo.bEditNameMode && !ItemInfo.hitTest(_root._xmouse, _root._ymouse)) {
			OnEndEditItemName({useNewName: false, newName: ""});
		}
	}

	private function onMouseWheel(delta: Number): Void
	{
/*		if (CategoryList.currentState == InventoryLists.TWO_PANELS && !ItemList.disableSelection && !ItemList.disableInput) {
			for (var target: Object = Mouse.getTopMostEntity(); !(target && target != undefined); target = target._parent) {
				if (target == ItemsListInputCatcher || target == MouseRotationRect) {
					if (delta == 1) {
						ItemList.moveSelectionUp();
					} else if (delta == -1) {
						ItemList.moveSelectionDown();
					}
				}
			}
		}*/
	}

	private function onMouseRotationStart(): Void
	{
		GameDelegate.call("StartMouseRotation", []);
//		CategoryList.CategoriesList.disableSelection = true;
		ItemList.disableSelection = true;
	}

	private function onMouseRotationStop(): Void
	{
		GameDelegate.call("StopMouseRotation", []);
//		CategoryList.CategoriesList.disableSelection = false;
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
