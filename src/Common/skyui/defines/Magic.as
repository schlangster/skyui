import skyui.defines.Actor;

class skyui.defines.Magic
{
	public static var NONE: Number					= Actor.NONE;

	// Reisist
	public static var DAMAGERESIST: Number			= Actor.DAMAGERESIST;
	public static var POISONRESIST: Number			= Actor.POISONRESIST;
	public static var FIRERESIST: Number			= Actor.FIRERESIST;
	public static var ELECTRICRESIST: Number		= Actor.ELECTRICRESIST;
	public static var FROSTRESIST: Number			= Actor.FROSTRESIST;
	public static var MAGICRESIST: Number			= Actor.MAGICRESIST;
	public static var DISEASERESIST: Number			= Actor.DISEASERESIST;

	// Magic Skill
	public static var ALTERATION: Number			= Actor.ALTERATION;
	public static var CONJURATION: Number			= Actor.CONJURATION;
	public static var DESTRUCTION: Number			= Actor.DESTRUCTION;
	public static var ILLUSION: Number				= Actor.ILLUSION;
	public static var RESTORATION: Number			= Actor.RESTORATION;

	// CastingType
	public static var CONSTANTEFFECT: Number		= 0x00;
	public static var FIREANDFORGET: Number			= 0x01;
	public static var CONCENTRATION: Number			= 0x02;

	// Delivery
	public static var SELF: Number					= 0x00;
	public static var CONTACT: Number				= 0x01;
	public static var AIMED: Number					= 0x02;
	public static var TARGETACTOR: Number			= 0x03;
	public static var TARGETLOCATION: Number		= 0x04;

	// CastingType
	public static var SPELL: Number					= 0x00;
	public static var DISEASE: Number				= 0x01;
	public static var POWER: Number					= 0x02;
	public static var LESSERPOWER: Number			= 0x03;
	public static var ABILITY: Number				= 0x04;
	public static var ADDICTION: Number				= 0x0A;
	public static var VOICE: Number					= 0x0B;

	// Archetype
	public static var VALUEMOD: Number				= 0x00;
	public static var SCRIPT: Number				= 0x01;
	public static var DISPEL: Number				= 0x02;
	public static var CUREDISEASE: Number			= 0x03;
	public static var ABSORB: Number				= 0x04;
	public static var DUALVALUEMOD: Number			= 0x05;
	public static var CALM: Number					= 0x06;
	public static var DEMORALIZE: Number			= 0x07;
	public static var FRENZY: Number				= 0x08;
	public static var DISARM: Number				= 0x09;
	public static var COMMANDSUMMONED: Number		= 0x0A;
	public static var INVISIBILITY: Number			= 0x0B;
	public static var LIGHT: Number					= 0x0C;

	public static var LOCK: Number					= 0x0F;
	public static var OPEN: Number					= 0x10;
	public static var BOUNDWEAPON: Number			= 0x11;
	public static var SUMMONCREATURE: Number		= 0x12;
	public static var DETECTLIFE: Number			= 0x13;
	public static var TELEKINESIS: Number			= 0x14;
	public static var PARALYSIS: Number				= 0x15;
	public static var REANIMATE: Number				= 0x16;
	public static var SOULTRAP: Number				= 0x17;
	public static var TURNUNDEAD: Number			= 0x18;
	public static var GUIDE: Number					= 0x19;
	public static var WEREWOLFFEED: Number			= 0x1A;
	public static var CUREPARALYSIS: Number			= 0x1B;
	public static var CUREADDICTION: Number			= 0x1C;
	public static var CUREPOISON: Number			= 0x1D;
	public static var CONCUSSION: Number			= 0x1E;
	public static var VALUEANDPARTS: Number			= 0x1F;
	public static var ACCUMULATEMAGNITUDE: Number	= 0x20;
	public static var STAGGER: Number				= 0x21;
	public static var PEAKVALUEMOD: Number			= 0x22;
	public static var CLOAK: Number					= 0x23;
	public static var WEREWOLF: Number				= 0x24;
	public static var SLOWTIME: Number				= 0x25;
	public static var RALLY: Number					= 0x26;
	public static var ENHANCEWEAPON: Number			= 0x27;
	public static var SPAWNHAZARD: Number			= 0x28;
	public static var ETHEREALIZE: Number			= 0x29;
	public static var BANISH: Number				= 0x2A;

	public static var DISGUISE: Number				= 0x2C;
	public static var GRABACTOR: Number				= 0x2D;
	public static var VAMPIRELORD: Number			= 0x2E;

	// MGEF flags
	public static var MGEF_HOSTILE: Number			= 0x00000001;
	public static var MGEF_RECOVER: Number			= 0x00000002;
	public static var MGEF_DETRIMENTAL: Number		= 0x00000004;
	public static var MGEF_NOHITEVENT: Number		= 0x00000010;
	public static var MGEF_DISPELKEYWORDS: Number	= 0x00000100;
	public static var MGEF_NODURATION: Number		= 0x00000200;
	public static var MGEF_NOMAGNITUDE: Number		= 0x00000400;
	public static var MGEF_NOAREA: Number			= 0x00000800;
	public static var MGEF_FXPERSIST: Number		= 0x00001000;
	public static var MGEF_GLORYVISUALS: Number		= 0x00004000;
	public static var MGEF_HIDEINUI: Number			= 0x00008000;
	public static var MGEF_NORECAST: Number			= 0x00020000;
	public static var MGEF_MAGNITUDE: Number		= 0x00200000;
	public static var MGEF_DURATION: Number			= 0x00400000;
	public static var MGEF_PAINLESS: Number			= 0x04000000;
	public static var MGEF_NOHITEFFECT: Number		= 0x08000000;
	public static var MGEF_NODEATHDISPEL: Number	= 0x10000000;
}