import skyui.defines.Actor;

class skyui.defines.Magic
{
	// Reisist
	public static var RESIST_NONE: Number				= Actor.ACTORVALUE_NONE;
	public static var RESIST_DAMAGE: Number				= Actor.ACTORVALUE_DAMAGERESIST;
	public static var RESIST_POISON: Number				= Actor.ACTORVALUE_POISONRESIST;
	public static var RESIST_FIRE: Number				= Actor.ACTORVALUE_FIRERESIST;
	public static var RESIST_ELECTRIC: Number			= Actor.ACTORVALUE_ELECTRICRESIST;
	public static var RESIST_FROST: Number				= Actor.ACTORVALUE_FROSTRESIST;
	public static var RESIST_MAGIC: Number				= Actor.ACTORVALUE_MAGICRESIST;
	public static var RESIST_DISEASE: Number			= Actor.ACTORVALUE_DISEASERESIST;

	// Magic Skill (school)
	public static var SCHOOL_NONE: Number				= Actor.ACTORVALUE_NONE;
	public static var SCHOOL_ALTERATION: Number			= Actor.ACTORVALUE_ALTERATION;
	public static var SCHOOL_CONJURATION: Number		= Actor.ACTORVALUE_CONJURATION;
	public static var SCHOOL_DESTRUCTION: Number		= Actor.ACTORVALUE_DESTRUCTION;
	public static var SCHOOL_ILLUSION: Number			= Actor.ACTORVALUE_ILLUSION;
	public static var SCHOOL_RESTORATION: Number		= Actor.ACTORVALUE_RESTORATION;

	// CastingType
	public static var CONSTANTEFFECT: Number			= 0x00;
	public static var FIREANDFORGET: Number				= 0x01;
	public static var CONCENTRATION: Number				= 0x02;

	// Delivery
	public static var DELIVERY_SELF: Number				= 0x00;
	public static var DELIVERY_CONTACT: Number			= 0x01;
	public static var DELIVERY_AIMED: Number			= 0x02;
	public static var DELIVERY_TARGETACTOR: Number		= 0x03;
	public static var DELIVERY_TARGETLOCATION: Number	= 0x04;

	// CastingType
	public static var CASTTYPE_SPELL: Number			= 0x00;
	public static var CASTTYPE_DISEASE: Number			= 0x01;
	public static var CASTTYPE_POWER: Number			= 0x02;
	public static var CASTTYPE_LESSERPOWER: Number		= 0x03;
	public static var CASTTYPE_ABILITY: Number			= 0x04;
	public static var CASTTYPE_ADDICTION: Number		= 0x0A;
	public static var CASTTYPE_VOICE: Number			= 0x0B;

	// Archetype
	public static var ARCHETYPE_VALUEMOD: Number			= 0x00;
	public static var ARCHETYPE_SCRIPT: Number				= 0x01;
	public static var ARCHETYPE_DISPEL: Number				= 0x02;
	public static var ARCHETYPE_CUREDISEASE: Number			= 0x03;
	public static var ARCHETYPE_ABSORB: Number				= 0x04;
	public static var ARCHETYPE_DUALVALUEMOD: Number		= 0x05;
	public static var ARCHETYPE_CALM: Number				= 0x06;
	public static var ARCHETYPE_DEMORALIZE: Number			= 0x07;
	public static var ARCHETYPE_FRENZY: Number				= 0x08;
	public static var ARCHETYPE_DISARM: Number				= 0x09;
	public static var ARCHETYPE_COMMANDSUMMONED: Number		= 0x0A;
	public static var ARCHETYPE_INVISIBILITY: Number		= 0x0B;
	public static var ARCHETYPE_LIGHT: Number				= 0x0C;

	public static var ARCHETYPE_LOCK: Number				= 0x0F;
	public static var ARCHETYPE_OPEN: Number				= 0x10;
	public static var ARCHETYPE_BOUNDWEAPON: Number			= 0x11;
	public static var ARCHETYPE_SUMMONCREATURE: Number		= 0x12;
	public static var ARCHETYPE_DETECTLIFE: Number			= 0x13;
	public static var ARCHETYPE_TELEKINESIS: Number			= 0x14;
	public static var ARCHETYPE_PARALYSIS: Number			= 0x15;
	public static var ARCHETYPE_REANIMATE: Number			= 0x16;
	public static var ARCHETYPE_SOULTRAP: Number			= 0x17;
	public static var ARCHETYPE_TURNUNDEAD: Number			= 0x18;
	public static var ARCHETYPE_GUIDE: Number				= 0x19;
	public static var ARCHETYPE_WEREWOLFFEED: Number		= 0x1A;
	public static var ARCHETYPE_CUREPARALYSIS: Number		= 0x1B;
	public static var ARCHETYPE_CUREADDICTION: Number		= 0x1C;
	public static var ARCHETYPE_CUREPOISON: Number			= 0x1D;
	public static var ARCHETYPE_CONCUSSION: Number			= 0x1E;
	public static var ARCHETYPE_VALUEANDPARTS: Number		= 0x1F;
	public static var ARCHETYPE_ACCUMULATEMAGNITUDE: Number	= 0x20;
	public static var ARCHETYPE_STAGGER: Number				= 0x21;
	public static var ARCHETYPE_PEAKVALUEMOD: Number		= 0x22;
	public static var ARCHETYPE_CLOAK: Number				= 0x23;
	public static var ARCHETYPE_WEREWOLF: Number			= 0x24;
	public static var ARCHETYPE_SLOWTIME: Number			= 0x25;
	public static var ARCHETYPE_RALLY: Number				= 0x26;
	public static var ARCHETYPE_ENHANCEWEAPON: Number		= 0x27;
	public static var ARCHETYPE_SPAWNHAZARD: Number			= 0x28;
	public static var ARCHETYPE_ETHEREALIZE: Number			= 0x29;
	public static var ARCHETYPE_BANISH: Number				= 0x2A;

	public static var ARCHETYPE_DISGUISE: Number			= 0x2C;
	public static var ARCHETYPE_GRABACTOR: Number			= 0x2D;
	public static var ARCHETYPE_VAMPIRELORD: Number			= 0x2E;

	// MGEF flags
	public static var MGEFFLAG_HOSTILE: Number			= 0x00000001;
	public static var MGEFFLAG_RECOVER: Number			= 0x00000002;
	public static var MGEFFLAG_DETRIMENTAL: Number		= 0x00000004;
	public static var MGEFFLAG_NOHITEVENT: Number		= 0x00000010;
	public static var MGEFFLAG_DISPELKEYWORDS: Number	= 0x00000100;
	public static var MGEFFLAG_NODURATION: Number		= 0x00000200;
	public static var MGEFFLAG_NOMAGNITUDE: Number		= 0x00000400;
	public static var MGEFFLAG_NOAREA: Number			= 0x00000800;
	public static var MGEFFLAG_FXPERSIST: Number		= 0x00001000;
	public static var MGEFFLAG_GLORYVISUALS: Number		= 0x00004000;
	public static var MGEFFLAG_HIDEINUI: Number			= 0x00008000;
	public static var MGEFFLAG_NORECAST: Number			= 0x00020000;
	public static var MGEFFLAG_MAGNITUDE: Number		= 0x00200000;
	public static var MGEFFLAG_DURATION: Number			= 0x00400000;
	public static var MGEFFLAG_PAINLESS: Number			= 0x04000000;
	public static var MGEFFLAG_NOHITEFFECT: Number		= 0x08000000;
	public static var MGEFFLAG_NODEATHDISPEL: Number	= 0x10000000;
}