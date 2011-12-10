import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;
import skyui.Config;
import gfx.io.GameDelegate;

class skyui.InventoryItemList extends skyui.ConfigurableList
{
	private var _itemInfo:Object;

	function InvalidateData()
	{
		for (var i = 0; i < _entryList.length; i++) {
			requestItemInfo(i);

			switch (_itemInfo.type) {
				case InventoryDefines.ICT_ARMOR :
					_entryList[i].infoArmor = _itemInfo.armor;
					break;
				case InventoryDefines.ICT_WEAPON :
					_entryList[i].infoDamage = _itemInfo.damage;
					break;
				case InventoryDefines.ICT_SPELL :
				case InventoryDefines.ICT_SHOUT :
					_entryList[i].infoSpellCost = _itemInfo.spellCost.toString();
					break;
				case InventoryDefines.ICT_SOUL_GEMS :
					_entryList[i].infoSoulLVL = _itemInfo.soulLVL;
					break;
			}

			_entryList[i].infoValue = Math.round(_itemInfo.value);
			_entryList[i].infoWeight = int(_itemInfo.weight * 100) / 100;
			_entryList[i].infoType = _itemInfo.type;
			_entryList[i].infoPotionType = _itemInfo.potionType;
			_entryList[i].infoWeightValue = _itemInfo.weight != 0 ?  Math.round(_itemInfo.value / _itemInfo.weight) : 0;
		}

		super.InvalidateData();
	}

	function updateItemInfo(a_updateObj:Object)
	{
		_itemInfo = a_updateObj;
	}

	function requestItemInfo(a_index:Number)
	{
		var oldIndex = _selectedIndex;
		_selectedIndex = a_index;
		GameDelegate.call("RequestItemCardInfo",[],this,"updateItemInfo");
		_selectedIndex = oldIndex;
	}

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		var columns = currentView.columns;
		
		var states = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

		for (var i=0; i<columns.length; i++) {
			var e = a_entryClip[_columnNames[i]];
			
			// Substitute @variables by entryObject properties
			if (_columnEntryValues[i] != undefined) {
				if (_columnEntryValues[i].charAt(0) == "@") {
					e.SetText(a_entryObject[_columnEntryValues[i].slice(1)]);
				}
			}
			
			// Process based on column type
			switch (columns[i].type) {
				// Equip Icon
				case Config.COL_TYPE_EQUIP_ICON:
					if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
						e.gotoAndStop(states[a_entryObject.equipState]);
					} else {
						e.gotoAndStop("None");
					}
					break;

				// Item Icon
				case Config.COL_TYPE_ITEM_ICON:
					if (a_entryObject.extended == undefined) {
			
						// Default without script extender
						switch (a_entryObject.infoType) {
							case InventoryDefines.ICT_WEAPON :
								e.gotoAndStop("category_weapons");
								break;
							case InventoryDefines.ICT_ARMOR :
								e.gotoAndStop("category_armor");
								break;
							case InventoryDefines.ICT_POTION :
								e.gotoAndStop("category_potions");
								break;
							case InventoryDefines.ICT_SPELL :
								e.gotoAndStop("category_scrolls");
								break;
							case InventoryDefines.ICT_FOOD :
								e.gotoAndStop("category_food");
								break;
							case InventoryDefines.ICT_INGREDIENT :
								e.gotoAndStop("category_ingredients");
								break;
							case InventoryDefines.ICT_BOOK :
								e.gotoAndStop("category_books");
								break;
							case InventoryDefines.ICT_KEY :
								e.gotoAndStop("category_keys");
								break;
							default :
								e.gotoAndStop("category_misc");
						}
					} else {
						
						// With plugin-extended attributes
						switch (a_entryObject.infoType) {
							case InventoryDefines.ICT_WEAPON :
								if (a_entryObject.formType == Defines.FORMTYPE_ARROW) {
									e.gotoAndStop("type_arrow");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_DAGGER) {
									e.gotoAndStop("weapon_dagger");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_BOW) {
									e.gotoAndStop("weapon_bow");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_GREATSWORD) {
									e.gotoAndStop("weapon_greatsword");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_WARAXE) {
									e.gotoAndStop("weapon_waraxe");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_MACE) {
									e.gotoAndStop("weapon_mace");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_LONGSWORD) {
									e.gotoAndStop("weapon_sword");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_HAMMER) {
									e.gotoAndStop("weapon_hammer");
									break;
								} else if (a_entryObject.weaponType == Defines.WEAPON_TYPE_STAFF) {
									e.gotoAndStop("weapon_staff");
									break;
								}
								e.gotoAndStop("default_weapons");
								break;
							case InventoryDefines.ICT_ARMOR :
								e.gotoAndStop("default_armor");
								break;
							case InventoryDefines.ICT_POTION :
								e.gotoAndStop("default_potions");
								break;
							case InventoryDefines.ICT_SPELL :
								e.gotoAndStop("default_scrolls");
								break;
							case InventoryDefines.ICT_FOOD :
								e.gotoAndStop("default_food");
								break;
							case InventoryDefines.ICT_INGREDIENT :
								e.gotoAndStop("default_ingredients");
								break;
							case InventoryDefines.ICT_BOOK :
								e.gotoAndStop("default_books");
								break;
							case InventoryDefines.ICT_KEY :
								e.gotoAndStop("default_keys");
								break;
							default :
								if (a_entryObject.weaponType == Defines.FORMTYPE_SOULGEM) 
									e.gotoAndStop("misc_soulgem");
								else
									e.gotoAndStop("default_misc");
								
						}
					}
					break;
					
				// Name
				case Config.COL_TYPE_NAME:
					if (a_entryObject.text != undefined) {
			
						// Text
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
			
						e.autoSize = "left";
						e.textAutoSize = "shrink";
//						e.SetText(text,true);
						e.SetText(text);
			
						if (a_entryObject.negativeEffect == true || a_entryObject.isStealing == true) {
							e.textColor = a_entryObject.enabled == false ? (8388608) : (16711680);
						} else {
							e.textColor = a_entryObject.enabled == false ? (5000268) : (16777215);
						}
						
						// BestInClass icon
						var iconPos = e._x + e._width + 5;
				
						if (a_entryObject.bestInClass == true) {
							a_entryClip.bestIcon._x = iconPos;
							iconPos = iconPos + 10;
				
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
		
					} else {
						e.SetText(" ");
					}
					
					break;
					
				// Rest
				case Config.COL_TYPE_NUMBER:
				case Config.COL_TYPE_TEXT:
				default:
					// Do nothing. Those require no special formating and the value has already been set
			}
		}
	}
}