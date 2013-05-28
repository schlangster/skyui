import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;

import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Material;
import skyui.defines.Weapon;

class InventoryIconSetter implements IListProcessor
{
  /* PRIVATE VARIABLES */

	private var _noIconColors: Boolean;


  /* INITIALIZATION */

 	public function InventoryIconSetter(a_configAppearance: Object)
 	{
 		_noIconColors = a_configAppearance.icons.item.noColor;
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
				processResist(a_entryObject);
				break;

			case Form.TYPE_ARMOR:
				processArmorIcon(a_entryObject);
				break;

			case Form.TYPE_BOOK:
				processBookIcon(a_entryObject);
				break;

			case Form.TYPE_INGREDIENT:
				a_entryObject.iconLabel = "default_ingredient";
				break;

			case Form.TYPE_LIGHT:
				a_entryObject.iconLabel = "misc_torch";
				break;

			case Form.TYPE_MISC:
				processMiscIcon(a_entryObject);
				break;

			case Form.TYPE_WEAPON:
				processWeaponIcon(a_entryObject);
				break;

			case Form.TYPE_AMMO:
				processAmmoIcon(a_entryObject);
				break;

			case Form.TYPE_KEY:
				a_entryObject.iconLabel = "default_key";
				break;

			case Form.TYPE_POTION:
				processPotionIcon(a_entryObject);
				break;

			case Form.TYPE_SOULGEM:
				processSoulGemIcon(a_entryObject);
				break;
		}

		if (_noIconColors && a_entryObject.iconColor != undefined)
			delete(a_entryObject.iconColor);
	}

	private function processResist(a_entryObject: Object): Void
	{
		if (a_entryObject.resistance == undefined || a_entryObject.resistance == Actor.AV_NONE)
			return;

		switch(a_entryObject.resistance) {
			case Actor.AV_FIRERESIST:
				a_entryObject.iconColor = 0xC73636;
				break;

			case Actor.AV_ELECTRICRESIST:
				a_entryObject.iconColor = 0xFFFF00;
				break;

			case Actor.AV_FROSTRESIST:
				a_entryObject.iconColor = 0x1FFBFF;
				break;
		}
	}

	private function processArmorIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_armor";
		a_entryObject.iconColor = 0xEDDA87;

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
		a_entryObject.iconColor = 0x756000;

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
		a_entryObject.iconColor = 0x6B7585;

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

	// Books
	private function processBookIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_book";

		switch(a_entryObject.subType) {
			case Item.BOOK_RECIPE:
			case Item.BOOK_NOTE:
				a_entryObject.iconLabel = "book_note";
				break;

			case Item.BOOK_SPELLTOME:
				a_entryObject.iconLabel = "book_tome";
				break;
		}
	}

	// Weapons
	private function processWeaponIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_weapon";
		a_entryObject.iconColor = 0xA4A5BF;

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

	// Ammo
	private function processAmmoIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "weapon_arrow";
		a_entryObject.iconColor = 0xA89E8C;

		switch(a_entryObject.subType) {
			case Weapon.AMMO_ARROW:
				a_entryObject.iconLabel = "weapon_arrow";
				break;
			case Weapon.AMMO_BOLT:
				a_entryObject.iconLabel = "weapon_bolt";
				break;
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
				a_entryObject.iconColor = 0xAD00B3;
				break;
				
			case Item.POTION_HEALTH:
			case Item.POTION_HEALRATE:
			case Item.POTION_HEALRATEMULT:
				a_entryObject.iconLabel = "potion_health";
				a_entryObject.iconColor = 0xDB2E73;
				break;
				
			case Item.POTION_MAGICKA:
			case Item.POTION_MAGICKARATE:
			case Item.POTION_MAGICKARATEMULT:
				a_entryObject.iconLabel = "potion_magic";
				a_entryObject.iconColor = 0x2E9FDB;
				break;
				
			case Item.POTION_STAMINA:	
			case Item.POTION_STAMINARATE:
			case Item.POTION_STAMINARATEMULT:
				a_entryObject.iconLabel = "potion_stam";
				a_entryObject.iconColor = 0x51DB2E;
				break;

			case Item.POTION_FIRERESIST:
				a_entryObject.iconLabel = "potion_fire";
				a_entryObject.iconColor = 0xC73636;
				break;

			case Item.POTION_ELECTRICRESIST:
				a_entryObject.iconLabel = "potion_shock";
				a_entryObject.iconColor = 0xEAAB00;
				break;

			case Item.POTION_FROSTRESIST:
				a_entryObject.iconLabel = "potion_frost";
				a_entryObject.iconColor = 0x1FFBFF;
				break;
		}

	}

	private function processSoulGemIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "misc_soulgem";
		a_entryObject.iconColor = 0xE3E0FF;

		switch(a_entryObject.subType) {
			case Item.SOULGEM_PETTY:
				a_entryObject.iconColor = 0xD7D4FF;
				processSoulGemStatusIcon(a_entryObject);
				break;

			case Item.SOULGEM_LESSER:
				a_entryObject.iconColor = 0xC0BAFF;
				processSoulGemStatusIcon(a_entryObject);
				break;

			case Item.SOULGEM_COMMON:
				a_entryObject.iconColor = 0xABA3FF;
				processSoulGemStatusIcon(a_entryObject);
				break;

			case Item.SOULGEM_GREATER:
				a_entryObject.iconColor = 0x948BFC;
				processGrandSoulGemIcon(a_entryObject);
				break;

			case Item.SOULGEM_GRAND:
				a_entryObject.iconColor = 0x7569FF;
				processGrandSoulGemIcon(a_entryObject);
				break;

			case Item.SOULGEM_AZURA:
				a_entryObject.iconColor = 0x7569FF;
				a_entryObject.iconLabel = "soulgem_azura";
				break;
		}
	}

	private function processGrandSoulGemIcon(a_entryObject: Object): Void {
		switch(a_entryObject.status) {
			case Item.SOULGEMSTATUS_EMPTY:
				a_entryObject.iconLabel = "soulgem_grandempty";
				break;

			case Item.SOULGEMSTATUS_FULL:
				a_entryObject.iconLabel = "soulgem_grandfull";
				break;

			case Item.SOULGEMSTATUS_PARTIAL:
				a_entryObject.iconLabel = "soulgem_grandpartial";
				break;
		}
	}

	private function processSoulGemStatusIcon(a_entryObject: Object): Void {
		switch(a_entryObject.status) {
			case Item.SOULGEMSTATUS_EMPTY:
				a_entryObject.iconLabel = "soulgem_empty";
				break;

			case Item.SOULGEMSTATUS_FULL:
				a_entryObject.iconLabel = "soulgem_full";
				break;

			case Item.SOULGEMSTATUS_PARTIAL:
				a_entryObject.iconLabel = "soulgem_partial";
				break;
		}
	}

	private function processMiscIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_misc";

		switch(a_entryObject.subType) {
			case Item.MISC_ARTIFACT:
				a_entryObject.iconLabel = "misc_artifact";
				break;

			case Item.MISC_GEM:
				a_entryObject.iconLabel = "misc_gem";
				a_entryObject.iconColor = 0xFFB0D1;
				break;

			case Item.MISC_HIDE:
				a_entryObject.iconLabel = "misc_hide";
				a_entryObject.iconColor = 0xDBB36E;
				break;

			case Item.MISC_REMAINS:
				a_entryObject.iconLabel = "misc_remains";
				break;

			case Item.MISC_INGOT:
				a_entryObject.iconLabel = "misc_ingot"; //"misc_ore"
				a_entryObject.iconColor = 0x828282;
				break;

			case Item.MISC_CLUTTER:
				a_entryObject.iconLabel = "misc_clutter";
				break;

			case Item.MISC_FIREWOOD:
				a_entryObject.iconLabel = "misc_wood";
				a_entryObject.iconColor = 0xA89E8C;
				break;

			case Item.MISC_DRAGONCLAW:
				a_entryObject.iconLabel = "misc_dragonclaw";
				break;

			case Item.MISC_LOCKPICK:
				a_entryObject.iconLabel = "misc_lockpick";
				break;

			case Item.MISC_GOLD:
				a_entryObject.iconLabel = "misc_gold";
				a_entryObject.iconColor = 0xCCCC33;
				break;

			case Item.MISC_LEATHER:
				a_entryObject.iconLabel = "misc_leather";
				a_entryObject.iconColor = 0xBA8D23;
				break;

			case Item.MISC_LEATHERSTRIPS:
				a_entryObject.iconLabel = "misc_strips";
				a_entryObject.iconColor = 0xBA8D23;
				break;

			case Item.MISC_CHILDRENSCLOTHES:
				a_entryObject.iconColor = 0xEDDA87;
				a_entryObject.iconLabel = "clothing_body";
				break;

			// Maybe use later?
			// ... or not.
			/*
			case Item.MISC_TOOL:
				break;
				
			case Item.MISC_TOY:
				break;

			case Item.MISC_HOUSEPART:
				break;
			*/
		}
	}


}


// skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);