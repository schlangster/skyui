import flash.geom.ColorTransform;

import skyui.components.list.TabularEntryFormatter;
import skyui.components.list.TabularList;
import skyui.util.Defines;
import skyui.util.ConfigManager;


class InventoryEntryFormatter extends TabularEntryFormatter
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
		if (a_length > 3)
			_maxTextLength = a_length;
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
	
  	// @override TabularEntryFormatter
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
		
		if (_config.ItemList.entry.icon.showStolen != undefined)
			_bShowStolenIcon = _config.ItemList.entry.icon.showStolen;
		
		// Enabled entry
		if (_config.ItemList.entry.color.enabled.text != undefined)
			_defaultEnabledColor = _config.ItemList.entry.color.enabled.text;
		if (_config.ItemList.entry.color.enabled.negative != undefined)
			_negativeEnabledColor = _config.ItemList.entry.color.enabled.negative;
		if (_config.ItemList.entry.color.enabled.stolen != undefined)
			_stolenEnabledColor = _config.ItemList.entry.color.enabled.stolen;
		
		// Disabled entry
		if (_config.ItemList.entry.color.disabled.text != undefined)
			_defaultDisabledColor = _config.ItemList.entry.color.disabled.text;
		if (_config.ItemList.entry.color.disabled.negative != undefined)
			_negativeDisabledColor = _config.ItemList.entry.color.disabled.negative;
		if (_config.ItemList.entry.color.disabled.stolen != undefined)
			_stolenDisabledColor = _config.ItemList.entry.color.disabled.stolen;
	}

  	// @override TabularEntryFormatter
	public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryField.gotoAndStop(STATES[a_entryObject.equipState]);
		} else {
			a_entryField.gotoAndStop("None");
		}
	}

  	// @override TabularEntryFormatter
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip)
	{
		var iconLabel = a_entryObject["iconLabel"] != undefined ? a_entryObject["iconLabel"] : "default_misc";
		
		// The icon clip is loaded at runtime from a seperate .swf. So two scenarios are possible:
		// 1. The clip has been loaded, gotoAndStop will set it to the new label
		// 2. Loading is not done yet, so gotoAndStop will fail. In this case, the loaded clip will fetch the current label from
		//    the its parent (entryclip.iconLabel) as soon as it's done.  Same for the iconColor.
		a_entryClip.iconLabel = iconLabel;
		a_entryField.gotoAndStop(iconLabel);
		
		if (a_entryObject["iconColor"] != undefined) {
			var iconColor: Number = Number(a_entryObject["iconColor"]);
			changeIconColor(MovieClip(a_entryField), iconColor);
			a_entryClip.iconColor = iconColor;
			
		} else {
			resetIconColor(MovieClip(a_entryField));
			a_entryClip.iconColor = undefined;
		}
	}

  	// @override TabularEntryFormatter
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
	
  	// @override TabularEntryFormatter
	public function formatText(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		formatColor(a_entryField, a_entryObject);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function formatColor(a_entryField: Object, a_entryObject: Object): Void
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
	
	private function changeIconColor(a_icon: MovieClip, a_rgb: Number)
	{
		for (var e in a_icon) {
			if (a_icon[e] instanceof MovieClip) {
					//Note: Could check if all values of RGBA mult and .rgb are all the same then skip
					var colorTrans = new ColorTransform();
					colorTrans.rgb = a_rgb;
					a_icon[e].transform.colorTransform = colorTrans;
					// Shouldn't be necessary to recurse since we don't expect multiple clip depths for an icon
					//changeIconColor(a_icon[e], a_rgb);
			}
		}
	}

	private function resetIconColor(a_icon: MovieClip)
	{
		for (var e in a_icon) {
			if (a_icon[e] instanceof MovieClip) {
					a_icon[e].transform.colorTransform = new ColorTransform();
					// Shouldn't be necessary to recurse since we don't expect multiple clip depths for an icon
					//resetIconColor(a_icon[e]);
			}
		}
	}
}