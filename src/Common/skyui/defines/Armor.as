class skyui.defines.Armor
{
	public static var WEIGHT_LIGHT: Number		= 0;
	public static var WEIGHT_HEAVY: Number		= 1;
	public static var WEIGHT_NONE: Number		= 2;
	// SkyUI
	public static var WEIGHT_CLOTHING: Number	= 3;
	public static var WEIGHT_JEWELRY: Number	= 4;

	public static var PARTMASK_HEAD: Number				= 0x00000001;
	public static var PARTMASK_HAIR: Number				= 0x00000002;
	public static var PARTMASK_BODY: Number				= 0x00000004;
	public static var PARTMASK_HANDS: Number			= 0x00000008;
	public static var PARTMASK_FOREARMS: Number			= 0x00000010;
	public static var PARTMASK_AMULET: Number			= 0x00000020;
	public static var PARTMASK_RING: Number				= 0x00000040;
	public static var PARTMASK_FEET: Number				= 0x00000080;
	public static var PARTMASK_CALVES: Number			= 0x00000100;
	public static var PARTMASK_SHIELD: Number			= 0x00000200;
	public static var PARTMASK_TAIL: Number				= 0x00000400;
	public static var PARTMASK_LONGHAIR: Number			= 0x00000800;
	public static var PARTMASK_CIRCLET: Number			= 0x00001000;
	public static var PARTMASK_EARS: Number				= 0x00002000;
	public static var PARTMASK_UNNAMED14: Number		= 0x00004000;
	public static var PARTMASK_UNNAMED15: Number		= 0x00008000;
	public static var PARTMASK_UNNAMED16: Number		= 0x00010000;
	public static var PARTMASK_UNNAMED17: Number		= 0x00020000;
	public static var PARTMASK_UNNAMED18: Number		= 0x00040000;
	public static var PARTMASK_UNNAMED19: Number		= 0x00080000;
	public static var PARTMASK_DECAPITATEHEAD: Number	= 0x00100000;
	public static var PARTMASK_DECAPITATE: Number		= 0x00200000;
	public static var PARTMASK_UNNAMED22: Number		= 0x00400000;
	public static var PARTMASK_UNNAMED23: Number		= 0x00800000;
	public static var PARTMASK_UNNAMED24: Number		= 0x01000000;
	public static var PARTMASK_UNNAMED25: Number		= 0x02000000;
	public static var PARTMASK_UNNAMED26: Number		= 0x04000000;
	public static var PARTMASK_UNNAMED27: Number		= 0x08000000;
	public static var PARTMASK_UNNAMED28: Number		= 0x10000000;
	public static var PARTMASK_UNNAMED29: Number		= 0x20000000;
	public static var PARTMASK_UNNAMED30: Number		= 0x40000000;
	public static var PARTMASK_FX01: Number				= 0x80000000;

	public static var PARTMASK_PRECEDENCE: Array = [PARTMASK_BODY,
													PARTMASK_HAIR,
													PARTMASK_HANDS,
													PARTMASK_FOREARMS,
													PARTMASK_FEET,
													PARTMASK_CALVES,
													PARTMASK_SHIELD,
													PARTMASK_AMULET,
													PARTMASK_RING,
													PARTMASK_LONGHAIR,
													PARTMASK_EARS,
													PARTMASK_HEAD,
													PARTMASK_CIRCLET,
													PARTMASK_TAIL,
													PARTMASK_UNNAMED14,
													PARTMASK_UNNAMED15,
													PARTMASK_UNNAMED16,
													PARTMASK_UNNAMED17,
													PARTMASK_UNNAMED18,
													PARTMASK_UNNAMED19,
													PARTMASK_DECAPITATEHEAD,
													PARTMASK_DECAPITATE,
													PARTMASK_UNNAMED22,
													PARTMASK_UNNAMED23,
													PARTMASK_UNNAMED24,
													PARTMASK_UNNAMED25,
													PARTMASK_UNNAMED26,
													PARTMASK_UNNAMED27,
													PARTMASK_UNNAMED28,
													PARTMASK_UNNAMED29,
													PARTMASK_UNNAMED30,
													PARTMASK_FX01];

	// SkyUI
	public static var EQUIP_HEAD: Number		= 0;
	public static var EQUIP_HAIR: Number		= 1;
	public static var EQUIP_LONGHAIR: Number	= 2;
	public static var EQUIP_BODY: Number		= 3;
	public static var EQUIP_FOREARMS: Number	= 4;
	public static var EQUIP_HANDS: Number		= 5;
	public static var EQUIP_SHIELD: Number		= 6;
	public static var EQUIP_CALVES: Number		= 7;
	public static var EQUIP_FEET: Number		= 8;
	public static var EQUIP_CIRCLET: Number		= 9;
	public static var EQUIP_AMULET: Number		= 10;
	public static var EQUIP_EARS: Number		= 11;
	public static var EQUIP_RING: Number		= 12;
	public static var EQUIP_TAIL: Number		= 13;
}