import skyui.defines.Magic;
import skyui.defines.Actor;


class skyui.util.EffectIconMap
{
	private static var _archetypeMap: Array = [
		null,			// 0 - ARCHETYPE_VALUEMOD					EMBLEM
		null,			// 1 - ARCHETYPE_SCRIPT						nn
		null,			// 2 - ARCHETYPE_DISPEL						nn
		null,			// 3 - ARCHETYPE_CUREDISEASE				nn
		null,			// 4 - ARCHETYPE_ABSORB						EMBLEM
		null,			// 5 - ARCHETYPE_DUALVALUEMOD				EMBLEM
		null,			// 6 - ARCHETYPE_CALM						nn
		null,			// 7 - ARCHETYPE_DEMORALIZE					nn
		null,			// 8 - ARCHETYPE_FRENZY						nn
		null,			// 9 - ARCHETYPE_DISARM						nn
		"conjure",		// 10 - ARCHETYPE_COMMANDSUMMONED			OK
		"invisibility",	// 11 - ARCHETYPE_INVISIBILITY				OK
		"light",		// 12 - ARCHETYPE_LIGHT						OK
		null,
		null,
		null,			// 15 - ARCHETYPE_LOCK						nn
		null,			// 16 - ARCHETYPE_OPEN						nn
		"bound_item",	// 17 - ARCHETYPE_BOUNDWEAPON				OK
		"conjure",		// 18 - ARCHETYPE_SUMMONCREATURE			OK
		null,			// 19 - ARCHETYPE_DETECTLIFE				nn
		null,			// 20 - ARCHETYPE_TELEKINESIS				nn
		"paralysis",	// 21 - ARCHETYPE_PARALYSIS					X
		null,			// 22 - ARCHETYPE_REANIMATE					nn
		null,			// 23 - ARCHETYPE_SOULTRAP					nn
		null,			// 24 - ARCHETYPE_TURNUNDEAD				nn
		"clairvoyance",	// 25 - ARCHETYPE_GUIDE						X
		null,			// 26 - ARCHETYPE_WEREWOLFFEED				nn
		null,			// 27 - ARCHETYPE_CUREPARALYSIS				nn
		null,			// 28 - ARCHETYPE_CUREADDICTION				nn
		null,			// 29 - ARCHETYPE_CUREPOISON				nn
		null,			// 30 - ARCHETYPE_CONCUSSION				nn
		null,			// 31 - ARCHETYPE_VALUEANDPARTS				nn
		null,			// 32 - ARCHETYPE_ACCUMULATEMAGNITUDE		nn
		null,			// 33 - ARCHETYPE_STAGGER					nn
		null,			// 34 - ARCHETYPE_PEAKVALUEMOD				EMBLEM
		"cloak",		// 35 - ARCHETYPE_CLOAK						X
		"werewolf",		// 36 - ARCHETYPE_WEREWOLF					OK
		"slowtime",		// 37 - ARCHETYPE_SLOWTIME					X
		null,			// 38 - ARCHETYPE_RALLY						nn
		"buffweapon",	// 39 - ARCHETYPE_ENHANCEWEAPON				X
		null,			// 40 - ARCHETYPE_SPAWNHAZARD				nn
		"ethereal",		// 41 - ARCHETYPE_ETHEREALIZE				X
		null,			// 42 - ARCHETYPE_BANISH					nn
		null,
		null,			// 44 - ARCHETYPE_DISGUISE					?
		null,			// 45 - ARCHETYPE_GRABACTOR					nn
		"vampire"		// 46 - ARCHETYPE_VAMPIRELORD				OK
	];
	
	private static var _avMap: Array = [
		null,						// 0 - AV_AGGRESSION			nn
		null,						// 1 - AV_CONFIDENCE			nn
		null,						// 2 - AV_ENERGY				nn
		null,						// 3 - AV_MORALITY				nn
		null,						// 4 - AV_MOOD					nn
		null,						// 5 - AV_ASSISTANCE			nn
		"av_skill_weapon_1h",		// 6 - AV_ONEHANDED
		"av_skill_weapon_2h",		// 7 - AV_TWOHANDED
		"av_skill_archery",			// 8 - AV_MARKSMAN
		"av_skill_block",			// 9 - AV_BLOCK
		"av_skill_smithing",		// 10 - AV_SMITHING
		"av_skill_armor_heavy",		// 11 - AV_HEAVYARMOR
		"av_skill_armor_light",		// 12 - AV_LIGHTARMOR
		"av_skill_pickpocket",		// 13 - AV_PICKPOCKET
		"av_skill_lockpicking",		// 14 - AV_LOCKPICKING
		"av_skill_sneak",			// 15 - AV_SNEAK
		"av_skill_alchemy",			// 16- AV_ALCHEMY
		"av_skill_persuasion",		// 17 - AV_SPEECHCRAFT
		"av_skill_alteration",		// 18 - AV_ALTERATION
		"av_skill_conjuration",		// 19 - AV_CONJURATION
		"av_skill_destruction",		// 20 - AV_DESTRUCTION
		"av_skill_illusion",		// 21 - AV_ILLUSION
		"av_skill_restoration",		// 22 - AV_RESTORATION
		"av_skill_enchanting",		// 23 - AV_ENCHANTING
		"av_health",				// 24 - AV_HEALTH
		"av_magica",				// 25 - AV_MAGICKA
		"av_stamina",				// 26 - AV_STAMINA
		"av_health_regen",			// 27 - AV_HEALRATE
		"av_magicka_regen",			// 28 - AV_MAGICKARATE
		"av_stamina_regen",			// 29 - AV_STAMINARATE
		"destruction_special_slow",	// 30 - AV_SPEEDMULT			X
		null, 						// 31 - AV_INVENTORYWEIGHT		nn
		"av_carryweight",			// 32 - AV_CARRYWEIGHT
		null,						// 33 - AV_CRITCHANCE
		"av_skill_unarmed",			// 34 - AV_MELEEDAMAGE
		"av_skill_unarmed",			// 35 - AV_UNARMEDDAMAGE
		null, 						// 36 - AV_MASS
		null,						// 37 - AV_VOICEPOINTS
		null,						// 38 - AV_VOICERATE
		null,						// 39 - AV_DAMAGERESIST			x
		"av_resist_poison",			// 40 - AV_POISONRESIST
		"av_resist_fire",			// 41 - AV_FIRERESIST
		"av_resist_shock",			// 42 - AV_ELECTRICRESIST
		"av_resist_frost",			// 43 - AV_FROSTRESIST
		"av_resist_magic",			// 44 - AV_MAGICRESIST
		"av_resist_disease",		// 45 - AV_DISEASERESIST
		null,						// 46 - AV_PERCEPTIONCONDITION
		null,						// 47 - AV_ENDURANCECONDITION
		null,						// 48 - AV_LEFTATTACKCONDITION
		null,						// 49 - AV_RIGHTATTACKCONDITION
		null,						// 50 - AV_LEFTMOBILITYCONDITION
		null,						// 51 - AV_RIGHTMOBILITYCONDITION
		null,						// 52 - AV_BRAINCONDITION
		null,						// 53 - AV_PARALYSIS
		"invisibility",				// 54 - AV_INVISIBILITY
		"nighteye",					// 55 - AV_NIGHTEYE
		null,						// 56 - AV_DETECTLIFERANGE
		"av_waterbreathing",		// 57 - AV_WATERBREATHING
		null,						// 58 - AV_WATERWALKING
		null,						// 59 - AV_IGNORECRIPPLEDLIMBS
		null,						// 60 - AV_FAME
		null,						// 61 - AV_INFAMY
		null,						// 62 - AV_JUMPINGBONUS
		"av_ward",					// 63 - AV_WARDPOWER
		null,						// 64 - AV_RIGHTITEMCHARGE
		null,						// 65 - AV_ARMORPERKS
		null,						// 66 - AV_SHIELDPERKS
		null,						// 67 - AV_WARDDEFLECTION
		null,						// 68 - AV_VARIABLE01
		null,						// 69 - AV_VARIABLE02
		null,						// 70 - AV_VARIABLE03
		null,						// 71 - AV_VARIABLE04
		null,						// 72 - AV_VARIABLE05
		null,						// 73 - AV_VARIABLE06
		null,						// 74 - AV_VARIABLE07
		null,						// 75 - AV_VARIABLE08
		null,						// 76 - AV_VARIABLE09
		null,						// 77 - AV_VARIABLE10
		null,						// 78 - AV_BOWSPEEDBONUS
		null,						// 79 - AV_FAVORACTIVE
		null,						// 80 - AV_FAVORSPERDAY
		null,						// 81 - AV_FAVORSPERDAYTIMER
		null,						// 82 - AV_LEFTITEMCHARGE
		null,						// 83 - AV_ABSORBCHANCE
		null,						// 84 - AV_BLINDNESS
		null,						// 85 - AV_WEAPONSPEEDMULT
		"av_skill_shout",			// 86 - AV_SHOUTRECOVERYMULT
		null,						// 87 - AV_BOWSTAGGERBONUS
		"telekinesis",				// 88 - AV_TELEKINESIS
		null,						// 89 - AV_FAVORPOINTSBONUS
		null,						// 90 - AV_LASTBRIBEDINTIMIDATED
		null,						// 91 - AV_LASTFLATTERED
		"muffle",					// 92 - AV_MOVEMENTNOISEMULT
		null,						// 93 - AV_BYPASSVENDORSTOLENCHECK
		null,						// 94 - AV_BYPASSVENDORKEYWORDCHECK
		null,						// 95 - AV_WAITINGFORPLAYER
		"av_skill_weapon_1h",		// 96 - AV_ONEHANDEDMOD
		"av_skill_weapon_2h",		// 97 - AV_TWOHANDEDMOD
		"av_skill_archery",			// 98 - AV_MARKSMANMOD
		"av_skill_block",			// 99 - AV_BLOCKMOD
		"av_skill_smithing",		// 100 - AV_SMITHINGMOD
		"av_skill_armor_heavy",		// 101 - AV_HEAVYARMORMOD
		"av_skill_armor_light",		// 102 - AV_LIGHTARMORMOD
		"av_skill_pickpocket",		// 103 - AV_PICKPOCKETMOD
		"av_skill_lockpicking",		// 104 - AV_LOCKPICKINGMOD
		"av_skill_sneak",			// 105 - AV_SNEAKMOD
		"av_skill_alchemy",			// 106 - AV_ALCHEMYMOD
		"av_skill_persuasion",		// 107 - AV_SPEECHCRAFTMOD
		"av_skill_alteration",		// 108 - AV_ALTERATIONMOD
		"av_skill_conjuration",		// 109 - AV_CONJURATIONMOD
		"av_skill_destruction",		// 110 - AV_DESTRUCTIONMOD
		"av_skill_illusion",		// 111 - AV_ILLUSIONMOD
		"av_skill_restoration",		// 112 - AV_RESTORATIONMOD
		"av_skill_enchanting",		// 113 - AV_ENCHANTINGMOD
		null,						// 114 - AV_ONEHANDEDSKILLADVANCE
		null,						// 115 - AV_TWOHANDEDSKILLADVANCE
		null,						// 116 - AV_MARKSMANSKILLADVANCE
		null,						// 117 - AV_BLOCKSKILLADVANCE
		null,						// 118 - AV_SMITHINGSKILLADVANCE
		null,						// 119 - AV_HEAVYARMORSKILLADVANCE
		null,						// 120 - AV_LIGHTARMORSKILLADVANCE
		null,						// 121 - AV_PICKPOCKETSKILLADVANCE
		null,						// 122 - AV_LOCKPICKINGSKILLADVANCE
		null,						// 123 - AV_SNEAKSKILLADVANCE
		null,						// 124 - AV_ALCHEMYSKILLADVANCE
		null,						// 125 - AV_SPEECHCRAFTSKILLADVANCE
		null,						// 126 - AV_ALTERATIONSKILLADVANCE
		null,						// 127 - AV_CONJURATIONSKILLADVANCE
		null,						// 128 - AV_DESTRUCTIONSKILLADVANCE
		null,						// 129 - AV_ILLUSIONSKILLADVANCE
		null,						// 130 - AV_RESTORATIONSKILLADVANCE
		null,						// 131 - AV_ENCHANTINGSKILLADVANCE
		null,						// 132 - AV_LEFTWEAPONSPEEDMULT
		null,						// 133 - AV_DRAGONSOULS
		null,						// 134 - AV_COMBATHEALTHREGENMULT
		"av_skill_weapon_1h",		// 135 - AV_ONEHANDEDPOWERMOD
		"av_skill_weapon_2h",		// 136 - AV_TWOHANDEDPOWERMOD
		"av_skill_archery",			// 137 - AV_MARKSMANPOWERMOD
		"av_skill_block",			// 138 - AV_BLOCKPOWERMOD
		"av_skill_smithing",		// 139 - AV_SMITHINGPOWERMOD
		"av_skill_armor_heavy",		// 140 - AV_HEAVYARMORPOWERMOD
		"av_skill_armor_light",		// 141 - AV_LIGHTARMORPOWERMOD
		"av_skill_pickpocket",		// 142 - AV_PICKPOCKETPOWERMOD
		"av_skill_lockpicking",		// 143 - AV_LOCKPICKINGPOWERMOD
		"av_skill_sneak",			// 144 - AV_SNEAKPOWERMOD
		"av_skill_alchemy",			// 145 - AV_ALCHEMYPOWERMOD
		"av_skill_barter",			// 146 - AV_SPEECHCRAFTPOWERMOD
		"av_skill_alteration",		// 147 - AV_ALTERATIONPOWERMOD
		"av_skill_conjuration",		// 148 - AV_CONJURATIONPOWERMOD
		"av_skill_destruction",		// 149 - AV_DESTRUCTIONPOWERMOD
		"av_skill_illusion",		// 150 - AV_ILLUSIONPOWERMOD
		"av_skill_restoration",		// 151 - AV_RESTORATIONPOWERMOD
		"av_skill_enchanting",		// 152 - AV_ENCHANTINGPOWERMOD
		null,						// 153 - AV_DRAGONREND
		null,						// 154 - AV_ATTACKDAMAGEMULT
		"av_health_regen",			// 155 - AV_HEALRATEMULT
		"av_magicka_regen",			// 156 - AV_MAGICKARATEMULT
		"av_stamina_regen",			// 157 - AV_STAMINARATEMULT
		null,						// 158 - AV_WEREWOLFPERKS
		null,						// 159 - AV_VAMPIREPERKS
		null,						// 160 - AV_GRABACTOROFFSET
		null,						// 161 - AV_GRABBED
		null,						// 162 - AV_DEPRECATED05
		null						// 163 - AV_REFLECTDAMAGE
	];
	
	public static function lookupIconLabel(a_effectData: Object): Object
	{
		var archetype = a_effectData.archetype;
		var actorValue = a_effectData.actorValue;
			
		var emblemLabel = "none";
		
		// Attempt to look up for simple archetypes
		var baseLabel = _archetypeMap[archetype];
		
		// Found one, done
		if (baseLabel)
			return {baseLabel: baseLabel, emblemLabel: emblemLabel};
		
		// Archetype + ActorValue combinations
		
		switch (archetype) {
			case Magic.ARCHETYPE_VALUEMOD:
			case Magic.ARCHETYPE_DUALVALUEMOD:
			case Magic.ARCHETYPE_PEAKVALUEMOD:
				var isDetrimental = a_effectData.effectFlags & Magic.MGEFFLAG_DETRIMENTAL;
				var isRecovering = a_effectData.effectFlags & Magic.MGEFFLAG_RECOVER;
				
				if (isDetrimental) {
					emblemLabel = isRecovering ? "drain" : "damage";
				} else {
					emblemLabel = isRecovering ? "fortify" : "restore";
				}
		}
		
		baseLabel = _avMap[actorValue];
		if (baseLabel)
			return {baseLabel: baseLabel, emblemLabel: emblemLabel};
			
		// Replace health icon with resistType icon
		if (actorValue == Actor.AV_HEALTH) {
			var resistType = a_effectData.resistType;
			
			switch (a_effectData.resistType) {
				case Actor.AV_FIRERESIST:
					baseLabel = "magic_fire";
					break;
				case Actor.AV_FROSTRESIST:
					baseLabel = "magic_fire";
					break;
				case Actor.AV_ELECTRICRESIST:
					baseLabel = "magic_shock";
					break;
			}
		}
		
		if (baseLabel)
			baseLabel = "default_effect";
		
		return {baseLabel: baseLabel, emblemLabel: emblemLabel};
	}
}