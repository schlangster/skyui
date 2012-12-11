import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;

import skyui.defines.Actor;
import skyui.defines.Magic;

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
		
		for (var i: Number = 0; i < entryList.length; i++) {
			if (entryList[i].skyui_inventoryIconSet)
				continue;
			entryList[i].skyui_inventoryIconSet = true;
			processEntry(entryList[i]);
		}
	}

  /* PRIVATE FUNCTIONS */
	private function processEntry(a_entryObject: Object): Void
	{
		//skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);
		switch (a_entryObject.type) {
			case InventoryDefines.ICT_SPELL:
				processSpellIcon(a_entryObject);
				processResist(a_entryObject);
				break;

			case InventoryDefines.ICT_SHOUT:
				a_entryObject.iconLabel = "default_shout";
				break;

			case InventoryDefines.ICT_ACTIVE_EFFECT:
				a_entryObject.iconLabel = "default_effect";
				break;

			case InventoryDefines.ICT_SPELL_DEFAULT:
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
			case Magic.ALTERATION:
				a_entryObject.iconLabel = "default_alteration";
				break;

			case Magic.CONJURATION:
				a_entryObject.iconLabel = "default_conjuration";
				break;

			case Magic.DESTRUCTION:
				a_entryObject.iconLabel = "default_destruction";
				break;

			case Magic.ILLUSION:
				a_entryObject.iconLabel = "default_illusion";
				break;

			case Magic.RESTORATION:
				a_entryObject.iconLabel = "default_restoration";
				break;

		}
	}

	private function processResist(a_entryObject: Object): Void
	{
		if (a_entryObject.resistance == undefined || a_entryObject.resistance == Actor.NONE)
			return;

		switch(a_entryObject.resistance) {
			case Magic.FIRERESIST:
				a_entryObject.iconColor = 0xC73636;
				break;

			case Magic.ELECTRICRESIST:
				a_entryObject.iconColor = 0xFFFF00;
				break;

			case Magic.FROSTRESIST:
				a_entryObject.iconColor = 0x1FFBFF;
				break;

			case Magic.DAMAGERESIST:
			case Magic.POISONRESIST:
			case Magic.MAGICRESIST:
			case Magic.DISEASERESIST:
				break;
		}
	}
}


// skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);

/*
;props.destructionSpellIcon.propertiesToSet = <'iconLabel', 'iconColor'>
;props.destructionSpellIcon.filter = <'infoType': ICT_SPELL, 'subType': SPELL_TYPE_DESTRUCTION>
;props.destructionSpellIcon.defaultValues = <'iconLabel': 'default_destruction'>
;props.destructionSpellIcon.dataMember1.filter = <'magicType': MAGICTYPE_FIRE> 
;props.destructionSpellIcon.dataMember1.set = <'iconLabel': 'magic_fire', 'iconColor': 0xC73636>
;props.destructionSpellIcon.dataMember2.filter = <'magicType': MAGICTYPE_SHOCK> 
;props.destructionSpellIcon.dataMember2.set = <'iconLabel': 'magic_shock', 'iconColor': 0xFFFF00>
;props.destructionSpellIcon.dataMember3.filter = <'magicType': MAGICTYPE_FROST> 
;props.destructionSpellIcon.dataMember3.set = <'iconLabel': 'magic_frost', 'iconColor': 0x1FFBFF>*/