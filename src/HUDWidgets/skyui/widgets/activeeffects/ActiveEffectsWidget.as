import skyui.util.Defines;

import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsGroup;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
  /* CONSTANTS */
	private static var EFFECT_FADE_IN_DURATION: Number = 0.25;
	private static var EFFECT_FADE_OUT_DURATION: Number = 0.75;
	private static var EFFECT_MOVE_DURATION: Number = 1.00;
	private static var GROUP_MOVE_DURATION: Number = 1.00;

	// NO './', bsa doesn't like it!
	private static var ICON_LOCATION: String = "skyui/skyui_icons_psychosteve.swf"; // TEST: Change to ../skyui/... when testing

	// config
	private var _effectBaseSize: Number; // {small: 32.0, medium: 48.0, large: 64.0} Default: medium
	private var _groupEffectCount: Number;
	private var _clampCorner: String;
	private var _orientation: String;



	private var _effectSpacing: Number; // _effectBaseSize/10
	private var _groupSpacing: Number; // _effectBaseSize/10


  /* PRIVATE VARIABLES */
	private var _marker: Number = 1;
	private var _sortFlag: Boolean = true;

	private var _effectsHash: Object;
	private var _effectsGroups: Array;

	

	private var _intervalId: Number;

	//Grow dir
	private var _hGrowDirection: String;
	private var _vGrowDirection: String;
	

  /* PUBLIC VARIABLES */
	// Passed from SKSE
	public var effectDataArray: Array;

	// Config
	public var updateInterval: Number = 150;

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

	// Papyrus interface
	// @Papyrus
	public function initNumbers(a_effectSize: Number, a_groupEffectCount: Number): Void
	{
		_effectBaseSize = a_effectSize;
		_groupEffectCount = a_groupEffectCount;
	}

	// @Papyrus
	public function initStrings(a_clampCorner: String, a_orientation: String): Void
	{
		updateClampCorner(a_clampCorner);
		_orientation = a_orientation.toLowerCase();
	}

	// @Papyrus
	public function initCommit(): Void
	{
		_groupSpacing = _effectSpacing = _effectBaseSize/10;
		invalidateSize();

		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
	}

	// @Papyrus
	public function setEffectSize(a_effectBaseSize: Number): Void
	{
		_effectBaseSize = a_effectBaseSize;
		_groupSpacing = _effectSpacing = _effectBaseSize/10.0;

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
	public function setClampCorner(a_clampCorner: String): Void
	{
		updateClampCorner(a_clampCorner);

		invalidateEffects();
	}

	// Helper function for setClampCorner
	private function updateClampCorner(a_clampCorner: String): Void
	{
		_clampCorner = a_clampCorner.toUpperCase();
		switch(_clampCorner) {
			case "BR":
				_hGrowDirection = "left";
				_vGrowDirection = "up";
				break;
			case "BL":
				_hGrowDirection = "right";
				_vGrowDirection = "up";
				break;
			case "TL":
				_hGrowDirection = "right";
				_vGrowDirection = "down";
				break;
			default:
				_clampCorner = "TR";
				_hGrowDirection = "left";
				_vGrowDirection = "down";
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
										iconLocation: ICON_LOCATION,
										groupMoveDuration: GROUP_MOVE_DURATION,
										groupSpacing: _groupSpacing,
										effectBaseSize: _effectBaseSize,
										effectSpacing: _effectSpacing,
										effectFadeInDuration: EFFECT_FADE_IN_DURATION,
										effectFadeOutDuration: EFFECT_FADE_OUT_DURATION,
										effectMoveDuration: EFFECT_MOVE_DURATION,
										hGrowDirection: _hGrowDirection,
										vGrowDirection: _vGrowDirection,
										orientation: _orientation};
										
			// Name needs to be unique so append getNextHighestDepth() to the name
			effectsGroup = attachMovie("ActiveEffectsGroup", "effectsGroup" + getNextHighestDepth(), getNextHighestDepth(), initObject);
			_effectsGroups.push(effectsGroup);

			freeEffectsGroup = effectsGroup;
		}

		return freeEffectsGroup;
	}

	private function invalidateEffects(): Void
	{
		clearInterval(_intervalId);
		_sortFlag = true;

		var effectsGroup: MovieClip;
		for (var i: Number = 0; i < _effectsGroups.length; i++) {
			effectsGroup = _effectsGroups[i];
			effectsGroup.removeMovieClip();
		}

		_effectsHash = new Object();
		_effectsGroups = new Array();

		// Logic here to check if in the right HUD Mode, avoid unnecessary updates
		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
	}
}