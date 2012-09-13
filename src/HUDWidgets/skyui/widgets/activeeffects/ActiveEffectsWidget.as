import skyui.util.Defines;

import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsColumn;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
  /* CONSTANTS */
	// TODO: Make these config vars.
	static private var COLUMN_MOVE_DURATION: Number = 1.00;
	private var _columnSpacing: Number; // _effectBaseSize/10

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
	private var _effectsColumns: Array;

	private var _yMin: Number;

	private var _maxEffectsColumnLength: Number;

	private var _intervalId: Number;

  /* PUBLIC VARIABLES */
	// Passed from SKSE
	public var effectDataArray: Array;

	// Config
	public var updateInterval: Number = 150;

	public function ActiveEffectsWidget()
	{
		super();

		_effectsHash = new Object();
		_effectsColumns = new Array();

		effectDataArray = new Array();

		/* // TEST: init
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

		initNumbers(48.0);
		initCommit();

		setInterval(this, "testEffectSize", 3000);
		_global.setTimeout(this,"timeout", 1000);
		_global.setTimeout(this,"timeout2",3000);
		//*/

	}

  /* PUBLIC FUNCTIONS */
	// Papyrus interface
	public function initNumbers(a_effectSize: Number): Void
	{
		_effectBaseSize = a_effectSize;
	}


	public function initCommit(): Void
	{
		_columnSpacing = _effectSpacing = _effectBaseSize/10;

		_yMin = (_root.HUDMovieBaseInstance.LocationLockBase)? _root.HUDMovieBaseInstance.LocationLockBase.getBounds(this)["yMax"]: Stage.safeRect.top;
		var _yMax: Number = ((_root.HUDMovieBaseInstance.ArrowInfoInstance)? (_root.HUDMovieBaseInstance.ArrowInfoInstance.getBounds(this)["yMin"]): Stage.safeRect.bottom) - _effectBaseSize;
		_maxEffectsColumnLength = Math.floor((_yMax - _yMin)/(_effectBaseSize + _effectSpacing)) + 1;

		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
	}


	public function setEffectSize(a_effectBaseSize: Number): Void
	{
		clearInterval(_intervalId);
		_sortFlag = true;

		_effectBaseSize = a_effectBaseSize;
		_columnSpacing = _effectSpacing = _effectBaseSize/10.0;

		_yMin = (_root.HUDMovieBaseInstance.LocationLockBase)? _root.HUDMovieBaseInstance.LocationLockBase.getBounds(this)["yMax"]: Stage.safeRect.top;
		var _yMax: Number = ((_root.HUDMovieBaseInstance.ArrowInfoInstance)? (_root.HUDMovieBaseInstance.ArrowInfoInstance.getBounds(this)["yMin"]): Stage.safeRect.bottom) - _effectBaseSize;
		_maxEffectsColumnLength = Math.floor((_yMax - _yMin)/(_effectBaseSize + _effectSpacing)) + 1;

		var effectsColumn: MovieClip;
		for (var i: Number = 0; i < _effectsColumns.length; i++) {
			effectsColumn = _effectsColumns[i];
			effectsColumn.removeMovieClip();
		}

		_effectsHash = new Object();
		_effectsColumns = new Array();

		onIntervalUpdate();
		_intervalId = setInterval(this, "onIntervalUpdate", updateInterval);
	}

	// Called from ActiveEffectsColumn
	public function onColumnRemoved(a_column: MovieClip): Void
	{
		var removedColumn: MovieClip = a_column;
		var columnIdx: Number = removedColumn.index;

		_effectsColumns.splice(columnIdx, 1);
		removedColumn.removeMovieClip();

		var effectsColumn: MovieClip;
		for (var i: Number = columnIdx; i < _effectsColumns.length; i++) {
			effectsColumn = _effectsColumns[i];
			effectsColumn.updatePosition(i);
		}	
	}


  /* PRIVATE FUNCTIONS */
	private function onIntervalUpdate(): Void
	{
		
		///* // TEST: Uncomment when testing.
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
		var effectsColumn: MovieClip;

		for (var i: Number = 0; i < effectDataArray.length; i++) {
			effectData = effectDataArray[i];
			effectClip = _effectsHash[effectData.id];

			if (!effectClip) {
				// New Effect
				effectsColumn = getFreeEffectsColumn();
				effectClip = effectsColumn.addEffect(effectData);
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

	private function getFreeEffectsColumn(): MovieClip
	{
		var effectsColumn: MovieClip;
		var newColumnIdx: Number = _effectsColumns.length;

		var freeEffectsColumn: MovieClip;


		for (var i: Number = 0; i < newColumnIdx; i++) {
			effectsColumn = _effectsColumns[i];

			if (effectsColumn.length < _maxEffectsColumnLength) {
				freeEffectsColumn = effectsColumn;
				break;
			}
		}

		var initObject: Object = {index: newColumnIdx,
									iconLocation: ICON_LOCATION,
									columnMoveDuration: COLUMN_MOVE_DURATION,
									columnSpacing: _columnSpacing,
									effectBaseSize: _effectBaseSize,
									effectSpacing: _effectSpacing,
									effectFadeInDuration: EFFECT_FADE_IN_DURATION,
									effectFadeOutDuration: EFFECT_FADE_OUT_DURATION,
									effectMoveDuration: EFFECT_MOVE_DURATION,
									_y: _yMin};

		if (freeEffectsColumn == undefined) {
			effectsColumn = attachMovie("ActiveEffectsColumn", "effectsColumn" + newColumnIdx, getNextHighestDepth(), initObject);
			_effectsColumns.push(effectsColumn);

			freeEffectsColumn = effectsColumn;
		}

		return freeEffectsColumn;
	}

	/*// TEST: functions
	private function testEffectSize()
	{
		setEffectSize((_effectBaseSize == 32) ? (48): (_effectBaseSize == 48) ? 64 : 32);
	}

	private function timeout()
	{
		effectDataArray = [{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							//{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, // <-- remove
							//{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132999, actorValue: 54, effectFlags: 4201474, archetype: 11}
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
}