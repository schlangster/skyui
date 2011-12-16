import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;
import skyui.Config;
import gfx.io.GameDelegate;

class skyui.MagicItemList extends skyui.ConfigurableList
{
	private var _itemInfo:Object;
	
	// override onConfigLoad to use config.MagicItemList
	function onConfigLoad(event)
	{
		_config = event.config;
		_views = _config.MagicItemList.views;
		_entryWidth = _config.MagicItemList.entry.width;

		// Create default formats
		for (var prop in _config.MagicItemList.entry.format) {
			if (_defaultEntryFormat.hasOwnProperty(prop)) {
				_defaultEntryFormat[prop] = _config.MagicItemList.entry.format[prop];
			}
		}
		for (var prop in _config.MagicItemList.label.format) {
			if (_defaultLabelFormat.hasOwnProperty(prop)) {
				_defaultLabelFormat[prop] = _config.MagicItemList.label.format[prop];
			}
		}
		updateView();
	}	
	
	function InvalidateData()
	{
		for (var i = 0; i < _entryList.length; i++) {
			requestItemInfo(i);
			switch (_itemInfo.type) {
				case InventoryDefines.ICT_SPELL_DEFAULT :
					_entryList[i].infoSpellCost = "-";
					_entryList[i].infoCastTime = "-";
					_entryList[i].infoType = _itemInfo["type"];
					break;
				case InventoryDefines.ICT_SPELL :
					_entryList[i].infoSpellCost = _itemInfo["spellCost"];
					_entryList[i].infoType = Defines.MAGIC_TYPES.indexOf(_itemInfo["magicSchoolName"]);
					_entryList[i].infoCastTime = _itemInfo["castTime"];
					/* not used
					//_entryList[i].infoCastLevel = _itemInfo["castLevel"];
					//_entryList[i].infoSchoolLevel = _itemInfo["magicSchoolLevel"];
					//_entryList[i].infoSchoolPercent = _itemInfo["magicSchoolPct"];
					*/
					break;
				case InventoryDefines.ICT_SHOUT :
					_entryList[i].infoSpellCost = _itemInfo["spellCost"];
					_entryList[i].infoCastTime = "-";
					_entryList[i].infoUnlocked = _itemInfo["unlocked0"];
					_entryList[i].infoType = _itemInfo["type"];
					_entryList[i].infoShoutType = Defines.SHOUT_TYPES.indexOf(_itemInfo["word0"]);
					break;
				case InventoryDefines.ICT_ACTIVE_EFFECT :
					_entryList[i].infoSpellCost = "-";
					_entryList[i].infoCastTime = "-";
					_entryList[i].infoType = _itemInfo["type"];
					_entryList[i].infoTimeRemaining = _itemInfo["timeRemaining"];
					_entryList[i].infoNegativeEffect = _itemInfo["negativeEffect"];
					_entryList[i].infoItem = _itemInfo["name"];
			}
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
					  switch (a_entryObject.infoType) {
							case Defines.MAGIC_ALTERATION :
								e.gotoAndStop("category_alteration");
								break;
							case Defines.MAGIC_ILLUSION :
								e.gotoAndStop("category_illusion");
								break;
							case Defines.MAGIC_DESTRUCTION :
								e.gotoAndStop("category_destruction");
								break;								
							case Defines.MAGIC_CONJURATION :
								e.gotoAndStop("category_conjuration");
								break;
							case Defines.MAGIC_RESTORATION :
								e.gotoAndStop("category_restoration");
								break;
							case InventoryDefines.ICT_SHOUT :
								e.gotoAndStop("category_shouts");
								break;
							case InventoryDefines.ICT_ACTIVE_EFFECT :
								e.gotoAndStop("category_activeeffects");
								break;
							case InventoryDefines.ICT_SPELL_DEFAULT : // Powers
								e.gotoAndStop("category_powers");
								break;
							default :
								e.gotoAndStop("category_misc");
								break;
						} // end switch
					} // end if
					else {		
						// Default without script extender
						// unused for now
					}
					
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