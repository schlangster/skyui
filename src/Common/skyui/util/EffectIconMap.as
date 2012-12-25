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
		"calm",	//6
		null,
		"frenzy",	//8
		null,
		"conjure",	//10
		"invisibility",	//11
		"light",	//12
		null,
		null,
		null,
		null,
		"bound_item",	//17
		"conjure",	//18
		"detectlife",	//19
		"telekinesis",	//20
		"paralyze",	//21
		"reanimate",	//22
		"soultrap",	//23
		"turnundead",	//24
		"clairvoyance",	//25
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"invisibility",	//35
		"werewolf",	//36
		null,
		"rally",	//38
		null,
		null,
		null,
		"banish",	//42
		null,
		null,
		null,
		"vampire"	//46
	];
	
	private static var _posValueModTable: Array = [
		null,
		null,
		null,
		null,
		null,
		null,
		"av_skill_weapon_1h",	//6
		"av_skill_weapon_2h",	//7
		"av_skill_archery",	//8
		"av_skill_block",	//9
		"av_skill_smithing",	//10
		"av_skill_armor_heavy",	//11
		"av_skill_armor_light",	//12
		"av_skill_pickpocket",	//13
		"av_skill_lockpicking",	//14
		"av_skill_sneak",	//15
		"av_skill_alchemy",	//16
		"av_skill_persuasion",	//17
		"av_skill_alteration",	//18
		"av_skill_conjuration",	//19
		"av_skill_destruction",	//20
		"av_skill_illusion",	//21
		"av_skill_restoration",	//22
		"av_skill_enchanting",	//23
		null,
		null,
		null,
		"av_health_regen",	//27
		"av_magicka_regen",	//28
		"av_stamina_regen",	//29
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
		"av_resist_poison",	//40
		"av_resist_fire",	//41
		"av_resist_shock",	//42
		"av_resist_frost",	//43
		"av_resist_magic",	//44
		"av_resist_disease",	//45
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		"invisibility",	//54
		"nighteye",	//55
		null,
		"waterbreathing",	//57
		null,
		null,
		null,
		null,
		null,
		"ward",	//63
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
		"av_skill_shout",	//86
		null,
		"telekinesis",	//88
		null,
		null,
		null,
		"muffle",	//92
		null,
		null,
		null,
		"av_skill_weapon_1h",	//96
		"av_skill_weapon_2h",	//97
		"av_skill_archery",	//98
		"av_skill_block",	//99
		"av_skill_smithing",	//100
		"av_skill_armor_heavy",	//101
		"av_skill_armor_light",	//102
		"av_skill_pickpocket",	//103
		"av_skill_lockpicking",	//104
		"av_skill_sneak",	//105
		"av_skill_alchemy",	//106
		"av_skill_persuasion",	//107
		"av_skill_alteration",	//108
		"av_skill_conjuration",	//109
		"av_skill_destruction",	//110
		"av_skill_illusion",	//111
		"av_skill_restoration",	//112
		"av_skill_enchanting",	//113
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
		"av_skill_weapon_1h",	//135
		"av_skill_weapon_2h",	//136
		"av_skill_archery",	//137
		"av_skill_block",	//138
		"av_skill_smithing",	//139
		"av_skill_armor_heavy",	//140
		"av_skill_armor_light",	//141
		"av_skill_pickpocket",	//142
		"av_skill_lockpicking",	//143
		"av_skill_sneak",	//144
		"av_skill_alchemy",	//145
		"av_skill_barter",	//146
		"av_skill_alteration",	//147
		"av_skill_conjuration",	//148
		"av_skill_destruction",	//149
		"av_skill_illusion",	//150
		"av_skill_restoration",	//151
		"av_skill_enchanting",	//152
		null,
		null,
		"av_health_regen",	//155
		"av_magicka_regen",	//156
		"av_stamina_regen"	//157
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