class skyui.defines.Item
{
	public static var OTHER: Number				= undefined;

	public static var POTION_HEALTH: Number				= 0;
	public static var POTION_HEALRATE: Number			= 1;
	public static var POTION_HEALRATEMULT: Number		= 2;
	public static var POTION_MAGICKA: Number			= 3;
	public static var POTION_MAGICKARATE: Number		= 4;
	public static var POTION_MAGICKARATEMULT: Number	= 5;
	public static var POTION_STAMINA: Number			= 6;
	public static var POTION_STAMINARATE: Number		= 7;
	public static var POTION_STAMINARATEMULT: Number	= 8;
	public static var POTION_FIRERESIST: Number			= 9;
	public static var POTION_ELECTRICRESIST: Number		= 10;
	public static var POTION_FROSTRESIST: Number		= 11;
	public static var POTION_POTION: Number				= 12;
	public static var POTION_DRINK: Number				= 13;
	public static var POTION_FOOD: Number				= 14;
	public static var POTION_POISON: Number				= 15;

	
	public static var MISC_GEM: Number				= 0;
	public static var MISC_DRAGONCLAW: Number		= 1;
	public static var MISC_ARTIFACT: Number			= 2;
	public static var MISC_LEATHER: Number			= 3;
	public static var MISC_LEATHERSTRIPS: Number	= 4;
	public static var MISC_HIDE: Number				= 5;
	public static var MISC_REMAINS: Number			= 6;
	public static var MISC_INGOT: Number			= 7;
	public static var MISC_TOOL: Number				= 8;
	public static var MISC_CHILDRENSCLOTHES: Number	= 9;
	public static var MISC_TOY: Number				= 10;
	public static var MISC_FIREWOOD: Number			= 11;
	//
	public static var MISC_FASTENER: Number			= 12;
	public static var MISC_WEAPONRACK: Number		= 13;
	public static var MISC_SHELF: Number			= 14;
	public static var MISC_FURNITURE: Number		= 15;
	public static var MISC_EXTERIOR: Number			= 16;
	public static var MISC_CONTAINER: Number		= 17;
	//
	public static var MISC_HOUSEPART: Number		= 18;
	public static var MISC_CLUTTER: Number			= 19;
	public static var MISC_LOCKPICK: Number			= 20;
	public static var MISC_GOLD: Number				= 21;

	public static var BOOK_SPELLTOME: Number		= 0;
	public static var BOOK_NOTE: Number				= 1;
	public static var BOOK_RECIPE: Number			= 2;

	// SKSE
	
	// BOOK Flags
	public static var BOOKFLAG_SPELL: Number		= 0x01;
	public static var BOOKFLAG_SKILL: Number		= 0x04;
	public static var BOOKFLAG_READ: Number			= 0x08;

	// BOOK bookTypes
	public static var BOOKTYPE_NOTE: Number			= 0xFF;

	// ALCH Flags
	public static var ALCHFLAG_MANUALCALC: Number	= 0x00001;
	public static var ALCHFLAG_FOOD: Number			= 0x00002;
	public static var ALCHFLAG_MEDICINE: Number		= 0x10000;
	public static var ALCHFLAG_POISON: Number 		= 0x20000;

	public static var SOULGEMSTATUS_EMPTY: Number	= 0;
	public static var SOULGEMSTATUS_PARTIAL: Number	= 1;
	public static var SOULGEMSTATUS_FULL: Number	= 2;

	public static var SOULGEM_NONE: Number			= 0;
	public static var SOULGEM_PETTY: Number			= 1;
	public static var SOULGEM_LESSER: Number		= 2;
	public static var SOULGEM_COMMON: Number		= 3;
	public static var SOULGEM_GREATER: Number		= 4;
	public static var SOULGEM_GRAND: Number			= 5;
	public static var SOULGEM_AZURA: Number			= 6;
}