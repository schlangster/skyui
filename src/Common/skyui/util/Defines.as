class skyui.util.Defines
{
	// Category filterflags
	public static var FLAG_CATEGORY_DIVIDER: Number			= 0;
	
	public static var FLAG_INV_ALL: Number					= 0x000003FF; // Sum of below
	public static var FLAG_INV_FAVORITES: Number			= 0x00000001;
	public static var FLAG_INV_WEAPONS: Number				= 0x00000002;
	public static var FLAG_INV_ARMOR: Number				= 0x00000004;
	public static var FLAG_INV_POTIONS: Number				= 0x00000008;
	public static var FLAG_INV_SCROLLS: Number				= 0x00000010;
	public static var FLAG_INV_FOOD: Number					= 0x00000020;
	public static var FLAG_INV_INGREDIENTS: Number			= 0x00000040;
	public static var FLAG_INV_BOOKS: Number				= 0x00000080;
	public static var FLAG_INV_KEYS: Number					= 0x00000100;
	public static var FLAG_INV_MISC: Number					= 0x00000200;
	
	public static var FLAG_CONTAINER_ALL: Number			= 0x000FFC00; // Sum of below
	public static var FLAG_CONTAINER_WEAPONS: Number		= 0x00000800;
	public static var FLAG_CONTAINER_ARMOR: Number			= 0x00001000;
	public static var FLAG_CONTAINER_POTIONS: Number		= 0x00002000;
	public static var FLAG_CONTAINER_SCROLLS: Number		= 0x00004000;
	public static var FLAG_CONTAINER_FOOD: Number			= 0x00008000;
	public static var FLAG_CONTAINER_INGREDIENTS: Number	= 0x00010000;
	public static var FLAG_CONTAINER_BOOKS: Number			= 0x00020000;
	public static var FLAG_CONTAINER_KEYS: Number			= 0x00040000;
	public static var FLAG_CONTAINER_MISC: Number			= 0x00080000;
	
	public static var FLAG_MAGIC_ALL: Number				= 0x000001FF; //Sum of below, or -257;
	public static var FLAG_MAGIC_FAVORITES: Number			= 0x00000001;
	public static var FLAG_MAGIC_ALTERATION: Number			= 0x00000002;
	public static var FLAG_MAGIC_ILLUSION: Number			= 0x00000004;
	public static var FLAG_MAGIC_DESTRUCTION: Number		= 0x00000008;
	public static var FLAG_MAGIC_CONJURATION: Number		= 0x00000010;
	public static var FLAG_MAGIC_RESTORATION: Number		= 0x00000020;
	public static var FLAG_MAGIC_SHOUTS: Number				= 0x00000040;
	public static var FLAG_MAGIC_POWERS: Number				= 0x00000080;
	public static var FLAG_MAGIC_ACTIVE_EFFECT: Number		= 0x00000100;
	
	public static var FLAG_ENCHANTING_DISENCHANT: Number	= 0x0000000A; //10;
	public static var FLAG_ENCHANTING_ITEM: Number			= 0x00000005; //5;
	public static var FLAG_ENCHANTING_ENCHANTMENT: Number	= 0x00000030; //48;
	public static var FLAG_ENCHANTING_SOULGEM: Number		= 0x00000040; //64;
	
	// baseIds (formId & 0x00FFFFFF)
	public static var FORMID_GOLD001: Number							= 0x00000F;
	public static var FORMID_LEATHER01: Number							= 0x0DB5D2;
	public static var FORMID_LEATHERSTRIPS: Number						= 0x0800E4;
	
	public static var FORMID_BOUNDARROW: Number							= 0x10B0A7;
	public static var FORMID_CWARROW: Number							= 0x020DDF;
	public static var FORMID_CWARROWSHORT: Number						= 0x020F02;
	public static var FORMID_DAEDRICARROW: Number						= 0x0139C0;
	public static var FORMID_DRAUGRARROW: Number						= 0x034182;
	public static var FORMID_DUNARCHERPRATICEARROW: Number				= 0x0CAB52;
	public static var FORMID_DUNGEIRMUNDSIGDISARROWSILLUSION: Number	= 0x0E738A;
	public static var FORMID_DWARVENARROW: Number 						= 0x0139BC;
	public static var FORMID_DWARVENSPHEREARROW: Number 				= 0x07B932;
	public static var FORMID_DWARVENSPHEREBOLT01: Number 				= 0x07B935;
	public static var FORMID_DWARVENSPHEREBOLT02: Number 				= 0x10EC8C;
	public static var FORMID_EBONYARROW: Number 						= 0x0139BF;
	public static var FORMID_ELVENARROW: Number 						= 0x0139BD;
	public static var FORMID_FALMERARROW: Number 						= 0x038341;
	public static var FORMID_FOLLOWERIRONARROW: Number 					= 0x10E2DE;
	public static var FORMID_FORSWORNARROW: Number 						= 0x0CEE9E;
	public static var FORMID_GLASSARROW: Number 						= 0x0139BE;
	public static var FORMID_IRONARROW: Number 							= 0x01397D;
	public static var FORMID_MQ101STEELARROW: Number 					= 0x105EE7;
	public static var FORMID_NORDHEROARROW: Number 						= 0x0EAFDF;
	public static var FORMID_ORCISHARROW: Number 						= 0x0139BB;
	public static var FORMID_STEELARROW: Number 						= 0x01397F;
	public static var FORMID_TRAPDART: Number 							= 0x0236DD;
	
	public static var FORMID_RUBYDRAGONCLAW: Number 					= 0x04B56C;
	public static var FORMID_IVORYDRAGONCLAW: Number 					= 0x0AB7BB;
	public static var FORMID_GLASSCLAW: Number 							= 0x07C260;
	public static var FORMID_EBONYCLAW: Number 							= 0x05AF48;
	public static var FORMID_EMERALDDRAGONCLAW: Number 					= 0x0ED417;
	public static var FORMID_DIAMONDCLAW: Number 						= 0x0AB375;
	public static var FORMID_IRONCLAW: Number 							= 0x08CDFA;
	public static var FORMID_CORALDRAGONCLAW: Number 					= 0x0B634C;
	public static var FORMID_E3GOLDENCLAW: Number 						= 0x0999E7;
	public static var FORMID_SAPPHIREDRAGONCLAW: Number 				= 0x0663D7;
	public static var FORMID_MS13GOLDENCLAW: Number 					= 0x039647;

	public static var FORMID_DA01AZURASSTARBROKEN: Number 				= 0x028AD7;
	public static var FORMID_DA01SOULGEMBLACKSTAR: Number 				= 0x063B29;
	public static var FORMID_DA01SOULGEMAZURASSTAR: Number 				= 0x063B27;
	
	// pick axes
	public static var FORMID_WEAPPICKAXE: Number 						= 0x0E3C16;
	public static var FORMID_SSDROCKSPLINTERPICKAXE: Number 			= 0x06A707;
	public static var FORMID_DUNVOLUNRUUDPICKAXE: Number 				= 0x1019D4;

	// woodcutter's axes
	public static var FORMID_AXE01: Number 								= 0x02F2F4;
	public static var FORMID_DUNHALTEDSTREAMPOACHERSAXE: Number 		= 0x0AE086;
	
}