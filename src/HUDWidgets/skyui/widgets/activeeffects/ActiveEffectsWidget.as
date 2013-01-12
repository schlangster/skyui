import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsGroup;
import skyui.defines.Magic;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;


class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
  /* CONSTANTS */
  
	private static var EFFECT_FADE_IN_DURATION: Number = 0.25;
	private static var EFFECT_FADE_OUT_DURATION: Number = 0.75;
	private static var EFFECT_MOVE_DURATION: Number = 1.00;
	private static var GROUP_MOVE_DURATION: Number = 1.00;

	private static var ICON_SOURCE: String = "skyui/icons_effect_psychosteve.swf";
	

	// config
	private var _effectBaseSize: Number; // "small" = 32.0, "medium" = 48.0, "large" = 64.0, Default: "medium"
	private var _groupEffectCount: Number;
	private var _orientation: String;

	private var _effectSpacing: Number; // == _effectBaseSize/10


  /* PRIVATE VARIABLES */
  
	private var _marker: Number = 1;
	private var _sortFlag: Boolean = true;

	private var _effectsHash: Object;
	private var _effectsGroups: Array;

	private var _intervalId: Number;
	private var _updateInterval: Number = 150; // Put in config?

	//Grow dir
	private var _hGrowDirection: String;
	private var _vGrowDirection: String;

	private var _enabled: Boolean;
	

  /* PUBLIC VARIABLES */
  
	// Passed from SKSE
	public var effectDataArray: Array;

	public function ActiveEffectsWidget()
	{
		super();

		_effectsHash = new Object();
		_effectsGroups = new Array();

		effectDataArray = new Array();
	}

  /* PUBLIC FUNCTIONS */
  
	// @overrides WidgetBase
	public function getWidth(): Number {
		return _effectBaseSize;
	}

	// @overrides WidgetBase
	public function getHeight(): Number {
		return _effectBaseSize;
	}

	// Called from ActiveEffectsGroup
	public function onGroupRemoved(a_group: MovieClip): Void
	{
		var removedGroup: MovieClip = a_group;
		var groupIdx: Number = removedGroup.index;

		_effectsGroups.splice(groupIdx, 1);
		removedGroup.removeMovieClip();

		var effectsGroup: MovieClip;
		for (var i: Number = groupIdx; i < _effectsGroups.length; i++) {
			effectsGroup = _effectsGroups[i];
			effectsGroup.updatePosition(i); //Sets new index
		}	
	}
  
	// @Papyrus
	public function initNumbers(a_enabled: Boolean, a_effectSize: Number, a_groupEffectCount: Number): Void
	{
		_enabled = a_enabled;
		_effectBaseSize = a_effectSize;
		_groupEffectCount = a_groupEffectCount;
	}

	// @Papyrus
	public function initStrings(a_orientation: String): Void
	{
		_orientation = a_orientation.toLowerCase();
	}

	// @Papyrus
	public function initCommit(): Void
	{
		_effectSpacing = _effectBaseSize/10;
		invalidateSize();

		if (_enabled)
			drawEffects();
	}

	// @Papyrus
	public function setEffectSize(a_effectBaseSize: Number): Void
	{
		_effectBaseSize = a_effectBaseSize;
		_effectSpacing = _effectBaseSize/10.0;

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

  /* PRIVATE FUNCTIONS */
  
	private function onIntervalUpdate(): Void
	{
		effectDataArray.splice(0);
		skse.RequestActivePlayerEffects(effectDataArray);

		if (_sortFlag) {
			// Make sure oldest effects are at the top
			effectDataArray.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			_sortFlag = false;
		}

		var effectData: Object;
		var effectClip: MovieClip;
		var effectsGroup: MovieClip;

		for (var i: Number = 0; i < effectDataArray.length; i++) {
			effectData = effectDataArray[i];
			effectClip = _effectsHash[effectData.id];

			if ((effectData.effectFlags & Magic.MGEFFLAG_HIDEINUI) != 0)
				continue;

			if (!effectClip) {
				// New Effect
				effectsGroup = getFreeEffectsGroup();
				effectClip = effectsGroup.addEffect(effectData);
				_effectsHash[effectData.id] = effectClip;
			} else {
				// Current Effect
				effectClip.updateEffect(effectData);
			}

			effectClip.marker = _marker;
		}

		for (var s: String in _effectsHash) {
			effectClip = _effectsHash[s];

			if (effectClip.marker != _marker) {
				effectClip.remove();
				
				delete(_effectsHash[s]);
			}
		}

		_marker = 1 - _marker;
	}

	private function getFreeEffectsGroup(): MovieClip
	{
		var newGroupIdx: Number = _effectsGroups.length;

		var effectsGroup: MovieClip;
		var freeEffectsGroup: MovieClip;
		for (var i: Number = 0; i < newGroupIdx; i++) {
			effectsGroup = _effectsGroups[i];

			if (effectsGroup.length < _groupEffectCount) {
				freeEffectsGroup = effectsGroup;
				break;
			}
		}

		if (freeEffectsGroup == undefined) {
			var initObject: Object = {index: newGroupIdx,
										iconLocation: _rootPath + ICON_SOURCE,
										groupMoveDuration: GROUP_MOVE_DURATION,
										effectBaseSize: _effectBaseSize,
										effectSpacing: _effectSpacing,
										effectFadeInDuration: EFFECT_FADE_IN_DURATION,
										effectFadeOutDuration: EFFECT_FADE_OUT_DURATION,
										effectMoveDuration: EFFECT_MOVE_DURATION,
										hAnchor: _hAnchor,
										vAnchor: _vAnchor,
										orientation: _orientation};
										
			// Name needs to be unique so append getNextHighestDepth() to the name
			effectsGroup = attachMovie("ActiveEffectsGroup", "effectsGroup" + getNextHighestDepth(), getNextHighestDepth(), initObject);
			_effectsGroups.push(effectsGroup);

			freeEffectsGroup = effectsGroup;
		}

		return freeEffectsGroup;
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

	private function invalidateEffects(): Void
	{
		if (!_enabled)
			return;

		eraseEffects();

		// Logic here to check if in the right HUD Mode, avoid unnecessary updates?
		drawEffects();
	}
}