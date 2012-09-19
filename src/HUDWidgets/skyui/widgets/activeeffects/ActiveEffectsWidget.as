import skyui.util.Defines;

import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsGroup;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
  /* CONSTANTS */
	// TODO: Make these config vars.
	static private var GROUP_MOVE_DURATION: Number = 1.00;
	private var _groupSpacing: Number; // _effectBaseSize/10

	// NO './', bsa doesn't like it!
	static private var ICON_LOCATION: String = "skyui/skyui_icons_psychosteve.swf"; // TEST: Change to ../skyui/... when testing
	private var _effectBaseSize: Number; // {small: 32.0, medium: 48.0, large: 64.0} Default: medium
	private var _effectSpacing: Number; // _effectBaseSize/10
	static private var EFFECT_FADE_IN_DURATION: Number = 0.25;
	static private var EFFECT_FADE_OUT_DURATION: Number = 0.75;
	static private var EFFECT_MOVE_DURATION: Number = 1.00;

  /* PRIVATE VARIABLES */
	private var _marker: Number = 1;
	private var _sortFlag: Boolean = true;

	private var _effectsHash: Object;
	private var _effectsGroups: Array;

	private var _yMin: Number;

	private var _maxEffectsGroupLength: Number;

	private var _intervalId: Number;

	// Align
	private var _hAlign: String;
	private var _vAlign: String;

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

		///* // TEST: init
		effectDataArray = [
							{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, // <-- remove
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 59661324496, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 1000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5964613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966143296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 2000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966134442496, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132966, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132449666, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 1500, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5964613296666, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 450, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966143296666, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 1000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 59661344424946, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 20, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132999, actorValue: 54, effectFlags: 4201474, archetype: 11}
							];

		initNumbers(100, 0, 48.0, 3);
		initStrings("right", "top", "left", "down");
		initCommit();

		//setInterval(this, "testEffectSize", 3000);
		_global.setTimeout(this,"timeout", 1000);
		_global.setTimeout(this,"timeout2",1500);
		//*/

	}

  /* PUBLIC FUNCTIONS */
	// Papyrus interface
	public function initNumbers(a_positionX: Number, a_positionY: Number, a_effectSize: Number, a_groupLength: Number): Void
	{
		setPositionX(a_positionX);
		setPositionY(a_positionY);

		_effectBaseSize = a_effectSize;
		_maxEffectsGroupLength = a_groupLength;
	}

	public function initStrings(a_hAlign: String, a_vAlign: String, a_hGrowDirection: String, a_vGrowDirection: String): Void
	{
		_hAlign = a_hAlign.toLowerCase();
		_vAlign = a_vAlign.toLowerCase();
		_hGrowDirection = a_hGrowDirection.toLowerCase();
		_vGrowDirection = a_vGrowDirection.toLowerCase();
	}

	public function initCommit(): Void
	{
		_groupSpacing = _effectSpacing = _effectBaseSize/10;

		//_yMin = (_root.HUDMovieBaseInstance.LocationLockBase)? _root.HUDMovieBaseInstance.LocationLockBase.getBounds(this)["yMax"]: Stage.safeRect.top;
		//var _yMax: Number = ((_root.HUDMovieBaseInstance.ArrowInfoInstance)? (_root.HUDMovieBaseInstance.ArrowInfoInstance.getBounds(this)["yMin"]): Stage.safeRect.bottom) - _effectBaseSize;
		//_maxEffectsGroupLength = Math.floor((_yMax - _yMin)/(_effectBaseSize + _effectSpacing)) + 1;

		invalidateSize();
		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
	}


	public function setEffectSize(a_effectBaseSize: Number): Void
	{
		clearInterval(_intervalId);
		_sortFlag = true;

		_effectBaseSize = a_effectBaseSize;
		_groupSpacing = _effectSpacing = _effectBaseSize/10.0;

		//_yMin = (_root.HUDMovieBaseInstance.LocationLockBase)? _root.HUDMovieBaseInstance.LocationLockBase.getBounds(this)["yMax"]: Stage.safeRect.top;
		//var _yMax: Number = ((_root.HUDMovieBaseInstance.ArrowInfoInstance)? (_root.HUDMovieBaseInstance.ArrowInfoInstance.getBounds(this)["yMin"]): Stage.safeRect.bottom) - _effectBaseSize;
		//_maxEffectsGroupLength = Math.floor((_yMax - _yMin)/(_effectBaseSize + _effectSpacing)) + 1;

		var effectsGroup: MovieClip;
		for (var i: Number = 0; i < _effectsGroups.length; i++) {
			effectsGroup = _effectsGroups[i];
			effectsGroup.removeMovieClip();
		}

		invalidateSize(); // Invalidate after all clips are removed

		_effectsHash = new Object();
		_effectsGroups = new Array();

		onIntervalUpdate();
		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
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


  /* PRIVATE FUNCTIONS */
	private function onIntervalUpdate(): Void
	{
		
		/* // TEST: Uncomment when testing.
		effectDataArray.splice(0);
		skse.RequestActivePlayerEffects(effectDataArray);

		if (_sortFlag) {
			// Make sure oldest effects are at the top
			effectDataArray.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			_sortFlag = false;
		}
		//*/

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
		var effectsGroup: MovieClip;
		var newGroupIdx: Number = _effectsGroups.length;

		var freeEffectsGroup: MovieClip;


		for (var i: Number = 0; i < newGroupIdx; i++) {
			effectsGroup = _effectsGroups[i];

			if (effectsGroup.length < _maxEffectsGroupLength) {
				freeEffectsGroup = effectsGroup;
				break;
			}
		}

		var initObject: Object = {index: newGroupIdx,
									iconLocation: ICON_LOCATION,
									groupMoveDuration: GROUP_MOVE_DURATION,
									groupSpacing: _groupSpacing,
									effectBaseSize: _effectBaseSize,
									effectSpacing: _effectSpacing,
									effectFadeInDuration: EFFECT_FADE_IN_DURATION,
									effectFadeOutDuration: EFFECT_FADE_OUT_DURATION,
									effectMoveDuration: EFFECT_MOVE_DURATION,
									hGrowDirection: _hGrowDirection}; //String

		if (freeEffectsGroup == undefined) {
			effectsGroup = attachMovie("ActiveEffectsGroup", "effectsGroup" + newGroupIdx, getNextHighestDepth(), initObject);
			_effectsGroups.push(effectsGroup);

			freeEffectsGroup = effectsGroup;
		}

		return freeEffectsGroup;
	}





































	///*// TEST: functions
	private function testEffectSize()
	{
		setEffectSize((_effectBaseSize == 32) ? (48): (_effectBaseSize == 48) ? 64 : 32);
	}

	private function timeout()
	{
		effectDataArray = [{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}//, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, // <-- remove
							//{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							//{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132999, actorValue: 54, effectFlags: 4201474, archetype: 11}
							];
		onIntervalUpdate();
	}

	private function timeout2()
	{
		effectDataArray = [//{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, // <-- remove
							//{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132999, actorValue: 54, effectFlags: 4201474, archetype: 11}
							];

		onIntervalUpdate();
	}
	//*/

	// @overrides WidgetBase
	public function getWidth(): Number {
		return _effectBaseSize;
	}

	// @overrides WidgetBase
	public function getHeight(): Number {
		return _effectBaseSize;
	}
}