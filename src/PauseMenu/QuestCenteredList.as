dynamic class QuestCenteredList extends Shared.CenteredScrollingList
{

	function QuestCenteredList()
	{
		super();
	}

	function SetEntryText(aEntryClip, aEntryObject)
	{
		super.SetEntryText(aEntryClip, aEntryObject);
		if (aEntryClip.textField != undefined) 
		{
			aEntryClip.textField.textColor = aEntryObject.completed == true ? 6316128 : 16777215;
		}
		if (aEntryClip.EquipIcon != undefined) 
		{
			if (aEntryObject != undefined && aEntryObject.active) 
			{
				aEntryClip.EquipIcon.gotoAndStop("Equipped");
				return;
			}
			aEntryClip.EquipIcon.gotoAndStop("None");
		}
	}

}
