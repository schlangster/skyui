import gfx.events.EventDispatcher;
import dui.ItemSortingFilter;

class dui.SortedInventoryItemList extends dui.FilteredList
{
	private var _maxTextLength:Number;
	private var _sortFilter:ItemSortingFilter;
	private var _bAscending;
	private var _lastSortBy;
	
	// Children
	var header:MovieClip;

	function InventoryItemList()
	{
		super();		
		_indent = header._y + header._height;
		
		_sortFilter = new ItemSortingFilter();
		addFilter(_sortFilter);
		
		_bAscending = true;
		_lastSortBy = 0;
	}
	
	function onLoad()
	{
		super.onLoad();
		
		_sortFilter.addEventListener("filterChange",this,"onFilterChange");
		
		header.buttons.textButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput) {
				_parent._parent._parent.onSortToggle(ItemSortingFilter.SORT_BY_NAME);
				_parent._parent._bMouseDrivenNav = true;
			}
		};
		
		header.buttons.valueButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput) {
				_parent._parent._parent.onSortToggle(ItemSortingFilter.SORT_BY_VALUE);
				_parent._parent._bMouseDrivenNav = true;
			}
		};
		
		header.buttons.weightButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput) {
				_parent._parent._parent.onSortToggle(ItemSortingFilter.SORT_BY_WEIGHT);
				_parent._parent._bMouseDrivenNav = true;
			}
		};
		
		header.buttons.statButtonArea.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (!_parent._parent.listAnimating && !_parent._parent._bDisableInput) {
				_parent._parent._parent.onSortToggle(ItemSortingFilter.SORT_BY_STAT);
				_parent._parent._bMouseDrivenNav = true;
			}
		};
	}
	
	function onSortToggle(a_sortBy:Number)
	{
		debug.textField.SetText("received sort by " + a_sortBy);
		
		if (_lastSortBy == a_sortBy) {
			_bAscending = !_bAscending
		} else if (a_sortBy == ItemSortingFilter.SORT_BY_NAME) {
			_bAscending = true;
		} else {
			_bAscending = false;
		}
		_lastSortBy = a_sortBy;

		var pos = 5;

		switch (a_sortBy) {
			case ItemSortingFilter.SORT_BY_STAT:
				pos = pos + header.buttons.statButtonArea._x + header.buttons.statButtonArea._width;
				break;
			case ItemSortingFilter.SORT_BY_VALUE:
				pos = pos + header.buttons.valueButtonArea._x + header.buttons.valueButtonArea._width;			
				break;
			case ItemSortingFilter.SORT_BY_WEIGHT:
				pos = pos + header.buttons.weightButtonArea._x + header.buttons.weightButtonArea._width;
				break;
			default:
				pos = pos + header.buttons.textButtonArea._x + header.buttons.textButtonArea._width;
		}
		
		header.sortIcon._x = pos;
		header.sortIcon.gotoAndStop(_bAscending? "asc" : "desc");
		_sortFilter.setSortBy(a_sortBy, _bAscending);
	}
	
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

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		super.setEntryText(a_entryClip, a_entryObject);
		
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