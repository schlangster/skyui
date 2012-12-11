import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Material;
import skyui.defines.Weapon;

class InventoryDataSetter extends ItemcardDataExtender
{
  /* PRIVATE VARIABLES */

	private var _combinedValue: Boolean;
	private var _combinedWeight: Boolean;

  /* PUBLIC FUNCTIONS */

	public function InventoryDataSetter(a_configItemList: Object, a_configAppearance: Object)
	{
		super();
		
		_combinedValue	= a_configItemList.inventory.combinedValue;
		_combinedWeight	= a_configItemList.inventory.combinedWeight;
	}

	// @override ItemcardDataExtender
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		//skyui.util.Debug.dump("a_entryObject", a_entryObject);
		//skyui.util.Debug.dump("a_itemInfo", a_itemInfo);

		a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;
		a_entryObject.type = a_itemInfo.type;
		a_entryObject.value = a_itemInfo.value;// * (_sortByCombinedValue ? a_entryObject.count : 1);
		a_entryObject.weight = a_itemInfo.weight;// * (_sortByCombinedWeight ? a_entryObject.count : 1);
		a_entryObject.armor = a_itemInfo.armor;
		a_entryObject.damage = a_itemInfo.damage;

		a_entryObject.valueWeight = (a_itemInfo.weight > 0) ? (a_itemInfo.value / a_itemInfo.weight) : ((a_itemInfo.value != 0) ? undefined : 0); // 0/0 = 0

		a_entryObject.isEquipped = (a_entryObject.equipState > 0);
		a_entryObject.isStolen = (a_itemInfo.stolen == true);
		a_entryObject.isEnchanted = false;
		a_entryObject.isPoisoned = false;

		a_entryObject.valueDisplay = String(Math.round(a_itemInfo.value * 10) / 10) + ((_combinedValue == true && a_entryObject.count > 1 && a_itemInfo.value > 0) ? (" (" + String(Math.round(a_itemInfo.value * a_entryObject.count * 10) / 10) + ")") : "");
		a_entryObject.weightDisplay = String(Math.round(a_itemInfo.weight * 10) / 10) + ((_combinedWeight == true && a_entryObject.count > 1 && a_itemInfo.weight > 0) ? (" (" + String(Math.round(a_itemInfo.weight * a_entryObject.count * 10) / 10) + ")") : "");
		a_entryObject.valueWeightDisplay = (a_entryObject.valueWeight != undefined) ? (Math.round(a_entryObject.valueWeight * 10) / 10) : "-"; // Any item without a weight but has value has a valueWeight == undefined, so should be displayed as "-"
		a_entryObject.armorDisplay = (a_entryObject.armor > 0) ? (Math.round(a_entryObject.armor * 10) / 10) : "-";
		a_entryObject.damageDisplay = (a_entryObject.damage > 0) ? (Math.round(a_entryObject.damage * 10) / 10) : "-";

		a_entryObject.subTypeDisplay = "-";
		a_entryObject.materialDisplay = "-";
		a_entryObject.weightClassDisplay = "-";

		switch (a_entryObject.formType) {
			case Form.SCROLLITEM:
				a_entryObject.subTypeDisplay = "$Scroll";
				break;

			case Form.ARMOR:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				processArmorClass(a_entryObject);
				processArmorPartMask(a_entryObject);
				processMaterialKeywords(a_entryObject);

				//Move this to the specific DataProcessor
				processArmorOther(a_entryObject);
				break;

			case Form.BOOK:
				processBookType(a_entryObject);
				break;

			case Form.INGREDIENT:
				a_entryObject.subTypeDisplay = "$Ingredient";
				break;

			case Form.LIGHT:
				a_entryObject.subTypeDisplay = "$Torch";
				break;

			case Form.MISC:
				processMiscType(a_entryObject);
				break;

			case Form.WEAPON:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				a_entryObject.isPoisoned = (a_itemInfo.poisoned == true); 
				processWeaponType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				break;

			case Form.AMMO:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				processAmmoType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				///processAmmoFormIDs(a_entryObject); //Vanilla arrows don't have material keywords
				break;

			case Form.KEY:
				processKeyType(a_entryObject);
				break;

			case Form.POTION:
				processPotionType(a_entryObject);
				break;

			case Form.SOULGEM:
				processSoulGemType(a_entryObject);
				processSoulGemStatus(a_entryObject);
				break;
		}
	}

  /* PRIVATE FUNCTIONS */

	private function processArmorClass(a_entryObject: Object): Void
	{
		if (a_entryObject.weightClass == Armor.NONE)
			a_entryObject.weightClass = Armor.OTHER
		a_entryObject.weightClassDisplay = "$Other";

		switch (a_entryObject.weightClass) {
			case Armor.LIGHT:
				a_entryObject.weightClass = Armor.LIGHT;
				a_entryObject.weightClassDisplay = "$Light";
				break;

			case Armor.HEAVY:
				a_entryObject.weightClass = Armor.HEAVY;
				a_entryObject.weightClassDisplay = "$Heavy";
				break;

			default:
				if (a_entryObject.keywords == undefined)
					break;

				if (a_entryObject.keywords["VendorItemClothing"] != undefined) {
					a_entryObject.weightClass = Armor.CLOTHING;
					a_entryObject.weightClassDisplay = "$Clothing";
				} else if (a_entryObject.keywords["VendorItemJewelry"] != undefined) {
					a_entryObject.weightClass = Armor.JEWELRY;
					a_entryObject.weightClassDisplay = "$Jewelry";
				}	 
		}
	}

	private function processMaterialKeywords(a_entryObject: Object): Void
	{
		a_entryObject.material = Material.OTHER;
		a_entryObject.materialDisplay = "$Other";

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["ArmorMaterialDaedric"] != undefined ||
			a_entryObject.keywords["WeapMaterialDaedric"] != undefined) {
			a_entryObject.material = Material.DAEDRIC;
			a_entryObject.materialDisplay = "$Daedric";
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonplate"] != undefined) {
			a_entryObject.material = Material.DRAGONPLATE;
			a_entryObject.materialDisplay = "$Dragon Plate";
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonscale"] != undefined) {
			a_entryObject.material = Material.DRAGONSCALE;
			a_entryObject.materialDisplay = "$Dragon Scale";
		
		} else if (a_entryObject.keywords["ArmorMaterialDwarven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialDwarven"] != undefined) {
			a_entryObject.material = Material.DWARVEN;
			a_entryObject.materialDisplay = "$Dwarven";
		
		} else if (a_entryObject.keywords["ArmorMaterialEbony"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialEbony"] != undefined) {
			a_entryObject.material = Material.EBONY;
			a_entryObject.materialDisplay = "$Ebony";
		
		} else if (a_entryObject.keywords["ArmorMaterialElven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialElven"] != undefined) {
			a_entryObject.material = Material.ELVEN;
			a_entryObject.materialDisplay = "$Elven";
		
		} else if (a_entryObject.keywords["ArmorMaterialElvenGilded"] != undefined) {
			a_entryObject.material = Material.ELVENGILDED;
			a_entryObject.materialDisplay = "$Elven Gilded";
		
		} else if (a_entryObject.keywords["ArmorMaterialGlass"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialGlass"] != undefined) {
			a_entryObject.material = Material.GLASS;
			a_entryObject.materialDisplay = "$Glass";
		
		} else if (a_entryObject.keywords["ArmorMaterialHide"] != undefined) {
			a_entryObject.material = Material.HIDE;
			a_entryObject.materialDisplay = "$Hide";
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialHeavy"] != undefined ||
		 		   a_entryObject.keywords["ArmorMaterialImperialLight"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialImperial"] != undefined) {
			a_entryObject.material = Material.IMPERIAL;
			a_entryObject.materialDisplay = "$Imperial";
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialStudded"] != undefined) {
			a_entryObject.material = Material.IMPERIALSTUDDED;
			a_entryObject.materialDisplay = "$Imperial Studded";
		
		} else if (a_entryObject.keywords["ArmorMaterialIron"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialIron"] != undefined) {
			a_entryObject.material = Material.IRON;
			a_entryObject.materialDisplay = "$Iron";
		
		} else if (a_entryObject.keywords["ArmorMaterialIronBanded"] != undefined) {
			a_entryObject.material = Material.IRONBANDED;
			a_entryObject.materialDisplay = "$Iron Banded";
		
		} else if (a_entryObject.keywords["ArmorMaterialLeather"] != undefined) {
			a_entryObject.material = Material.LEATHER;
			a_entryObject.materialDisplay = "$Leather";
		
		} else if (a_entryObject.keywords["ArmorMaterialOrcish"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialOrcish"] != undefined) {
			a_entryObject.material = Material.ORCISH;
			a_entryObject.materialDisplay = "$Orcish";
		
		} else if (a_entryObject.keywords["ArmorMaterialScaled"] != undefined) {
			a_entryObject.material = Material.SCALED;
			a_entryObject.materialDisplay = "$Scaled";
		
		} else if (a_entryObject.keywords["ArmorMaterialSteel"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialSteel"] != undefined) {
			a_entryObject.material = Material.STEEL;
			a_entryObject.materialDisplay = "$Steel";
		
		} else if (a_entryObject.keywords["ArmorMaterialSteelPlate"] != undefined) {
			a_entryObject.material = Material.STEELPLATE;
			a_entryObject.materialDisplay = "$Steel Plate";
		
		} else if (a_entryObject.keywords["ArmorMaterialStormcloak"] != undefined) {
			a_entryObject.material = Material.STORMCLOAK;
			a_entryObject.materialDisplay = "$Stormcloak";
		
		} else if (a_entryObject.keywords["ArmorMaterialStudded"] != undefined) {
			a_entryObject.material = Material.STUDDED;
			a_entryObject.materialDisplay = "$Studded";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialDawnguard"] != undefined) {
			a_entryObject.material = Material.DAWNGUARD;
			a_entryObject.materialDisplay = "$Dawnguard";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialFalmerHardened"] != undefined) {
			a_entryObject.material = Material.FALMERHARDENED;
			a_entryObject.materialDisplay = "$Falmer Hardened";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialHunter"] != undefined) {
			a_entryObject.material = Material.HUNTER;
			a_entryObject.materialDisplay = "$Hunter";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialVampire"] != undefined) {
			a_entryObject.material = Material.VAMPIRE;
			a_entryObject.materialDisplay = "$Vampire";
		
		} else if (a_entryObject.keywords["DLC1LD_CraftingMaterialAetherium"] != undefined) {
			a_entryObject.material = Material.AETHERIUM;
			a_entryObject.materialDisplay = "$Aetherium";
		
		} else if (a_entryObject.keywords["DLC1WeapMaterialDragonbone"] != undefined) {
			a_entryObject.material = Material.DRAGONBONE;
			a_entryObject.materialDisplay = "$Dragonbone";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialBonemoldHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialBonemoldLight"] != undefined) {
			a_entryObject.material = Material.BONEMOLD;
			a_entryObject.materialDisplay = "$Bonemold";

		} else if (a_entryObject.keywords["DLC2ArmorMaterialChitinHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialChitinLight"] != undefined) {
			a_entryObject.material = Material.CHITIN;
			a_entryObject.materialDisplay = "$Chitin";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialMoragTong"] != undefined) {
			a_entryObject.material = Material.MORAGTONG;
			a_entryObject.materialDisplay = "$Morag Tong";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialNordicHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialNordicLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeapMaterialNordic"] != undefined) {
			a_entryObject.material = Material.NORDIC;
			a_entryObject.materialDisplay = "$Nordic";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialStahlrimHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialStahlrimLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeapMaterialStahlrim"] != undefined) {
			a_entryObject.material = Material.STAHLRIM;
			a_entryObject.materialDisplay = "$Stahlrim";
			if (a_entryObject.keywords["DLC2dunHaknirArmor"] != undefined) {
				a_entryObject.material = Material.DEATHBRAND;
				a_entryObject.materialDisplay = "$Deathbrand";
			}
		
		} else if (a_entryObject.keywords["WeapMaterialDraugr"] != undefined) {
			a_entryObject.material = Material.DRAGUR;
			a_entryObject.materialDisplay = "$Dragur";
		
		} else if (a_entryObject.keywords["WeapMaterialDraugrHoned"] != undefined) {
			a_entryObject.material = Material.DRAGURHONED;
			a_entryObject.materialDisplay = "$Dragur Honed";
		
		} else if (a_entryObject.keywords["WeapMaterialFalmer"] != undefined) {
			a_entryObject.material = Material.FALMER;
			a_entryObject.materialDisplay = "$Falmer";
		
		} else if (a_entryObject.keywords["WeapMaterialFalmerHoned"] != undefined) {
			a_entryObject.material = Material.FALMERHONED;
			a_entryObject.materialDisplay = "$Falmer Honed";
		
		} else if (a_entryObject.keywords["WeapMaterialSilver"] != undefined) {
			a_entryObject.material = Material.SILVER;
			a_entryObject.materialDisplay = "$Silver";
		
		} else if (a_entryObject.keywords["WeapMaterialWood"] != undefined) {
			a_entryObject.material = Material.WOOD;
			a_entryObject.materialDisplay = "$Wood";
		}
	}

	private function processWeaponType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Weapon.OTHER;
		a_entryObject.subTypeDisplay = "$Weapon";

		switch (a_entryObject.weaponType) {
			case Weapon.TYPE_HANDTOHANDMELEE:
			case Weapon.TYPE_H2H:
				a_entryObject.subType = Weapon.MELEE;
				a_entryObject.subTypeDisplay = "$Melee";
				break;

			case Weapon.TYPE_ONEHANDSWORD:
			case Weapon.TYPE_1HS:
				a_entryObject.subType = Weapon.SWORD;
				a_entryObject.subTypeDisplay = "$Sword";
				break;

			case Weapon.TYPE_ONEHANDDAGGER:
			case Weapon.TYPE_1HD:
				a_entryObject.subType = Weapon.DAGGER;
				a_entryObject.subTypeDisplay = "$Dagger";
				break;

			case Weapon.TYPE_ONEHANDAXE:
			case Weapon.TYPE_1HA:
				a_entryObject.subType = Weapon.WARAXE;
				a_entryObject.subTypeDisplay = "$War Axe";
				break;

			case Weapon.TYPE_ONEHANDMACE:
			case Weapon.TYPE_1HM:
				a_entryObject.subType = Weapon.MACE;
				a_entryObject.subTypeDisplay = "$Mace";
				break;

			case Weapon.TYPE_TWOHANDSWORD:
			case Weapon.TYPE_2HS:
				a_entryObject.subType = Weapon.GREATSWORD;
				a_entryObject.subTypeDisplay = "$Greatsword";
				break;

			case Weapon.TYPE_TWOHANDAXE:
			case Weapon.TYPE_2HA:
				a_entryObject.subType = Weapon.BATTLEAXE;
				a_entryObject.subTypeDisplay = "$Battleaxe";

				if (a_entryObject.keywords != undefined && a_entryObject.keywords["WeapTypeWarhammer"] != undefined) {
					a_entryObject.subType = Weapon.WARHAMMER;
					a_entryObject.subTypeDisplay = "$Warhammer";
				}
				break;

			case Weapon.TYPE_BOW:
			case Weapon.TYPE_BOW2:
				a_entryObject.subType = Weapon.BOW;
				a_entryObject.subTypeDisplay = "$Bow";
				break;

			case Weapon.TYPE_STAFF:
			case Weapon.TYPE_STAFF2:
				a_entryObject.subType = Weapon.STAFF;
				a_entryObject.subTypeDisplay = "$Staff";
				break;

			case Weapon.TYPE_CROSSBOW:
			case Weapon.TYPE_CBOW:
				a_entryObject.subType = Weapon.CROSSBOW;
				a_entryObject.subTypeDisplay = "$Crossbow";
				break;
		}
	}


	private function processArmorPartMask(a_entryObject: Object): Void
	{
		if (a_entryObject.partMask == undefined)
			return;

		// Sets subType as the most important bitmask index.
		for (var i = 0; i < Armor.FLAG_PRECEDENCE.length; i++) {
			if (a_entryObject.partMask & Armor.FLAG_PRECEDENCE[i]) {
				a_entryObject.mainPartMask = Armor.FLAG_PRECEDENCE[i];
				break;
			}
		}

		if (a_entryObject.mainPartMask == undefined)
			return;

		switch (a_entryObject.mainPartMask) {
			case Armor.FLAG_HEAD:
				a_entryObject.subType = Armor.HEAD;
				a_entryObject.subTypeDisplay = "$Head";
				break;
			case Armor.FLAG_HAIR:
				a_entryObject.subType = Armor.HAIR;
				a_entryObject.subTypeDisplay = "$Head";
				break;
			case Armor.FLAG_LONGHAIR:
				a_entryObject.subType = Armor.LONGHAIR;
				a_entryObject.subTypeDisplay = "$Head";
				break;

			case Armor.FLAG_BODY:
				a_entryObject.subType = Armor.BODY;
				a_entryObject.subTypeDisplay = "$Body";
				break;

			case Armor.FLAG_HANDS:
				a_entryObject.subType = Armor.HANDS;
				a_entryObject.subTypeDisplay = "$Hands";
				break;

			case Armor.FLAG_FOREARMS:
				a_entryObject.subType = Armor.FOREARMS;
				a_entryObject.subTypeDisplay = "$Forearms";
				break;

			case Armor.FLAG_AMULET:
				a_entryObject.subType = Armor.AMULET;
				a_entryObject.subTypeDisplay = "$Amulet";
				break;

			case Armor.FLAG_RING:
				a_entryObject.subType = Armor.RING;
				a_entryObject.subTypeDisplay = "$Ring";
				break;

			case Armor.FLAG_FEET:
				a_entryObject.subType = Armor.FEET;
				a_entryObject.subTypeDisplay = "$Feet";
				break;

			case Armor.FLAG_CALVES:
				a_entryObject.subType = Armor.CALVES;
				a_entryObject.subTypeDisplay = "$Calves";
				break;

			case Armor.FLAG_SHIELD:
				a_entryObject.subType = Armor.SHIELD;
				a_entryObject.subTypeDisplay = "$Shield";
				break;

			case Armor.FLAG_CIRCLET:
				a_entryObject.subType = Armor.CIRCLET;
				a_entryObject.subTypeDisplay = "$Circlet";
				break;

			case Armor.FLAG_EARS:
				a_entryObject.subType = Armor.EARS;
				a_entryObject.subTypeDisplay = "$Ears";
				break;

			case Armor.FLAG_TAIL:
				a_entryObject.subType = Armor.TAIL;
				a_entryObject.subTypeDisplay = "$Tail";
				break;

			default:
				a_entryObject.subType = a_entryObject.mainPartMask;
				break;
		}
	}

	private function processArmorOther(a_entryObject): Void
	{
		if (a_entryObject.weightClass != Armor.OTHER)
			return;

		switch(a_entryObject.mainPartMask) {
			case Armor.FLAG_HEAD:
			case Armor.FLAG_HAIR:
			case Armor.FLAG_LONGHAIR:
			case Armor.FLAG_BODY:
			case Armor.FLAG_HANDS:
			case Armor.FLAG_FOREARMS:
			case Armor.FLAG_FEET:
			case Armor.FLAG_CALVES:
			case Armor.FLAG_SHIELD:
			case Armor.FLAG_TAIL:
				a_entryObject.weightClass = Armor.CLOTHING;
				a_entryObject.weightClassDisplay = "$Clothing";
				break;

			case Armor.FLAG_AMULET:
			case Armor.FLAG_RING:
			case Armor.FLAG_CIRCLET:
			case Armor.FLAG_EARS:
				a_entryObject.weightClass = Armor.JEWELRY;
				a_entryObject.weightClassDisplay = "$Jewelry";
				break;
		}
	}

	private function processBookType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Book";
		
		if (a_entryObject.bookType & Item.BOOK_NOTE) {
			a_entryObject.subType = Item.NOTE;
			a_entryObject.subTypeDisplay = "$Note";
		}

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["VendorItemRecipe"] != undefined) {
			a_entryObject.subType = Item.RECIPE;
			a_entryObject.subTypeDisplay = "$Recipe";
		} else if (a_entryObject.keywords["VendorItemSpellTome"] != undefined) {
			a_entryObject.subType = Item.SPELLTOME;
			a_entryObject.subTypeDisplay = "$Spell Tome";
		}
	}

	private function processAmmoType(a_entryObject: Object): Void
	{
		if ((a_entryObject.flags & Weapon.FLAG_NONBOLT) != 0) {
			a_entryObject.subType = Weapon.ARROW;
			a_entryObject.subTypeDisplay = "$Arrow";
		} else {
			a_entryObject.subType = Weapon.BOLT;
			a_entryObject.subTypeDisplay = "$Bolt";
		}
	}

	private function processKeyType(a_entryObject: Object): Void
	{
		a_entryObject.subTypeDisplay = "$Key";

		if (a_entryObject.value <= 0) {
			a_entryObject.value = undefined;
			a_entryObject.valueDisplay = "-";
		}

		if (a_entryObject.weight <= 0) {
			a_entryObject.weight = undefined;
			a_entryObject.weightDisplay = "-";
		}
	}

	private function processPotionType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.POTION;
		a_entryObject.subTypeDisplay = "$Potion";

		if ((a_entryObject.flags & Item.ALCH_FOOD) != 0) {
			a_entryObject.subType = Item.FOOD;
			a_entryObject.subTypeDisplay = "$Food";

			if (a_entryObject.type == InventoryDefines.ICT_POTION) {
				a_entryObject.subType = Item.DRINK;
				a_entryObject.subTypeDisplay = "$Drink";
			}
		} else if ((a_entryObject.flags & Item.ALCH_POISON) != 0) {
			a_entryObject.subType = Item.POISON;
			a_entryObject.subTypeDisplay = "$Poison";
		} else {
			switch (a_entryObject.actorValue) {
				case Actor.HEALTH:
					a_entryObject.subType = Item.HEALTH;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.MAGICKA:
					a_entryObject.subType = Item.MAGICKA;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.STAMINA:
					a_entryObject.subType = Item.STAMINA;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.HEALRATE:
					a_entryObject.subType = Item.HEALRATE;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.MAGICKARATE:
					a_entryObject.subType = Item.MAGICKARATE;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.STAMINARATE:
					a_entryObject.subType = Item.STAMINARATE;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.HEALRATEMULT:
					a_entryObject.subType = Item.HEALRATEMULT;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.MAGICKARATEMULT:
					a_entryObject.subType = Item.MAGICKARATEMULT;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.STAMINARATEMULT:
					a_entryObject.subType = Item.STAMINARATEMULT;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.FIRERESIST:
					a_entryObject.subType = Item.FIRERESIST;
					break;

				case Actor.ELECTRICRESIST:
					a_entryObject.subType = Item.SHOCKRESIST;
					break;

				case Actor.FROSTRESIST:
					a_entryObject.subType = Item.FROSTRESIST;
					break;
			}
		}
	}

	private function processSoulGemType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Soul Gem";

		// Ignores soulgems that have a size of None
		if (a_entryObject.gemSize != undefined && a_entryObject.gemSize != Item.SOULGEM_NONE)
			a_entryObject.subType = a_entryObject.gemSize;
	}

	private function processSoulGemStatus(a_entryObject: Object): Void
	{
		if (a_entryObject.gemSize == undefined || a_entryObject.soulSize == undefined || a_entryObject.soulSize == Item.SOULGEM_NONE)
			a_entryObject.status = Item.SOULGEM_EMPTY;
		else if (a_entryObject.soulSize >= a_entryObject.gemSize)
			a_entryObject.status = Item.SOULGEM_FULL;
		else
			a_entryObject.status = Item.SOULGEM_PARTIAL;
	}

	private function processMiscType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Misc";

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["BYOHAdoptionClothesKeyword"] != undefined) {
			a_entryObject.subType = Item.CHILDRENSCLOTHES;
			a_entryObject.subTypeDisplay = "$Childrens Clothes";

		} else if (a_entryObject.keywords["BYOHAdoptionToyKeyword"] != undefined) {
			a_entryObject.subType = Item.TOY;
			a_entryObject.subTypeDisplay = "$Toy";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryWeaponRacks"] != undefined) {
			a_entryObject.subType = Item.WEAPONRACK;
			a_entryObject.subTypeDisplay = "$Weapon Rack";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryShelf"] != undefined) {
			a_entryObject.subType = Item.SHELF;
			a_entryObject.subTypeDisplay = "$Shelf";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryFurniture"] != undefined) {
			a_entryObject.subType = Item.FURNITURE;
			a_entryObject.subTypeDisplay = "$Furniture";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryExterior"] != undefined) {
			a_entryObject.subType = Item.EXTERIOR;
			a_entryObject.subTypeDisplay = "$Exterior Furniture";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryContainers"] != undefined) {
			a_entryObject.subType = Item.CONTAINER;
			a_entryObject.subTypeDisplay = "$Container";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryBuilding"] != undefined) {
			a_entryObject.subType = Item.HOUSEPART;
			a_entryObject.subTypeDisplay = "$House Part";

		} else if (a_entryObject.keywords["BYOHHouseCraftingCategorySmithing"] != undefined) {
			a_entryObject.subType = Item.FASTENER;
			a_entryObject.subTypeDisplay = "$Fastener";

		} else if (a_entryObject.keywords["VendorItemDaedricArtifact"] != undefined) {
			a_entryObject.subType = Item.ARTIFACT;
			a_entryObject.subTypeDisplay = "$Artifact";

		} else if (a_entryObject.keywords["VendorItemGem"] != undefined) {
			a_entryObject.subType = Item.GEM;
			a_entryObject.subTypeDisplay = "$Gem";

		} else if (a_entryObject.keywords["VendorItemAnimalHide"] != undefined) {
			a_entryObject.subType = Item.HIDE;
			a_entryObject.subTypeDisplay = "$Hide";

		} else if (a_entryObject.keywords["VendorItemTool"] != undefined) {
			a_entryObject.subType = Item.TOOL;
			a_entryObject.subTypeDisplay = "$Tool";

		} else if (a_entryObject.keywords["VendorItemAnimalPart"] != undefined) {
			a_entryObject.subType = Item.REMAINS;
			a_entryObject.subTypeDisplay = "$Remains";

		} else if (a_entryObject.keywords["VendorItemOreIngot"] != undefined) {
			a_entryObject.subType = Item.INGOT;
			a_entryObject.subTypeDisplay = "$Ingot";

		} else if (a_entryObject.keywords["VendorItemClutter"] != undefined) {
			a_entryObject.subType = Item.CLUTTER;
			a_entryObject.subTypeDisplay = "$Clutter";

		} else if (a_entryObject.keywords["VendorItemFirewood"] != undefined) {
			a_entryObject.subType = Item.FIREWOOD;
			a_entryObject.subTypeDisplay = "$Firewood";
		}
	}
}


// skyui.util.Debug.dump(a_entryObject["text"], a_entryObject);