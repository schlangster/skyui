import flash.geom.ColorTransform;
import flash.geom.Transform;

import skyui.components.list.TabularList;
import skyui.components.list.TabularListEntry;
import skyui.components.list.ListState;
import skyui.util.ConfigManager;


class InventoryListEntry extends TabularListEntry
{
  /* CONSTANTS */
  
	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];

  /* PRIVATE VARIABLES */
	
	private var _iconLabel: String;
	private var _iconColor: Number;
	
  /* STAGE ELMENTS */
  
  	public var itemIcon: MovieClip;
  	public var equipIcon: MovieClip;
	
	public var bestIcon: MovieClip;
	public var favoriteIcon: MovieClip;
	public var poisonIcon: MovieClip;
	public var stolenIcon: MovieClip;
	public var enchIcon: MovieClip;
	public var readIcon: MovieClip;
	
	
  /* INITIALIZATION */
	
  	// @override TabularListEntry
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		super.initialize();
		
		var iconLoader = new MovieClipLoader();
		iconLoader.addListener(this);
		iconLoader.loadClip(a_state.iconSource, itemIcon);
		
		itemIcon._visible = false;
		equipIcon._visible = false;
		
		for (var i = 0; this["textField" + i] != undefined; i++)
			this["textField" + i]._visible = false;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override TabularListEntry
	public function setSpecificEntryLayout(a_entryObject: Object, a_state: ListState): Void
	{
		var iconY = TabularList(a_state.list).layout.entryHeight * 0.25;
		var iconSize = TabularList(a_state.list).layout.entryHeight * 0.5;
			
		bestIcon._height = bestIcon._width = iconSize;
		favoriteIcon._height = favoriteIcon._width = iconSize;
		poisonIcon._height = poisonIcon._width = iconSize;
		stolenIcon._height = stolenIcon._width = iconSize;
		enchIcon._height = enchIcon._width = iconSize;
		readIcon._height = readIcon._width = iconSize;
			
		bestIcon._y = iconY;
		favoriteIcon._y = iconY;
		poisonIcon._y = iconY;
		stolenIcon._y = iconY;
		enchIcon._y = iconY;
		readIcon._y = iconY;
	}

  	// @override TabularListEntry
	public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void
	{
		if (a_entryObject != undefined && a_entryObject.equipState != undefined) {
			a_entryField.gotoAndStop(STATES[a_entryObject.equipState]);
		} else {
			a_entryField.gotoAndStop("None");
		}
	}

  	// @override TabularListEntry
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState)
	{
		_iconLabel = a_entryObject["iconLabel"] != undefined ? a_entryObject["iconLabel"] : "default_misc";
		_iconColor = a_entryObject["iconColor"];

		// Could return here if _iconLoaded is false
		a_entryField.gotoAndStop(_iconLabel);
		changeIconColor(MovieClip(a_entryField), _iconColor);
	}

  	// @override TabularListEntry
	public function formatName(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void
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

		if (text.length > a_state.maxTextLength) {
			text = text.substr(0, a_state.maxTextLength - 3) + "...";
		}

		a_entryField.autoSize = "left";
		a_entryField.SetText(text);
		
		formatColor(a_entryField, a_entryObject, a_state);

		// BestInClass icon
		var iconPos = a_entryField._x + a_entryField._width + 5;

		// All icons have the same size
		var iconSpace = bestIcon._width * 1.25;

		if (a_entryObject.bestInClass == true) {
			bestIcon._x = iconPos;
			iconPos = iconPos + iconSpace;

			bestIcon.gotoAndStop("show");
		} else {
			bestIcon.gotoAndStop("hide");
		}

		// Fav icon
		if (a_entryObject.favorite == true) {
			favoriteIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			favoriteIcon.gotoAndStop("show");
		} else {
			favoriteIcon.gotoAndStop("hide");
		}

		// Poisoned Icon
		if (a_entryObject.isPoisoned == true) {
			poisonIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			poisonIcon.gotoAndStop("show");
		} else {
			poisonIcon.gotoAndStop("hide");
		}

		// Stolen Icon
		if ((a_entryObject.isStolen == true || a_entryObject.isStealing == true) && a_state.showStolenIcon == true) {
			stolenIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			stolenIcon.gotoAndStop("show");
		} else {
			stolenIcon.gotoAndStop("hide");
		}

		// Enchanted Icon
		if (a_entryObject.isEnchanted == true) {
			enchIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			enchIcon.gotoAndStop("show");
		} else {
			enchIcon.gotoAndStop("hide");
		}

		// Enchanted Icon
		if (a_entryObject.isRead == true) {
			readIcon._x = iconPos;
			iconPos = iconPos + iconSpace;
			readIcon.gotoAndStop("show");
		} else {
			readIcon.gotoAndStop("hide");
		}
	}
	
  	// @override TabularEntry
	public function formatText(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void
	{
		formatColor(a_entryField, a_entryObject, a_state);
	}
	
	
  /* PRIVATE FUNCTIONS */

	// @implements MovieClipLoader
	private function onLoadInit(a_icon: MovieClip): Void
	{
		a_icon.gotoAndStop(_iconLabel);
		changeIconColor(a_icon, _iconColor);
	}
	
	private function formatColor(a_entryField: Object, a_entryObject: Object, a_state: ListState): Void
	{
		// Negative Effect
		if (a_entryObject.negativeEffect == true)
			a_entryField.textColor = a_entryObject.enabled == false ? a_state.negativeDisabledColor : a_state.negativeEnabledColor;
			
		// Stolen
		else if (a_entryObject.infoIsStolen == true || a_entryObject.isStealing == true)
			a_entryField.textColor = a_entryObject.enabled == false ? a_state.stolenDisabledColor : a_state.stolenEnabledColor;
			
		// Default
		else
			a_entryField.textColor = a_entryObject.enabled == false ? a_state.defaultDisabledColor : a_state.defaultEnabledColor;
	}
	
	private function changeIconColor(a_icon: MovieClip, a_rgb: Number): Void
	{
		var element: Object;
		for (var e: String in a_icon) {
			element = a_icon[e];
			if (element instanceof MovieClip) {
				//Note: Could check if all values of RGBA mult and .rgb are all the same then skip
				var ct: ColorTransform = new ColorTransform();
				var tf: Transform = new Transform(MovieClip(element));
				// Could return here if (a_rgb == tf.colorTransform.rgb && a_rgb != undefined)
				ct.rgb = (a_rgb == undefined)? 0xFFFFFF: a_rgb;
				tf.colorTransform = ct;
				// Shouldn't be necessary to recurse since we don't expect multiple clip depths for an icon
				//changeIconColor(element, a_rgb);
			}
		}
	}
}