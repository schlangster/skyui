import skyui.components.list.BasicList;
import skyui.util.Defines;

class InventoryDataExtender extends ItemcardDataExtender
{
  /* CONSTANTS */

	private static var OVERRIDE_ORDER = [2, 1, 3, 4, 7, 8, 9, 5, 6, 10, 11, 0, 12];
	

  /* INITIALIZATION */
  
	public function InventoryDataExtender()
	{
		super();
	}


  /* PUBLIC FUNCTIONS */
	
  	// @override ItemcardDataExtender
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		switch (a_itemInfo.type) {
			case InventoryDefines.ICT_ARMOR :
				a_entryObject.infoArmor = a_itemInfo.armor ? a_itemInfo.armor : "-";
				a_entryObject.infoDamage = "-";
				a_entryObject.infoIsEnchanted = (a_itemInfo.effects != "");
				break;
				
			case InventoryDefines.ICT_WEAPON :
				a_entryObject.infoDamage = a_itemInfo.damage ? a_itemInfo.damage : "-";
				a_entryObject.infoArmor = "-";
				a_entryObject.infoIsEnchanted = (a_itemInfo.effects != "");
				break;
				
			case InventoryDefines.ICT_POTION :
				// if potion item has spellCost then it is a scroll
				if (a_itemInfo.skillName)
					a_itemInfo.type = InventoryDefines.ICT_BOOK;
				else if (a_itemInfo.spellCost)
					a_itemInfo.type = InventoryDefines.ICT_SPELL;
				// Fall through
				
			default:
				a_entryObject.infoArmor = "-";
				a_entryObject.infoDamage = "-";
				a_entryObject.infoIsEnchanted = false;
		}

		a_entryObject.infoValue = Math.round(a_itemInfo.value);		
		a_entryObject.infoWeight = Math.round(a_itemInfo.weight * 10) / 10;
		
		a_entryObject.infoType = a_itemInfo.type;
		a_entryObject.infoPotionType = a_itemInfo.potionType;
		a_entryObject.infoWeightValue = a_itemInfo.weight > 0 ? Math.round(a_itemInfo.value / a_itemInfo.weight) : "-";
		
		a_entryObject.infoIsPoisoned = (a_itemInfo.poisoned > 0);
		a_entryObject.infoIsStolen = (a_itemInfo.stolen > 0);
		a_entryObject.infoIsEquipped = (a_entryObject.equipState > 0);
		
		if (a_entryObject.formType == Defines.FORMTYPE_WEAPON) {
			// Differentiate battleaxe and warhammer
			fixWeaponSubType(a_entryObject);
			
		} else if (a_entryObject.formType == Defines.FORMTYPE_ARMOR) {
			processArmorSubType(a_entryObject);
			fixWeightClassSorting(a_entryObject);
			
		} else if (a_entryObject.formType == Defines.FORMTYPE_ALCH) {
			fixAlchemySubType(a_entryObject);
			
		} else if (a_entryObject.formType == Defines.FORMTYPE_SOULGEM) {
			setSoulGemStatus(a_entryObject);
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function fixWeaponSubType(a_entryObject: Object): Void
	{
		// Differentiate between battleaxe and warhammer
		
		if (a_entryObject.subType > Defines.WEAPON_TYPE_BATTLEAXE)
			// Bump up higher values to allow for the correct position for warhammers
			// Adding warhammers to the end would cause it to not sort properly
			a_entryObject.subType++;
			
		else if (a_entryObject.subType == Defines.WEAPON_TYPE_BATTLEAXE && a_entryObject.keywords["WeapTypeWarhammer"])
			a_entryObject.subType = Defines.WEAPON_TYPE_HAMMER;
	}
	
	private function processArmorSubType(a_entryObject: Object): Void
	{
		// Determine override order.  This way for example anything with the body bit true will be
		// considered type body. Otherwise hooded robes will be grouped with helmets, and helmets
		// that cover the face would have a different values from those that don't, etc.
		// see BGSBipedObjectForm kPart enum for determining number
		var subType = 0;
		
		var matchSubType = 0;
		var bitMask = 0;
		
		for (var i = 0; i < OVERRIDE_ORDER.length; i++) {
			matchSubType = 1;
			// For the duration of overrideOrder we check types in that order
			if (i < OVERRIDE_ORDER.length)
				matchSubType = OVERRIDE_ORDER[i];
			
			bitMask = 1 << matchSubType;
			// purposeful binary bitwise AND
			if (a_entryObject.partMask & bitMask) {
				// subType = matchSubType would coincide with order in construction kit
				// but doesn't sort as nicely.
				subType = i + 1;
				break;
			}
		}
		a_entryObject.subType = subType;		
	}
	
	private function fixWeightClassSorting(a_entryObject:Object)
	{
		// Swap heavy and light values for better sorting
		if (a_entryObject.weightClass == 0) {
			a_entryObject.weightClass = 1;
		} else if (a_entryObject.weightClass == 1) {
			a_entryObject.weightClass = 0;
		}
	}
	
	private function fixAlchemySubType(a_entryObject: Object): Void
	{
		//Set subtype based on flags rather than magic school
		a_entryObject.subType = a_entryObject.flags;
		
		// Now apply some corretions
		// This will sort helpful and harmful potions and food
		if (a_entryObject.flags == 1)
			// Correct a few potions like sleeping tree sap
			// (I believe because AutoCalc set no No unlike most potions)
			a_entryObject.subType = 0;
		
		if (a_entryObject.flags == 2)
			// Correct the subType for clam and gourds
			// (I believe because they have AutoCalc set to yes unlike most food)
			a_entryObject.subType = 3;
			
		else if (a_entryObject.flags == 0x20000)
			a_entryObject.subType = 2; // harmful potions
		
	}

	private function setSoulGemStatus(a_entryObject: Object): Void
	{
		if (a_entryObject.soulSize == undefined || a_entryObject.gemSize == undefined || a_entryObject.soulSize <= 0)
			a_entryObject.status = Defines.SOULGEM_EMPTY;
			
		else if (a_entryObject.soulSize >= a_entryObject.gemSize)
			a_entryObject.status = Defines.SOULGEM_FULL;
			
		else
			a_entryObject.status = Defines.SOULGEM_PARTIAL;
	}
}