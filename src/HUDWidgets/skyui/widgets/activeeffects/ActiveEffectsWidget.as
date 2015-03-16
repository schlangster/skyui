import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsGroup;
import skyui.widgets.activeeffects.ActiveEffect;
import skyui.defines.Magic;

import gfx.events.EventDispatcher;


class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
  /* CONSTANTS */
	
	private static var EFFECT_SPACING: Number			= 5.00;
	private static var EFFECT_FADE_IN_DURATION: Number	= 0.25;
	private static var EFFECT_FADE_OUT_DURATION: Number	= 0.75;
	private static var EFFECT_MOVE_DURATION: Number		= 1.00;

	private static var ICON_SOURCE: String = "skyui/icons_effect_psychosteve.swf";
	

	// config
	private var _effectBaseSize: Number; // "small" = 32.0, "medium" = 48.0, "large" = 64.0, Default: "medium"
	private var _groupEffectCount: Number;
	private var _orientation: String;


  /* PRIVATE VARIABLES */
	
	// Phases between 0 and 1 during update intervals
	private var _marker: Number = 1;
	
	private var _sortFlag: Boolean = true;

	private var _effectsHash: Object;
	private var _effectsGroups: Array;

	private var _intervalId: Number;
	private var _updateInterval: Number = 150;

	private var _enabled: Boolean;
	
	private var _minTimeLeft: Number = 180;
	

  /* PUBLIC VARIABLES */
	
	// Passed from SKSE
	public var effectDataArray: Array;

	public function ActiveEffectsWidget()
	{
		super();

		EventDispatcher.initialize(this);

		_effectsHash = new Object();
		_effectsGroups = new Array();

		effectDataArray = new Array();
	}

  /* PUBLIC FUNCTIONS */
	
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
  
	// @overrides WidgetBase
	public function getWidth(): Number
	{
		return _effectBaseSize;
	}

	// @overrides WidgetBase
	public function getHeight(): Number
	{
		return _effectBaseSize;
	}
	
	// @Papyrus
	public function initNumbers(a_enabled: Boolean, a_effectSize: Number, a_groupEffectCount: Number, a_minTimeLeft: Number): Void
	{
		_enabled = a_enabled;
		_effectBaseSize = a_effectSize;
		_groupEffectCount = a_groupEffectCount;
		_minTimeLeft = a_minTimeLeft;
	}

	// @Papyrus
	public function initStrings(a_orientation: String): Void
	{
		_orientation = a_orientation.toLowerCase();
	}

	// @Papyrus
	public function initCommit(): Void
	{
		invalidateSize();

		if (_enabled)
			drawEffects();
	}

	// @Papyrus
	public function setEffectSize(a_effectBaseSize: Number): Void
	{
		_effectBaseSize = a_effectBaseSize;

		invalidateSize();
		invalidateEffects();
	}

	// @Papyrus
	public function setGroupEffectCount(a_groupEffectCount: Number): Void
	{
		_groupEffectCount = a_groupEffectCount;

		invalidateEffects();
	}

	// @Papyrus
	public function setEnabled(a_enabled: Boolean): Void
	{
		_enabled = a_enabled;

		if (_enabled) {
			eraseEffects();
			drawEffects();
		} else {
			eraseEffects();
		}
	}

	// @Papyrus
	public function setOrientation(a_orientation: String): Void
	{
		_orientation = a_orientation.toLowerCase();

		invalidateEffects();
	}
	
	// @Papyrus
	public function setMinTimeLeft(a_seconds: Number): Void
	{
		_minTimeLeft = a_seconds;
	}

  /* PRIVATE FUNCTIONS */
	
	// @override WidgetBase
	private function updatePosition(): Void
	{
		super.updatePosition();
		invalidateEffects();
	}

	private function onIntervalUpdate(): Void
	{
		effectDataArray.splice(0);
		skse.RequestActivePlayerEffects(effectDataArray);

		if (_sortFlag) {
			// Make sure oldest effects are at the top
			effectDataArray.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			_sortFlag = false;
		}

		for (var i=0; i < effectDataArray.length; i++) {
			var effectData = effectDataArray[i];
			
			// Ignore if time left is > minimum, i.e. for blessings that last several hours
			if (_minTimeLeft != 0 && _minTimeLeft < (effectData.duration - effectData.elapsed))
				continue;
				
			var effectClip: ActiveEffect = _effectsHash[effectData.id];

			if (!effectClip) {
				// New Effect
				var effectsGroup = getFreeEffectsGroup();
				effectClip = effectsGroup.addEffect(effectData);
				_effectsHash[effectData.id] = effectClip;
			} else {
				// Existing Effect
				effectClip.updateEffect(effectData);
			}

			effectClip.marker = _marker;
		}

		for (var s: String in _effectsHash) {
			var effectClip = _effectsHash[s];

			if (effectClip.marker != _marker) {
				effectClip.remove();
				
				delete(_effectsHash[s]);
			}
		}

		_marker = 1 - _marker;
	}

	private function getFreeEffectsGroup(): MovieClip
	{
		// Existing group has free slots?
		for (var i=0; i < _effectsGroups.length; i++) {
			var group = _effectsGroups[i];
			if (group.length < _groupEffectCount)
				return group;
		}
		
		// No free slots, create new group
		var newGroupIdx = _effectsGroups.length;
		var initObject = {
			index: newGroupIdx,
			iconLocation: _rootPath + ICON_SOURCE,
			effectBaseSize: _effectBaseSize,
			effectSpacing: EFFECT_SPACING,
			effectFadeInDuration: EFFECT_FADE_IN_DURATION,
			effectFadeOutDuration: EFFECT_FADE_OUT_DURATION,
			effectMoveDuration: EFFECT_MOVE_DURATION,
			hAnchor: _hAnchor,
			vAnchor: _vAnchor,
			orientation: _orientation
		};
										
		// Name needs to be unique so append getNextHighestDepth() to the name
		var newGroup = attachMovie("ActiveEffectsGroup", "effectsGroup" + getNextHighestDepth(), getNextHighestDepth(), initObject);
		newGroup.addEventListener("groupRemoved", this, "onGroupRemoved");
		_effectsGroups.push(newGroup);

		return newGroup;
	}

	// Called from ActiveEffectsGroup
	public function onGroupRemoved(event: Object): Void
	{
		var removedGroup: MovieClip = event.target;
		var groupIdx: Number = removedGroup.index;

		_effectsGroups.splice(groupIdx, 1);
		removedGroup.removeMovieClip();

		var effectsGroup: MovieClip;
		for (var i: Number = groupIdx; i < _effectsGroups.length; i++) {
			effectsGroup = _effectsGroups[i];
			effectsGroup.updatePosition(i); //Sets new index
		}
	}

	private function invalidateEffects(): Void
	{
		if (!_enabled)
			return;

		eraseEffects();

		// Logic here to check if in the right HUD Mode, avoid unnecessary updates?
		drawEffects();
	}

	private function eraseEffects(): Void
	{
		clearInterval(_intervalId);

		var effectsGroup: MovieClip;
		for (var i: Number = 0; i < _effectsGroups.length; i++) {
			effectsGroup = _effectsGroups[i];
			effectsGroup.removeMovieClip();
		}
		_effectsHash = new Object();
		_effectsGroups = new Array();
	}

	private function drawEffects(): Void
	{
		clearInterval(_intervalId);

		_sortFlag = true;
		_intervalId = setInterval(this, "onIntervalUpdate", _updateInterval);
	}
}