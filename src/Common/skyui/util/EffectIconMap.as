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
		"paralysis",	// 21 - ARCHETYPE_PARALYSIS					OK
		null,			// 22 - ARCHETYPE_REANIMATE					nn
		null,			// 23 - ARCHETYPE_SOULTRAP					nn
		null,			// 24 - ARCHETYPE_TURNUNDEAD				nn
		"clairvoyance",	// 25 - ARCHETYPE_GUIDE						OK
		null,			// 26 - ARCHETYPE_WEREWOLFFEED				nn
		null,			// 27 - ARCHETYPE_CUREPARALYSIS				nn
		null,			// 28 - ARCHETYPE_CUREADDICTION				nn
		null,			// 29 - ARCHETYPE_CUREPOISON				nn
		null,			// 30 - ARCHETYPE_CONCUSSION				nn
		null,			// 31 - ARCHETYPE_VALUEANDPARTS				nn
		null,			// 32 - ARCHETYPE_ACCUMULATEMAGNITUDE		nn
		null,			// 33 - ARCHETYPE_STAGGER					nn
		null,			// 34 - ARCHETYPE_PEAKVALUEMOD				EMBLEM
		"cloak",		// 35 - ARCHETYPE_CLOAK						OK
		"werewolf",		// 36 - ARCHETYPE_WEREWOLF					OK
		"slow_time",	// 37 - ARCHETYPE_SLOWTIME					OK
		null,			// 38 - ARCHETYPE_RALLY						nn
		"ench_weapon",	// 39 - ARCHETYPE_ENHANCEWEAPON				OK
		null,			// 40 - ARCHETYPE_SPAWNHAZARD				nn
		"ethereal",		// 41 - ARCHETYPE_ETHEREALIZE				OK
		null,			// 42 - ARCHETYPE_BANISH					nn
		null,
		null,			// 44 - ARCHETYPE_DISGUISE					nn
		null,			// 45 - ARCHETYPE_GRABACTOR					nn
		"vampire"		// 46 - ARCHETYPE_VAMPIRELORD				OK
	];
	
	private static var _avMap: Array = [
		null,						// 0 - AV_AGGRESSION					nn
		null,						// 1 - AV_CONFIDENCE					nn
		null,						// 2 - AV_ENERGY						nn
		null,						// 3 - AV_MORALITY						nn
		null,						// 4 - AV_MOOD							nn
		null,						// 5 - AV_ASSISTANCE					nn
		"av_skill_weapon_1h",		// 6 - AV_ONEHANDED						OK
		"av_skill_weapon_2h",		// 7 - AV_TWOHANDED						OK
		"av_skill_archery",			// 8 - AV_MARKSMAN						OK
		"av_skill_block",			// 9 - AV_BLOCK							OK
		"av_skill_smithing",		// 10 - AV_SMITHING						OK
		"av_skill_armor_heavy",		// 11 - AV_HEAVYARMOR					OK
		"av_skill_armor_light",		// 12 - AV_LIGHTARMOR					OK
		"av_skill_pickpocket",		// 13 - AV_PICKPOCKET					OK
		"av_skill_lockpicking",		// 14 - AV_LOCKPICKING					OK
		"av_skill_sneak",			// 15 - AV_SNEAK						OK
		"av_skill_alchemy",			// 16 - AV_ALCHEMY						OK
		"av_skill_persuasion",		// 17 - AV_SPEECHCRAFT					OK
		"av_skill_alteration",		// 18 - AV_ALTERATION					OK
		"av_skill_conjuration",		// 19 - AV_CONJURATION					OK
		"av_skill_destruction",		// 20 - AV_DESTRUCTION					OK
		"av_skill_illusion",		// 21 - AV_ILLUSION						OK
		"av_skill_restoration",		// 22 - AV_RESTORATION					OK
		"av_skill_enchanting",		// 23 - AV_ENCHANTING					OK
		"av_health",				// 24 - AV_HEALTH						OK
		"av_magicka",				// 25 - AV_MAGICKA						OK
		"av_stamina",				// 26 - AV_STAMINA						OK
		"av_health_regen",			// 27 - AV_HEALRATE						OK
		"av_magicka_regen",			// 28 - AV_MAGICKARATE					OK
		"av_stamina_regen",			// 29 - AV_STAMINARATE					OK
		"av_speedmult",				// 30 - AV_SPEEDMULT					OK
		null, 						// 31 - AV_INVENTORYWEIGHT				nn
		"av_carryweight",			// 32 - AV_CARRYWEIGHT					OK
		null,						// 33 - AV_CRITCHANCE					nn
		"av_skill_unarmed",			// 34 - AV_MELEEDAMAGE					OK
		"av_skill_unarmed",			// 35 - AV_UNARMEDDAMAGE				OK
		null, 						// 36 - AV_MASS							nn
		null,						// 37 - AV_VOICEPOINTS					nn
		null,						// 38 - AV_VOICERATE					nn
		"av_resist_damage",			// 39 - AV_DAMAGERESIST					OK
		"av_resist_poison",			// 40 - AV_POISONRESIST					OK
		"av_resist_fire",			// 41 - AV_FIRERESIST					OK
		"av_resist_shock",			// 42 - AV_ELECTRICRESIST				OK
		"av_resist_frost",			// 43 - AV_FROSTRESIST					OK
		"av_resist_magic",			// 44 - AV_MAGICRESIST					OK
		"av_resist_disease",		// 45 - AV_DISEASERESIST				OK
		null,						// 46 - AV_PERCEPTIONCONDITION			nn
		null,						// 47 - AV_ENDURANCECONDITION			nn
		null,						// 48 - AV_LEFTATTACKCONDITION			nn
		null,						// 49 - AV_RIGHTATTACKCONDITION			nn
		null,						// 50 - AV_LEFTMOBILITYCONDITION		nn
		null,						// 51 - AV_RIGHTMOBILITYCONDITION		nn
		null,						// 52 - AV_BRAINCONDITION				nn
		"paralysis",				// 53 - AV_PARALYSIS					OK
		"invisibility",				// 54 - AV_INVISIBILITY					OK
		"av_nighteye",				// 55 - AV_NIGHTEYE						OK
		null,						// 56 - AV_DETECTLIFERANGE				nn
		"av_waterbreathing",		// 57 - AV_WATERBREATHING				OK
		"av_waterwalking",			// 58 - AV_WATERWALKING					OK
		null,						// 59 - AV_IGNORECRIPPLEDLIMBS			nn
		null,						// 60 - AV_FAME							nn
		null,						// 61 - AV_INFAMY						nn
		null,						// 62 - AV_JUMPINGBONUS					nn
		"av_ward",					// 63 - AV_WARDPOWER					OK
		null,						// 64 - AV_RIGHTITEMCHARGE				nn
		"av_armorperks",			// 65 - AV_ARMORPERKS					OK
		null,						// 66 - AV_SHIELDPERKS					nn
		null,						// 67 - AV_WARDDEFLECTION				nn
		null,						// 68 - AV_VARIABLE01					nn
		null,						// 69 - AV_VARIABLE02					nn
		null,						// 70 - AV_VARIABLE03					nn
		null,						// 71 - AV_VARIABLE04					nn
		null,						// 72 - AV_VARIABLE05					nn
		null,						// 73 - AV_VARIABLE06					nn
		null,						// 74 - AV_VARIABLE07					nn
		null,						// 75 - AV_VARIABLE08					nn
		null,						// 76 - AV_VARIABLE09					nn
		null,						// 77 - AV_VARIABLE10					nn
		"av_bow_speed",				// 78 - AV_BOWSPEEDBONUS				OK
		null,						// 79 - AV_FAVORACTIVE					nn
		null,						// 80 - AV_FAVORSPERDAY					nn
		null,						// 81 - AV_FAVORSPERDAYTIMER			nn
		null,						// 82 - AV_LEFTITEMCHARGE				nn
		"av_absorb",				// 83 - AV_ABSORBCHANCE					OK
		null,						// 84 - AV_BLINDNESS					nn
		"av_weapon_speed",			// 85 - AV_WEAPONSPEEDMULT				OK
		"av_skill_shout",			// 86 - AV_SHOUTRECOVERYMULT			OK
		"av_bow_stagger",			// 87 - AV_BOWSTAGGERBONUS				OK
		null,						// 88 - AV_TELEKINESIS					nn
		null,						// 89 - AV_FAVORPOINTSBONUS				nn
		null,						// 90 - AV_LASTBRIBEDINTIMIDATED		nn
		null,						// 91 - AV_LASTFLATTERED				nn
		"av_noise",					// 92 - AV_MOVEMENTNOISEMULT			OK
		null,						// 93 - AV_BYPASSVENDORSTOLENCHECK		nn
		null,						// 94 - AV_BYPASSVENDORKEYWORDCHECK		nn
		null,						// 95 - AV_WAITINGFORPLAYER				nn
		"av_skill_weapon_1h",		// 96 - AV_ONEHANDEDMOD					OK
		"av_skill_weapon_2h",		// 97 - AV_TWOHANDEDMOD					OK
		"av_skill_archery",			// 98 - AV_MARKSMANMOD					OK
		"av_skill_block",			// 99 - AV_BLOCKMOD						OK
		"av_skill_smithing",		// 100 - AV_SMITHINGMOD					OK
		"av_skill_armor_heavy",		// 101 - AV_HEAVYARMORMOD				OK
		"av_skill_armor_light",		// 102 - AV_LIGHTARMORMOD				OK
		"av_skill_pickpocket",		// 103 - AV_PICKPOCKETMOD				OK
		"av_skill_lockpicking",		// 104 - AV_LOCKPICKINGMOD				OK
		"av_skill_sneak",			// 105 - AV_SNEAKMOD					OK
		"av_skill_alchemy",			// 106 - AV_ALCHEMYMOD					OK
		"av_skill_persuasion",		// 107 - AV_SPEECHCRAFTMOD				OK
		"av_skill_alteration",		// 108 - AV_ALTERATIONMOD				OK
		"av_skill_conjuration",		// 109 - AV_CONJURATIONMOD				OK
		"av_skill_destruction",		// 110 - AV_DESTRUCTIONMOD				OK
		"av_skill_illusion",		// 111 - AV_ILLUSIONMOD					OK
		"av_skill_restoration",		// 112 - AV_RESTORATIONMOD				OK
		"av_skill_enchanting",		// 113 - AV_ENCHANTINGMOD				OK
		"av_skill_weapon_1h",		// 114 - AV_ONEHANDEDSKILLADVANCE		OK
		"av_skill_weapon_2h",		// 115 - AV_TWOHANDEDSKILLADVANCE		OK
		"av_skill_archery",			// 116 - AV_MARKSMANSKILLADVANCE		OK
		"av_skill_block",			// 117 - AV_BLOCKSKILLADVANCE			OK
		"av_skill_smithing",		// 118 - AV_SMITHINGSKILLADVANCE		OK
		"av_skill_armor_heavy",		// 119 - AV_HEAVYARMORSKILLADVANCE		OK
		"av_skill_armor_light",		// 120 - AV_LIGHTARMORSKILLADVANCE		OK
		"av_skill_pickpocket",		// 121 - AV_PICKPOCKETSKILLADVANCE		OK
		"av_skill_lockpicking",		// 122 - AV_LOCKPICKINGSKILLADVANCE		OK
		"av_skill_sneak",			// 123 - AV_SNEAKSKILLADVANCE			OK
		"av_skill_alchemy",			// 124 - AV_ALCHEMYSKILLADVANCE			OK
		"av_skill_persuasion",		// 125 - AV_SPEECHCRAFTSKILLADVANCE		OK
		"av_skill_alteration",		// 126 - AV_ALTERATIONSKILLADVANCE		OK
		"av_skill_conjuration",		// 127 - AV_CONJURATIONSKILLADVANCE		OK
		"av_skill_destruction",		// 128 - AV_DESTRUCTIONSKILLADVANCE		OK
		"av_skill_illusion",		// 129 - AV_ILLUSIONSKILLADVANCE		OK
		"av_skill_restoration",		// 130 - AV_RESTORATIONSKILLADVANCE		OK
		"av_skill_enchanting",		// 131 - AV_ENCHANTINGSKILLADVANCE		OK
		null,						// 132 - AV_LEFTWEAPONSPEEDMULT			OK
		null,						// 133 - AV_DRAGONSOULS					nn
		null,						// 134 - AV_COMBATHEALTHREGENMULT		nn
		"av_skill_weapon_1h",		// 135 - AV_ONEHANDEDPOWERMOD			OK
		"av_skill_weapon_2h",		// 136 - AV_TWOHANDEDPOWERMOD			OK
		"av_skill_archery",			// 137 - AV_MARKSMANPOWERMOD			OK
		"av_skill_block",			// 138 - AV_BLOCKPOWERMOD				OK
		"av_skill_smithing",		// 139 - AV_SMITHINGPOWERMOD			OK
		"av_skill_armor_heavy",		// 140 - AV_HEAVYARMORPOWERMOD			OK
		"av_skill_armor_light",		// 141 - AV_LIGHTARMORPOWERMOD			OK
		"av_skill_pickpocket",		// 142 - AV_PICKPOCKETPOWERMOD			OK
		"av_skill_lockpicking",		// 143 - AV_LOCKPICKINGPOWERMOD			OK
		"av_skill_sneak",			// 144 - AV_SNEAKPOWERMOD				OK
		"av_skill_alchemy",			// 145 - AV_ALCHEMYPOWERMOD				OK
		"av_skill_persuasion",		// 146 - AV_SPEECHCRAFTPOWERMOD			OK
		"av_skill_alteration",		// 147 - AV_ALTERATIONPOWERMOD			OK
		"av_skill_conjuration",		// 148 - AV_CONJURATIONPOWERMOD			OK
		"av_skill_destruction",		// 149 - AV_DESTRUCTIONPOWERMOD			OK
		"av_skill_illusion",		// 150 - AV_ILLUSIONPOWERMOD			OK
		"av_skill_restoration",		// 151 - AV_RESTORATIONPOWERMOD			OK
		"av_skill_enchanting",		// 152 - AV_ENCHANTINGPOWERMOD			OK
		null,						// 153 - AV_DRAGONREND					nn
		null,						// 154 - AV_ATTACKDAMAGEMULT			nn
		"av_health_regen",			// 155 - AV_HEALRATEMULT				OK
		"av_magicka_regen",			// 156 - AV_MAGICKARATEMULT				OK
		"av_stamina_regen",			// 157 - AV_STAMINARATEMULT				OK
		null,						// 158 - AV_WEREWOLFPERKS				nn
		null,						// 159 - AV_VAMPIREPERKS				nn
		null,						// 160 - AV_GRABACTOROFFSET				nn
		null,						// 161 - AV_GRABBED						nn
		null,						// 162 - AV_DEPRECATED05				nn
		null						// 163 - AV_REFLECTDAMAGE				
	];
	
	public static function lookupIconLabel(a_effectData: Object): Object
	{
		var archetype = a_effectData.archetype;
		var actorValue = a_effectData.actorValue;
			
		var emblemLabel = "none";
		
		// 1. Attempt to look up for simple archetypes
		var baseLabel = _archetypeMap[archetype];
		
		// Found one, done
		if (baseLabel)
			return {baseLabel: baseLabel, emblemLabel: emblemLabel};
		
		// 2. Archetype + ActorValue combinations
		
		// Set emblem
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
		
		// Lookup base icon
		baseLabel = _avMap[actorValue];
			
		// Replace base icon for damage health with resistType icon
		if (actorValue == Actor.AV_HEALTH) {
			var resistType = a_effectData.resistType;
			
			switch (a_effectData.resistType) {
				case Actor.AV_FIRERESIST:
					baseLabel = "magic_fire";
					break;
				case Actor.AV_FROSTRESIST:
					baseLabel = "magic_frost";
					break;
				case Actor.AV_ELECTRICRESIST:
					baseLabel = "magic_shock";
					break;
			}
		}
		
		// 3. No match? Default
		if (!baseLabel)
			baseLabel = "default_effect";
		
		return {baseLabel: baseLabel, emblemLabel: emblemLabel};
	}
}