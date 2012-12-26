import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;

import skyui.defines.Actor;
import skyui.defines.Magic;
import skyui.defines.Inventory;

class MagicIconSetter implements IListProcessor
{
  /* INITIALIZATION */

 	public function MagicIconSetter()
 	{
 	}
	

  /* PUBLIC FUNCTIONS */

	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList: Array = a_list.entryList;
		
		for (var i: Number = 0; i < entryList.length; i++)
			processEntry(entryList[i]);
	}

  /* PRIVATE FUNCTIONS */
	private function processEntry(a_entryObject: Object): Void
	{
		//skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);
		switch (a_entryObject.type) {
			case Inventory.ICT_SPELL:
				processSpellIcon(a_entryObject);
				break;

			case Inventory.ICT_SHOUT:
				a_entryObject.iconLabel = "default_shout";
				break;

			case Inventory.ICT_ACTIVE_EFFECT:
				a_entryObject.iconLabel = "default_effect";
				break;

			case Inventory.ICT_SPELL_DEFAULT:
				a_entryObject.iconLabel = "default_power";
				break;
				
			default:
				break;
		}
	}

	private function processSpellIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_power";
		// fire rune, actorValue = Health, school = Destruction, resistance = Fire, effectFlags = hostile+detrimental
		switch(a_entryObject.school)
		{
			case Actor.AV_ALTERATION:
				a_entryObject.iconLabel = "default_alteration";
				break;

			case Actor.AV_CONJURATION:
				a_entryObject.iconLabel = "default_conjuration";
				break;

			case Actor.AV_DESTRUCTION:
				a_entryObject.iconLabel = "default_destruction";
				processResist(a_entryObject);
				break;

			case Actor.AV_ILLUSION:
				a_entryObject.iconLabel = "default_illusion";
				break;

			case Actor.AV_RESTORATION:
				a_entryObject.iconLabel = "default_restoration";
				break;

		}
	}

	private function processResist(a_entryObject: Object): Void
	{
		if (a_entryObject.resistance == undefined || a_entryObject.resistance == Actor.AV_NONE)
			return;

		switch(a_entryObject.resistance) {
			case Actor.AV_FIRERESIST:
				a_entryObject.iconLabel = "magic_fire";
				a_entryObject.iconColor = 0xC73636;
				break;

			case Actor.AV_ELECTRICRESIST:
				a_entryObject.iconLabel = "magic_shock";
				a_entryObject.iconColor = 0xEAAB00;
				break;

			case Actor.AV_FROSTRESIST:
				a_entryObject.iconLabel = "magic_frost";
				a_entryObject.iconColor = 0x1FFBFF;
				break;
		}
	}
}