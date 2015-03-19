class skyui.defines.Inventory
{
	public static var ICT_NONE: Number				= 0;
	public static var ICT_ARMOR: Number				= 1;
	public static var ICT_WEAPON: Number			= 2;
	public static var ICT_MISC: Number				= 3;
	public static var ICT_BOOK: Number				= 4;
	public static var ICT_FOOD: Number				= 5;
	public static var ICT_POTION: Number			= 6;
	public static var ICT_SPELL: Number				= 7;
	public static var ICT_INGREDIENT: Number		= 8;
	public static var ICT_KEY: Number				= 9;
	public static var ICT_SHOUT: Number				= 10;
	public static var ICT_ACTIVE_EFFECT: Number		= 11;
	public static var ICT_SOUL_GEMS: Number			= 12;
	public static var ICT_SPELL_DEFAULT: Number		= 13;
	public static var ICT_LIST: Number				= 14;
	public static var ICT_CRAFT_ENCHANTING: Number	= 15;
	public static var ICT_HOUSE_PART: Number		= 16;
	
	public static var ES_NONE: Number				= 0;
	public static var ES_EQUIPPED: Number			= 1;
	public static var ES_LEFT_EQUIPPED: Number		= 2;
	public static var ES_RIGHT_EQUIPPED: Number		= 3;
	public static var ES_BOTH_EQUIPPED: Number		= 4;
	
	public static var QUANTITY_MENU_COUNT_LIMIT: Number = 5;

	// Category filterflags
	public static var FILTERFLAG_DIVIDER: Number				= 0x00000000;
	
	public static var FILTERFLAG_INV_ALL: Number				= 0x000003FF; // Sum of below
	public static var FILTERFLAG_INV_FAVORITES: Number			= 0x00000001;
	public static var FILTERFLAG_INV_WEAPONS: Number			= 0x00000002;
	public static var FILTERFLAG_INV_ARMOR: Number				= 0x00000004;
	public static var FILTERFLAG_INV_POTIONS: Number			= 0x00000008;
	public static var FILTERFLAG_INV_SCROLLS: Number			= 0x00000010;
	public static var FILTERFLAG_INV_FOOD: Number				= 0x00000020;
	public static var FILTERFLAG_INV_INGREDIENTS: Number		= 0x00000040;
	public static var FILTERFLAG_INV_BOOKS: Number				= 0x00000080;
	public static var FILTERFLAG_INV_KEYS: Number				= 0x00000100;
	public static var FILTERFLAG_INV_MISC: Number				= 0x00000200;
	
	public static var FILTERFLAG_CONTAINER_ALL: Number			= 0x000FFC00; // Sum of below
	public static var FILTERFLAG_CONTAINER_WEAPONS: Number		= 0x00000800;
	public static var FILTERFLAG_CONTAINER_ARMOR: Number		= 0x00001000;
	public static var FILTERFLAG_CONTAINER_POTIONS: Number		= 0x00002000;
	public static var FILTERFLAG_CONTAINER_SCROLLS: Number		= 0x00004000;
	public static var FILTERFLAG_CONTAINER_FOOD: Number			= 0x00008000;
	public static var FILTERFLAG_CONTAINER_INGREDIENTS: Number	= 0x00010000;
	public static var FILTERFLAG_CONTAINER_BOOKS: Number		= 0x00020000;
	public static var FILTERFLAG_CONTAINER_KEYS: Number			= 0x00040000;
	public static var FILTERFLAG_CONTAINER_MISC: Number			= 0x00080000;
	
	public static var FILTERFLAG_MAGIC_ALL: Number				= -257; // 0xFFFFFEFF
	public static var FILTERFLAG_MAGIC_FAVORITES: Number		= 0x00000001;
	public static var FILTERFLAG_MAGIC_ALTERATION: Number		= 0x00000002;
	public static var FILTERFLAG_MAGIC_ILLUSION: Number			= 0x00000004;
	public static var FILTERFLAG_MAGIC_DESTRUCTION: Number		= 0x00000008;
	public static var FILTERFLAG_MAGIC_CONJURATION: Number		= 0x00000010;
	public static var FILTERFLAG_MAGIC_RESTORATION: Number		= 0x00000020;
	public static var FILTERFLAG_MAGIC_SHOUTS: Number			= 0x00000040;
	public static var FILTERFLAG_MAGIC_POWERS: Number			= 0x00000080;
	public static var FILTERFLAG_MAGIC_ACTIVEEFFECTS: Number	= 0x00000100;
	
	public static var FILTERFLAG_ENCHANTING_ITEM: Number		= 0x00000005; //5;
	public static var FILTERFLAG_ENCHANTING_DISENCHANT: Number	= 0x0000000A; //10;
	public static var FILTERFLAG_ENCHANTING_ENCHANTMENT: Number	= 0x00000030; //48;
	public static var FILTERFLAG_ENCHANTING_SOULGEM: Number		= 0x00000040; //64;
	
	// incomplete, but others are irrelevant for now
	public static var FILTERFLAG_CRAFT_JEWELRY: Number		 	= 0x00010000;
	public static var FILTERFLAG_CRAFT_FOOD: Number				= 0x00020000;
	public static var FILTERFLAG_CRAFT_MISC: Number				= 0x40000000;
	
	// Filter flags for custom categories in ConstructObject crafting
	public static var FILTERFLAG_CUST_CRAFT_ALL: Number			= 0x0000003F;
	public static var FILTERFLAG_CUST_CRAFT_WEAPONS: Number		= 0x00000001;
	public static var FILTERFLAG_CUST_CRAFT_AMMO: Number		= 0x00000002;
	public static var FILTERFLAG_CUST_CRAFT_ARMOR: Number		= 0x00000004;
	public static var FILTERFLAG_CUST_CRAFT_JEWELRY: Number		= 0x00000008;
	public static var FILTERFLAG_CUST_CRAFT_FOOD: Number		= 0x00000010;
	public static var FILTERFLAG_CUST_CRAFT_MISC: Number		= 0x00000020;
	
	// Filter flags for custom categories in ConstructObject alchemy
	public static var FILTERFLAG_CUST_ALCH_INGREDIENTS: Number	= 0x00000001;
	public static var FILTERFLAG_CUST_ALCH_GOOD: Number			= 0x00000002;
	public static var FILTERFLAG_CUST_ALCH_BAD: Number			= 0x00000004;
	public static var FILTERFLAG_CUST_ALCH_OTHER: Number		= 0x00000008;
}