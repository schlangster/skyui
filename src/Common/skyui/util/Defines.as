class skyui.util.Defines
{
	// Category filterflags
	static var FLAG_CATEGORY_DIVIDER = 0;
	
	static var FLAG_INV_ALL = 1023;
	static var FLAG_INV_FAVORITES = 1;
	static var FLAG_INV_WEAPONS = 2;
	static var FLAG_INV_ARMOR = 4;
	static var FLAG_INV_POTIONS = 8;
	static var FLAG_INV_SCROLLS = 16;
	static var FLAG_INV_FOOD = 32;
	static var FLAG_INV_INGREDIENTS = 64;
	static var FLAG_INV_BOOKS = 128;
	static var FLAG_INV_KEYS = 256;
	static var FLAG_INV_MISC = 512;
	
	static var FLAG_CONTAINER_ALL = 1047552;
	static var FLAG_CONTAINER_WEAPONS = 2048;
	static var FLAG_CONTAINER_ARMOR = 4096;
	static var FLAG_CONTAINER_POTIONS = 8192;
	static var FLAG_CONTAINER_SCROLLS = 16384;
	static var FLAG_CONTAINER_FOOD = 32768;
	static var FLAG_CONTAINER_INGREDIENTS = 65536;
	static var FLAG_CONTAINER_BOOKS = 131072;
	static var FLAG_CONTAINER_KEYS = 262144;
	static var FLAG_CONTAINER_MISC = 524288;
	
	static var FLAG_MAGIC_ALL = -257;
	static var FLAG_MAGIC_FAVORITES = 1;
	static var FLAG_MAGIC_ALTERATION = 2;
	static var FLAG_MAGIC_ILLUSION = 4;
	static var FLAG_MAGIC_DESTRUCTION = 8;
	static var FLAG_MAGIC_CONJURATION = 16;
	static var FLAG_MAGIC_RESTORATION = 32;
	static var FLAG_MAGIC_SHOUTS = 64;
	static var FLAG_MAGIC_POWERS = 128;
	static var FLAG_MAGIC_ACTIVE_EFFECT = 256;
	
	static var FLAG_ENCHANTING_DISENCHANT = 10;
	static var FLAG_ENCHANTING_ITEM = 5;
	static var FLAG_ENCHANTING_ENCHANTMENT = 48;
	static var FLAG_ENCHANTING_SOULGEM = 64;
	
	// For unknown values
	static var TYPE_UNKNOWN = 950;
	
	// Form types
	static var FORMTYPE_SCROLL = 23;
	static var FORMTYPE_ARMOR = 26;
	static var FORMTYPE_BOOK = 27;
	static var FORMTYPE_INGREDIENT = 30;
	static var FORMTYPE_TORCH = 31;
	static var FORMTYPE_MISC = 32;
	static var FORMTYPE_WEAPON = 41;
	static var FORMTYPE_AMMO = 42;
	static var FORMTYPE_KEY = 45;
	static var FORMTYPE_ALCH = 46;
	static var FORMTYPE_SOULGEM = 52;
	static var FORMTYPE_SHOUT = 0x77;
	static var FORMTYPE_SPELL = 0x16;

	// Materials
	static var MATERIAL_ARTIFACT = 1;
	static var MATERIAL_MAGIC = 2;
	static var MATERIAL_DAEDRIC = 3;
	static var MATERIAL_DRAGONPLATE = 4;
	static var MATERIAL_NIGHTINGALE = 5;
	static var MATERIAL_EBONY = 6;
	static var MATERIAL_DRAGONSCALE = 7;
	static var MATERIAL_ORCISH = 8;
	static var MATERIAL_STEELPLATE = 9;
	static var MATERIAL_GLASS = 10;
	static var MATERIAL_ELVENGILDED = 11;
	static var MATERIAL_DWARVEN = 12;
	static var MATERIAL_SCALED = 13;

	// Materials used for weapons but not (vanilla) armor
	static var MATERIAL_SILVER = 14;
	static var MATERIAL_NORDHERO = 15;
	static var MATERIAL_DRAUGR = 16;
	static var MATERIAL_FALMERHONED = 17;
	static var MATERIAL_FALMER = 18;

	static var MATERIAL_STEEL = 19;
	static var MATERIAL_BROTHERHOOD = 20;
	static var MATERIAL_ELVEN = 21;
	static var MATERIAL_IRONBANDED = 22;
	static var MATERIAL_LEATHER = 23;
	static var MATERIAL_IMPERIALSTUDDED = 24;
	static var MATERIAL_STUDDED = 25;
	static var MATERIAL_FUR = 26;
	static var MATERIAL_IMPERIALHEAVY = 27;
	static var MATERIAL_IRON = 28;
	static var MATERIAL_IMPERIALLIGHT = 29;
	static var MATERIAL_STORMCLOAK = 30;
	static var MATERIAL_HIDE = 31;
	static var MATERIAL_CLOTHING = 32;


	// Weapon types
	static var WEAPON_TYPE_LONGSWORD = 1;
	static var WEAPON_TYPE_DAGGER = 2;
	static var WEAPON_TYPE_WARAXE = 3;
	static var WEAPON_TYPE_MACE = 4;
	static var WEAPON_TYPE_GREATSWORD = 5;
	static var WEAPON_TYPE_BATTLEAXE = 6;
	static var WEAPON_TYPE_HAMMER = 7;
	static var WEAPON_TYPE_BOW = 8;
	static var WEAPON_TYPE_STAFF = 9;
	//NOTE: values as given by SKSE before modification by actionscript:
	//static var WEAPON_TYPE_BATTLEAXE = 6;
	//static var WEAPON_TYPE_BOW = 7;
	//static var WEAPON_TYPE_STAFF = 8;
	//static var WEAPON_TYPE_HAMMER = 18; // 18 would be next available, see SKSE TESObjectWEAP

	// Armor types
	// weightClass (light and heavy values swapped vs SKSE ennm for better sorting)
	static var ARMOR_WEIGHTCLASS_HEAVY = 0;
	static var ARMOR_WEIGHTCLASS_LIGHT = 1;
	static var ARMOR_WEIGHTCLASS_NONE = 2;
	
	static var ARMOR_SUBTYPE_BODY = 1;
	static var ARMOR_SUBTYPE_HEAD = 2;
	static var ARMOR_SUBTYPE_HANDS = 3;
	static var ARMOR_SUBTYPE_FOREARMS = 4;
	static var ARMOR_SUBTYPE_FEET = 5;
	static var ARMOR_SUBTYPE_CALVES = 6;
	static var ARMOR_SUBTYPE_SHIELD = 7;
	static var ARMOR_SUBTYPE_AMULET = 8;
	static var ARMOR_SUBTYPE_RING = 9;
	static var ARMOR_SUBTYPE_MASK = 12;
	static var ARMOR_SUBTYPE_CIRCLET = 13;
	
	// Alchemy types (potions and food)
	static var ALCH_TYPE_POTION = 0;
	static var ALCH_TYPE_POISON = 2;
	static var ALCH_TYPE_FOOD = 3;

	// Soul gem types
	static var SOULGEM_EMPTY = 0;
	static var SOULGEM_PARTIAL = 1;
	static var SOULGEM_FULL = 2;

	// Book types
	static var BOOK_TYPE_RECIPE = 1;
	static var BOOK_TYPE_NOTE = 2;
	static var BOOK_TYPE_MAP = 3;
	static var BOOK_TYPE_JOURNAL = 4;
	static var BOOK_TYPE_SPELLTOME = 5;
	
	// Misc types
	static var MISC_TYPE_GOLD = 0;
	static var MISC_TYPE_DRAGONCLAW = 1;
	static var MISC_TYPE_ARTIFACT = 2;
	static var MISC_TYPE_GEM = 3;
	static var MISC_TYPE_INGOT = 4;
	static var MISC_TYPE_ORE = 5;
	static var MISC_TYPE_LEATHER = 6;
	static var MISC_TYPE_LEATHERSTRIPS = 7;
	static var MISC_TYPE_HIDE = 8;
	static var MISC_TYPE_TOOL = 9;
	static var MISC_TYPE_REMAINS = 10;
	static var MISC_TYPE_CLUTTER = TYPE_UNKNOWN + 1;
	
	// Spell type
	static var SPELL_TYPE_ALTERATION = 18;
	static var SPELL_TYPE_CONJURATION = 19;
	static var SPELL_TYPE_DESTRUCTION = 20;
	static var SPELL_TYPE_ILLUSION = 21;
	static var SPELL_TYPE_RESTORATION = 22;
	
	// Actor Value
	// For potion and magic effects
	static var ACTORVALUE_HEALTH = 24;
	static var ACTORVALUE_MAGICKA = 25;
	static var ACTORVALUE_STAMINA  = 26;
	static var ACTORVALUE_STRENGTH = 32;
	static var ACTORVALUE_FIRE = 41;
	static var ACTORVALUE_SHOCK = 42;
	static var ACTORVALUE_FROST = 43;
	static var ACTORVALUE_MAGIC = 44;
	
	// Magic Type
	static var MAGICTYPE_FIRE = 41;
	static var MAGICTYPE_SHOCK = 42;
	static var MAGICTYPE_FROST = 43;
	
	// Form Ids
	static var FORMID_GOLD001 = 0xF;
	static var FORMID_LEATHER01 = 0xDB5D2;
	static var FORMID_LEATHERSTRIPS = 0x800E4;
	
	static var FORMID_BOUNDARROW = 0x10B0A7;
	static var FORMID_CWARROW = 0x20DDF;
	static var FORMID_CWARROWSHORT = 0x20F02;
	static var FORMID_DAEDRICARROW = 0x139C0;
	static var FORMID_DRAUGRARROW = 0x34182;
	static var FORMID_DUNARCHERPRATICEARROW = 0xCAB52;
	static var FORMID_DUNGEIRMUNDSIGDISARROWSILLUSION = 0xE738A;
	static var FORMID_DWARVENARROW = 0x139BC;
	static var FORMID_DWARVENSPHEREARROW = 0x7B932;
	static var FORMID_DWARVENSPHEREBOLT01 = 0x7B935;
	static var FORMID_DWARVENSPHEREBOLT02 = 0x10EC8C;
	static var FORMID_EBONYARROW = 0x139BF;
	static var FORMID_ELVENARROW = 0x139BD;
	static var FORMID_FALMERARROW = 0x38341;
	static var FORMID_FOLLOWERIRONARROW = 0x10E2DE;
	static var FORMID_FORSWORNARROW = 0xCEE9E;
	static var FORMID_GLASSARROW = 0x139BE;
	static var FORMID_IRONARROW = 0x1397D;
	static var FORMID_MQ101STEELARROW = 0x105EE7;
	static var FORMID_NORDHEROARROW = 0xEAFDF;
	static var FORMID_ORCISHARROW = 0x139BB;
	static var FORMID_STEELARROW = 0x1397F;
	static var FORMID_TRAPDART = 0x236DD;
	
	static var FORMID_RUBYDRAGONCLAW = 0x4B56C;
	static var FORMID_IVORYDRAGONCLAW = 0xAB7BB;
	static var FORMID_GLASSCLAW = 0x7C260;
	static var FORMID_EBONYCLAW = 0x5AF48;
	static var FORMID_EMERALDDRAGONCLAW = 0xED417;
	static var FORMID_DIAMONDCLAW = 0xAB375;
	static var FORMID_IRONCLAW = 0x8CDFA;
	static var FORMID_CORALDRAGONCLAW = 0xB634C;
	static var FORMID_E3GOLDENCLAW = 0x999E7;
	static var FORMID_SAPPHIREDRAGONCLAW = 0x663D7;
	static var FORMID_MS13GOLDENCLAW = 0x39647;

	static var FORMID_DA01AZURASSTARBROKEN = 0x28AD7;
	static var FORMID_DA01SOULGEMBLACKSTAR = 0x63B29;
	static var FORMID_DA01SOULGEMAZURASSTAR = 0x63B27;
	
	// pick axes
	static var FORMID_WEAPPICKAXE = 0xE3C16;
	static var FORMID_SSDROCKSPLINTERPICKAXE = 0x6A707;
	static var FORMID_DUNVOLUNRUUDPICKAXE = 0x1019D4;

	// woodcutter's axes
	static var FORMID_AXE01 = 0x2F2F4;
	static var FORMID_DUNHALTEDSTREAMPOACHERSAXE = 0xAE086;
	
}