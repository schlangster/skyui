import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;
import gfx.io.GameDelegate;

class skyui.InventoryItemList extends skyui.FilteredList
{
	private var _statType:Number;
	private var _itemInfo:Object;

	function InvalidateData()
	{
		for (var i = 0; i < _entryList.length; i++) {
			requestItemInfo(i);

			switch (_itemInfo.type) {
				case InventoryDefines.ICT_ARMOR :
					_entryList[i]._infoStat = _itemInfo.armor;
					break;
				case InventoryDefines.ICT_WEAPON :
					_entryList[i]._infoStat = _itemInfo.damage;
					break;
				case InventoryDefines.ICT_SPELL :
				case InventoryDefines.ICT_SHOUT :
					_entryList[i]._infoStat = _itemInfo.spellCost.toString();
					break;
				case InventoryDefines.ICT_SOUL_GEMS :
					_entryList[i]._infoStat = _itemInfo.soulLVL;
					break;
				default :
					_entryList[i]._infoStat = 0;
			}

			_entryList[i]._infoValue = _itemInfo.value;
			_entryList[i]._infoWeight = _itemInfo.weight;
			_entryList[i]._infoType = _itemInfo.type;
			_entryList[i]._potionType = _itemInfo.potionType;
		}

		super.InvalidateData();
	}

	function updateItemInfo(a_updateObj:Object)
	{
		this._itemInfo = a_updateObj;
	}

	function requestItemInfo(a_index:Number)
	{
		var oldIndex = _selectedIndex;
		_selectedIndex = a_index;
		GameDelegate.call("RequestItemCardInfo",[],this,"updateItemInfo");
		_selectedIndex = oldIndex;
	}

	function set statType(a_type:Number)
	{
		_statType = a_type;
	}

	function get statType():Number
	{
		return _statType;
	}

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		var states = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

		if (a_entryObject.text != undefined) {

			// Value, Weight, Stat
			a_entryClip.weightField.SetText(int(a_entryObject._infoWeight * 100) / 100);
			a_entryClip.valueField.SetText(Math.round(a_entryObject._infoValue));

			if (a_entryObject._infoStat != undefined && (_statType == Defines.FLAG_ARMOR || _statType == Defines.FLAG_DAMAGE)) {
				a_entryClip.statField.SetText(Math.round(a_entryObject._infoStat));
			} else {
				a_entryClip.statField.SetText(" ");
			}

			// Text
			var text = a_entryObject.text; // + " " + a_entryObject.formType + " " + a_entryObject.weaponType;
			if (a_entryObject.soulLVL != undefined) {
				text = text + " (" + a_entryObject.soulLVL + ")";
			}

			if (a_entryObject.count > 1) {
				text = text + " (" + a_entryObject.count.toString() + ")";
			}

			if (text.length > _maxTextLength) {
				text = text.substr(0, _maxTextLength - 3) + "...";
			}

			a_entryClip.textField.autoSize = "left";
			a_entryClip.textField.textAutoSize = "shrink";
			a_entryClip.textField.SetText(text,true);

			if (a_entryObject.negativeEffect == true || a_entryObject.isStealing == true) {
				a_entryClip.textField.textColor = a_entryObject.enabled == false ? (8388608) : (16711680);
			} else {
				a_entryClip.textField.textColor = a_entryObject.enabled == false ? (5000268) : (16777215);
			}

		} else {
			a_entryClip.textField.SetText(" ");
		}

		// Equip Icon
		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryClip.EquipIcon.gotoAndStop(states[a_entryObject.equipState]);
		} else {
			a_entryClip.EquipIcon.gotoAndStop("None");
		}

		// BestInClass icon
		var iconPos = a_entryClip.textField._x + a_entryClip.textField._width + 5;

		if (a_entryObject.bestInClass == true) {
			a_entryClip.bestIcon._x = iconPos;
			iconPos = iconPos + a_entryClip.bestIcon._width + 5;

			a_entryClip.bestIcon.gotoAndStop("show");
		} else {
			a_entryClip.bestIcon.gotoAndStop("hide");
		}

		// Fav icon
		if (a_entryObject.favorite == true) {
			a_entryClip.favoriteIcon._x = iconPos;
			a_entryClip.favoriteIcon.gotoAndStop("show");
		} else {
			a_entryClip.favoriteIcon.gotoAndStop("hide");
		}

		// Iventory icon

		if (a_entryObject.extended == undefined) {

			// Default without script extender
			switch (a_entryObject._infoType) {
				case InventoryDefines.ICT_WEAPON :
					a_entryClip.typeIcon.gotoAndStop("category_weapons");
					break;
				case InventoryDefines.ICT_ARMOR :
					a_entryClip.typeIcon.gotoAndStop("category_armor");
					break;
				case InventoryDefines.ICT_POTION :
					a_entryClip.typeIcon.gotoAndStop("category_potions");
					break;
				case InventoryDefines.ICT_SPELL :
					a_entryClip.typeIcon.gotoAndStop("category_scrolls");
					break;
				case InventoryDefines.ICT_FOOD :
					a_entryClip.typeIcon.gotoAndStop("category_food");
					break;
				case InventoryDefines.ICT_INGREDIENT :
					a_entryClip.typeIcon.gotoAndStop("category_ingredients");
					break;
				case InventoryDefines.ICT_BOOK :
					a_entryClip.typeIcon.gotoAndStop("category_books");
					break;
				case InventoryDefines.ICT_KEY :
					a_entryClip.typeIcon.gotoAndStop("category_keys");
					break;
				default :
					a_entryClip.typeIcon.gotoAndStop("category_misc");
			}
		} else {
			
			// With plugin-extended attributes
			switch (a_entryObject._infoType) {
				case InventoryDefines.ICT_WEAPON :
					if (a_entryObject.formType == Defines.FORMTYPE_ARROW) {
						a_entryClip.typeIcon.gotoAndStop("type_arrow");
						break;
					} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_DAGGER) {
						a_entryClip.typeIcon.gotoAndStop("weapon_dagger");
						break;
					} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_BOW) {
						a_entryClip.typeIcon.gotoAndStop("weapon_bow");
						break;
					} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_GREATSWORD) {
						a_entryClip.typeIcon.gotoAndStop("weapon_greatsword");
						break;
					} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_WARAXE) {
						a_entryClip.typeIcon.gotoAndStop("weapon_waraxe");
						break;
					}
				
					a_entryClip.typeIcon.gotoAndStop("category_weapons");
					break;
				case InventoryDefines.ICT_ARMOR :
					a_entryClip.typeIcon.gotoAndStop("category_armor");
					break;
				case InventoryDefines.ICT_POTION :
					a_entryClip.typeIcon.gotoAndStop("category_potions");
					break;
				case InventoryDefines.ICT_SPELL :
					a_entryClip.typeIcon.gotoAndStop("category_scrolls");
					break;
				case InventoryDefines.ICT_FOOD :
					a_entryClip.typeIcon.gotoAndStop("category_food");
					break;
				case InventoryDefines.ICT_INGREDIENT :
					a_entryClip.typeIcon.gotoAndStop("category_ingredients");
					break;
				case InventoryDefines.ICT_BOOK :
					a_entryClip.typeIcon.gotoAndStop("category_books");
					break;
				case InventoryDefines.ICT_KEY :
					a_entryClip.typeIcon.gotoAndStop("category_keys");
					break;
				default :
					a_entryClip.typeIcon.gotoAndStop("category_misc");
			}
		}
	}
}