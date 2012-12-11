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

  /* INITIALIZATION */

 	public function InventoryIconSetter()
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
		switch (a_entryObject.formType) {
			case Form.SCROLLITEM:
				a_entryObject.iconLabel = "default_scroll";
				break;

			case Form.ARMOR:
				processArmorIcon(a_entryObject);
				break;

			case Form.BOOK:
				processBookIcon(a_entryObject);
				break;

			case Form.INGREDIENT:
				a_entryObject.iconLabel = "default_ingredient";
				break;

			case Form.LIGHT:
				a_entryObject.iconLabel = "misc_torch";
				break;

			case Form.MISC:
				processMiscIcon(a_entryObject);
				break;

			case Form.WEAPON:
				processWeaponIcon(a_entryObject);
				break;

			case Form.AMMO:
				processAmmoIcon(a_entryObject);
				break;

			case Form.KEY:
				a_entryObject.iconLabel = "default_key";
				break;

			case Form.POTION:
				processPotionIcon(a_entryObject);
				break;

			case Form.SOULGEM:
				processSoulGemIcon(a_entryObject);
				break;
		}
	}

	private function processArmorIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_armor";
		a_entryObject.iconColor = 0xEDDA87;

		switch (a_entryObject.weightClass) {
			case Armor.LIGHT:
				processLightArmorIcon(a_entryObject);
				break;

			case Armor.HEAVY:
				processHeavyArmorIcon(a_entryObject);
				break;

			case Armor.JEWELRY:
				processJewelryArmorIcon(a_entryObject);
				break;

			case Armor.CLOTHING:
			default:
				processClothingArmorIcon(a_entryObject);
				break;
		}
	}

	private function processLightArmorIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconColor = 0x756000;

		switch(a_entryObject.subType) {
			case Armor.HEAD:
			case Armor.HAIR:
			case Armor.LONGHAIR:
				a_entryObject.iconLabel = "lightarmor_head";
				break;

			case Armor.BODY:
			case Armor.TAIL:
				a_entryObject.iconLabel = "lightarmor_body";
				break;

			case Armor.HANDS:
				a_entryObject.iconLabel = "lightarmor_hands";
				break;

			case Armor.FOREARMS:
				a_entryObject.iconLabel = "lightarmor_forearms";
				break;

			case Armor.FEET:
				a_entryObject.iconLabel = "lightarmor_feet";
				break;

			case Armor.CALVES:
				a_entryObject.iconLabel = "lightarmor_calves";
				break;

			case Armor.SHIELD:
				a_entryObject.iconLabel = "lightarmor_shield";
				break;

			case Armor.AMULET:
			case Armor.RING:
			case Armor.CIRCLET:
			case Armor.EARS:
				processJewelryArmorIcon(a_entryObject);
				break;


		}
	}

	private function processHeavyArmorIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconColor = 0x6B7585;

		switch(a_entryObject.subType) {
			case Armor.HEAD:
			case Armor.HAIR:
			case Armor.LONGHAIR:
				a_entryObject.iconLabel = "armor_head";
				break;

			case Armor.BODY:
			case Armor.TAIL:
				a_entryObject.iconLabel = "armor_body";
				break;

			case Armor.HANDS:
				a_entryObject.iconLabel = "armor_hands";
				break;

			case Armor.FOREARMS:
				a_entryObject.iconLabel = "armor_forearms";
				break;

			case Armor.FEET:
				a_entryObject.iconLabel = "armor_feet";
				break;

			case Armor.CALVES:
				a_entryObject.iconLabel = "armor_calves";
				break;

			case Armor.SHIELD:
				a_entryObject.iconLabel = "armor_shield";
				break;

			case Armor.AMULET:
			case Armor.RING:
			case Armor.CIRCLET:
			case Armor.EARS:
				processJewelryArmorIcon(a_entryObject);
				break;

		}
	}

	private function processJewelryArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.AMULET:
				a_entryObject.iconLabel = "armor_amulet";
				break;

			case Armor.RING:
				a_entryObject.iconLabel = "armor_ring";
				break;

			case Armor.CIRCLET:
				a_entryObject.iconLabel = "armor_circlet";
				break;

			case Armor.EARS:
				break;
		}
	}

	private function processClothingArmorIcon(a_entryObject: Object): Void
	{
		switch(a_entryObject.subType) {
			case Armor.HEAD:
			case Armor.HAIR:
			case Armor.LONGHAIR:
				a_entryObject.iconLabel = "clothing_head";
				break;

			case Armor.BODY:
			case Armor.TAIL:
				a_entryObject.iconLabel = "clothing_body";
				break;

			case Armor.HANDS:
				a_entryObject.iconLabel = "clothing_hands";
				break;

			case Armor.FOREARMS:
				a_entryObject.iconLabel = "clothing_forearms";
				break;

			case Armor.FEET:
				a_entryObject.iconLabel = "clothing_feet";
				break;

			case Armor.CALVES:
				a_entryObject.iconLabel = "clothing_calves";
				break;

			case Armor.SHIELD:
				a_entryObject.iconLabel = "clothing_shield";
				break;

			case Armor.EARS:
				break;

		}
	}

	// Books
	private function processBookIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_book";

		switch(a_entryObject.subType) {
			case Item.RECIPE:
			case Item.NOTE:
				a_entryObject.iconLabel = "book_note";
				break;

			case Item.SPELLTOME:
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
			case Weapon.MELEE:
				break;

			case Weapon.SWORD:
				a_entryObject.iconLabel = "weapon_sword";
				break;

			case Weapon.DAGGER:
				a_entryObject.iconLabel = "weapon_dagger";
				break;

			case Weapon.WARAXE:
				a_entryObject.iconLabel = "weapon_waraxe";
				break;

			case Weapon.MACE:
				a_entryObject.iconLabel = "weapon_mace";
				break;

			case Weapon.GREATSWORD:
				a_entryObject.iconLabel = "weapon_greatsword";
				break;

			case Weapon.BATTLEAXE:
				a_entryObject.iconLabel = "weapon_battleaxe";
				break;

			case Weapon.WARHAMMER:
				a_entryObject.iconLabel = "weapon_hammer";
				break;

			case Weapon.BOW:
				a_entryObject.iconLabel = "weapon_bow";
				break;

			case Weapon.STAFF:
				a_entryObject.iconLabel = "weapon_staff";
				break;

			case Weapon.CROSSBOW:
				a_entryObject.iconLabel = "weapon_crossbow";
				break;

			case Weapon.OTHER:
				break;
		}
	}

	// Ammo
	private function processAmmoIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "weapon_arrow";
		a_entryObject.iconColor = 0xA89E8C;

		switch(a_entryObject.subType) {
			case Weapon.ARROW:
				a_entryObject.iconLabel = "weapon_arrow";
				break;
			case Weapon.BOLT:
				a_entryObject.iconLabel = "weapon_bolt";
				break;
		}
	}

	private function processPotionIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_potion";

		switch(a_entryObject.subType) {
			case Item.DRINK:
				a_entryObject.iconLabel = "food_wine";
				break;

			case Item.FOOD:
				a_entryObject.iconLabel = "default_food";
				break;
				
			case Item.POISON:
				a_entryObject.iconLabel = "potion_poison";
				a_entryObject.iconColor = 0xAD00B3;
				break;
				
			case Item.HEALTH:
			case Item.HEALRATE:
			case Item.HEALRATEMULT:
				a_entryObject.iconLabel = "potion_health";
				a_entryObject.iconColor = 0xDB2E73;
				break;
				
			case Item.MAGICKA:
			case Item.MAGICKARATE:
			case Item.MAGICKARATEMULT:
				a_entryObject.iconLabel = "potion_magic";
				a_entryObject.iconColor = 0x2E9FDB;
				break;
				
			case Item.STAMINA:	
			case Item.STAMINARATE:
			case Item.STAMINARATEMULT:
				a_entryObject.iconLabel = "potion_stam";
				a_entryObject.iconColor = 0x51DB2E;
				break;

			case Item.FIRERESIST:
				a_entryObject.iconLabel = "potion_fire";
				break;

			case Item.SHOCKRESIST:
				a_entryObject.iconLabel = "potion_shock";
				break;

			case Item.FROSTRESIST:
				a_entryObject.iconLabel = "potion_frost";
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

			case Item.SOULGEM_GRAND:
				a_entryObject.iconColor = 0x948BFC;
				processGrandSoulGemIcon(a_entryObject);
				break;

			case Item.SOULGEM_GREATER:
				a_entryObject.iconColor = 0x7569FF;
				processGrandSoulGemIcon(a_entryObject);
				break;
		}
	}

	private function processGrandSoulGemIcon(a_entryObject: Object): Void {
		switch(a_entryObject.status) {
			case Item.SOULGEM_EMPTY:
				a_entryObject.iconLabel = "soulgem_grandempty";
				break;

			case Item.SOULGEM_FULL:
				a_entryObject.iconLabel = "soulgem_grandfull";
				break;

			case Item.SOULGEM_PARTIAL:
				a_entryObject.iconLabel = "soulgem_grandpartial";
				break;
		}
	}

	private function processSoulGemStatusIcon(a_entryObject: Object): Void {
		switch(a_entryObject.status) {
			case Item.SOULGEM_EMPTY:
				a_entryObject.iconLabel = "soulgem_empty";
				break;

			case Item.SOULGEM_FULL:
				a_entryObject.iconLabel = "soulgem_full";
				break;

			case Item.SOULGEM_PARTIAL:
				a_entryObject.iconLabel = "soulgem_partial";
				break;
		}
	}

	private function processMiscIcon(a_entryObject: Object): Void
	{
		a_entryObject.iconLabel = "default_misc";

		switch(a_entryObject.subType) {
			case Item.CHILDRENSCLOTHES:
				break;

			case Item.TOY:
				break;

			case Item.WEAPONRACK:
				break;

			case Item.SHELF:
				break;

			case Item.FURNITURE:
				break;

			case Item.EXTERIOR:
				break;

			case Item.CONTAINER:
				break;

			case Item.HOUSEPART:
				break;

			case Item.FASTENER:
				break;

			case Item.ARTIFACT:
				a_entryObject.iconLabel = "misc_artifact";
				break;

			case Item.GEM:
				a_entryObject.iconLabel = "misc_gem";
				a_entryObject.iconColor = 0xFFB0D1;
				break;

			case Item.HIDE:
				a_entryObject.iconLabel = "misc_hide";
				a_entryObject.iconColor = 0xDBB36E;
				break;

			case Item.TOOL:
				break;

			case Item.REMAINS:
				a_entryObject.iconLabel = "misc_remains";
				break;

			case Item.INGOT:
				a_entryObject.iconLabel = "misc_ingot"; //"misc_ore"
				a_entryObject.iconColor = 0x828282;
				break;

			case Item.CLUTTER:
				a_entryObject.iconLabel = "misc_clutter";
				break;

			case Item.FIREWOOD:
				break;
		}
	}


}


// skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);