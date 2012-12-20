import skyui.defines.Magic;
import skyui.defines.Actor;


class skyui.util.EffectIconMap
{
	private static var _archetypeTable: Array = [
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_illusion_calm",	//6
		null,
		"effect_illusion_frenzy",	//8
		null,
		"effect_conjuration_conjure",	//10
		"effect_illusion_invisibility",	//11
		"effect_alteration_light",	//12
		null,
		null,
		null,
		null,
		"effect_conjuration_bound",	//17
		"effect_conjuration_conjure",	//18
		"effect_alteration_detectlife",	//19
		"effect_alteration_telekinesis",	//20
		"effect_alteration_paralyze",	//21
		"effect_conjuration_reanimate",	//22
		"effect_conjuration_soultrap",	//23
		"effect_restoration_turnundead",	//24
		"effect_illusion_clairvoyance",	//25
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_illusion_invisibility",	//35
		"effect_skills_misc_werewolf",	//36
		null,
		"effect_illusion_rally",	//38
		null,
		null,
		null,
		"effect_conjuration_banish",	//42
		null,
		null,
		null,
		"effect_skills_misc_vampire"	//46
	];
	
	private static var _posValueModTable: Array = [
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_skills_fortify_weapon_1h",	//6
		"effect_skills_fortify_weapon_2h",	//7
		"effect_skills_fortify_archery",	//8
		"effect_skills_fortify_block",	//9
		"effect_skills_fortify_smithing",	//10
		"effect_skills_fortify_armor_heavy",	//11
		"effect_skills_fortify_armor_light",	//12
		"effect_skills_fortify_pickpocket",	//13
		"effect_skills_fortify_lockpicking",	//14
		"effect_skills_fortify_sneak",	//15
		"effect_skills_fortify_alchemy",	//16
		"effect_skills_fortify_persuasion",	//17
		"effect_skills_fortify_alteration",	//18
		"effect_skills_fortify_conjuration",	//19
		"effect_skills_fortify_destruction",	//20
		"effect_skills_fortify_illusion",	//21
		"effect_skills_fortify_restoration",	//22
		"effect_skills_fortify_enchanting",	//23
		null,
		null,
		null,
		"effect_restoration_fortify_health_regen",	//27
		"effect_restoration_fortify_magicka_regen",	//28
		"effect_restoration_fortify_stamina_regen",	//29
		null,
		null,
		"effect_restoration_fortify_carry",	//32
		null,
		"effect_restoration_fortify_unarmed",	//34
		"effect_restoration_fortify_unarmed",	//35
		null,
		null,
		null,
		null,
		"effect_restoration_resist_poison",	//40
		"effect_restoration_resist_fire",	//41
		"effect_restoration_resist_shock",	//42
		"effect_restoration_resist_frost",	//43
		"effect_restoration_resist_magic",	//44
		"effect_restoration_resist_disease",	//45
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_illusion_invisibility",	//54
		"effect_illusion_nighteye",	//55
		null,
		"effect_alteration_waterbreathing",	//57
		null,
		null,
		null,
		null,
		null,
		"effect_restoration_ward",	//63
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_restoration_fortify_shout",	//86
		null,
		"effect_alteration_telekinesis",	//88
		null,
		null,
		null,
		"effect_illusion_muffle",	//92
		null,
		null,
		null,
		"effect_skills_fortify_weapon_1h",	//96
		"effect_skills_fortify_weapon_2h",	//97
		"effect_skills_fortify_archery",	//98
		"effect_skills_fortify_block",	//99
		"effect_skills_fortify_smithing",	//100
		"effect_skills_fortify_armor_heavy",	//101
		"effect_skills_fortify_armor_light",	//102
		"effect_skills_fortify_pickpocket",	//103
		"effect_skills_fortify_lockpicking",	//104
		"effect_skills_fortify_sneak",	//105
		"effect_skills_fortify_alchemy",	//106
		"effect_skills_fortify_persuasion",	//107
		"effect_skills_fortify_alteration",	//108
		"effect_skills_fortify_conjuration",	//109
		"effect_skills_fortify_destruction",	//110
		"effect_skills_fortify_illusion",	//111
		"effect_skills_fortify_restoration",	//112
		"effect_skills_fortify_enchanting",	//113
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_skills_fortify_weapon_1h",	//135
		"effect_skills_fortify_weapon_2h",	//136
		"effect_skills_fortify_archery",	//137
		"effect_skills_fortify_block",	//138
		"effect_skills_fortify_smithing",	//139
		"effect_skills_fortify_armor_heavy",	//140
		"effect_skills_fortify_armor_light",	//141
		"effect_skills_fortify_pickpocket",	//142
		"effect_skills_fortify_lockpicking",	//143
		"effect_skills_fortify_sneak",	//144
		"effect_skills_fortify_alchemy",	//145
		"effect_skills_fortify_barter",	//146
		"effect_skills_fortify_alteration",	//147
		"effect_skills_fortify_conjuration",	//148
		"effect_skills_fortify_destruction",	//149
		"effect_skills_fortify_illusion",	//150
		"effect_skills_fortify_restoration",	//151
		"effect_skills_fortify_enchanting",	//152
		null,
		null,
		"effect_restoration_fortify_health_regen",	//155
		"effect_restoration_fortify_magicka_regen",	//156
		"effect_restoration_fortify_stamina_regen"	//157
	];
	
	private static var _negValueModTable: Array = [
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_destruction_damage_health",	//24
		"effect_destruction_damage_magica",	//25
		"effect_destruction_damage_stamina",	//26
		"effect_destruction_damage_health_regen",	//27
		"effect_destruction_damage_magicka_regen",	//28
		"effect_destruction_damage_stamina_regen",	//29
		"effect_destruction_special_slow",	//30
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_destruction_weakness_poison",	//40
		"effect_destruction_weakness_fire",	//41
		"effect_destruction_weakness_shock",	//42
		"effect_destruction_weakness_frost",	//43
		"effect_destruction_weakness_magic",	//44
		"effect_destruction_weakness_disease",	//45
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"effect_destruction_damage_health_regen",	//155
		"effect_destruction_damage_magicka_regen",	//156
		"effect_destruction_damage_stamina_regen"	//157
	];
	
	public static function lookupIconLabel(a_effectData: Object): String
	{
		var archetype = a_effectData.archetype;
		var actorValue = a_effectData.actorValue;
			
		// Attempt to lookup for simple archetypes
		var iconLabel = _archetypeTable[archetype];
		if (iconLabel)
			return iconLabel;
			
		if (!actorValue)
			return "default_effect";
		
		// Archetype + ActorValue combinations
		if (a_effectData.effectFlags & Magic.MGEFFLAG_DETRIMENTAL) {
			// Negative value modifiers
			iconLabel = _negValueModTable[actorValue];
			if (iconLabel)
				return iconLabel;
				
			switch (actorValue) {
				case Actor.AV_HEALTH:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_health" : "effect_restoration_fortify_health";
				case Actor.AV_MAGICKA:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_magicka" : "effect_restoration_fortify_magicka";
				case Actor.AV_STAMINA:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_stamina" : "effect_restoration_fortify_stamina";
			}
				
		} else {
			// Positive value modifiers
			iconLabel = _posValueModTable[actorValue];
			if (iconLabel)
				return iconLabel;
			
			switch (actorValue) {
				case Actor.AV_HEALTH:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_health" : "effect_restoration_fortify_health";
				case Actor.AV_MAGICKA:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_magicka" : "effect_restoration_fortify_magicka";
				case Actor.AV_STAMINA:
					return archetype == Magic.ARCHETYPE_VALUEMOD ? "effect_restoration_stamina" : "effect_restoration_fortify_stamina";
			}
		}
		
		return "default_effect";
	}
}