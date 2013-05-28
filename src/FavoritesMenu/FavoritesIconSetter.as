import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;

import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Weapon;

class FavoritesIconSetter implements IListProcessor
{
  /* INITIALIZATION */

 	public function FavoritesIconSetter(a_configAppearance: Object)
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
		switch (a_entryObject.formType) {
			case Form.TYPE_SCROLLITEM:
				a_entryObject.iconLabel = "default_scroll";
				break;

			case Form.TYPE_ARMOR:
				processArmorClass(a_entryObject);
				processArmorPartMask(a_entryObject);
				processArmorOther(a_entryObject);
				processArmorBaseId(a_entryObject);
			
				processArmorIcon(a_entryObject);
				break;

			case Form.TYPE_INGREDIENT:
				a_entryObject.iconLabel = "default_ingredient";
				break;

			case Form.TYPE_LIGHT:
				a_entryObject.iconLabel = "misc_torch";
				break;

			case Form.TYPE_WEAPON:
				processWeaponType(a_entryObject);
				processWeaponBaseId(a_entryObject);
			
				processWeaponIcon(a_entryObject);
				break;

			case Form.TYPE_AMMO:
				processAmmoType(a_entryObject);
			
				processAmmoIcon(a_entryObject);
				break;

			case Form.TYPE_POTION:
				processPotionType(a_entryObject);
			
				processPotionIcon(a_entryObject);
				break;;
				
			case Form.TYPE_SPELL:
				processSpellIcon(a_entryObject);
				break;

			case Form.TYPE_SHOUT:
				a_entryObject.iconLabel = "default_shout";
				break;
				
			default:
				a_entryObject.iconLabel = "default_misc";
				break;
		}
	}
	
	private function processArmorClass(a_entryObject: Object): Void
	{
		if (a_entryObject.weightClass == Armor.WEIGHT_NONE)
			a_entryObject.weightClass = null;

		switch (a_entryObject.weightClass) {
			case Armor.WEIGHT_LIGHT:
			case Armor.WEIGHT_HEAVY:
				break;

			default:
				if (a_entryObject.keywords == undefined)
					break;

				if (a_entryObject.keywords["VendorItemClothing"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_CLOTHING;
				} else if (a_entryObject.keywords["VendorItemJewelry"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				}	 
		}
	}
	
	private function processArmorPartMask(a_entryObject: Object): Void
	{
		if (a_entryObject.partMask == undefined)
			return;

		// Sets subType as the most important bitmask index.
		for (var i = 0; i < Armor.PARTMASK_PRECEDENCE.length; i++) {
			if (a_entryObject.partMask & Armor.PARTMASK_PRECEDENCE[i]) {
				a_entryObject.mainPartMask = Armor.PARTMASK_PRECEDENCE[i];
				break;
			}
		}

		if (a_entryObject.mainPartMask == undefined)
			return;

		switch (a_entryObject.mainPartMask) {
			case Armor.PARTMASK_HEAD:
				a_entryObject.subType = Armor.EQUIP_HEAD;
				break;
			case Armor.PARTMASK_HAIR:
				a_entryObject.subType = Armor.EQUIP_HAIR;
				break;
			case Armor.PARTMASK_LONGHAIR:
				a_entryObject.subType = Armor.EQUIP_LONGHAIR;
				break;

			case Armor.PARTMASK_BODY:
				a_entryObject.subType = Armor.EQUIP_BODY;
				break;

			case Armor.PARTMASK_HANDS:
				a_entryObject.subType = Armor.EQUIP_HANDS;
				break;

			case Armor.PARTMASK_FOREARMS:
				a_entryObject.subType = Armor.EQUIP_FOREARMS;
				break;

			case Armor.PARTMASK_AMULET:
				a_entryObject.subType = Armor.EQUIP_AMULET;
				break;

			case Armor.PARTMASK_RING:
				a_entryObject.subType = Armor.EQUIP_RING;
				break;

			case Armor.PARTMASK_FEET:
				a_entryObject.subType = Armor.EQUIP_FEET;
				break;

			case Armor.PARTMASK_CALVES:
				a_entryObject.subType = Armor.EQUIP_CALVES;
				break;

			case Armor.PARTMASK_SHIELD:
				a_entryObject.subType = Armor.EQUIP_SHIELD;
				break;

			case Armor.PARTMASK_CIRCLET:
				a_entryObject.subType = Armor.EQUIP_CIRCLET;
				break;

			case Armor.PARTMASK_EARS:
				a_entryObject.subType = Armor.EQUIP_EARS;
				break;

			case Armor.PARTMASK_TAIL:
				a_entryObject.subType = Armor.EQUIP_TAIL;
				break;

			default:
				a_entryObject.subType = a_entryObject.mainPartMask;
				break;
		}
	}

	private function processArmorOther(a_entryObject): Void
	{
		if (a_entryObject.weightClass != null)
			return;

		switch (a_entryObject.mainPartMask) {
			case Armor.PARTMASK_HEAD:
			case Armor.PARTMASK_HAIR:
			case Armor.PARTMASK_LONGHAIR:
			case Armor.PARTMASK_BODY:
			case Armor.PARTMASK_HANDS:
			case Armor.PARTMASK_FOREARMS:
			case Armor.PARTMASK_FEET:
			case Armor.PARTMASK_CALVES:
			case Armor.PARTMASK_SHIELD:
			case Armor.PARTMASK_TAIL:
				a_entryObject.weightClass = Armor.WEIGHT_CLOTHING;
				break;

			case Armor.PARTMASK_AMULET:
			case Armor.PARTMASK_RING:
			case Armor.PARTMASK_CIRCLET:
			case Armor.PARTMASK_EARS:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				break;
		}
	}

	private function processArmorBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_CLOTHESWEDDINGWREATH:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				break
			case Form.BASEID_DLC1CLOTHESVAMPIRELORDARMOR:
				a_entryObject.subType = Armor.EQUIP_BODY;
				break;
		}
	}

	private function processArmorIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_armor";

		switch (a_entryObject.weightClass) {
			case Armor.WEIGHT_LIGHT:
				processLightArmorIcon(a_entryObject);
				break;

			case Armor.WEIGHT_HEAVY:
				processHeavyArmorIcon(a_entryObject);
				break;

			case Armor.WEIGHT_JEWELRY:
				processJewelryArmorIcon(a_entryObject);
				break;

			case Armor.WEIGHT_CLOTHING:
			default:
				processClothingArmorIcon(a_entryObject);
				break;
		}
	}

	private function processLightArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.EQUIP_HEAD:
			case Armor.EQUIP_HAIR:
			case Armor.EQUIP_LONGHAIR:
				a_entryObject.iconLabel = "lightarmor_head";
				break;

			case Armor.EQUIP_BODY:
			case Armor.EQUIP_TAIL:
				a_entryObject.iconLabel = "lightarmor_body";
				break;

			case Armor.EQUIP_HANDS:
				a_entryObject.iconLabel = "lightarmor_hands";
				break;

			case Armor.EQUIP_FOREARMS:
				a_entryObject.iconLabel = "lightarmor_forearms";
				break;

			case Armor.EQUIP_FEET:
				a_entryObject.iconLabel = "lightarmor_feet";
				break;

			case Armor.EQUIP_CALVES:
				a_entryObject.iconLabel = "lightarmor_calves";
				break;

			case Armor.EQUIP_SHIELD:
				a_entryObject.iconLabel = "lightarmor_shield";
				break;

			case Armor.EQUIP_AMULET:
			case Armor.EQUIP_RING:
			case Armor.EQUIP_CIRCLET:
			case Armor.EQUIP_EARS:
				processJewelryArmorIcon(a_entryObject);
				break;


		}
	}

	private function processHeavyArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.EQUIP_HEAD:
			case Armor.EQUIP_HAIR:
			case Armor.EQUIP_LONGHAIR:
				a_entryObject.iconLabel = "armor_head";
				break;

			case Armor.EQUIP_BODY:
			case Armor.EQUIP_TAIL:
				a_entryObject.iconLabel = "armor_body";
				break;

			case Armor.EQUIP_HANDS:
				a_entryObject.iconLabel = "armor_hands";
				break;

			case Armor.EQUIP_FOREARMS:
				a_entryObject.iconLabel = "armor_forearms";
				break;

			case Armor.EQUIP_FEET:
				a_entryObject.iconLabel = "armor_feet";
				break;

			case Armor.EQUIP_CALVES:
				a_entryObject.iconLabel = "armor_calves";
				break;

			case Armor.EQUIP_SHIELD:
				a_entryObject.iconLabel = "armor_shield";
				break;

			case Armor.EQUIP_AMULET:
			case Armor.EQUIP_RING:
			case Armor.EQUIP_CIRCLET:
			case Armor.EQUIP_EARS:
				processJewelryArmorIcon(a_entryObject);
				break;

		}
	}

	private function processJewelryArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.EQUIP_AMULET:
				a_entryObject.iconLabel = "armor_amulet";
				break;

			case Armor.EQUIP_RING:
				a_entryObject.iconLabel = "armor_ring";
				break;

			case Armor.EQUIP_CIRCLET:
				a_entryObject.iconLabel = "armor_circlet";
				break;

			case Armor.EQUIP_EARS:
				break;
		}
	}

	private function processClothingArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.EQUIP_HEAD:
			case Armor.EQUIP_HAIR:
			case Armor.EQUIP_LONGHAIR:
				a_entryObject.iconLabel = "clothing_head";
				break;

			case Armor.EQUIP_BODY:
			case Armor.EQUIP_TAIL:
				a_entryObject.iconLabel = "clothing_body";
				break;

			case Armor.EQUIP_HANDS:
				a_entryObject.iconLabel = "clothing_hands";
				break;

			case Armor.EQUIP_FOREARMS:
				a_entryObject.iconLabel = "clothing_forearms";
				break;

			case Armor.EQUIP_FEET:
				a_entryObject.iconLabel = "clothing_feet";
				break;

			case Armor.EQUIP_CALVES:
				a_entryObject.iconLabel = "clothing_calves";
				break;

			case Armor.EQUIP_SHIELD:
				a_entryObject.iconLabel = "clothing_shield";
				break;

			case Armor.EQUIP_EARS:
				break;

		}
	}
	
	private function processWeaponType(a_entryObject: Object): Void
	{
		a_entryObject.subType = null;

		switch (a_entryObject.weaponType) {
			case Weapon.ANIM_HANDTOHANDMELEE:
			case Weapon.ANIM_H2H:
				a_entryObject.subType = Weapon.TYPE_MELEE;
				break;

			case Weapon.ANIM_ONEHANDSWORD:
			case Weapon.ANIM_1HS:
				a_entryObject.subType = Weapon.TYPE_SWORD;
				break;

			case Weapon.ANIM_ONEHANDDAGGER:
			case Weapon.ANIM_1HD:
				a_entryObject.subType = Weapon.TYPE_DAGGER;
				break;

			case Weapon.ANIM_ONEHANDAXE:
			case Weapon.ANIM_1HA:
				a_entryObject.subType = Weapon.TYPE_WARAXE;
				break;

			case Weapon.ANIM_ONEHANDMACE:
			case Weapon.ANIM_1HM:
				a_entryObject.subType = Weapon.TYPE_MACE;
				break;

			case Weapon.ANIM_TWOHANDSWORD:
			case Weapon.ANIM_2HS:
				a_entryObject.subType = Weapon.TYPE_GREATSWORD;
				break;

			case Weapon.ANIM_TWOHANDAXE:
			case Weapon.ANIM_2HA:
				a_entryObject.subType = Weapon.TYPE_BATTLEAXE;

				if (a_entryObject.keywords != undefined && a_entryObject.keywords["WeapTypeWarhammer"] != undefined) {
					a_entryObject.subType = Weapon.TYPE_WARHAMMER;
				}
				break;

			case Weapon.ANIM_BOW:
			case Weapon.ANIM_BOW2:
				a_entryObject.subType = Weapon.TYPE_BOW;
				break;

			case Weapon.ANIM_STAFF:
			case Weapon.ANIM_STAFF2:
				a_entryObject.subType = Weapon.TYPE_STAFF;
				break;

			case Weapon.ANIM_CROSSBOW:
			case Weapon.ANIM_CBOW:
				a_entryObject.subType = Weapon.TYPE_CROSSBOW;
				break;
		}
	}

	private function processWeaponBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_WEAPPICKAXE:
			case Form.BASEID_SSDROCKSPLINTERPICKAXE:
			case Form.BASEID_DUNVOLUNRUUDPICKAXE:
				a_entryObject.subType = Weapon.TYPE_PICKAXE;
				break;
			case Form.BASEID_AXE01:
			case Form.BASEID_DUNHALTEDSTREAMPOACHERSAXE:
				a_entryObject.subType = Weapon.TYPE_WOODAXE;
				break;
		}
	}

	// Weapons
	private function processWeaponIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_weapon";

		switch(a_entryObject.subType) {
			case Weapon.TYPE_MELEE:
				break;

			case Weapon.TYPE_SWORD:
				a_entryObject.iconLabel = "weapon_sword";
				break;

			case Weapon.TYPE_DAGGER:
				a_entryObject.iconLabel = "weapon_dagger";
				break;

			case Weapon.TYPE_WARAXE:
				a_entryObject.iconLabel = "weapon_waraxe";
				break;

			case Weapon.TYPE_MACE:
				a_entryObject.iconLabel = "weapon_mace";
				break;

			case Weapon.TYPE_GREATSWORD:
				a_entryObject.iconLabel = "weapon_greatsword";
				break;

			case Weapon.TYPE_BATTLEAXE:
				a_entryObject.iconLabel = "weapon_battleaxe";
				break;

			case Weapon.TYPE_WARHAMMER:
				a_entryObject.iconLabel = "weapon_hammer";
				break;

			case Weapon.TYPE_BOW:
				a_entryObject.iconLabel = "weapon_bow";
				break;

			case Weapon.TYPE_STAFF:
				a_entryObject.iconLabel = "weapon_staff";
				break;

			case Weapon.TYPE_CROSSBOW:
				a_entryObject.iconLabel = "weapon_crossbow";
				break;

			case Weapon.TYPE_PICKAXE:
				a_entryObject.iconLabel = "weapon_pickaxe";
				break;

			case Weapon.TYPE_WOODAXE:
				a_entryObject.iconLabel = "weapon_woodaxe";
				break;
		}
	}
	
	private function processAmmoType(a_entryObject: Object): Void
	{
		if ((a_entryObject.flags & Weapon.AMMOFLAG_NONBOLT) != 0) {
			a_entryObject.subType = Weapon.AMMO_ARROW;
		} else {
			a_entryObject.subType = Weapon.AMMO_BOLT;
		}
	}

	// Ammo
	private function processAmmoIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "weapon_arrow";

		switch(a_entryObject.subType) {
			case Weapon.AMMO_ARROW:
				a_entryObject.iconLabel = "weapon_arrow";
				break;
			case Weapon.AMMO_BOLT:
				a_entryObject.iconLabel = "weapon_bolt";
				break;
		}
	}
	
	private function processPotionType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.POTION_POTION;

		if ((a_entryObject.flags & Item.ALCHFLAG_FOOD) != 0) {
			a_entryObject.subType = Item.POTION_FOOD;

			// SKSE >= 1.6.6
			if (a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == Form.FORMID_ITMPotionUse) {
				a_entryObject.subType = Item.POTION_DRINK;
			}
			
		} else if ((a_entryObject.flags & Item.ALCHFLAG_POISON) != 0) {
			a_entryObject.subType = Item.POTION_POISON;
		} else {
			switch (a_entryObject.actorValue) {
				case Actor.AV_HEALTH:
					a_entryObject.subType = Item.POTION_HEALTH;
					break;
				case Actor.AV_MAGICKA:
					a_entryObject.subType = Item.POTION_MAGICKA;
					break;
				case Actor.AV_STAMINA:
					a_entryObject.subType = Item.POTION_STAMINA;
					break;

				case Actor.AV_HEALRATE:
					a_entryObject.subType = Item.POTION_HEALRATE;
					break;
				case Actor.AV_MAGICKARATE:
					a_entryObject.subType = Item.POTION_MAGICKARATE;
					break;
				case Actor.AV_STAMINARATE:
					a_entryObject.subType = Item.POTION_STAMINARATE;
					break;

				case Actor.AV_HEALRATEMULT:
					a_entryObject.subType = Item.POTION_HEALRATEMULT;
					break;
				case Actor.AV_MAGICKARATEMULT:
					a_entryObject.subType = Item.POTION_MAGICKARATEMULT;
					break;
				case Actor.AV_STAMINARATEMULT:
					a_entryObject.subType = Item.POTION_STAMINARATEMULT;
					break;

				case Actor.AV_FIRERESIST:
					a_entryObject.subType = Item.POTION_FIRERESIST;
					break;

				case Actor.AV_ELECTRICRESIST:
					a_entryObject.subType = Item.POTION_ELECTRICRESIST;
					break;

				case Actor.AV_FROSTRESIST:
					a_entryObject.subType = Item.POTION_FROSTRESIST;
					break;
			}
		}
	}

	private function processPotionIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_potion";

		switch(a_entryObject.subType) {
			case Item.POTION_DRINK:
				a_entryObject.iconLabel = "food_wine";
				break;

			case Item.POTION_FOOD:
				a_entryObject.iconLabel = "default_food";
				break;
				
			case Item.POTION_POISON:
				a_entryObject.iconLabel = "potion_poison";
				break;
				
			case Item.POTION_HEALTH:
			case Item.POTION_HEALRATE:
			case Item.POTION_HEALRATEMULT:
				a_entryObject.iconLabel = "potion_health";
				break;
				
			case Item.POTION_MAGICKA:
			case Item.POTION_MAGICKARATE:
			case Item.POTION_MAGICKARATEMULT:
				a_entryObject.iconLabel = "potion_magic";
				break;
				
			case Item.POTION_STAMINA:	
			case Item.POTION_STAMINARATE:
			case Item.POTION_STAMINARATEMULT:
				a_entryObject.iconLabel = "potion_stam";
				break;

			case Item.POTION_FIRERESIST:
				a_entryObject.iconLabel = "potion_fire";
				break;

			case Item.POTION_ELECTRICRESIST:
				a_entryObject.iconLabel = "potion_shock";
				break;

			case Item.POTION_FROSTRESIST:
				a_entryObject.iconLabel = "potion_frost";
				break;
		}

	}

	private function processSpellIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_power";
		
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
				break;

			case Actor.AV_ILLUSION:
				a_entryObject.iconLabel = "default_illusion";
				break;

			case Actor.AV_RESTORATION:
				a_entryObject.iconLabel = "default_restoration";
				break;

		}
	}

}