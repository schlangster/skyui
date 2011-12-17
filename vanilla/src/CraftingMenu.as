dynamic class CraftingMenu extends MovieClip
{
	static var MT_SINGLE_PANEL: Number = 0;
	static var MT_DOUBLE_PANEL: Number = 1;
	static var LIST_OFFSET: Number = 20;
	static var SELECT_BUTTON: Number = 0;
	static var EXIT_BUTTON: Number = 1;
	static var AUX_BUTTON: Number = 2;
	static var CRAFT_BUTTON: Number = 3;
	var AdditionalDescription;
	var AdditionalDescriptionHolder;
	var BottomBarInfo;
	var ButtonText;
	var CategoryList;
	var ExitMenuRect;
	var InventoryLists;
	var ItemInfo;
	var ItemInfoHolder;
	var ItemList;
	var ItemListTweener;
	var ItemsListInputCatcher;
	var MenuDescription;
	var MenuDescriptionHolder;
	var MenuName;
	var MenuNameHolder;
	var MenuType;
	var MouseRotationRect;
	var Platform;
	var RestoreCategoryRect;
	var SavedCategoryCenterText;
	var SavedCategoryScrollRatio;
	var SavedCategorySelectedText;
	var _bCanCraft;
	var _bCanFadeItemInfo;
	var _bItemCardAdditionalDescription;
	var _parent;
	var bCanExpandPanel;
	var bHideAdditionalDescription;

	function CraftingMenu()
	{
		super();
		this._bCanCraft = false;
		this.bCanExpandPanel = true;
		this._bCanFadeItemInfo = true;
		this.bHideAdditionalDescription = false;
		this._bItemCardAdditionalDescription = false;
		this.ButtonText = new Array("", "", "", "");
		this.Platform = 0;
		this.CategoryList = this.InventoryLists;
		this.ItemInfo = this.ItemInfoHolder.ItemInfo;
		Mouse.addListener(this);
	}

	function Initialize()
	{
		this.ItemInfoHolder = this.ItemInfoHolder;
		this.ItemInfoHolder.gotoAndStop("default");
		this.ItemInfo.addEventListener("endEditItemName", this, "OnEndEditItemName");
		this.ItemInfo.addEventListener("subMenuAction", this, "OnSubMenuAction");
		this.BottomBarInfo = this.BottomBarInfo;
		this.AdditionalDescriptionHolder = this.ItemInfoHolder.AdditionalDescriptionHolder;
		this.AdditionalDescription = this.AdditionalDescriptionHolder.AdditionalDescription;
		this.AdditionalDescription.textAutoSize = "shrink";
		this.MenuName = this.CategoryList.CategoriesList._parent.CategoryLabel;
		this.MenuName.autoSize = "left";
		this.MenuNameHolder._visible = false;
		this.MenuDescription = this.MenuDescriptionHolder.MenuDescription;
		this.MenuDescription.autoSize = "center";
		this.BottomBarInfo.SetButtonsArt([{PCArt: "E", XBoxArt: "360_A", PS3Art: "PS3_A"}, {PCArt: "Tab", XBoxArt: "360_B", PS3Art: "PS3_B"}, {PCArt: "F", XBoxArt: "360_Y", PS3Art: "PS3_Y"}, {PCArt: "R", XBoxArt: "360_X", PS3Art: "PS3_X"}]);
		if (this.ItemListTweener == undefined) 
		{
			if (this.CategoryList != undefined) 
			{
				this.MenuType = CraftingMenu.MT_DOUBLE_PANEL;
				gfx.managers.FocusHandler.instance.setFocus(this.CategoryList, 0);
				this.CategoryList.ShowCategoriesList();
				this.CategoryList.addEventListener("itemHighlightChange", this, "OnItemHighlightChange");
				this.CategoryList.addEventListener("showItemsList", this, "OnShowItemsList");
				this.CategoryList.addEventListener("hideItemsList", this, "OnHideItemsList");
				this.CategoryList.addEventListener("categoryChange", this, "OnCategoryListChange");
				this.ItemList = this.CategoryList.ItemsList;
				this.ItemList.addEventListener("itemPress", this, "OnItemSelect");
			}
		}
		else 
		{
			this.MenuType = CraftingMenu.MT_SINGLE_PANEL;
			this.ItemList = this.ItemListTweener.List_mc;
			this.ItemListTweener.gotoAndPlay("showList");
			gfx.managers.FocusHandler.instance.setFocus(this.ItemList, 0);
			this.ItemList.addEventListener("listMovedUp", this, "OnItemListMovedUp");
			this.ItemList.addEventListener("listMovedDown", this, "OnItemListMovedDown");
			this.ItemList.addEventListener("itemPress", this, "OnItemListPressed");
		}
		this.BottomBarInfo["Button" + CraftingMenu.CRAFT_BUTTON].addEventListener("press", this, "onCraftButtonPress");
		this.BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].addEventListener("click", this, "onExitButtonPress");
		this.BottomBarInfo["Button" + CraftingMenu.EXIT_BUTTON].disabled = false;
		this.BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].addEventListener("click", this, "onAuxButtonPress");
		this.BottomBarInfo["Button" + CraftingMenu.AUX_BUTTON].disabled = false;
		this.ItemsListInputCatcher.onMouseDown = function ()
		{
			if (Mouse.getTopMostEntity() == this) 
			{
				this._parent.onItemsListInputCatcherClick();
			}
		}
		;
		this.RestoreCategoryRect.onRollOver = function ()
		{
			if (this._parent.CategoryList.currentState == InventoryLists.TWO_PANELS) 
			{
				this._parent.CategoryList.RestoreCategoryIndex();
			}
		}
		;
		this.ExitMenuRect.onPress = function ()
		{
			gfx.io.GameDelegate.call("CloseMenu", []);
		}
		;
		this.bCanCraft = false;
		this.PositionElements();
		this.SetPlatform(this.Platform);
	}

	function get bCanCraft()
	{
		return this._bCanCraft;
	}

	function set bCanCraft(abCanCraft)
	{
		this._bCanCraft = abCanCraft;
		this.UpdateButtonText();
	}

	function onCraftButtonPress()
	{
		if (this.bCanCraft) 
		{
			gfx.io.GameDelegate.call("CraftButtonPress", []);
		}
	}

	function onExitButtonPress()
	{
		gfx.io.GameDelegate.call("CloseMenu", []);
	}

	function onAuxButtonPress()
	{
		gfx.io.GameDelegate.call("AuxButtonPress", []);
	}

	function get bCanFadeItemInfo()
	{
		gfx.io.GameDelegate.call("CanFadeItemInfo", [], this, "SetCanFadeItemInfo");
		return this._bCanFadeItemInfo;
	}

	function SetCanFadeItemInfo(abCanFade)
	{
		this._bCanFadeItemInfo = abCanFade;
	}

	function get bItemCardAdditionalDescription()
	{
		return this._bItemCardAdditionalDescription;
	}

	function set bItemCardAdditionalDescription(abItemCardDesc)
	{
		this._bItemCardAdditionalDescription = abItemCardDesc;
		if (abItemCardDesc) 
		{
			this.AdditionalDescription.text = "";
		}
	}

	function SetPartitionedFilterMode(abPartitioned)
	{
		this.CategoryList.ItemsList.filterer.SetPartitionedFilterMode(abPartitioned);
	}

	function GetItemShown()
	{
		return this.ItemList.selectedIndex >= 0 && (this.CategoryList == undefined || this.CategoryList.currentState == InventoryLists.TWO_PANELS || this.CategoryList.currentState == InventoryLists.TRANSITIONING_TO_TWO_PANELS);
	}

	function GetNumCategories()
	{
		return this.CategoryList != undefined && this.CategoryList.CategoriesList != undefined ? this.CategoryList.CategoriesList.entryList.length : 0;
	}

	function onMouseUp()
	{
		if (this.ItemInfo.bEditNameMode && !this.ItemInfo.hitTest(_root._xmouse, _root._ymouse)) 
		{
			this.OnEndEditItemName({useNewName: false, newName: ""});
		}
	}

	function onMouseWheel(delta)
	{
		if (this.CategoryList.currentState == InventoryLists.TWO_PANELS && !this.ItemList.disableSelection && !this.ItemList.disableInput) 
		{
			var __reg2 = Mouse.getTopMostEntity();
			for (;;) 
			{
				if (!(__reg2 && __reg2 != undefined)) 
				{
					return;
				}
				if (__reg2 == this.ItemsListInputCatcher || __reg2 == this.MouseRotationRect) 
				{
					if (delta == 1) 
					{
						this.ItemList.moveSelectionUp();
					}
					else if (delta == -1) 
					{
						this.ItemList.moveSelectionDown();
					}
				}
				__reg2 = __reg2._parent;
			}
		}
	}

	function onMouseRotationStart()
	{
		gfx.io.GameDelegate.call("StartMouseRotation", []);
		this.CategoryList.CategoriesList.disableSelection = true;
		this.ItemList.disableSelection = true;
	}

	function onMouseRotationStop()
	{
		gfx.io.GameDelegate.call("StopMouseRotation", []);
		this.CategoryList.CategoriesList.disableSelection = false;
		this.ItemList.disableSelection = false;
	}

	function onItemsListInputCatcherClick()
	{
		if (this.CategoryList.currentState == InventoryLists.TWO_PANELS && !this.ItemList.disableSelection && !this.ItemList.disableInput) 
		{
			this.OnItemSelect({index: this.ItemList.selectedIndex});
		}
	}

	function onMouseRotationFastClick(aiMouseButton)
	{
		if (aiMouseButton == 0) 
		{
			this.onItemsListInputCatcherClick();
		}
	}

	function UpdateButtonText()
	{
		var __reg2 = this.ButtonText.concat();
		if (!this.bCanCraft) 
		{
			__reg2[CraftingMenu.CRAFT_BUTTON] = "";
		}
		if (!this.GetItemShown()) 
		{
			__reg2[CraftingMenu.SELECT_BUTTON] = "";
		}
		this.BottomBarInfo.SetButtonsText.apply(this.BottomBarInfo, __reg2);
	}

	function UpdateItemList(abFullRebuild)
	{
		if (abFullRebuild == true) 
		{
			this.CategoryList.InvalidateListData();
		}
		else 
		{
			this.ItemList.UpdateList();
		}
		if (this.MenuType == CraftingMenu.MT_SINGLE_PANEL) 
		{
			this.FadeInfoCard(this.ItemList.entryList.length == 0);
		}
	}

	function UpdateItemDisplay()
	{
		var __reg2 = this.GetItemShown();
		this.FadeInfoCard(!__reg2);
		this.SetSelectedItem(this.ItemList.selectedIndex);
		gfx.io.GameDelegate.call("ShowItem3D", [__reg2]);
	}

	function FadeInfoCard(abFadeOut)
	{
		if (abFadeOut && this.bCanFadeItemInfo) 
		{
			this.ItemInfo.FadeOutCard();
			if (this.bHideAdditionalDescription) 
			{
				this.AdditionalDescriptionHolder._visible = false;
			}
			return;
		}
		if (abFadeOut) 
		{
			return;
		}
		this.ItemInfo.FadeInCard();
		if (this.bHideAdditionalDescription) 
		{
			this.AdditionalDescriptionHolder._visible = true;
		}
	}

	function PositionElements()
	{
		Shared.GlobalFunc.SetLockFunction();
		if (this.MenuType == CraftingMenu.MT_SINGLE_PANEL) 
		{
			this.ItemListTweener.Lock("L");
			this.ItemListTweener._x = this.ItemListTweener._x - CraftingMenu.LIST_OFFSET;
		}
		else if (this.MenuType == CraftingMenu.MT_DOUBLE_PANEL) 
		{
			MovieClip(this.CategoryList).Lock("L");
			this.CategoryList._x = this.CategoryList._x - CraftingMenu.LIST_OFFSET;
		}
		this.MenuNameHolder.Lock("L");
		this.MenuNameHolder._x = this.MenuNameHolder._x - CraftingMenu.LIST_OFFSET;
		this.MenuDescriptionHolder.Lock("TR");
		var __reg3 = Stage.visibleRect.x + Stage.safeRect.x;
		var __reg4 = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		this.BottomBarInfo.PositionElements(__reg3, __reg4);
		MovieClip(this.ExitMenuRect).Lock("TL");
		this.ExitMenuRect._x = this.ExitMenuRect._x - (Stage.safeRect.x + 10);
		this.ExitMenuRect._y = this.ExitMenuRect._y - Stage.safeRect.y;
		this.RestoreCategoryRect._x = this.ExitMenuRect._x + this.CategoryList.CategoriesList._parent._width + 25;
		this.ItemsListInputCatcher._x = this.RestoreCategoryRect._x + this.RestoreCategoryRect._width;
		this.ItemsListInputCatcher._width = _root._width - this.ItemsListInputCatcher._x;
		MovieClip(this.MouseRotationRect).Lock("T");
		this.MouseRotationRect._x = this.ItemInfo._parent._x;
		this.MouseRotationRect._width = this.ItemInfo._parent._width;
		this.MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
	}

	function OnItemListPressed(event)
	{
		gfx.io.GameDelegate.call("CraftSelectedItem", [this.ItemList.selectedIndex]);
		gfx.io.GameDelegate.call("SetSelectedItem", [this.ItemList.selectedIndex]);
	}

	function OnItemSelect(event)
	{
		gfx.io.GameDelegate.call("ChooseItem", [event.index]);
		gfx.io.GameDelegate.call("ShowItem3D", [event.index != -1]);
		this.UpdateButtonText();
	}

	function OnItemHighlightChange(event)
	{
		this.SetSelectedItem(event.index);
		this.FadeInfoCard(event.index == -1);
		this.UpdateButtonText();
		gfx.io.GameDelegate.call("ShowItem3D", [event.index != -1]);
	}

	function OnShowItemsList(event)
	{
		if (this.Platform == 0) 
		{
			gfx.io.GameDelegate.call("SetSelectedCategory", [this.CategoryList.CategoriesList.selectedIndex]);
		}
		this.OnItemHighlightChange(event);
	}

	function OnHideItemsList(event)
	{
		this.SetSelectedItem(event.index);
		this.FadeInfoCard(true);
		this.UpdateButtonText();
		gfx.io.GameDelegate.call("ShowItem3D", [false]);
	}

	function OnCategoryListChange(event)
	{
		if (this.Platform != 0) 
		{
			gfx.io.GameDelegate.call("SetSelectedCategory", [event.index]);
		}
	}

	function SetSelectedItem(aSelection)
	{
		gfx.io.GameDelegate.call("SetSelectedItem", [aSelection]);
	}

	function handleInput(aInputEvent, aPathToFocus)
	{
		if (this.bCanExpandPanel && aPathToFocus.length > 0) 
		{
			aPathToFocus[0].handleInput(aInputEvent, aPathToFocus.slice(1));
		}
		else if (this.MenuType == CraftingMenu.MT_DOUBLE_PANEL && aPathToFocus.length > 1) 
		{
			aPathToFocus[1].handleInput(aInputEvent, aPathToFocus.slice(2));
		}
		return true;
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		this.Platform = aiPlatform;
		this.BottomBarInfo.SetPlatform(aiPlatform, abPS3Switch);
		this.ItemInfo.SetPlatform(aiPlatform, abPS3Switch);
		this.CategoryList.SetPlatform(aiPlatform, abPS3Switch);
	}

	function UpdateIngredients(aLineTitle, aIngredients, abShowPlayerCount)
	{
		var __reg4 = this.bItemCardAdditionalDescription ? this.ItemInfo.GetItemName() : this.AdditionalDescription;
		__reg4.text = aLineTitle != undefined && aLineTitle.length > 0 ? aLineTitle + ": " : "";
		var __reg11 = __reg4.getNewTextFormat();
		var __reg9 = __reg4.getNewTextFormat();
		var __reg3 = 0;
		while (__reg3 < aIngredients.length) 
		{
			var __reg2 = aIngredients[__reg3];
			__reg9.color = __reg2.PlayerCount < __reg2.RequiredCount ? 7829367 : 16777215;
			__reg4.setNewTextFormat(__reg9);
			var __reg6 = "";
			if (__reg2.RequiredCount > 1) 
			{
				__reg6 = __reg2.RequiredCount + " ";
			}
			var __reg5 = "";
			if (abShowPlayerCount && __reg2.PlayerCount >= 1) 
			{
				__reg5 = " (" + __reg2.PlayerCount + ")";
			}
			var __reg8 = __reg6 + __reg2.Name + __reg5 + (__reg3 >= aIngredients.length - 1 ? "" : ", ");
			__reg4.replaceText(__reg4.length, __reg4.length + 1, __reg8);
			++__reg3;
		}
		__reg4.setNewTextFormat(__reg11);
	}

	function EditItemName(aInitialText, aMaxChars)
	{
		this.ItemInfo.StartEditName(aInitialText, aMaxChars);
	}

	function OnEndEditItemName(event)
	{
		this.ItemInfo.EndEditName();
		gfx.io.GameDelegate.call("EndItemRename", [event.useNewName, event.newName]);
	}

	function ShowSlider(aiMaxValue, aiMinValue, aiCurrentValue, aiSnapInterval)
	{
		this.ItemInfo.ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue);
		this.ItemInfo.quantitySlider.snapping = true;
		this.ItemInfo.quantitySlider.snapInterval = aiSnapInterval;
		this.ItemInfo.quantitySlider.addEventListener("change", this, "OnSliderChanged");
		this.OnSliderChanged();
	}

	function OnSliderChanged(event)
	{
		gfx.io.GameDelegate.call("CalculateCharge", [this.ItemInfo.quantitySlider.value], this, "SetChargeValues");
	}

	function SetSliderValue(aValue)
	{
		this.ItemInfo.quantitySlider.value = aValue;
	}

	function OnSubMenuAction(event)
	{
		if (event.opening == true) 
		{
			this.ItemList.disableSelection = true;
			this.ItemList.disableInput = true;
			this.CategoryList.CategoriesList.disableSelection = true;
			this.CategoryList.CategoriesList.disableInput = true;
		}
		else if (event.opening == false) 
		{
			this.ItemList.disableSelection = false;
			this.ItemList.disableInput = false;
			this.CategoryList.CategoriesList.disableSelection = false;
			this.CategoryList.CategoriesList.disableInput = false;
		}
		if (event.menu == "quantity") 
		{
			if (event.opening) 
			{
				return;
			}
			gfx.io.GameDelegate.call("SliderClose", [!event.canceled, event.value]);
		}
	}

	function PreRebuildList()
	{
		this.SavedCategoryCenterText = this.CategoryList.CategoriesList.centeredEntry.text;
		this.SavedCategorySelectedText = this.CategoryList.CategoriesList.selectedEntry.text;
		this.SavedCategoryScrollRatio = this.CategoryList.CategoriesList.maxScrollPosition <= 0 ? 0 : this.CategoryList.CategoriesList.scrollPosition / this.CategoryList.CategoriesList.maxScrollPosition;
	}

	function PostRebuildList(abRestoreSelection)
	{
		if (abRestoreSelection) 
		{
			var __reg3 = this.CategoryList.CategoriesList.entryList;
			var __reg4 = -1;
			var __reg5 = -1;
			var __reg2 = 0;
			while (__reg2 < __reg3.length) 
			{
				if (this.SavedCategoryCenterText == __reg3[__reg2].text) 
				{
					__reg4 = __reg2;
				}
				if (this.SavedCategorySelectedText == __reg3[__reg2].text) 
				{
					__reg5 = __reg2;
				}
				++__reg2;
			}
			if (__reg4 == -1) 
			{
				__reg4 = Math.floor(this.SavedCategoryScrollRatio * __reg3.length);
			}
			__reg4 = Math.max(0, __reg4);
			this.CategoryList.CategoriesList.RestoreScrollPosition(__reg4, false);
			if (__reg5 != -1) 
			{
				this.CategoryList.CategoriesList.selectedIndex = __reg5;
			}
			this.CategoryList.CategoriesList.UpdateList();
			this.CategoryList.ItemsList.filterer.itemFilter = this.CategoryList.CategoriesList.selectedEntry.flag;
			this.CategoryList.ItemsList.UpdateList();
		}
	}

}
