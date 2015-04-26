import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;


class FavoritesListEntry extends BasicListEntry
{
  /* CONSTANTS */
  
	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];
	

  /* PRIVATE VARIABLES */
	
	
  /* STAGE ELMENTS */
  
  	public var itemIcon: MovieClip;
  	public var equipIcon: MovieClip;
	public var textField: TextField;
  	public var selectIndicator: MovieClip;
	public var hotkeyIcon: MovieClip;
	public var mainHandIcon: MovieClip;
	public var offHandIcon: MovieClip;
	
	
  /* INITIALIZATION */
	
  	// @override BasicListEntry
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		super.initialize();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override BasicListEntry
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{		
		var isAssigned = a_entryObject == a_state.assignedEntry;
		var isSelected = a_entryObject == a_state.list.selectedEntry || isAssigned;
		
		var groupIndex = a_state.activeGroupIndex;
		var isMainHand: Boolean = groupIndex != -1 && (a_entryObject.mainHandFlag & (1 << groupIndex)) != 0;
		var isOffHand: Boolean = groupIndex != -1 && (a_entryObject.offHandFlag & (1 << groupIndex)) != 0;
		
		isEnabled = a_state.assignedEntry == null || isAssigned;
		_alpha = isEnabled ? 100 : 25;
		
		if (selectIndicator != undefined)
			selectIndicator._visible = isSelected;
		
		if (a_entryObject.text == undefined) {
			textField.SetText(" ");
		} else {
			var hotkey = a_entryObject.hotkey;
			if (hotkey != undefined && hotkey != -1) {
				if (hotkey >= 0 && hotkey <= 7) {
					textField.SetText(a_entryObject.text);
					
					hotkeyIcon._visible = true;
					hotkeyIcon.gotoAndStop(hotkey + 1);
				} else {
					textField.SetText("$HK" + hotkey);
					textField.SetText(textField.text + ". " + a_entryObject.text);
					hotkeyIcon._visible = false;
				}
				
			} else {
				textField.SetText(a_entryObject.text);
				hotkeyIcon._visible = false;
			}
			var maxTextLength: Number = 32;
			if (textField.text.length > maxTextLength) {
				textField.SetText(textField.text.substr(0, maxTextLength - 3) + "...");
			}
		}
//		textField.textAutoSize = "shrink";

		var iconLabel = a_entryObject.iconLabel != undefined ? a_entryObject.iconLabel : "default_misc";
		itemIcon.gotoAndStop(iconLabel);
		itemIcon._alpha = isSelected ? 90 : 50;
		
		if (a_entryObject == null)
			equipIcon.gotoAndStop("None");
		else
			equipIcon.gotoAndStop(STATES[a_entryObject.equipState]);

		var iconOffset = textField._x + textField.textWidth + 8;

		if (isMainHand) {
			mainHandIcon._x = iconOffset;
			iconOffset += 12;
		}
		mainHandIcon._visible = isMainHand;
		
		if (isOffHand) {
			offHandIcon._x = iconOffset;
		}
		offHandIcon._visible = isOffHand;
	}
	
	
  /* PRIVATE FUNCTIONS */
}