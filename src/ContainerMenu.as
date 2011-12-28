import gfx.io.GameDelegate;

class ContainerMenu extends ItemMenu
{
	static var NULL_HAND:Number = -1;
	static var RIGHT_HAND:Number = 0;
	static var LEFT_HAND:Number = 1;

	private var _bNPCMode:Boolean;
	private var _bShowEquipButtonHelp:Boolean;
	private var _equipHand:Number;
	private var _selectedCategory;

	var ContainerButtonArt:Object;
	var InventoryButtonArt:Object;

	// ?
	var bPCControlsReady:Boolean = true;


	function ContainerMenu()
	{
		super();
		ContainerButtonArt = [{PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LBRB"},
							  {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A"},
							  {PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X"}];
		InventoryButtonArt = [{PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LBRB"},
							  {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A"},
							  {PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X"},
							  {PCArt:"F",XBoxArt:"360_Y",PS3Art:"PS3_Y"}];
		_bNPCMode = false;
		_bShowEquipButtonHelp = true;
		_equipHand = undefined;
	}

	function InitExtensions()
	{
		super.InitExtensions(false);
		GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
		GameDelegate.addCallBack("XButtonPress",this,"onXButtonPress");
		ItemCardFadeHolder_mc.StealTextInstance._visible = false;
		updateButtons();
	}

	function ShowItemsList()
	{
		InventoryLists_mc.ShowItemsList(false);
	}

	function handleInput(details,pathToFocus)
	{
		super.handleInput(details,pathToFocus);

		if (ShouldProcessItemsListInput(false)) {
			if (_platform == 0 && details.code == 16) {
				_bShowEquipButtonHelp = details.value != "keyUp";
				updateButtons();
			}
		}

		return true;
	}

	function onXButtonPress()
	{
		if (isViewingContainer() && ! _bNPCMode) {
			GameDelegate.call("TakeAllItems",[]);
			return;
		}

		if (isViewingContainer()) {
			return;
		}

		StartItemTransfer();
	}

	function UpdateItemCardInfo(a_updateObj:Object)
	{
		super.UpdateItemCardInfo(a_updateObj);

		updateButtons();

		if (a_updateObj.pickpocketChance != undefined) {
			ItemCardFadeHolder_mc.StealTextInstance._visible = true;
			ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.html = true;
			ItemCardFadeHolder_mc.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + isViewingContainer() ? _root.TranslationBass.ToStealTextInstance.text:_root.TranslationBass.ToPlaceTextInstance.text;
			return;
		}

		ItemCardFadeHolder_mc.StealTextInstance._visible = false;
	}

	function onShowItemsList(event)
	{
		_selectedCategory = InventoryLists_mc.CategoriesList.selectedIndex;
		updateButtons();

		super.onShowItemsList(event);
	}

	function onHideItemsList(event)
	{
		super.onHideItemsList(event);

		BottomBar_mc.UpdatePerItemInfo({type:InventoryDefines.ICT_NONE});
		updateButtons();
	}

	function updateButtons()
	{
		BottomBar_mc.SetButtonsArt(isViewingContainer() ? ContainerButtonArt:InventoryButtonArt);

		if (InventoryLists_mc.currentState != InventoryLists.TRANSITIONING_TO_SHOW_PANEL && InventoryLists_mc.currentState != InventoryLists.SHOW_PANEL) {
			BottomBar_mc.SetButtonText("",0);
			BottomBar_mc.SetButtonText("",1);
			BottomBar_mc.SetButtonText("",2);
			BottomBar_mc.SetButtonText("",3);

			return;
		}

		updateEquipButtonText();

		if (isViewingContainer()) {
			BottomBar_mc.SetButtonText("$Take",1);
		} else {
			BottomBar_mc.SetButtonText(_bShowEquipButtonHelp ? "":InventoryDefines.GetEquipText(ItemCard_mc.itemInfo.type),1);
		}

		if (isViewingContainer()) {
			if (_bNPCMode) {
				BottomBar_mc.SetButtonText("",2);
			} else if (isViewingContainer()) {
				BottomBar_mc.SetButtonText("$Take All",2);
			}
		} else if (_bNPCMode) {
			BottomBar_mc.SetButtonText("$Give",2);
		} else {
			BottomBar_mc.SetButtonText("$Store",2);
		}

		updateFavoriteText();
	}

	function onMouseRotationFastClick(a_mouseButton:Number)
	{
		GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
	}

	function updateEquipButtonText()
	{
		BottomBar_mc.SetButtonText(_bShowEquipButtonHelp ? InventoryDefines.GetEquipText(ItemCard_mc.itemInfo.type) : "",0);
	}

	function updateFavoriteText()
	{
		if (! isViewingContainer()) {
			BottomBar_mc.SetButtonText(ItemCard_mc.itemInfo.favorite ? "$Unfavorite":"$Favorite",3);
			return;
		}

		BottomBar_mc.SetButtonText("",3);
	}

	function isViewingContainer()
	{
		var divider = InventoryLists_mc.CategoriesList.dividerIndex;
		return divider != undefined && _selectedCategory < divider;
	}

	function onQuantityMenuSelect(event)
	{
		if (_equipHand != undefined) {
			GameDelegate.call("EquipItem",[_equipHand,event.amount]);
			_equipHand = undefined;
			return;
		}

		if (InventoryLists_mc.ItemsList.selectedEntry.enabled) {
			GameDelegate.call("ItemTransfer",[event.amount,isViewingContainer()]);
			return;
		}

		GameDelegate.call("DisabledItemSelect",[]);
	}

	function AttemptEquip(a_slot:Number, a_bCheckOverList:Boolean)
	{
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;

		if (ShouldProcessItemsListInput(bCheckOverList)) {
			if (_platform == 0) {
				if (!isViewingContainer() || _bShowEquipButtonHelp) {
					StartItemEquip(a_slot);
				} else {
					StartItemTransfer();
				}
				return;
			}
			StartItemEquip(a_slot);
		}
	}

	function onItemSelect(event)
	{
		if (event.keyboardOrMouse != 0) {
			if (! isViewingContainer()) {
				StartItemEquip(ContainerMenu.NULL_HAND);
				return;
			}
			StartItemTransfer();
		}
	}

	function StartItemTransfer()
	{
		if (ItemCard_mc.itemInfo.weight == 0 && isViewingContainer()) {
			onQuantityMenuSelect({amount:InventoryLists_mc.ItemsList.selectedEntry.count});
			return;
		}

		if (InventoryLists_mc.ItemsList.selectedEntry.count <= InventoryDefines.QUANTITY_MENU_COUNT_LIMIT) {
			onQuantityMenuSelect({amount:1});
			return;
		}

		ItemCard_mc.ShowQuantityMenu(InventoryLists_mc.ItemsList.selectedEntry.count);
	}

	function StartItemEquip(a_equipHand)
	{
		if (isViewingContainer()) {
			_equipHand = a_equipHand;
			StartItemTransfer();
			return;
		}

		GameDelegate.call("EquipItem",[a_equipHand]);
	}

	function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		
		if (event.menu == "quantity") {
			GameDelegate.call("QuantitySliderOpen",[event.opening]);
		}
	}

	function SetPlatform(a_platform:Number, a_bPS3Switch:Boolean)
	{
		super.SetPlatform(a_platform,a_bPS3Switch);
		
		_platform = a_platform;
		_bShowEquipButtonHelp = a_platform != 0;
		updateButtons();
	}

}