class skyui.defines.Armor
{
	public static var OTHER: Number	= undefined;

	public static var LIGHT: Number		= 0;
	public static var HEAVY: Number		= 1;
	public static var NONE: Number		= 2;
	// SkyUI
	public static var CLOTHING: Number	= 3;
	public static var JEWELRY: Number	= 4;

	public static var FLAG_HEAD: Number				= 0x00000001;
	public static var FLAG_HAIR: Number				= 0x00000002;
	public static var FLAG_BODY: Number				= 0x00000004;
	public static var FLAG_HANDS: Number			= 0x00000008;
	public static var FLAG_FOREARMS: Number			= 0x00000010;
	public static var FLAG_AMULET: Number			= 0x00000020;
	public static var FLAG_RING: Number				= 0x00000040;
	public static var FLAG_FEET: Number				= 0x00000080;
	public static var FLAG_CALVES: Number			= 0x00000100;
	public static var FLAG_SHIELD: Number			= 0x00000200;
	public static var FLAG_TAIL: Number				= 0x00000400;
	public static var FLAG_LONGHAIR: Number			= 0x00000800;
	public static var FLAG_CIRCLET: Number			= 0x00001000;
	public static var FLAG_EARS: Number				= 0x00002000;
	public static var FLAG_UNNAMED14: Number		= 0x00004000;
	public static var FLAG_UNNAMED15: Number		= 0x00008000;
	public static var FLAG_UNNAMED16: Number		= 0x00010000;
	public static var FLAG_UNNAMED17: Number		= 0x00020000;
	public static var FLAG_UNNAMED18: Number		= 0x00040000;
	public static var FLAG_UNNAMED19: Number		= 0x00080000;
	public static var FLAG_DECAPITATEHEAD: Number	= 0x00100000;
	public static var FLAG_DECAPITATE: Number		= 0x00200000;
	public static var FLAG_UNNAMED22: Number		= 0x00400000;
	public static var FLAG_UNNAMED23: Number		= 0x00800000;
	public static var FLAG_UNNAMED24: Number		= 0x01000000;
	public static var FLAG_UNNAMED25: Number		= 0x02000000;
	public static var FLAG_UNNAMED26: Number		= 0x04000000;
	public static var FLAG_UNNAMED27: Number		= 0x08000000;
	public static var FLAG_UNNAMED28: Number		= 0x10000000;
	public static var FLAG_UNNAMED29: Number		= 0x20000000;
	public static var FLAG_UNNAMED30: Number		= 0x40000000;
	public static var FLAG_FX01: Number				= 0x80000000;

	public static var FLAG_PRECEDENCE: Array = [Armor.FLAG_BODY,
												 Armor.FLAG_HAIR,
												 Armor.FLAG_HANDS,
												 Armor.FLAG_FOREARMS,
												 Armor.FLAG_FEET,
												 Armor.FLAG_CALVES,
												 Armor.FLAG_SHIELD,
												 Armor.FLAG_AMULET,
												 Armor.FLAG_RING,
												 Armor.FLAG_LONGHAIR,
												 Armor.FLAG_EARS,
												 Armor.FLAG_HEAD,
												 Armor.FLAG_CIRCLET,
												 Armor.FLAG_TAIL,
												 Armor.FLAG_UNNAMED14,
												 Armor.FLAG_UNNAMED15,
												 Armor.FLAG_UNNAMED16,
												 Armor.FLAG_UNNAMED17,
												 Armor.FLAG_UNNAMED18,
												 Armor.FLAG_UNNAMED19,
												 Armor.FLAG_DECAPITATEHEAD,
												 Armor.FLAG_DECAPITATE,
												 Armor.FLAG_UNNAMED22,
												 Armor.FLAG_UNNAMED23,
												 Armor.FLAG_UNNAMED24,
												 Armor.FLAG_UNNAMED25,
												 Armor.FLAG_UNNAMED26,
												 Armor.FLAG_UNNAMED27,
												 Armor.FLAG_UNNAMED28,
												 Armor.FLAG_UNNAMED29,
												 Armor.FLAG_UNNAMED30,
												 Armor.FLAG_FX01];

	// SkyUI
	public static var HEAD: Number		= 0;
	public static var HAIR: Number		= 1;
	public static var LONGHAIR: Number	= 2;
	public static var BODY: Number		= 3;
	public static var FOREARMS: Number	= 4;
	public static var HANDS: Number		= 5;
	public static var SHIELD: Number	= 6;
	public static var CALVES: Number	= 7;
	public static var FEET: Number		= 8;
	public static var CIRCLET: Number	= 9;
	public static var AMULET: Number	= 10;
	public static var EARS: Number		= 11;
	public static var RING: Number		= 12;
	public static var TAIL: Number		= 13;
}