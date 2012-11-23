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
  
  	public var equipIcon: MovieClip;
	public var textField: TextField;
  	public var selectIndicator: MovieClip;
	
	
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
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		if (selectIndicator != undefined)
			selectIndicator._visible = isSelected;
		
		if (a_entryObject.text == undefined) {
			textField.SetText(" ");
		} else {
			if (a_entryObject.hotkey != undefined && a_entryObject.hotkey != -1) {
				appendHotkeyText(textField, a_entryObject.hotkey, a_entryObject.text);
			} else {
				textField.SetText(a_entryObject.text);
			}
			var maxTextLength: Number = 35;
			if (textField.text.length > maxTextLength) {
				textField.SetText(textField.text.substr(0, maxTextLength - 3) + "...");
			}
		}
		textField.textAutoSize = "shrink";
		
		if (a_entryObject == null)
			equipIcon.gotoAndStop("None");
		else
			equipIcon.gotoAndStop(STATES[a_entryObject.equipState]);
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	function appendHotkeyText(atfText: TextField, aiHotkey: Number, astrItemName: String): Void
	{
		if (aiHotkey >= 0 && aiHotkey <= 7) {
			atfText.SetText(aiHotkey + 1 + ". " + astrItemName);
			return;
		}
		atfText.SetText("$HK" + aiHotkey);
		atfText.SetText(atfText.text + ". " + astrItemName);
	}
  
}