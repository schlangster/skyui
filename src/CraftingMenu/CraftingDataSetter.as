import skyui.util.Translator;

import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Material;
import skyui.defines.Weapon;
import skyui.defines.Inventory;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


// @abstract
class CraftingDataSetter implements IListProcessor
{
  /* INITIALIZATION */
  
	public function CraftingDataSetter()
	{
		super();
	}
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.skyui_itemDataProcessed)
				continue;
				
			e.skyui_itemDataProcessed = true;
			
			// Fix wrong property names
			fixSKSEExtendedObject(e);

			processEntry(e);
		}
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function processEntry(a_entryObject: Object): Void
	{
		a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;

		a_entryObject.isEquipped = (a_entryObject.equipState > 0);

		a_entryObject.infoValue = (a_entryObject.value > 0) ? (Math.round(a_entryObject.value * 100) / 100) : null;
		a_entryObject.infoWeight =(a_entryObject.weight > 0) ? (Math.round(a_entryObject.weight * 100) / 100) : null;
		
		a_entryObject.infoValueWeight = (a_entryObject.weight > 0 && a_entryObject.value > 0) ? (Math.round((a_entryObject.value / a_entryObject.weight) * 100) / 100) : null;

		switch (a_entryObject.formType) {
			case Form.TYPE_SCROLLITEM:
				a_entryObject.subTypeDisplay = Translator.translate("$Scroll");
				
				a_entryObject.duration = (a_entryObject.duration > 0) ? (Math.round(a_entryObject.duration * 100) / 100) : null;
				a_entryObject.magnitude = (a_entryObject.magnitude > 0) ? (Math.round(a_entryObject.magnitude * 100) / 100) : null;
				
				break;

			case Form.TYPE_ARMOR:
				a_entryObject.infoArmor = (a_entryObject.armor > 0) ? (Math.round(a_entryObject.armor * 100) / 100) : null;
				
				processArmorClass(a_entryObject);
				processArmorPartMask(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processArmorOther(a_entryObject);
				processArmorBaseId(a_entryObject);
				break;

			case Form.TYPE_BOOK:
				processBookType(a_entryObject);
				break;

			case Form.TYPE_INGREDIENT:
				a_entryObject.subTypeDisplay = Translator.translate("$Ingredient");
				break;

			case Form.TYPE_LIGHT:
				a_entryObject.subTypeDisplay = Translator.translate("$Torch");
				break;

			case Form.TYPE_MISC:
				processMiscType(a_entryObject);
				processMiscBaseId(a_entryObject);
				break;

			case Form.TYPE_WEAPON:
				a_entryObject.infoDamage = (a_entryObject.damage > 0) ? (Math.round(a_entryObject.damage * 100) / 100) : null;
				
				processWeaponType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processWeaponBaseId(a_entryObject);
				break;

			case Form.TYPE_AMMO:
				a_entryObject.infoDamage = (a_entryObject.damage > 0) ? (Math.round(a_entryObject.damage * 100) / 100) : null;
				
				processAmmoType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processAmmoBaseId(a_entryObject);
				break;

			case Form.TYPE_KEY:
				processKeyType(a_entryObject);
				break;

			case Form.TYPE_POTION:
				a_entryObject.duration = (a_entryObject.duration > 0) ? (Math.round(a_entryObject.duration * 100) / 100) : null;
				a_entryObject.magnitude = (a_entryObject.magnitude > 0) ? (Math.round(a_entryObject.magnitude * 100) / 100) : null;
			
				processPotionType(a_entryObject);
				break;

			case Form.TYPE_SOULGEM:
				processSoulGemType(a_entryObject);
				processSoulGemStatus(a_entryObject);
				processSoulGemBaseId(a_entryObject);
				break;
		}
	}


  /* PRIVATE FUNCTIONS */

	private function processArmorClass(a_entryObject: Object): Void
	{
		if (a_entryObject.weightClass == Armor.WEIGHT_NONE)
			a_entryObject.weightClass = null;
			
		a_entryObject.weightClassDisplay = Translator.translate("$Other");

		switch (a_entryObject.weightClass) {
			case Armor.WEIGHT_LIGHT:
				a_entryObject.weightClassDisplay = Translator.translate("$Light");
				break;

			case Armor.WEIGHT_HEAVY:
				a_entryObject.weightClassDisplay = Translator.translate("$Heavy");
				break;

			default:
				if (a_entryObject.keywords == undefined)
					break;

				if (a_entryObject.keywords["VendorItemClothing"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_CLOTHING;
					a_entryObject.weightClassDisplay = Translator.translate("$Clothing");
				} else if (a_entryObject.keywords["VendorItemJewelry"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
					a_entryObject.weightClassDisplay = Translator.translate("$Jewelry");
				}	 
		}
	}

	private function processMaterialKeywords(a_entryObject: Object): Void
	{
		a_entryObject.material = null;
		a_entryObject.materialDisplay = Translator.translate("$Other");

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["ArmorMaterialDaedric"] != undefined ||
			a_entryObject.keywords["WeapMaterialDaedric"] != undefined) {
			a_entryObject.material = Material.DAEDRIC;
			a_entryObject.materialDisplay = Translator.translate("$Daedric");
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonplate"] != undefined) {
			a_entryObject.material = Material.DRAGONPLATE;
			a_entryObject.materialDisplay = Translator.translate("$Dragonplate");
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonscale"] != undefined) {
			a_entryObject.material = Material.DRAGONSCALE;
			a_entryObject.materialDisplay = Translator.translate("$Dragonscale");
		
		} else if (a_entryObject.keywords["ArmorMaterialDwarven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialDwarven"] != undefined) {
			a_entryObject.material = Material.DWARVEN;
			a_entryObject.materialDisplay = Translator.translate("$Dwarven");
		
		} else if (a_entryObject.keywords["ArmorMaterialEbony"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialEbony"] != undefined) {
			a_entryObject.material = Material.EBONY;
			a_entryObject.materialDisplay = Translator.translate("$Ebony");
		
		} else if (a_entryObject.keywords["ArmorMaterialElven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialElven"] != undefined) {
			a_entryObject.material = Material.ELVEN;
			a_entryObject.materialDisplay = Translator.translate("$Elven");
		
		} else if (a_entryObject.keywords["ArmorMaterialElvenGilded"] != undefined) {
			a_entryObject.material = Material.ELVENGILDED;
			a_entryObject.materialDisplay = Translator.translate("$Elven Gilded");
		
		} else if (a_entryObject.keywords["ArmorMaterialGlass"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialGlass"] != undefined) {
			a_entryObject.material = Material.GLASS;
			a_entryObject.materialDisplay = Translator.translate("$Glass");
		
		} else if (a_entryObject.keywords["ArmorMaterialHide"] != undefined) {
			a_entryObject.material = Material.HIDE;
			a_entryObject.materialDisplay = Translator.translate("$Hide");
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialHeavy"] != undefined ||
		 		   a_entryObject.keywords["ArmorMaterialImperialLight"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialImperial"] != undefined) {
			a_entryObject.material = Material.IMPERIAL;
			a_entryObject.materialDisplay = Translator.translate("$Imperial");
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialStudded"] != undefined) {
			a_entryObject.material = Material.IMPERIALSTUDDED;
			a_entryObject.materialDisplay = Translator.translate("$Studded");
		
		} else if (a_entryObject.keywords["ArmorMaterialIron"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialIron"] != undefined) {
			a_entryObject.material = Material.IRON;
			a_entryObject.materialDisplay = Translator.translate("$Iron");
		
		} else if (a_entryObject.keywords["ArmorMaterialIronBanded"] != undefined) {
			a_entryObject.material = Material.IRONBANDED;
			a_entryObject.materialDisplay = Translator.translate("$Iron Banded");
		
		// Must be above leather, vampire armor has 2 material keywords
		} else if (a_entryObject.keywords["DLC1ArmorMaterialVampire"] != undefined) {
			a_entryObject.material = Material.VAMPIRE;
			a_entryObject.materialDisplay = Translator.translate("$Vampire");

		} else if (a_entryObject.keywords["ArmorMaterialLeather"] != undefined) {
			a_entryObject.material = Material.LEATHER;
			a_entryObject.materialDisplay = Translator.translate("$Leather");
		
		} else if (a_entryObject.keywords["ArmorMaterialOrcish"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialOrcish"] != undefined) {
			a_entryObject.material = Material.ORCISH;
			a_entryObject.materialDisplay = Translator.translate("$Orcish");
		
		} else if (a_entryObject.keywords["ArmorMaterialScaled"] != undefined) {
			a_entryObject.material = Material.SCALED;
			a_entryObject.materialDisplay = Translator.translate("$Scaled");
		
		} else if (a_entryObject.keywords["ArmorMaterialSteel"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialSteel"] != undefined) {
			a_entryObject.material = Material.STEEL;
			a_entryObject.materialDisplay = Translator.translate("$Steel");
		
		} else if (a_entryObject.keywords["ArmorMaterialSteelPlate"] != undefined) {
			a_entryObject.material = Material.STEELPLATE;
			a_entryObject.materialDisplay = Translator.translate("$Steel Plate");
		
		} else if (a_entryObject.keywords["ArmorMaterialStormcloak"] != undefined) {
			a_entryObject.material = Material.STORMCLOAK;
			a_entryObject.materialDisplay = Translator.translate("$Stormcloak");
		
		} else if (a_entryObject.keywords["ArmorMaterialStudded"] != undefined) {
			a_entryObject.material = Material.STUDDED;
			a_entryObject.materialDisplay = Translator.translate("$Studded");
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialDawnguard"] != undefined) {
			a_entryObject.material = Material.DAWNGUARD;
			a_entryObject.materialDisplay = Translator.translate("$Dawnguard");
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialFalmerHardened"] != undefined ||
					a_entryObject.keywords["DLC1ArmorMaterialFalmerHeavy"] != undefined) {
			a_entryObject.material = Material.FALMERHARDENED;
			a_entryObject.materialDisplay = Translator.translate("$Falmer Hardened");
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialHunter"] != undefined) {
			a_entryObject.material = Material.HUNTER;
			a_entryObject.materialDisplay = Translator.translate("$Hunter");
		
		} else if (a_entryObject.keywords["DLC1LD_CraftingMaterialAetherium"] != undefined) {
			a_entryObject.material = Material.AETHERIUM;
			a_entryObject.materialDisplay = Translator.translate("$Aetherium");
		
		} else if (a_entryObject.keywords["DLC1WeapMaterialDragonbone"] != undefined) {
			a_entryObject.material = Material.DRAGONBONE;
			a_entryObject.materialDisplay = Translator.translate("$Dragonbone");
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialBonemoldHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialBonemoldLight"] != undefined) {
			a_entryObject.material = Material.BONEMOLD;
			a_entryObject.materialDisplay = Translator.translate("$Bonemold");

		} else if (a_entryObject.keywords["DLC2ArmorMaterialChitinHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialChitinLight"] != undefined) {
			a_entryObject.material = Material.CHITIN;
			a_entryObject.materialDisplay = Translator.translate("$Chitin");
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialMoragTong"] != undefined) {
			a_entryObject.material = Material.MORAGTONG;
			a_entryObject.materialDisplay = Translator.translate("$Morag Tong");
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialNordicHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialNordicLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeaponMaterialNordic"] != undefined) {
			a_entryObject.material = Material.NORDIC;
			a_entryObject.materialDisplay = Translator.translate("$Nordic");
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialStalhrimHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialStalhrimLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeaponMaterialStalhrim"] != undefined) {
			a_entryObject.material = Material.STALHRIM;
			a_entryObject.materialDisplay = Translator.translate("$Stalhrim");
			if (a_entryObject.keywords["DLC2dunHaknirArmor"] != undefined) {
				a_entryObject.material = Material.DEATHBRAND;
				a_entryObject.materialDisplay = Translator.translate("$Deathbrand");
			}
		
		} else if (a_entryObject.keywords["WeapMaterialDraugr"] != undefined) {
			a_entryObject.material = Material.DRAUGR;
			a_entryObject.materialDisplay = Translator.translate("$Draugr");
		
		} else if (a_entryObject.keywords["WeapMaterialDraugrHoned"] != undefined) {
			a_entryObject.material = Material.DRAUGRHONED;
			a_entryObject.materialDisplay = Translator.translate("$Draugr Honed");
		
		} else if (a_entryObject.keywords["WeapMaterialFalmer"] != undefined) {
			a_entryObject.material = Material.FALMER;
			a_entryObject.materialDisplay = Translator.translate("$Falmer");
		
		} else if (a_entryObject.keywords["WeapMaterialFalmerHoned"] != undefined) {
			a_entryObject.material = Material.FALMERHONED;
			a_entryObject.materialDisplay = Translator.translate("$Falmer Honed");
		
		} else if (a_entryObject.keywords["WeapMaterialSilver"] != undefined) {
			a_entryObject.material = Material.SILVER;
			a_entryObject.materialDisplay = Translator.translate("$Silver");
		
		} else if (a_entryObject.keywords["WeapMaterialWood"] != undefined) {
			a_entryObject.material = Material.WOOD;
			a_entryObject.materialDisplay = Translator.translate("$Wood");
		}
	}

	private function processWeaponType(a_entryObject: Object): Void
	{
		a_entryObject.subType = null;
		a_entryObject.subTypeDisplay = Translator.translate("$Weapon");

		switch (a_entryObject.weaponType) {
			case Weapon.ANIM_HANDTOHANDMELEE:
			case Weapon.ANIM_H2H:
				a_entryObject.subType = Weapon.TYPE_MELEE;
				a_entryObject.subTypeDisplay = Translator.translate("$Melee");
				break;

			case Weapon.ANIM_ONEHANDSWORD:
			case Weapon.ANIM_1HS:
				a_entryObject.subType = Weapon.TYPE_SWORD;
				a_entryObject.subTypeDisplay = Translator.translate("$Sword");
				break;

			case Weapon.ANIM_ONEHANDDAGGER:
			case Weapon.ANIM_1HD:
				a_entryObject.subType = Weapon.TYPE_DAGGER;
				a_entryObject.subTypeDisplay = Translator.translate("$Dagger");
				break;

			case Weapon.ANIM_ONEHANDAXE:
			case Weapon.ANIM_1HA:
				a_entryObject.subType = Weapon.TYPE_WARAXE;
				a_entryObject.subTypeDisplay = Translator.translate("$War Axe");
				break;

			case Weapon.ANIM_ONEHANDMACE:
			case Weapon.ANIM_1HM:
				a_entryObject.subType = Weapon.TYPE_MACE;
				a_entryObject.subTypeDisplay = Translator.translate("$Mace");
				break;

			case Weapon.ANIM_TWOHANDSWORD:
			case Weapon.ANIM_2HS:
				a_entryObject.subType = Weapon.TYPE_GREATSWORD;
				a_entryObject.subTypeDisplay = Translator.translate("$Greatsword");
				break;

			case Weapon.ANIM_TWOHANDAXE:
			case Weapon.ANIM_2HA:
				a_entryObject.subType = Weapon.TYPE_BATTLEAXE;
				a_entryObject.subTypeDisplay = Translator.translate("$Battleaxe");

				if (a_entryObject.keywords != undefined && a_entryObject.keywords["WeapTypeWarhammer"] != undefined) {
					a_entryObject.subType = Weapon.TYPE_WARHAMMER;
					a_entryObject.subTypeDisplay = Translator.translate("$Warhammer");
				}
				break;

			case Weapon.ANIM_BOW:
			case Weapon.ANIM_BOW2:
				a_entryObject.subType = Weapon.TYPE_BOW;
				a_entryObject.subTypeDisplay = Translator.translate("$Bow");
				break;

			case Weapon.ANIM_STAFF:
			case Weapon.ANIM_STAFF2:
				a_entryObject.subType = Weapon.TYPE_STAFF;
				a_entryObject.subTypeDisplay = Translator.translate("$Staff");
				break;

			case Weapon.ANIM_CROSSBOW:
			case Weapon.ANIM_CBOW:
				a_entryObject.subType = Weapon.TYPE_CROSSBOW;
				a_entryObject.subTypeDisplay = Translator.translate("$Crossbow");
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
				a_entryObject.subTypeDisplay = Translator.translate("$Pickaxe");
				break;
			case Form.BASEID_AXE01:
			case Form.BASEID_DUNHALTEDSTREAMPOACHERSAXE:
				a_entryObject.subType = Weapon.TYPE_WOODAXE;
				a_entryObject.subTypeDisplay = Translator.translate("$Wood Axe");
				break;
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
				a_entryObject.subTypeDisplay = Translator.translate("$Head");
				break;
			case Armor.PARTMASK_HAIR:
				a_entryObject.subType = Armor.EQUIP_HAIR;
				a_entryObject.subTypeDisplay = Translator.translate("$Head");
				break;
			case Armor.PARTMASK_LONGHAIR:
				a_entryObject.subType = Armor.EQUIP_LONGHAIR;
				a_entryObject.subTypeDisplay = Translator.translate("$Head");
				break;

			case Armor.PARTMASK_BODY:
				a_entryObject.subType = Armor.EQUIP_BODY;
				a_entryObject.subTypeDisplay = Translator.translate("$Body");
				break;

			case Armor.PARTMASK_HANDS:
				a_entryObject.subType = Armor.EQUIP_HANDS;
				a_entryObject.subTypeDisplay = Translator.translate("$Hands");
				break;

			case Armor.PARTMASK_FOREARMS:
				a_entryObject.subType = Armor.EQUIP_FOREARMS;
				a_entryObject.subTypeDisplay = Translator.translate("$Forearms");
				break;

			case Armor.PARTMASK_AMULET:
				a_entryObject.subType = Armor.EQUIP_AMULET;
				a_entryObject.subTypeDisplay = Translator.translate("$Amulet");
				break;

			case Armor.PARTMASK_RING:
				a_entryObject.subType = Armor.EQUIP_RING;
				a_entryObject.subTypeDisplay = Translator.translate("$Ring");
				break;

			case Armor.PARTMASK_FEET:
				a_entryObject.subType = Armor.EQUIP_FEET;
				a_entryObject.subTypeDisplay = Translator.translate("$Feet");
				break;

			case Armor.PARTMASK_CALVES:
				a_entryObject.subType = Armor.EQUIP_CALVES;
				a_entryObject.subTypeDisplay = Translator.translate("$Calves");
				break;

			case Armor.PARTMASK_SHIELD:
				a_entryObject.subType = Armor.EQUIP_SHIELD;
				a_entryObject.subTypeDisplay = Translator.translate("$Shield");
				break;

			case Armor.PARTMASK_CIRCLET:
				a_entryObject.subType = Armor.EQUIP_CIRCLET;
				a_entryObject.subTypeDisplay = Translator.translate("$Circlet");
				break;

			case Armor.PARTMASK_EARS:
				a_entryObject.subType = Armor.EQUIP_EARS;
				a_entryObject.subTypeDisplay = Translator.translate("$Ears");
				break;

			case Armor.PARTMASK_TAIL:
				a_entryObject.subType = Armor.EQUIP_TAIL;
				a_entryObject.subTypeDisplay = Translator.translate("$Tail");
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
				a_entryObject.weightClassDisplay = Translator.translate("$Clothing");
				break;

			case Armor.PARTMASK_AMULET:
			case Armor.PARTMASK_RING:
			case Armor.PARTMASK_CIRCLET:
			case Armor.PARTMASK_EARS:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				a_entryObject.weightClassDisplay = Translator.translate("$Jewelry");
				break;
		}
	}

	private function processArmorBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_CLOTHESWEDDINGWREATH:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				a_entryObject.weightClassDisplay = Translator.translate("$Jewelry");
				break
			case Form.BASEID_DLC1CLOTHESVAMPIRELORDARMOR:
				a_entryObject.subType = Armor.EQUIP_BODY;
				a_entryObject.subTypeDisplay = Translator.translate("$Body");
				break;
		}
	}

	private function processBookType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = Translator.translate("$Book");

		a_entryObject.isRead = ((a_entryObject.flags & Item.BOOKFLAG_READ) != 0);
		
		if (a_entryObject.bookType == Item.BOOKTYPE_NOTE) {
			a_entryObject.subType = Item.BOOK_NOTE;
			a_entryObject.subTypeDisplay = Translator.translate("$Note");
		}

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["VendorItemRecipe"] != undefined) {
			a_entryObject.subType = Item.BOOK_RECIPE;
			a_entryObject.subTypeDisplay = Translator.translate("$Recipe");
		} else if (a_entryObject.keywords["VendorItemSpellTome"] != undefined) {
			a_entryObject.subType = Item.BOOK_SPELLTOME;
			a_entryObject.subTypeDisplay = Translator.translate("$Spell Tome");
		}
	}

	private function processAmmoType(a_entryObject: Object): Void
	{
		if ((a_entryObject.flags & Weapon.AMMOFLAG_NONBOLT) != 0) {
			a_entryObject.subType = Weapon.AMMO_ARROW;
			a_entryObject.subTypeDisplay = Translator.translate("$Arrow");
		} else {
			a_entryObject.subType = Weapon.AMMO_BOLT;
			a_entryObject.subTypeDisplay = Translator.translate("$Bolt");
		}
	}

	private function processAmmoBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_DAEDRICARROW:
				a_entryObject.material = Material.DAEDRIC;
				a_entryObject.materialDisplay = Translator.translate("$Daedric");
				break;
			case Form.BASEID_EBONYARROW:
				a_entryObject.material = Material.EBONY;
				a_entryObject.materialDisplay = Translator.translate("$Ebony");
				break;
			case Form.BASEID_GLASSARROW:
				a_entryObject.material = Material.GLASS;
				a_entryObject.materialDisplay = Translator.translate("$Glass");
				break;
			case Form.BASEID_ELVENARROW:
			case Form.BASEID_DLC1ELVENARROWBLESSED:
			case Form.BASEID_DLC1ELVENARROWBLOOD:
				a_entryObject.material = Material.ELVEN;
				a_entryObject.materialDisplay = Translator.translate("$Elven");
				break;
			case Form.BASEID_DWARVENARROW:
			case Form.BASEID_DWARVENSPHEREARROW:
			case Form.BASEID_DWARVENSPHEREBOLT01:
			case Form.BASEID_DWARVENSPHEREBOLT02:
			case Form.BASEID_DLC2DWARVENBALLISTABOLT:
				a_entryObject.material = Material.DWARVEN;
				a_entryObject.materialDisplay = Translator.translate("$Dwarven");
				break;
			case Form.BASEID_ORCISHARROW:
				a_entryObject.material = Material.ORCISH;
				a_entryObject.materialDisplay = Translator.translate("$Orcish");
				break;
			case Form.BASEID_NORDHEROARROW:
				a_entryObject.material = Material.NORDIC;
				a_entryObject.materialDisplay = Translator.translate("$Nordic");
				break;
			case Form.BASEID_DRAUGRARROW:
				a_entryObject.material = Material.DRAUGR;
				a_entryObject.materialDisplay = Translator.translate("$Draugr");
				break;
			case Form.BASEID_FALMERARROW:
				a_entryObject.material = Material.FALMER;
				a_entryObject.materialDisplay = Translator.translate("$Falmer");
				break;
			case Form.BASEID_STEELARROW:
			case Form.BASEID_MQ101STEELARROW:
				a_entryObject.material = Material.STEEL;
				a_entryObject.materialDisplay = Translator.translate("$Steel");
				break;
			case Form.BASEID_IRONARROW:
			case Form.BASEID_CWARROW:
			case Form.BASEID_CWARROWSHORT:
			case Form.BASEID_TRAPDART:
			case Form.BASEID_DUNARCHERPRATICEARROW:
			case Form.BASEID_DUNGEIRMUNDSIGDISARROWSILLUSION:
			case Form.BASEID_FOLLOWERIRONARROW:
			case Form.BASEID_TESTDLC1BOLT:
				a_entryObject.material = Material.IRON;
				a_entryObject.materialDisplay = Translator.translate("$Iron");
				break;
			case Form.BASEID_FORSWORNARROW:
				a_entryObject.material = Material.HIDE;
				a_entryObject.materialDisplay = Translator.translate("$Forsworn");
				break;
			case Form.BASEID_DLC2RIEKLINGSPEARTHROWN:
				a_entryObject.material = Material.WOOD;
				a_entryObject.materialDisplay = Translator.translate("$Wood");
				a_entryObject.subTypeDisplay = Translator.translate("$Spear");
				break;

		}
	}

	private function processKeyType(a_entryObject: Object): Void
	{
		a_entryObject.subTypeDisplay = Translator.translate("$Key");

		if (a_entryObject.infoValue <= 0)
			a_entryObject.infoValue = null;

		if (a_entryObject.infoValue <= 0)
			a_entryObject.infoValue = null;
	}

	private function processPotionType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.POTION_POTION;
		a_entryObject.subTypeDisplay = Translator.translate("$Potion");

		if ((a_entryObject.flags & Item.ALCHFLAG_FOOD) != 0) {
			a_entryObject.subType = Item.POTION_FOOD;
			a_entryObject.subTypeDisplay = Translator.translate("$Food");

			// SKSE >= 1.6.6
			if (a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == Form.FORMID_ITMPotionUse) {
				a_entryObject.subType = Item.POTION_DRINK;
				a_entryObject.subTypeDisplay = Translator.translate("$Drink");
			}
			
		} else if ((a_entryObject.flags & Item.ALCHFLAG_POISON) != 0) {
			a_entryObject.subType = Item.POTION_POISON;
			a_entryObject.subTypeDisplay = Translator.translate("$Poison");
		} else {
			switch (a_entryObject.actorValue) {
				case Actor.AV_HEALTH:
					a_entryObject.subType = Item.POTION_HEALTH;
					a_entryObject.subTypeDisplay = Translator.translate("$Health");
					break;
				case Actor.AV_MAGICKA:
					a_entryObject.subType = Item.POTION_MAGICKA;
					a_entryObject.subTypeDisplay = Translator.translate("$Magicka");
					break;
				case Actor.AV_STAMINA:
					a_entryObject.subType = Item.POTION_STAMINA;
					a_entryObject.subTypeDisplay = Translator.translate("$Stamina");
					break;

				case Actor.AV_HEALRATE:
					a_entryObject.subType = Item.POTION_HEALRATE;
					a_entryObject.subTypeDisplay = Translator.translate("$Health");
					break;
				case Actor.AV_MAGICKARATE:
					a_entryObject.subType = Item.POTION_MAGICKARATE;
					a_entryObject.subTypeDisplay = Translator.translate("$Magicka");
					break;
				case Actor.AV_STAMINARATE:
					a_entryObject.subType = Item.POTION_STAMINARATE;
					a_entryObject.subTypeDisplay = Translator.translate("$Stamina");
					break;

				case Actor.AV_HEALRATEMULT:
					a_entryObject.subType = Item.POTION_HEALRATEMULT;
					a_entryObject.subTypeDisplay = Translator.translate("$Health");
					break;
				case Actor.AV_MAGICKARATEMULT:
					a_entryObject.subType = Item.POTION_MAGICKARATEMULT;
					a_entryObject.subTypeDisplay = Translator.translate("$Magicka");
					break;
				case Actor.AV_STAMINARATEMULT:
					a_entryObject.subType = Item.POTION_STAMINARATEMULT;
					a_entryObject.subTypeDisplay = Translator.translate("$Stamina");
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

	private function processSoulGemType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = Translator.translate("$Soul Gem");

		// Ignores soulgems that have a size of None
		if (a_entryObject.gemSize != undefined && a_entryObject.gemSize != Item.SOULGEM_NONE)
			a_entryObject.subType = a_entryObject.gemSize;
	}

	private function processSoulGemStatus(a_entryObject: Object): Void
	{
		if (a_entryObject.gemSize == undefined || a_entryObject.soulSize == undefined || a_entryObject.soulSize == Item.SOULGEM_NONE)
			a_entryObject.status = Item.SOULGEMSTATUS_EMPTY;
		else if (a_entryObject.soulSize >= a_entryObject.gemSize)
			a_entryObject.status = Item.SOULGEMSTATUS_FULL;
		else
			a_entryObject.status = Item.SOULGEMSTATUS_PARTIAL;
			
		if (a_entryObject.soulSize != undefined)
		{
			switch (a_entryObject.soulSize)
			{
			case Item.SOULGEM_NONE:
				a_entryObject.soulSizeDisplay = "$Empty";
				break;
			case Item.SOULGEM_PETTY:
				a_entryObject.soulSizeDisplay = "$Petty";
				break;
			case Item.SOULGEM_LESSER:
				a_entryObject.soulSizeDisplay = "$Lesser";
				break;
			case Item.SOULGEM_COMMON:
				a_entryObject.soulSizeDisplay = "$Common";
				break;
			case Item.SOULGEM_GREATER:
				a_entryObject.soulSizeDisplay = "$Greater";
				break;
			case Item.SOULGEM_GRAND:
			case Item.SOULGEM_AZURA:
				a_entryObject.soulSizeDisplay = "$Grand";
				break;
			}
		}
	}

	private function processSoulGemBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_DA01SOULGEMBLACKSTAR:
			case Form.BASEID_DA01SOULGEMAZURASSTAR:
				a_entryObject.subType = Item.SOULGEM_AZURA;
				break;
		}
	}

	private function processMiscType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = Translator.translate("$Misc");

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["BYOHAdoptionClothesKeyword"] != undefined) {
			a_entryObject.subType = Item.MISC_CHILDRENSCLOTHES;
			a_entryObject.subTypeDisplay = Translator.translate("$Clothing");

		} else if (a_entryObject.keywords["BYOHAdoptionToyKeyword"] != undefined) {
			a_entryObject.subType = Item.MISC_TOY;
			a_entryObject.subTypeDisplay = Translator.translate("$Toy");

		
		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryWeaponRacks"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryShelf"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategoryFurniture"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryExterior"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategoryContainers"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryBuilding"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategorySmithing"] != undefined) {
			a_entryObject.subType = Item.MISC_HOUSEPART;
			a_entryObject.subTypeDisplay = Translator.translate("$House Part");
		

		} else if (a_entryObject.keywords["VendorItemDaedricArtifact"] != undefined) {
			a_entryObject.subType = Item.MISC_ARTIFACT;
			a_entryObject.subTypeDisplay = Translator.translate("$Artifact");

		} else if (a_entryObject.keywords["VendorItemGem"] != undefined) {
			a_entryObject.subType = Item.MISC_GEM;
			a_entryObject.subTypeDisplay = Translator.translate("$Gem");

		} else if (a_entryObject.keywords["VendorItemAnimalHide"] != undefined) {
			a_entryObject.subType = Item.MISC_HIDE;
			a_entryObject.subTypeDisplay = Translator.translate("$Hide");

		} else if (a_entryObject.keywords["VendorItemTool"] != undefined) {
			a_entryObject.subType = Item.MISC_TOOL;
			a_entryObject.subTypeDisplay = Translator.translate("$Tool");

		} else if (a_entryObject.keywords["VendorItemAnimalPart"] != undefined) {
			a_entryObject.subType = Item.MISC_REMAINS;
			a_entryObject.subTypeDisplay = Translator.translate("$Remains");

		} else if (a_entryObject.keywords["VendorItemOreIngot"] != undefined) {
			a_entryObject.subType = Item.MISC_INGOT;
			a_entryObject.subTypeDisplay = Translator.translate("$Ingot");

		} else if (a_entryObject.keywords["VendorItemClutter"] != undefined) {
			a_entryObject.subType = Item.MISC_CLUTTER;
			a_entryObject.subTypeDisplay = Translator.translate("$Clutter");

		} else if (a_entryObject.keywords["VendorItemFirewood"] != undefined) {
			a_entryObject.subType = Item.MISC_FIREWOOD;
			a_entryObject.subTypeDisplay = Translator.translate("$Firewood");
		}
	}

	private function processMiscBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_GEMAMETHYSTFLAWLESS:
				a_entryObject.subType = Item.MISC_GEM;
				a_entryObject.subTypeDisplay = Translator.translate("$Gem");
				break;

			case Form.BASEID_RUBYDRAGONCLAW:
			case Form.BASEID_IVORYDRAGONCLAW:
			case Form.BASEID_GLASSCLAW:
			case Form.BASEID_EBONYCLAW:
			case Form.BASEID_EMERALDDRAGONCLAW:
			case Form.BASEID_DIAMONDCLAW:
			case Form.BASEID_IRONCLAW:
			case Form.BASEID_CORALDRAGONCLAW:
			case Form.BASEID_E3GOLDENCLAW:
			case Form.BASEID_SAPPHIREDRAGONCLAW:
			case Form.BASEID_MS13GOLDENCLAW:
				a_entryObject.subTypeDisplay = Translator.translate("$Claw");
				a_entryObject.subType = Item.MISC_DRAGONCLAW;
				break;

			case Form.BASEID_LOCKPICK:
				a_entryObject.subType = Item.MISC_LOCKPICK;
				a_entryObject.subTypeDisplay = Translator.translate("$Lockpick");
				break;

			case Form.BASEID_GOLD001:
				a_entryObject.subType = Item.MISC_GOLD;
				a_entryObject.subTypeDisplay = Translator.translate("$Gold");
				break;

			case Form.BASEID_LEATHER01:
				a_entryObject.subTypeDisplay = Translator.translate("$Leather");
				a_entryObject.subType = Item.MISC_LEATHER;
				break;
			case Form.BASEID_LEATHERSTRIPS:
				a_entryObject.subTypeDisplay = Translator.translate("$Strips");
				a_entryObject.subType = Item.MISC_LEATHERSTRIPS;
				break;
		}
	}
	
	private function fixSKSEExtendedObject(a_extendedObject: Object): Void
	{
		if (a_extendedObject.formType == undefined)
			return;

		switch(a_extendedObject.formType) {
			case Form.TYPE_SPELL:
			case Form.TYPE_SCROLLITEM:
			case Form.TYPE_INGREDIENT:
			case Form.TYPE_POTION:
			case Form.TYPE_EFFECTSETTING:

				// school is sent as subType
				if (a_extendedObject.school == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.school = a_extendedObject.subType;
					delete(a_extendedObject.subType);
				}

				// resistance is sent as magicType
				if (a_extendedObject.resistance == undefined && a_extendedObject.magicType != undefined) {
					a_extendedObject.resistance = a_extendedObject.magicType;
					delete(a_extendedObject.magicType);
				}

				// primaryValue is sent as actorValue
				/* // Ignore
				if (a_extendedObject.primaryValue == undefined && a_extendedObject.actorValue != undefined) {
					a_extendedObject.primaryValue = a_extendedObject.actorValue;
					delete(a_extendedObject.actorValue);
				}
				*/
				break;

			case Form.TYPE_WEAPON:
				// weaponType is sent as subType
				if (a_extendedObject.weaponType == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.weaponType = a_extendedObject.subType;
					delete(a_extendedObject.subType);
				}
				break;

			case Form.TYPE_BOOK:
				// (SKSE < 1.6.6) flags and bookType (and some padding) are sent as one UInt32 bookType
				if (a_extendedObject.flags == undefined && a_extendedObject.bookType != undefined) {
					var oldBookType: Number = a_extendedObject.bookType;
					a_extendedObject.bookType	= (oldBookType & 0xFF00) >>> 8;
					a_extendedObject.flags		= (oldBookType & 0x00FF);
				}
				break;

			default:
				break;
		}

	}
}