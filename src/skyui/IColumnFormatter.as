interface skyui.IColumnFormatter
{
	// Field can be icon or textField
	function formatName(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip);
	function formatEquipIcon(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip);
	function formatItemIcon(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip);
	function formatText(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip);
}