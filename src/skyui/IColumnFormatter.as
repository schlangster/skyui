interface skyui.IColumnFormatter
{
	// Field can be icon or textField
	function formatName(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip);
	function formatEquipIcon(a_entryField:Object, a_entryObject:Object);
	function formatItemIcon(a_entryField:Object, a_entryObject:Object);
	function formatText(a_entryField:Object, a_entryObject:Object);
}