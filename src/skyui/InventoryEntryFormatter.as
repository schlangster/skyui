import skyui.components.list.TabularEntryFormatter;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.util.Defines;
import skyui.util.ConfigManager;


class skyui.InventoryEntryFormatter extends TabularEntryFormatter
{
  /* CONSTANTS */
  
	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];


  /* PRIVATE VARIABLES */
	
	private var _bShowStolenIcon: Boolean;

	private var _defaultEnabledColor;
	private var _defaultDisabledColor;
	private var _negativeEnabledColor;
	private var _negativeDisabledColor;
	private var _stolenEnabledColor;
	private var _stolenDisabledColor;

	private var _config: Object;
	
	
  /* PROPERTIES */
	
	private var _maxTextLength: Number;

	public function set maxTextLength(a_length:Number)
	{
		if (a_length > 3) {
			_maxTextLength = a_length;
		}
	}

	public function get maxTextLength():Number
	{
		return _maxTextLength;
	}


  /* CONSTRUCTORS */
	
	public function InventoryEntryFormatter(a_list: TabularList)
	{
		super(a_list);
		
		_maxTextLength = 50;
		_bShowStolenIcon = true;
		_defaultEnabledColor = 0xffffff;
		_defaultDisabledColor = 0x4c4c4c;
		
		_negativeEnabledColor = 0xff0000;
		_negativeDisabledColor = 0x800000;
		
		_stolenEnabledColor = 0xffffff;
		_stolenDisabledColor = 0x4c4c4c;

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override skyui.LayoutEntryFormatter
	public function setSpecificEntryLayout(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		var iconY = _list.layout.entryHeight * 0.25;
		var iconSize = _list.layout.entryHeight * 0.5;
			
		a_entryClip.bestIcon._height = a_entryClip.bestIcon._width = iconSize;
		a_entryClip.favoriteIcon._height = a_entryClip.favoriteIcon._width = iconSize;
		a_entryClip.poisonIcon._height = a_entryClip.poisonIcon._width = iconSize;
		a_entryClip.stolenIcon._height = a_entryClip.stolenIcon._width = iconSize;
		a_entryClip.enchIcon._height = a_entryClip.enchIcon._width = iconSize;
			
		a_entryClip.bestIcon._y = iconY;
		a_entryClip.favIcon._y = iconY;
		a_entryClip.poisonIcon._y = iconY;
		a_entryClip.stolenIcon._y = iconY;
		a_entryClip.enchIcon._y = iconY;
	}

	public function onConfigLoad(event)
	{
		_config = event.config;
		
		if (_config.ItemList.entry.icon.showStolen != undefined) {
			_bShowStolenIcon = _config.ItemList.entry.icon.showStolen;
		}
		
		// Enabled entry
		if (_config.ItemList.entry.color.enabled.text != undefined) {
			_defaultEnabledColor = _config.ItemList.entry.color.enabled.text;
		}
		if (_config.ItemList.entry.color.enabled.negative != undefined) {
			_negativeEnabledColor = _config.ItemList.entry.color.enabled.negative;
		}
		if (_config.ItemList.entry.color.enabled.stolen != undefined) {
			_stolenEnabledColor = _config.ItemList.entry.color.enabled.stolen;
		}
		
		// Disabled entry
		if (_config.ItemList.entry.color.disabled.text != undefined) {
			_defaultDisabledColor = _config.ItemList.entry.color.disabled.text;
		}
		if (_config.ItemList.entry.color.disabled.negative != undefined) {
			_negativeDisabledColor = _config.ItemList.entry.color.disabled.negative;
		}
		if (_config.ItemList.entry.color.disabled.stolen != undefined) {
			_stolenDisabledColor = _config.ItemList.entry.color.disabled.stolen;
		}
	}

  	// @override skyui.LayoutEntryFormatter
	public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryField.gotoAndStop(STATES[a_entryObject.equipState]);
		} else {
			a_entryField.gotoAndStop("None");
		}
	}

  	// @override skyui.LayoutEntryFormatter
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		var iconLabel: String;
		
		switch (a_entryObject.infoType) {
			case InventoryDefines.ICT_WEAPON :
				if (a_entryObject.formType == Defines.FORMTYPE_ARROW) {
					iconLabel = "weapon_arrow";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_DAGGER) {
					iconLabel = "weapon_dagger";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_BOW) {
					iconLabel = "weapon_bow";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_GREATSWORD) {
					iconLabel = "weapon_greatsword";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_WARAXE) {
					iconLabel = "weapon_waraxe";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_MACE) {
					iconLabel = "weapon_mace";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_LONGSWORD) {
					iconLabel = "weapon_sword";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_HAMMER) {
					iconLabel = "weapon_hammer";
					break;
				} else if (a_entryObject.subType == Defines.WEAPON_TYPE_STAFF) {
					iconLabel = "weapon_staff";
					break;
				}

				iconLabel = "default_weapon";
				break;
			case InventoryDefines.ICT_ARMOR :
				iconLabel = "default_armor";
				break;
			case InventoryDefines.ICT_POTION :
				iconLabel = "default_potion";
				break;
			case InventoryDefines.ICT_SPELL :
				iconLabel = "default_scroll";
				break;
			case InventoryDefines.ICT_FOOD :
				iconLabel = "default_food";
				break;
			case InventoryDefines.ICT_INGREDIENT :
				iconLabel = "default_ingredient";
				break;
			case InventoryDefines.ICT_BOOK :
				iconLabel = "default_book";
				break;
			case InventoryDefines.ICT_KEY :
				iconLabel = "default_key";
				break;
			case InventoryDefines.ICT_MISC :
			default :
				if (a_entryObject.formType == Defines.FORMTYPE_SOULGEM) {
					iconLabel = "misc_soulgem";
				} else {
					iconLabel = "default_misc";
				}
		}
		
		// The icon clip is loaded at runtime from a seperate .swf. So two scenarios are possible:
		// 1. The clip has been loaded, gotoAndStop will set it to the new label
		// 2. Loading is not done yet, so gotoAndStop will fail. In this case, the loaded clip will fetch the current label from
		//    the its parent (entryclip.iconLabel) as soon as it's done.
		a_entryClip.iconLabel = iconLabel;
		a_entryField.gotoAndStop(iconLabel);
	}

  	// @override skyui.LayoutEntryFormatter
	public function formatName(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		if (a_entryObject.text == undefined) {
			a_entryField.SetText(" ");
			return;
		}

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

		a_entryField.autoSize = "left";
		a_entryField.SetText(text);
		
		formatColor(a_entryField, a_entryObject);

		// BestInClass icon
		var iconPos = a_entryField._x + a_entryField._width + 5;

		// All icons have the same size
		var iconSpace = a_entryClip.bestIcon._width * 1.25;

		if (a_entryObject.bestInClass == true) {
			a_entryClip.bestIcon._x = iconPos;
			iconPos = iconPos + iconSpace;

			a_entryClip.bestIcon.gotoAndStop("show");
		} else {
			a_entryClip.bestIcon.gotoAndStop("hide");
		}

		// Fav icon
		if (a_entryObject.favorite == true) {
			a_entryClip.favoriteIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			a_entryClip.favoriteIcon.gotoAndStop("show");
		} else {
			a_entryClip.favoriteIcon.gotoAndStop("hide");
		}

		// Poisoned Icon
		if (a_entryObject.infoIsPoisoned == true) {
			a_entryClip.poisonIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			a_entryClip.poisonIcon.gotoAndStop("show");
		} else {
			a_entryClip.poisonIcon.gotoAndStop("hide");
		}

		// Stolen Icon
		if ((a_entryObject.infoIsStolen == true || a_entryObject.isStealing) && _bShowStolenIcon != false) {
			a_entryClip.stolenIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			a_entryClip.stolenIcon.gotoAndStop("show");
		} else {
			a_entryClip.stolenIcon.gotoAndStop("hide");
		}

		// Enchanted Icon
		if (a_entryObject.infoIsEnchanted == true) {
			a_entryClip.enchIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			a_entryClip.enchIcon.gotoAndStop("show");
		} else {
			a_entryClip.enchIcon.gotoAndStop("hide");
		}
	}
	
  	// @override skyui.LayoutEntryFormatter
	public function formatText(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		formatColor(a_entryField, a_entryObject);
	}
	
	public function formatColor(a_entryField: Object, a_entryObject: Object): Void
	{
		// Negative Effect
		if (a_entryObject.negativeEffect == true)
			a_entryField.textColor = a_entryObject.enabled == false ? _negativeDisabledColor : _negativeEnabledColor;
			
		// Stolen
		else if (a_entryObject.infoIsStolen == true || a_entryObject.isStealing == true)
			a_entryField.textColor = a_entryObject.enabled == false ? _stolenDisabledColor : _stolenEnabledColor;
			
		// Default
		else
			a_entryField.textColor = a_entryObject.enabled == false ? _defaultDisabledColor : _defaultEnabledColor;
	}
}