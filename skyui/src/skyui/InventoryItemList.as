import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.InventoryItemList extends skyui.FilteredList
{
	private var _statType:Number;

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
		}

		super.InvalidateData();
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
		super.setEntryText(a_entryClip,a_entryObject);

		if (a_entryObject.text != undefined) {
			a_entryClip.textField.SetText(a_entryObject.text);
			a_entryClip.weightField.SetText(int(a_entryObject._infoWeight * 100) / 100);
			a_entryClip.valueField.SetText(Math.round(a_entryObject._infoValue));

			if (a_entryObject._infoStat != undefined && (_statType == Defines.FLAG_ARMOR || _statType == Defines.FLAG_DAMAGE)) {
				a_entryClip.statField.SetText(Math.round(a_entryObject._infoStat));
			} else {
				a_entryClip.statField.SetText(" ");
			}
		} else {
			a_entryClip.textField.SetText(" ");
		}

		var states = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

		if (a_entryObject.text != undefined) {
			var text = a_entryObject.text;
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
		}

		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryClip.EquipIcon.gotoAndStop(states[a_entryObject.equipState]);
		} else {
			a_entryClip.EquipIcon.gotoAndStop("None");
		}

		var iconPos = a_entryClip.textField._x + a_entryClip.textField._width + 5;

		if (a_entryObject.bestInClass == true) {
			a_entryClip.bestIcon._x = iconPos;
			iconPos = iconPos + a_entryClip.bestIcon._width + 5;

			a_entryClip.bestIcon.gotoAndStop("show");
		} else {
			a_entryClip.bestIcon.gotoAndStop("hide");
		}

		if (a_entryObject.favorite == true) {
			a_entryClip.favoriteIcon._x = iconPos;
			a_entryClip.favoriteIcon.gotoAndStop("show");
		} else {
			a_entryClip.favoriteIcon.gotoAndStop("hide");
		}

		switch (a_entryObject._infoType) {
			case InventoryDefines.ICT_WEAPON :
				a_entryClip.typeIcon.gotoAndStop("weapon");
				break;
			case InventoryDefines.ICT_ARMOR :
				a_entryClip.typeIcon.gotoAndStop("armor");
				break;
			case InventoryDefines.ICT_POTION :
				a_entryClip.typeIcon.gotoAndStop("potion");
				break;
			case InventoryDefines.ICT_SPELL :
				a_entryClip.typeIcon.gotoAndStop("scroll");
				break;
			case InventoryDefines.ICT_FOOD :
				a_entryClip.typeIcon.gotoAndStop("food");
				break;
			case InventoryDefines.ICT_INGREDIENT :
				a_entryClip.typeIcon.gotoAndStop("ingredient");
				break;
			case InventoryDefines.ICT_BOOK :
				a_entryClip.typeIcon.gotoAndStop("book");
				break;
			case InventoryDefines.ICT_KEY :
				a_entryClip.typeIcon.gotoAndStop("key");
				break;
			default :
				a_entryClip.typeIcon.gotoAndStop("misc");
		}
	}
}