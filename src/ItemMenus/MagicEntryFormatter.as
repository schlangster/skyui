import skyui.util.Defines;
import skyui.components.list.TabularEntryFormatter;
import skyui.components.list.TabularList;


class MagicEntryFormatter extends InventoryEntryFormatter
{
  /* CONSTRUCTORS */
	
	public function MagicEntryFormatter(a_list: TabularList)
	{
		super(a_list);
	}
	
	
  /* PUBLIC FUNCTIONS */

  	// @override InventoryEntryFormatter
	public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_entryClip: MovieClip): Void
	{
		var iconLabel:String;
		
		switch (a_entryObject.infoType) {
			
			// Spell
			case InventoryDefines.ICT_SPELL :
				switch (a_entryObject.subType) {
					case Defines.SPELL_TYPE_ALTERATION :
						iconLabel = "default_alteration";
						break;
					case Defines.SPELL_TYPE_ILLUSION :
						iconLabel = "default_illusion";
						break;
					case Defines.SPELL_TYPE_DESTRUCTION :
						iconLabel = "default_destruction";
						break;
					case Defines.SPELL_TYPE_CONJURATION :
						iconLabel = "default_conjuration";
						break;
					case Defines.SPELL_TYPE_RESTORATION :
						iconLabel = "default_restoration";
						break;
					default:
						iconLabel = "default_power";
				}
				break;
			
			// Power
			case InventoryDefines.ICT_SPELL_DEFAULT :
				iconLabel = "default_power";
				break;
			
			// Shout
			case InventoryDefines.ICT_SHOUT :
				iconLabel = "default_shout";
				break;
			
			// Active Effect
			case InventoryDefines.ICT_ACTIVE_EFFECT :
			default:
				iconLabel = "default_effect";			
		}
		
		// The icon clip is loaded at runtime from a seperate .swf. So two scenarios are possible:
		// 1. The clip has been loaded, gotoAndStop will set it to the new label
		// 2. Loading is not done yet, so gotoAndStop will fail. In this case, the loaded clip will fetch the current label from
		//    the its parent (entryclip.iconLabel) as soon as it's done.
		a_entryClip.iconLabel = iconLabel;
		a_entryField.gotoAndStop(iconLabel);
	}
}