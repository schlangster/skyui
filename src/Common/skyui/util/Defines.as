class skyui.util.Defines
{
	// Category filterflags
	static var FLAG_CATEGORY_DIVIDER: Number = 0;
	
	static var FLAG_INV_ALL: Number = 1023;
	static var FLAG_INV_FAVORITES: Number = 1;
	static var FLAG_INV_WEAPONS: Number = 2;
	static var FLAG_INV_ARMOR: Number = 4;
	static var FLAG_INV_POTIONS: Number = 8;
	static var FLAG_INV_SCROLLS: Number = 16;
	static var FLAG_INV_FOOD: Number = 32;
	static var FLAG_INV_INGREDIENTS: Number = 64;
	static var FLAG_INV_BOOKS: Number = 128;
	static var FLAG_INV_KEYS: Number = 256;
	static var FLAG_INV_MISC: Number = 512;
	
	static var FLAG_CONTAINER_ALL: Number = 1047552;
	static var FLAG_CONTAINER_WEAPONS: Number = 2048;
	static var FLAG_CONTAINER_ARMOR: Number = 4096;
	static var FLAG_CONTAINER_POTIONS: Number = 8192;
	static var FLAG_CONTAINER_SCROLLS: Number = 16384;
	static var FLAG_CONTAINER_FOOD: Number = 32768;
	static var FLAG_CONTAINER_INGREDIENTS: Number = 65536;
	static var FLAG_CONTAINER_BOOKS: Number = 131072;
	static var FLAG_CONTAINER_KEYS: Number = 262144;
	static var FLAG_CONTAINER_MISC: Number = 524288;
	
	static var FLAG_MAGIC_ALL: Number = -257;
	static var FLAG_MAGIC_FAVORITES: Number = 1;
	static var FLAG_MAGIC_ALTERATION: Number = 2;
	static var FLAG_MAGIC_ILLUSION: Number = 4;
	static var FLAG_MAGIC_DESTRUCTION: Number = 8;
	static var FLAG_MAGIC_CONJURATION: Number = 16;
	static var FLAG_MAGIC_RESTORATION: Number = 32;
	static var FLAG_MAGIC_SHOUTS: Number = 64;
	static var FLAG_MAGIC_POWERS: Number = 128;
	static var FLAG_MAGIC_ACTIVE_EFFECT: Number = 256;
	
	static var FLAG_ENCHANTING_DISENCHANT: Number = 10;
	static var FLAG_ENCHANTING_ITEM: Number = 5;
	static var FLAG_ENCHANTING_ENCHANTMENT: Number = 48;
	static var FLAG_ENCHANTING_SOULGEM: Number = 64;
	
	// Active Effect typeFlags
	static var FLAG_EFFECTTYPE_HOSTILE: Number = 1;
	static var FLAG_EFFECTTYPE_RECOVER: Number = 2;
	static var FLAG_EFFECTTYPE_DETRIMENTAL: Number = 4;
	static var FLAG_EFFECTTYPE_NOHITEVENT: Number = 16;
	static var FLAG_EFFECTTYPE_DISPELKEYWORDS: Number = 256;
	static var FLAG_EFFECTTYPE_NODURATION: Number = 512;
	static var FLAG_EFFECTTYPE_NOMAGNITUDE: Number = 1024;
	static var FLAG_EFFECTTYPE_NOAREA: Number = 2048;
	static var FLAG_EFFECTTYPE_FXPERSIST: Number = 4096;
	static var FLAG_EFFECTTYPE_GLORYVISUALS: Number = 16384;
	static var FLAG_EFFECTTYPE_HIDEINUI: Number = 32768;
	static var FLAG_EFFECTTYPE_NORECAST: Number = 131072;
	static var FLAG_EFFECTTYPE_MAGNITUDE: Number = 2097152;
	static var FLAG_EFFECTTYPE_DURATION: Number = 4194304;
	static var FLAG_EFFECTTYPE_PAINLESS: Number = 67108864;
	static var FLAG_EFFECTTYPE_NOHITEFFECT: Number = 134217728;
	static var FLAG_EFFECTTYPE_NODEATHDISPEL: Number = 268435456;
	
	// For unknown values
	static var TYPE_UNKNOWN: Number = 950;
	
	// Form types
	static var FORMTYPE_SCROLL: Number = 23;
	static var FORMTYPE_ARMOR: Number = 26;
	static var FORMTYPE_BOOK: Number = 27;
	static var FORMTYPE_INGREDIENT: Number = 30;
	static var FORMTYPE_TORCH: Number = 31;
	static var FORMTYPE_MISC: Number = 32;
	static var FORMTYPE_WEAPON: Number = 41;
	static var FORMTYPE_AMMO: Number = 42;
	static var FORMTYPE_KEY: Number = 45;
	static var FORMTYPE_ALCH: Number = 46;
	static var FORMTYPE_SOULGEM: Number = 52;
	static var FORMTYPE_SHOUT: Number = 0x77;
	static var FORMTYPE_SPELL: Number = 0x16;

	// Materials
	static var MATERIAL_ARTIFACT: Number = 1;
	static var MATERIAL_MAGIC: Number = 2;
	static var MATERIAL_DAEDRIC: Number = 3;
	static var MATERIAL_DRAGONPLATE: Number = 4;
	static var MATERIAL_NIGHTINGALE: Number = 5;
	static var MATERIAL_EBONY: Number = 6;
	static var MATERIAL_DRAGONSCALE: Number = 7;
	static var MATERIAL_ORCISH: Number = 8;
	static var MATERIAL_STEELPLATE: Number = 9;
	static var MATERIAL_GLASS: Number = 10;
	static var MATERIAL_ELVENGILDED: Number = 11;
	static var MATERIAL_DWARVEN: Number = 12;
	static var MATERIAL_SCALED: Number = 13;

	// Materials used for weapons but not (vanilla) armor
	static var MATERIAL_SILVER: Number = 14;
	static var MATERIAL_NORDHERO: Number = 15;
	static var MATERIAL_DRAUGR: Number = 16;
	static var MATERIAL_FALMERHONED: Number = 17;
	static var MATERIAL_FALMER: Number = 18;

	static var MATERIAL_STEEL: Number = 19;
	static var MATERIAL_BROTHERHOOD: Number = 20;
	static var MATERIAL_ELVEN: Number = 21;
	static var MATERIAL_IRONBANDED: Number = 22;
	static var MATERIAL_LEATHER: Number = 23;
	static var MATERIAL_IMPERIALSTUDDED: Number = 24;
	static var MATERIAL_STUDDED: Number = 25;
	static var MATERIAL_FUR: Number = 26;
	static var MATERIAL_IMPERIALHEAVY: Number = 27;
	static var MATERIAL_IRON: Number = 28;
	static var MATERIAL_IMPERIALLIGHT: Number = 29;
	static var MATERIAL_STORMCLOAK: Number = 30;
	static var MATERIAL_HIDE: Number = 31;
	static var MATERIAL_CLOTHING: Number = 32;


	// Weapon types
	static var WEAPON_TYPE_LONGSWORD: Number = 1;
	static var WEAPON_TYPE_DAGGER: Number = 2;
	static var WEAPON_TYPE_WARAXE: Number = 3;
	static var WEAPON_TYPE_MACE: Number = 4;
	static var WEAPON_TYPE_GREATSWORD: Number = 5;
	static var WEAPON_TYPE_BATTLEAXE: Number = 6;
	static var WEAPON_TYPE_HAMMER: Number = 7;
	static var WEAPON_TYPE_BOW: Number = 8;
	static var WEAPON_TYPE_STAFF: Number = 9;
	//NOTE: values as given by SKSE before modification by actionscript:
	//static var WEAPON_TYPE_BATTLEAXE: Number = 6;
	//static var WEAPON_TYPE_BOW: Number = 7;
	//static var WEAPON_TYPE_STAFF: Number = 8;
	//static var WEAPON_TYPE_HAMMER: Number = 18; // 18 would be next available, see SKSE TESObjectWEAP

	// Armor types
	// weightClass (light and heavy values swapped vs SKSE ennm for better sorting)
	static var ARMOR_WEIGHTCLASS_HEAVY: Number = 0;
	static var ARMOR_WEIGHTCLASS_LIGHT: Number = 1;
	static var ARMOR_WEIGHTCLASS_NONE: Number = 2;
	
	static var ARMOR_SUBTYPE_BODY: Number = 1;
	static var ARMOR_SUBTYPE_HEAD: Number = 2;
	static var ARMOR_SUBTYPE_HANDS: Number = 3;
	static var ARMOR_SUBTYPE_FOREARMS: Number = 4;
	static var ARMOR_SUBTYPE_FEET: Number = 5;
	static var ARMOR_SUBTYPE_CALVES: Number = 6;
	static var ARMOR_SUBTYPE_SHIELD: Number = 7;
	static var ARMOR_SUBTYPE_AMULET: Number = 8;
	static var ARMOR_SUBTYPE_RING: Number = 9;
	static var ARMOR_SUBTYPE_MASK: Number = 12;
	static var ARMOR_SUBTYPE_CIRCLET: Number = 13;
	
	// Alchemy types (potions and food)
	static var ALCH_TYPE_POTION: Number = 0;
	static var ALCH_TYPE_POISON: Number = 2;
	static var ALCH_TYPE_FOOD: Number = 3;

	// Soul gem types
	static var SOULGEM_EMPTY: Number = 0;
	static var SOULGEM_PARTIAL: Number = 1;
	static var SOULGEM_FULL: Number = 2;

	// Book types
	static var BOOK_TYPE_RECIPE: Number = 1;
	static var BOOK_TYPE_NOTE: Number = 2;
	static var BOOK_TYPE_MAP: Number = 3;
	static var BOOK_TYPE_JOURNAL: Number = 4;
	static var BOOK_TYPE_SPELLTOME: Number = 5;
	
	// Misc types
	static var MISC_TYPE_GOLD: Number = 0;
	static var MISC_TYPE_DRAGONCLAW: Number = 1;
	static var MISC_TYPE_ARTIFACT: Number = 2;
	static var MISC_TYPE_GEM: Number = 3;
	static var MISC_TYPE_INGOT: Number = 4;
	static var MISC_TYPE_ORE: Number = 5;
	static var MISC_TYPE_LEATHER: Number = 6;
	static var MISC_TYPE_LEATHERSTRIPS: Number = 7;
	static var MISC_TYPE_HIDE: Number = 8;
	static var MISC_TYPE_TOOL: Number = 9;
	static var MISC_TYPE_REMAINS: Number = 10;
	static var MISC_TYPE_CLUTTER: Number = TYPE_UNKNOWN + 1;
	
	// Spell type
	static var SPELL_TYPE_ALTERATION: Number = 18;
	static var SPELL_TYPE_CONJURATION: Number = 19;
	static var SPELL_TYPE_DESTRUCTION: Number = 20;
	static var SPELL_TYPE_ILLUSION: Number = 21;
	static var SPELL_TYPE_RESTORATION: Number = 22;
	
	// Actor Value
	// For potion and magic effects
	static var ACTORVALUE_AGGRESSION: Number = 0;
	static var ACTORVALUE_CONFIDENCE: Number = 1;
	static var ACTORVALUE_ENERGY: Number = 2;
	static var ACTORVALUE_MORALITY: Number = 3;
	static var ACTORVALUE_MOOD: Number = 4;
	static var ACTORVALUE_ASSISTANCE: Number = 5;
	static var ACTORVALUE_ONEHANDED: Number = 6;
	static var ACTORVALUE_TWOHANDED: Number = 7;
	static var ACTORVALUE_MARKSMAN: Number = 8;
	static var ACTORVALUE_BLOCK: Number = 9;
	static var ACTORVALUE_SMITHING: Number = 10;
	static var ACTORVALUE_HEAVYARMOR: Number = 11;
	static var ACTORVALUE_LIGHTARMOR: Number = 12;
	static var ACTORVALUE_PICKPOCKET: Number = 13;
	static var ACTORVALUE_LOCKPICKING: Number = 14;
	static var ACTORVALUE_SNEAK: Number = 15;
	static var ACTORVALUE_ALCHEMY: Number = 16;
	static var ACTORVALUE_SPEECHCRAFT: Number = 17;
	static var ACTORVALUE_ALTERATION: Number = 18;
	static var ACTORVALUE_CONJURATION: Number = 19;
	static var ACTORVALUE_DESTRUCTION: Number = 20;
	static var ACTORVALUE_ILLUSION: Number = 21;
	static var ACTORVALUE_RESTORATION: Number = 22;
	static var ACTORVALUE_ENCHANTING: Number = 23;
	static var ACTORVALUE_HEALTH: Number = 24;
	static var ACTORVALUE_MAGICKA: Number = 25;
	static var ACTORVALUE_STAMINA: Number = 26;
	static var ACTORVALUE_HEALRATE: Number = 27;
	static var ACTORVALUE_MAGICKARATE: Number = 28;
	static var ACTORVALUE_STAMINARATE: Number = 29;
	static var ACTORVALUE_SPEEDMULT: Number = 30;
	static var ACTORVALUE_INVENTORYWEIGHT: Number = 31;
	static var ACTORVALUE_CARRYWEIGHT: Number = 32;
	static var ACTORVALUE_CRITCHANCE: Number = 33;
	static var ACTORVALUE_MELEEDAMAGE: Number = 34;
	static var ACTORVALUE_UNARMEDDAMAGE: Number = 35;
	static var ACTORVALUE_MASS: Number = 36;
	static var ACTORVALUE_VOICEPOINTS: Number = 37;
	static var ACTORVALUE_VOICERATE: Number = 38;
	static var ACTORVALUE_DAMAGERESIST: Number = 39;
	static var ACTORVALUE_POISONRESIST: Number = 40;
	static var ACTORVALUE_FIRERESIST: Number = 41;
	static var ACTORVALUE_ELECTRICRESIST: Number = 42;
	static var ACTORVALUE_FROSTRESIST: Number = 43;
	static var ACTORVALUE_MAGICRESIST: Number = 44;
	static var ACTORVALUE_DISEASERESIST: Number = 45;
	static var ACTORVALUE_PERCEPTIONCONDITION: Number = 46;
	static var ACTORVALUE_ENDURANCECONDITION: Number = 47;
	static var ACTORVALUE_LEFTATTACKCONDITION: Number = 48;
	static var ACTORVALUE_RIGHTATTACKCONDITION: Number = 49;
	static var ACTORVALUE_LEFTMOBILITYCONDITION: Number = 50;
	static var ACTORVALUE_RIGHTMOBILITYCONDITION: Number = 51;
	static var ACTORVALUE_BRAINCONDITION: Number = 52;
	static var ACTORVALUE_PARALYSIS: Number = 53;
	static var ACTORVALUE_INVISIBILITY: Number = 54;
	static var ACTORVALUE_NIGHTEYE: Number = 55;
	static var ACTORVALUE_DETECTLIFERANGE: Number = 56;
	static var ACTORVALUE_WATERBREATHING: Number = 57;
	static var ACTORVALUE_WATERWALKING: Number = 58;
	static var ACTORVALUE_IGNORECRIPPLEDLIMBS: Number = 59;
	static var ACTORVALUE_FAME: Number = 60;
	static var ACTORVALUE_INFAMY: Number = 61;
	static var ACTORVALUE_JUMPINGBONUS: Number = 62;
	static var ACTORVALUE_WARDPOWER: Number = 63;
	static var ACTORVALUE_RIGHTITEMCHARGE: Number = 64;
	static var ACTORVALUE_ARMORPERKS: Number = 65;
	static var ACTORVALUE_SHIELDPERKS: Number = 66;
	static var ACTORVALUE_WARDDEFLECTION: Number = 67;
	static var ACTORVALUE_VARIABLE01: Number = 68;
	static var ACTORVALUE_VARIABLE02: Number = 69;
	static var ACTORVALUE_VARIABLE03: Number = 70;
	static var ACTORVALUE_VARIABLE04: Number = 71;
	static var ACTORVALUE_VARIABLE05: Number = 72;
	static var ACTORVALUE_VARIABLE06: Number = 73;
	static var ACTORVALUE_VARIABLE07: Number = 74;
	static var ACTORVALUE_VARIABLE08: Number = 75;
	static var ACTORVALUE_VARIABLE09: Number = 76;
	static var ACTORVALUE_VARIABLE10: Number = 77;
	static var ACTORVALUE_BOWSPEEDBONUS: Number = 78;
	static var ACTORVALUE_FAVORACTIVE: Number = 79;
	static var ACTORVALUE_FAVORSPERDAY: Number = 80;
	static var ACTORVALUE_FAVORSPERDAYTIMER: Number = 81;
	static var ACTORVALUE_LEFTITEMCHARGE: Number = 82;
	static var ACTORVALUE_ABSORBCHANCE: Number = 83;
	static var ACTORVALUE_BLINDNESS: Number = 84;
	static var ACTORVALUE_WEAPONSPEEDMULT: Number = 85;
	static var ACTORVALUE_SHOUTRECOVERYMULT: Number = 86;
	static var ACTORVALUE_BOWSTAGGERBONUS: Number = 87;
	static var ACTORVALUE_TELEKINESIS: Number = 88;
	static var ACTORVALUE_FAVORPOINTSBONUS: Number = 89;
	static var ACTORVALUE_LASTBRIBEDINTIMIDATED: Number = 90;
	static var ACTORVALUE_LASTFLATTERED: Number = 91;
	static var ACTORVALUE_MOVEMENTNOISEMULT: Number = 92;
	static var ACTORVALUE_BYPASSVENDORSTOLENCHECK: Number = 93;
	static var ACTORVALUE_BYPASSVENDORKEYWORDCHECK: Number = 94;
	static var ACTORVALUE_WAITINGFORPLAYER: Number = 95;
	static var ACTORVALUE_ONEHANDEDMOD: Number = 96;
	static var ACTORVALUE_TWOHANDEDMOD: Number = 97;
	static var ACTORVALUE_MARKSMANMOD: Number = 98;
	static var ACTORVALUE_BLOCKMOD: Number = 99;
	static var ACTORVALUE_SMITHINGMOD: Number = 100;
	static var ACTORVALUE_HEAVYARMORMOD: Number = 101;
	static var ACTORVALUE_LIGHTARMORMOD: Number = 102;
	static var ACTORVALUE_PICKPOCKETMOD: Number = 103;
	static var ACTORVALUE_LOCKPICKINGMOD: Number = 104;
	static var ACTORVALUE_SNEAKMOD: Number = 105;
	static var ACTORVALUE_ALCHEMYMOD: Number = 106;
	static var ACTORVALUE_SPEECHCRAFTMOD: Number = 107;
	static var ACTORVALUE_ALTERATIONMOD: Number = 108;
	static var ACTORVALUE_CONJURATIONMOD: Number = 109;
	static var ACTORVALUE_DESTRUCTIONMOD: Number = 110;
	static var ACTORVALUE_ILLUSIONMOD: Number = 111;
	static var ACTORVALUE_RESTORATIONMOD: Number = 112;
	static var ACTORVALUE_ENCHANTINGMOD: Number = 113;
	static var ACTORVALUE_ONEHANDEDSKILLADVANCE: Number = 114;
	static var ACTORVALUE_TWOHANDEDSKILLADVANCE: Number = 115;
	static var ACTORVALUE_MARKSMANSKILLADVANCE: Number = 116;
	static var ACTORVALUE_BLOCKSKILLADVANCE: Number = 117;
	static var ACTORVALUE_SMITHINGSKILLADVANCE: Number = 118;
	static var ACTORVALUE_HEAVYARMORSKILLADVANCE: Number = 119;
	static var ACTORVALUE_LIGHTARMORSKILLADVANCE: Number = 120;
	static var ACTORVALUE_PICKPOCKETSKILLADVANCE: Number = 121;
	static var ACTORVALUE_LOCKPICKINGSKILLADVANCE: Number = 122;
	static var ACTORVALUE_SNEAKSKILLADVANCE: Number = 123;
	static var ACTORVALUE_ALCHEMYSKILLADVANCE: Number = 124;
	static var ACTORVALUE_SPEECHCRAFTSKILLADVANCE: Number = 125;
	static var ACTORVALUE_ALTERATIONSKILLADVANCE: Number = 126;
	static var ACTORVALUE_CONJURATIONSKILLADVANCE: Number = 127;
	static var ACTORVALUE_DESTRUCTIONSKILLADVANCE: Number = 128;
	static var ACTORVALUE_ILLUSIONSKILLADVANCE: Number = 129;
	static var ACTORVALUE_RESTORATIONSKILLADVANCE: Number = 130;
	static var ACTORVALUE_ENCHANTINGSKILLADVANCE: Number = 131;
	static var ACTORVALUE_LEFTWEAPONSPEEDMULT: Number = 132;
	static var ACTORVALUE_DRAGONSOULS: Number = 133;
	static var ACTORVALUE_COMBATHEALTHREGENMULT: Number = 134;
	static var ACTORVALUE_ONEHANDEDPOWERMOD: Number = 135;
	static var ACTORVALUE_TWOHANDEDPOWERMOD: Number = 136;
	static var ACTORVALUE_MARKSMANPOWERMOD: Number = 137;
	static var ACTORVALUE_BLOCKPOWERMOD: Number = 138;
	static var ACTORVALUE_SMITHINGPOWERMOD: Number = 139;
	static var ACTORVALUE_HEAVYARMORPOWERMOD: Number = 140;
	static var ACTORVALUE_LIGHTARMORPOWERMOD: Number = 141;
	static var ACTORVALUE_PICKPOCKETPOWERMOD: Number = 142;
	static var ACTORVALUE_LOCKPICKINGPOWERMOD: Number = 143;
	static var ACTORVALUE_SNEAKPOWERMOD: Number = 144;
	static var ACTORVALUE_ALCHEMYPOWERMOD: Number = 145;
	static var ACTORVALUE_SPEECHCRAFTPOWERMOD: Number = 146;
	static var ACTORVALUE_ALTERATIONPOWERMOD: Number = 147;
	static var ACTORVALUE_CONJURATIONPOWERMOD: Number = 148;
	static var ACTORVALUE_DESTRUCTIONPOWERMOD: Number = 149;
	static var ACTORVALUE_ILLUSIONPOWERMOD: Number = 150;
	static var ACTORVALUE_RESTORATIONPOWERMOD: Number = 151;
	static var ACTORVALUE_ENCHANTINGPOWERMOD: Number = 152;
	static var ACTORVALUE_DRAGONREND: Number = 153;
	static var ACTORVALUE_ATTACKDAMAGEMULT: Number = 154;
	static var ACTORVALUE_HEALRATEMULT: Number = 155;
	static var ACTORVALUE_MAGICKARATEMULT: Number = 156;
	static var ACTORVALUE_STAMINARATEMULT: Number = 157;
	static var ACTORVALUE_WEREWOLFPERKS: Number = 158;
	static var ACTORVALUE_VAMPIREPERKS: Number = 159;
	static var ACTORVALUE_GRABACTOROFFSET: Number = 160;
	static var ACTORVALUE_GRABBED: Number = 161;
	static var ACTORVALUE_DEPRECATED05: Number = 162;
	static var ACTORVALUE_REFLECTDAMAGE: Number = 163;
	
	// Real Values
	static var ACTORVALUE_STRENGTH: Number = 32;
	static var ACTORVALUE_FIRE: Number = 41;
	static var ACTORVALUE_SHOCK: Number = 42;
	static var ACTORVALUE_FROST: Number = 43;
	static var ACTORVALUE_MAGIC: Number = 44;
	
	// Magic Type
	static var MAGICTYPE_FIRE: Number = 41;
	static var MAGICTYPE_SHOCK: Number = 42;
	static var MAGICTYPE_FROST: Number = 43;
	
	// Archetype for Active Effects
	static var ARCHETYPE_VALUEMOD: Number = 0;
	static var ARCHETYPE_SCRIPT: Number = 1;
	static var ARCHETYPE_DISPEL: Number = 2;
	static var ARCHETYPE_CUREDISEASE: Number = 3;
	static var ARCHETYPE_ABSORB: Number = 4;
	static var ARCHETYPE_DUALVALUEMOD: Number = 5;
	static var ARCHETYPE_CALM: Number = 6;
	static var ARCHETYPE_DEMORALIZE: Number = 7;
	static var ARCHETYPE_FRENZY: Number = 8;
	static var ARCHETYPE_DISARM: Number = 9;
	static var ARCHETYPE_COMMANDSUMMONED: Number = 10;
	static var ARCHETYPE_INVISIBILITY: Number = 11;
	static var ARCHETYPE_LIGHT: Number = 12;
	static var ARCHETYPE_LOCK: Number = 15;
	static var ARCHETYPE_OPEN: Number = 16;
	static var ARCHETYPE_BOUNDWEAPON: Number = 17;
	static var ARCHETYPE_SUMMONCREATURE: Number = 18;
	static var ARCHETYPE_DETECTLIFE: Number = 19;
	static var ARCHETYPE_TELEKINESIS: Number = 20;
	static var ARCHETYPE_PARALYSIS: Number = 21;
	static var ARCHETYPE_REANIMATE: Number = 22;
	static var ARCHETYPE_SOULTRAP: Number = 23;
	static var ARCHETYPE_TURNUNDEAD: Number = 24;
	static var ARCHETYPE_GUIDE: Number = 25;
	static var ARCHETYPE_WEREWOLFFEED: Number = 26;
	static var ARCHETYPE_CUREPARALYSIS: Number = 27;
	static var ARCHETYPE_CUREADDICTION: Number = 28;
	static var ARCHETYPE_CUREPOISON: Number = 29;
	static var ARCHETYPE_CONCUSSION: Number = 30;
	static var ARCHETYPE_VALUEANDPARTS: Number = 31;
	static var ARCHETYPE_ACCUMULATEMAGNITUDE: Number = 32;
	static var ARCHETYPE_STAGGER: Number = 33;
	static var ARCHETYPE_PEAKVALUEMOD: Number = 34;
	static var ARCHETYPE_CLOAK: Number = 35;
	static var ARCHETYPE_WEREWOLF: Number = 36;
	static var ARCHETYPE_SLOWTIME: Number = 37;
	static var ARCHETYPE_RALLY: Number = 38;
	static var ARCHETYPE_ENHANCEWEAPON: Number = 39;
	static var ARCHETYPE_SPAWNHAZARD: Number = 40;
	static var ARCHETYPE_ETHEREALIZE: Number = 41;
	static var ARCHETYPE_BANISH: Number = 42;
	static var ARCHETYPE_DISGUISE: Number = 44;
	static var ARCHETYPE_GRABACTOR: Number = 45;
	static var ARCHETYPE_VAMPIRELORD: Number = 46;
	
	// Casting Type for Active Effects
	static var CASTINGTYPE_CONSTANTEFFECT: Number = 0;
	static var CASTINGTYPE_FIREANDFORGET: Number = 1;
	static var CASTINGTYPE_CONCENTRATION: Number = 2;
	
	// Form Ids
	static var FORMID_GOLD001: Number = 0xF;
	static var FORMID_LEATHER01: Number = 0xDB5D2;
	static var FORMID_LEATHERSTRIPS: Number = 0x800E4;
	
	static var FORMID_BOUNDARROW: Number = 0x10B0A7;
	static var FORMID_CWARROW: Number = 0x20DDF;
	static var FORMID_CWARROWSHORT: Number = 0x20F02;
	static var FORMID_DAEDRICARROW: Number = 0x139C0;
	static var FORMID_DRAUGRARROW: Number = 0x34182;
	static var FORMID_DUNARCHERPRATICEARROW: Number = 0xCAB52;
	static var FORMID_DUNGEIRMUNDSIGDISARROWSILLUSION: Number = 0xE738A;
	static var FORMID_DWARVENARROW: Number = 0x139BC;
	static var FORMID_DWARVENSPHEREARROW: Number = 0x7B932;
	static var FORMID_DWARVENSPHEREBOLT01: Number = 0x7B935;
	static var FORMID_DWARVENSPHEREBOLT02: Number = 0x10EC8C;
	static var FORMID_EBONYARROW: Number = 0x139BF;
	static var FORMID_ELVENARROW: Number = 0x139BD;
	static var FORMID_FALMERARROW: Number = 0x38341;
	static var FORMID_FOLLOWERIRONARROW: Number = 0x10E2DE;
	static var FORMID_FORSWORNARROW: Number = 0xCEE9E;
	static var FORMID_GLASSARROW: Number = 0x139BE;
	static var FORMID_IRONARROW: Number = 0x1397D;
	static var FORMID_MQ101STEELARROW: Number = 0x105EE7;
	static var FORMID_NORDHEROARROW: Number = 0xEAFDF;
	static var FORMID_ORCISHARROW: Number = 0x139BB;
	static var FORMID_STEELARROW: Number = 0x1397F;
	static var FORMID_TRAPDART: Number = 0x236DD;
	
	static var FORMID_RUBYDRAGONCLAW: Number = 0x4B56C;
	static var FORMID_IVORYDRAGONCLAW: Number = 0xAB7BB;
	static var FORMID_GLASSCLAW: Number = 0x7C260;
	static var FORMID_EBONYCLAW: Number = 0x5AF48;
	static var FORMID_EMERALDDRAGONCLAW: Number = 0xED417;
	static var FORMID_DIAMONDCLAW: Number = 0xAB375;
	static var FORMID_IRONCLAW: Number = 0x8CDFA;
	static var FORMID_CORALDRAGONCLAW: Number = 0xB634C;
	static var FORMID_E3GOLDENCLAW: Number = 0x999E7;
	static var FORMID_SAPPHIREDRAGONCLAW: Number = 0x663D7;
	static var FORMID_MS13GOLDENCLAW: Number = 0x39647;

	static var FORMID_DA01AZURASSTARBROKEN: Number = 0x28AD7;
	static var FORMID_DA01SOULGEMBLACKSTAR: Number = 0x63B29;
	static var FORMID_DA01SOULGEMAZURASSTAR: Number = 0x63B27;
	
	// pick axes
	static var FORMID_WEAPPICKAXE: Number = 0xE3C16;
	static var FORMID_SSDROCKSPLINTERPICKAXE: Number = 0x6A707;
	static var FORMID_DUNVOLUNRUUDPICKAXE: Number = 0x1019D4;

	// woodcutter's axes
	static var FORMID_AXE01: Number = 0x2F2F4;
	static var FORMID_DUNHALTEDSTREAMPOACHERSAXE: Number = 0xAE086;
	
}