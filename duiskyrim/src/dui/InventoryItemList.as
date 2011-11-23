class dui.InventoryItemList extends dui.FilteredList
{
	var _maxTextLength;

	function InventoryItemList()
	{
		super();
	}

	function setEntryText(a_entryClip, a_entryObject)
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

			if (a_entryObject.bestInClass == true) {
				text = text + "<img src=\'BestIcon.png\' vspace=\'2\'>";
			}

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

		if (a_entryObject.favorite == true && (a_entryObject.equipState == 0 || a_entryObject.equipState == 1)) {
			a_entryClip.EquipIcon.FavoriteIconInstance.gotoAndStop("On");
		} else {
			a_entryClip.EquipIcon.FavoriteIconInstance.gotoAndStop("Off");
		}
	}
}