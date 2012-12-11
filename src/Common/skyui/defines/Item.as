class skyui.defines.Item
{
	public static var OTHER: Number				= undefined;

	public static var HEALTH: Number			= 0;
	public static var HEALRATE: Number			= 1;
	public static var HEALRATEMULT: Number		= 2;
	public static var MAGICKA: Number			= 3;
	public static var MAGICKARATE: Number		= 4;
	public static var MAGICKARATEMULT: Number	= 5;
	public static var STAMINA: Number			= 6;
	public static var STAMINARATE: Number		= 7;
	public static var STAMINARATEMULT: Number	= 8;
	public static var FIRERESIST: Number		= 9;
	public static var SHOCKRESIST: Number		= 10;
	public static var FROSTRESIST: Number		= 11;
	public static var POTION: Number			= 12;
	public static var DRINK: Number				= 13;
	public static var FOOD: Number				= 14;
	public static var POISON: Number			= 15;

	public static var ARTIFACT: Number			= 0;
	public static var GEM: Number				= 1;
	public static var HIDE: Number				= 2;
	public static var TOOL: Number				= 3;
	public static var REMAINS: Number			= 4;
	public static var INGOT: Number				= 5;
	public static var CHILDRENSCLOTHES: Number	= 7;
	public static var TOY: Number				= 8;
	public static var FIREWOOD: Number			= 9;
	public static var FASTENER: Number			= 10;
	public static var WEAPONRACK: Number		= 11;
	public static var SHELF: Number				= 12;
	public static var FURNITURE: Number			= 13;
	public static var EXTERIOR: Number			= 14;
	public static var CONTAINER: Number			= 15;
	public static var HOUSEPART: Number			= 16;
	public static var CLUTTER: Number			= 17;

	public static var SPELLTOME: Number			= 0;
	public static var NOTE: Number				= 1;
	public static var RECIPE: Number			= 2;

	// SKSE
	
	// BOOK Flags
	public static var BOOK_SPELL: Number		= 0x0001;
	public static var BOOK_SKILL: Number		= 0x0004;
	public static var BOOK_NOTE: Number			= 0xFF00;

	// ALCH Flags
	public static var ALCH_MANUALCALC: Number	= 0x00001;
	public static var ALCH_FOOD: Number			= 0x00002;
	public static var ALCH_MEDICINE: Number		= 0x10000;
	public static var ALCH_POISON: Number 		= 0x20000;

	public static var SOULGEM_EMPTY: Number		= 0;
	public static var SOULGEM_PARTIAL: Number	= 1;
	public static var SOULGEM_FULL: Number		= 2;

	public static var SOULGEM_NONE: Number		= 0;
	public static var SOULGEM_PETTY: Number		= 1;
	public static var SOULGEM_LESSER: Number	= 2;
	public static var SOULGEM_COMMON: Number	= 3;
	public static var SOULGEM_GRAND: Number		= 4;
	public static var SOULGEM_GREATER: Number	= 5;
}