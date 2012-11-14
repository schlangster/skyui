import skyui.util.Defines;
import Shared.GlobalFunc;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;


class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
  /* CONSTANTS */
	private static var METER_WIDTH: Number = 15;
	private static var METER_PADDING: Number = 5;

  /* STAGE ELEMENTS */
	private var content: MovieClip;
	private var background: MovieClip;
	
  /* PUBLIC VARIABLES */
	public var marker: Number;

	// initObject
	public var index: Number;
	public var effectData: Object;
	public var iconLocation: String;
	public var effectBaseSize: Number;
	public var effectSpacing: Number;
	public var effectFadeInDuration: Number;
	public var effectFadeOutDuration: Number;
	public var effectMoveDuration: Number;

	public var hGrowDirection: String;
	public var vGrowDirection: String;
	public var orientation: String;
	
	
	
  /* PRIVATE VARIABLES */
	// Meter
	private var _meter: MovieClip;
	
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	// Icon
	private var _iconLoader: MovieClipLoader;
	private var _icon: MovieClip;
	private var _iconHolder: MovieClip;
	
	private var _iconLabel: String;
	
	public function ActiveEffect()
	{
		super();
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		
		_iconHolder = content.iconContent;
		_icon = _iconHolder.createEmptyMovieClip("icon", getNextHighestDepth());

		_width = _height = effectBaseSize;

		// Force position
		_x = determinePosition(index)[0];
		_y = determinePosition(index)[1];
		
		initEffect();
		_iconLoader.loadClip(iconLocation, _icon);
		
		updateEffect(effectData);
		
		background._alpha = 0;
		_iconHolder.iconBackground._alpha = 0;

		TweenLite.from(this, effectFadeInDuration, {_alpha: 0, overwrite: 0, easing: Linear.easeNone});
	}

  /* PUBLIC FUNCTIONS */

	public function updateEffect(a_effectData: Object): Void
	{
		if (_meter == undefined) // Constant effects, no timer (e.g. Healing)
			return;
		
		effectData = a_effectData;
		var newPercent: Number = (100 * (effectData.duration - effectData.elapsed)) / effectData.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, newPercent));
		_meter.gotoAndStop(meterFrame);
	}

	public function updatePosition(a_newIndex): Void
	{
		index = a_newIndex;

		TweenLite.to(this, effectMoveDuration, {_x: determinePosition(index)[0], _y: determinePosition(index)[1], overwrite: 0, easing: Linear.easeNone});
	}

	public function remove(): Void
	{
		TweenLite.to(this, effectFadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onEffectRemoved, onCompleteParams: [this], overwrite: 0, easing: Linear.easeNone});
	}

  /* PRIVATE FUNCTIONS */
	
	private function initEffect(): Void
	{
		_iconLabel = determineIconLabel();
 
		if (_iconLabel == "default_effect" || _iconLabel == undefined || _iconLabel == "") {
			skyui.util.Debug.log("[SkyUI Active Effects]: Couldn't determine icon for")
			for (var s: String in effectData)
				skyui.util.Debug.log("                        " + s + ": " + effectData[s])
		}
		
		// TODO: make icons scale. All the icons we use are 128*128 so it doesn't matter
		_iconHolder._width = _iconHolder._height = (_iconHolder._width - METER_PADDING - METER_WIDTH);
		_iconHolder._y = (background._height - _iconHolder._height) / 2;

		if (effectData.duration - effectData.elapsed > 1) {
			// Effect with duration, e.g. Potion of Fortifty Health
			initMeter();
		} else {
			// Instantaneous effect, no timer (e.g. Healing)
			// Healing actually has a duration of 1, but it keeps reapplying itself after it's dispelled
			// No meter, just icon: center the icon
			_iconHolder._x = (background._width - _iconHolder._width) / 2;
		}
	}

	private function initMeter(): Void
	{
		_meter = content.attachMovie("SimpleMeter", "meter", content.getNextHighestDepth(), {_x: (background._width - METER_WIDTH), _y: _iconHolder._y, _width: METER_WIDTH, _height: _iconHolder._height});
		_meter.background._alpha = 50;
		_meter.gotoAndStop("Empty");
		_meterEmptyIdx = _meter._currentframe;
		_meter.gotoAndStop("Full");
		_meterFullIdx = _meter._currentframe;
	}
	
	private function onLoadInit(a_mc: MovieClip): Void
	{
		_icon._x = 0;
		_icon._y = 0;

		// TODO, make it scale w/ icon size. All the icons we use are 128*128 so it doesn't matter
		_icon._width = _icon._height = _iconHolder.iconBackground._width;
		_icon.gotoAndStop(_iconLabel);
	}

	private function onLoadError(a_mc: MovieClip, a_errorCode: String): Void
	{
		var errorTextField: TextField = _iconHolder.createTextField("ErrorTextField", _iconHolder.getNextHighestDepth(), 0, 0, _iconHolder.iconBackground._width, _iconHolder.iconBackground._height);
		errorTextField.verticalAlign = "center";
		errorTextField.textAutoSize = "fit";
		errorTextField.multiLine = true;

		var tf: TextFormat = new TextFormat();
		tf.align = "center";
		tf.color = 0xFFFFFF;
		tf.indent = 20;
		tf.font = "$EverywhereBoldFont";
		errorTextField.setNewTextFormat(tf);

		errorTextField.text = "No Icon\nSource";
	}

	private function determinePosition(a_index: Number): Array
	{
		var newX: Number = 0;
		var newY: Number = 0;

		// orientation the axis in which new effects will be added to after the total number of effects > GroupEffectCount
		if (orientation == "vertical") {
			// Orientation is vertical so...
			// This effect is in a column, next effect will be shifted vertically
			if (vGrowDirection == "up") {
				newY = -(index * (effectBaseSize + effectSpacing));
			} else {
				newY = +(index * (effectBaseSize + effectSpacing));
			}
		} else {
			// This effect is in a row, next effect will be shifted horizontally
			if (hGrowDirection == "left") {
				newX = -(index * (effectBaseSize + effectSpacing));
			} else {
				newX = +(index * (effectBaseSize + effectSpacing));
			}
		}

		return [newX, newY];
	}
	
	private function determineIconLabel(): String
	{
		// Fortify are hollow
		// Resist are solid

		// Weakness to are hollow
		// Damage from are solid

		if (!effectData.actorValue)
			return "default_effect";
		
		switch(effectData.archetype) {
			// Alteration
			case Defines.ARCHETYPE_DETECTLIFE:
				return "effect_alteration_detectlife"; //Check this (no duration?)
			case Defines.ARCHETYPE_PARALYSIS:
				return "effect_alteration_paralyze";
			case Defines.ARCHETYPE_LIGHT:
				return "effect_alteration_light";
			case Defines.ARCHETYPE_TELEKINESIS:
				return "effect_alteration_telekinesis";

			// Conjuration
			case Defines.ARCHETYPE_BOUNDWEAPON:
				return "effect_conjuration_bound";
			case Defines.ARCHETYPE_REANIMATE:
				return "effect_conjuration_reanimate";
			case Defines.ARCHETYPE_SOULTRAP:
				return "effect_conjuration_soultrap";
			case Defines.ARCHETYPE_BANISH:
				return "effect_conjuration_banish";
			case Defines.ARCHETYPE_COMMANDSUMMONED: //Check these
			case Defines.ARCHETYPE_SUMMONCREATURE:
				return "effect_conjuration_conjure";

			// Illusion
			case Defines.ARCHETYPE_CALM:
				return "effect_illusion_calm";
			case Defines.ARCHETYPE_FRENZY:
				return "effect_illusion_frenzy";
			case Defines.ARCHETYPE_RALLY:
				return "effect_illusion_rally";
			case Defines.ARCHETYPE_INVISIBILITY:
			case Defines.ARCHETYPE_CLOAK:
				return "effect_illusion_invisibility";
			case Defines.ARCHETYPE_GUIDE:
				return "effect_illusion_clairvoyance";

			// Restoration
			case Defines.ARCHETYPE_TURNUNDEAD:
				return "effect_restoration_turnundead";

			// Skills
			case Defines.ARCHETYPE_WEREWOLF:
				return "effect_skills_misc_werewolf";
			case Defines.ARCHETYPE_VAMPIRELORD:
				return "effect_skills_misc_vampire";

			// Check last
			case Defines.ARCHETYPE_VALUEMOD:		// Stacking effects
			case Defines.ARCHETYPE_PEAKVALUEMOD:	// Non-Stacking Effects
			case Defines.ARCHETYPE_DUALVALUEMOD:	// 2 AV's are modified... maybe add new effects for these?
			case Defines.ARCHETYPE_ABSORB:			// Abosrb
				return (effectData.effectFlags & Defines.FLAG_EFFECTTYPE_DETRIMENTAL)? valueModDetrimental(): valueMod();


			default:
				return "default_effect";
		}
	}

	private function valueMod(): String
	{
		switch(effectData.actorValue) {
			// Alteration/Special
			/*
			Archetypes:
			effect_alteration_paralyze
			effect_alteration_detectlife
			effect_alteration_detectundead // Same as Detect Lice, can't differentiate
			effect_alteration_light

			Not needed:
			effect_alteration_armor
			effect_alteration_transmute // Can't determine, only defining option is Archetype Script.. Not an AE, anyway, instant effect
			*/
			case Defines.ACTORVALUE_WATERBREATHING:
				return "effect_alteration_waterbreathing";
			case Defines.ACTORVALUE_TELEKINESIS:
				return "effect_alteration_telekinesis"; //Also archetype

			//Conjuration
			/*
			Archetypes:
			effect_conjuration_bound
			effect_conjuration_reanimate
			effect_conjuration_soultrap
			effect_conjuration_banish
			effect_conjuration_conjure
			*/

			// Destruction
			/*
			Archetypes:
			effect_destruction_special_absoption // Check for Health, Stamina, Magicka Hostile?

			Detrimental:
			effect_destruction_damage_fire
			effect_destruction_damage_frost
			effect_destruction_damage_shock
			effect_destruction_damage_light
			effect_destruction_damage_poison
			effect_destruction_damage_health
			effect_destruction_damage_health_regen
			effect_destruction_damage_magicka
			effect_destruction_damage_magicka_regen
			effect_destruction_damage_stamina
			effect_destruction_damage_stamina_regen
			effect_destruction_weakness_fire
			effect_destruction_weakness_frost
			effect_destruction_weakness_shock
			effect_destruction_weakness_light
			effect_destruction_weakness_poison
			effect_destruction_special_slow
			*/

			// Illusion
			/*
			Archetypes:
			effect_illusion_frenzy
			effect_illusion_pacify // Calm
			effect_illusion_rally
			effect_illusion_clairvoyance // Guide
			*/
			case Defines.ACTORVALUE_INVISIBILITY:
				return "effect_illusion_invisibility"; // Also archetype
			case Defines.ACTORVALUE_MOVEMENTNOISEMULT:
				return "effect_illusion_muffle";
			case Defines.ACTORVALUE_NIGHTEYE:
				return "effect_illusion_nighteye";

			// Restoration
			/*
			effect_restoration_turnundead

			Don't know where to put:
			effect_restoration_health_regen
			effect_restoration_magica_regen
			effect_restoration_stamina_regen

			Not needed:
			effect_restoration_resist_light
			*/

			//Main stats
			case Defines.ACTORVALUE_HEALTH:
				if (effectData.archetype == Defines.ARCHETYPE_VALUEMOD)
					return "effect_restoration_health"; //Heals for XX points
				return "effect_restoration_fortify_health"; //Health is increased by XX points
			case Defines.ACTORVALUE_HEALRATE:
			case Defines.ACTORVALUE_HEALRATEMULT: // NEED multipliers
				return "effect_restoration_fortify_health_regen";
			case Defines.ACTORVALUE_MAGICKA:
				if (effectData.archetype == Defines.ARCHETYPE_VALUEMOD)
					return "effect_restoration_magicka";
				return "effect_restoration_fortify_magicka";
			case Defines.ACTORVALUE_MAGICKARATE:
			case Defines.ACTORVALUE_MAGICKARATEMULT:
				return "effect_restoration_fortify_magicka_regen";
			case Defines.ACTORVALUE_STAMINA:
				if (effectData.archetype == Defines.ARCHETYPE_VALUEMOD)
					return "effect_restoration_stamina";
				return "effect_restoration_fortify_stamina";
			case Defines.ACTORVALUE_STAMINARATE:
			case Defines.ACTORVALUE_STAMINARATEMULT:
				return "effect_restoration_fortify_stamina_regen";
			case Defines.ACTORVALUE_WARDPOWER:
				return "effect_restoration_ward";
			case Defines.ACTORVALUE_SHOUTRECOVERYMULT:
				return "effect_restoration_fortify_shout";
			case Defines.ACTORVALUE_MELEEDAMAGE: //MELEEDAMAGE isn't used?
			case Defines.ACTORVALUE_UNARMEDDAMAGE:
				return "effect_restoration_fortify_unarmed";
			case Defines.ACTORVALUE_CARRYWEIGHT:
				return "effect_restoration_fortify_carry";
			case Defines.ACTORVALUE_DISEASERESIST:
				return "effect_restoration_resist_disease";
			case Defines.ACTORVALUE_FIRERESIST:
				return "effect_restoration_resist_fire";
			case Defines.ACTORVALUE_FROSTRESIST:
				return "effect_restoration_resist_frost";
			case Defines.ACTORVALUE_ELECTRICRESIST:
				return "effect_restoration_resist_shock";
			case Defines.ACTORVALUE_MAGICRESIST: // NEED
				return "effect_restoration_resist_magic";
			case Defines.ACTORVALUE_POISONRESIST:
				return "effect_restoration_resist_poison";

			// Skills
			/*
			Archetype:
			effect_skills_fortify_alteration
			effect_skills_fortify_illusion
			effect_skills_fortify_destruction
			effect_skills_fortify_conjuration
			effect_skills_fortify_restoration
			effect_skills_fortify_alchemy
			effect_skills_fortify_archery
			effect_skills_fortify_barter
			effect_skills_fortify_block
			effect_skills_fortify_enchanting
			effect_skills_fortify_armor_light
			effect_skills_fortify_armor_heavy
			effect_skills_fortify_lockpicking
			effect_skills_fortify_weapon_1h
			effect_skills_fortify_weapon_2h
			effect_skills_fortify_persuasion //
			effect_skills_fortify_pickpocket
			effect_skills_fortify_smithing
			effect_skills_fortify_sneak
			effect_skills_fortify_spell
			effect_skills_misc_werewolf
			effect_skills_misc_vampire
			*/

			// Skills
			case Defines.ACTORVALUE_ALTERATION:
			case Defines.ACTORVALUE_ALTERATIONMOD:
			case Defines.ACTORVALUE_ALTERATIONPOWERMOD:
				return "effect_skills_fortify_alteration";
			case Defines.ACTORVALUE_ILLUSION:
			case Defines.ACTORVALUE_ILLUSIONMOD:
			case Defines.ACTORVALUE_ILLUSIONPOWERMOD:
				return "effect_skills_fortify_illusion";
			case Defines.ACTORVALUE_DESTRUCTION:
			case Defines.ACTORVALUE_DESTRUCTIONMOD:
			case Defines.ACTORVALUE_DESTRUCTIONPOWERMOD:
				return "effect_skills_fortify_destruction";
			case Defines.ACTORVALUE_CONJURATION:
			case Defines.ACTORVALUE_CONJURATIONMOD:
			case Defines.ACTORVALUE_CONJURATIONPOWERMOD:
				return "effect_skills_fortify_conjuration";
			case Defines.ACTORVALUE_RESTORATION:
			case Defines.ACTORVALUE_RESTORATIONMOD:
			case Defines.ACTORVALUE_RESTORATIONPOWERMOD:
				return "effect_skills_fortify_restoration";
			case Defines.ACTORVALUE_ALCHEMY:
			case Defines.ACTORVALUE_ALCHEMYMOD:
			case Defines.ACTORVALUE_ALCHEMYPOWERMOD:
				return "effect_skills_fortify_alchemy";
			case Defines.ACTORVALUE_MARKSMAN:
			case Defines.ACTORVALUE_MARKSMANMOD:
			case Defines.ACTORVALUE_MARKSMANPOWERMOD:
				return "effect_skills_fortify_archery";
			case Defines.ACTORVALUE_SPEECHCRAFTPOWERMOD: //SPEECHCRAFTPOWERMOD is used for fortify Barter
				return "effect_skills_fortify_barter";
			case Defines.ACTORVALUE_BLOCK: 
			case Defines.ACTORVALUE_BLOCKMOD:
			case Defines.ACTORVALUE_BLOCKPOWERMOD:
				return "effect_skills_fortify_block";
			case Defines.ACTORVALUE_ENCHANTING:
			case Defines.ACTORVALUE_ENCHANTINGMOD:
			case Defines.ACTORVALUE_ENCHANTINGPOWERMOD:
				return "effect_skills_fortify_enchanting";
			case Defines.ACTORVALUE_LIGHTARMOR:
			case Defines.ACTORVALUE_LIGHTARMORMOD:
			case Defines.ACTORVALUE_LIGHTARMORPOWERMOD:
				return "effect_skills_fortify_armor_light";
			case Defines.ACTORVALUE_HEAVYARMOR:
			case Defines.ACTORVALUE_HEAVYARMORMOD:
			case Defines.ACTORVALUE_HEAVYARMORPOWERMOD:
				return "effect_skills_fortify_armor_heavy";
			case Defines.ACTORVALUE_LOCKPICKING:
			case Defines.ACTORVALUE_LOCKPICKINGMOD:
			case Defines.ACTORVALUE_LOCKPICKINGPOWERMOD:
				return "effect_skills_fortify_lockpicking";
			case Defines.ACTORVALUE_ONEHANDED:
			case Defines.ACTORVALUE_ONEHANDEDMOD:
			case Defines.ACTORVALUE_ONEHANDEDPOWERMOD:
				return "effect_skills_fortify_weapon_1h";
			case Defines.ACTORVALUE_TWOHANDED: 
			case Defines.ACTORVALUE_TWOHANDEDMOD:
			case Defines.ACTORVALUE_TWOHANDEDPOWERMOD:
				return "effect_skills_fortify_weapon_2h";
			case Defines.ACTORVALUE_SPEECHCRAFT:
			case Defines.ACTORVALUE_SPEECHCRAFTMOD: //SPEECHCRAFTPOWERMOD is used for fortify Barter
				return "effect_skills_fortify_persuasion";
			case Defines.ACTORVALUE_PICKPOCKET:
			case Defines.ACTORVALUE_PICKPOCKETMOD:
			case Defines.ACTORVALUE_PICKPOCKETPOWERMOD:
				return "effect_skills_fortify_pickpocket";
			case Defines.ACTORVALUE_SMITHING:
			case Defines.ACTORVALUE_SMITHINGMOD:
			case Defines.ACTORVALUE_SMITHINGPOWERMOD:
				return "effect_skills_fortify_smithing";
			case Defines.ACTORVALUE_SNEAK:
			case Defines.ACTORVALUE_SNEAKMOD:
			case Defines.ACTORVALUE_SNEAKPOWERMOD:
				return "effect_skills_fortify_sneak";

			default:
				return "default_effect";
		}
	}

//Hostile: This Effect is treated as an attack. Only Hostile effects can be resisted.
//Detrimental: This Effect is applied as a negative value (damage) to the specified Actor Value.

	private function valueModDetrimental(): String
	{
		switch(effectData.actorValue) {
			// Destruction
			/* 
			Archetypes:
			effect_destruction_special_absoption
			

			not needed:
			effect_destruction_special_absoption
			effect_destruction_weakness_light

			need:
			effect_destruction_weakness_disease
			effect_destruction_weakness_magic
			*/
			case Defines.ACTORVALUE_HEALTH:
				return "effect_destruction_damage_health"; //Drain health?
			case Defines.ACTORVALUE_HEALRATE:
			case Defines.ACTORVALUE_HEALRATEMULT: //Different icon
				return "effect_destruction_damage_health_regen";
			case Defines.ACTORVALUE_MAGICKA:
				return "effect_destruction_damage_magica";
			case Defines.ACTORVALUE_MAGICKARATE:
			case Defines.ACTORVALUE_MAGICKARATEMULT:
				return "effect_destruction_damage_magicka_regen";
			case Defines.ACTORVALUE_STAMINA:
				return "effect_destruction_damage_stamina";
			case Defines.ACTORVALUE_STAMINARATE:
			case Defines.ACTORVALUE_STAMINARATEMULT:
				return "effect_destruction_damage_stamina_regen";

			case Defines.ACTORVALUE_FIRERESIST:
				return "effect_destruction_weakness_fire";
			case Defines.ACTORVALUE_FROSTRESIST:
				return "effect_destruction_weakness_frost";
			case Defines.ACTORVALUE_ELECTRICRESIST:
				return "effect_destruction_weakness_shock";
			case Defines.ACTORVALUE_POISONRESIST:
				return "effect_destruction_weakness_poison";

			//case Defines.ACTORVALUE_MAGICRESIST:
			//	return "effect_destruction_weakness_magic";
			//case Defines.ACTORVALUE_DISEASERESIST:
			//	return "effect_destruction_weakness_disease";

			case Defines.ACTORVALUE_SPEEDMULT:
				return "effect_destruction_special_slow";

			default:
				return "default_effect";
		}
	}

		
	private function parseTime(a_s: Number): String
	{
		var s: Number = Math.floor(a_s);
		var m: Number = 0;
		var h: Number = 0;
		var d: Number = 0;

		if (s >= 60) {
			m = Math.floor(s / 60);
			s = s % 60;
		}
		if  (m >= 60) {
			h = Math.floor(m / 60);
			m = m % 60;
		}
		if  (h >= 24) {
			d = Math.floor(h / 24);
			h = h % 24;
		}
		
		return ((d != 0 ? (d + "d ") : "") +
				(h != 0 || d ? (h + "h ") : "") +
				(m != 0 || d || h ? (m + "m ") : "") +
				(s + "s"));
	}
}



