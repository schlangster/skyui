import skyui.util.Defines;

import skyui.widgets.WidgetBase;
import skyui.widgets.activeeffects.ActiveEffectsColumn;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{

	static private var EFFECT_LIST_LENGTH: Number = 3;
	static private var COLUMN_SPACING: Number = 10;

	private var _marker: Number = 1;
	private var _sortFlag: Boolean = true;

	private var _effectsHash: Object;
	private var _effectsColumns: Array;

	// @SKSE
	public var effectDataArray: Array;

	// @Config
	public var updateInterval: Number = 150;

	public function ActiveEffectsWidget()
	{
		_effectsHash = new Object();
		_effectsColumns = new Array();

		effectDataArray = new Array();

		
		/* // TEST: Comment when testing
		effectDataArray = [{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, // <-- remove
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11},
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 5966132999, actorValue: 54, effectFlags: 4201474, archetype: 11}
							];

		onIntervalUpdate();
		_global.setTimeout(this,"timeout", 1000);
		_global.setTimeout(this,"timeout2",3000);//*/

		setInterval(this, "onIntervalUpdate", updateInterval);
	}

	public function removeColumn(a_column: MovieClip): Void
	{
		var removedColumn: MovieClip = a_column;
		var columnIdx: Number = removedColumn.index;

		_effectsColumns.splice(columnIdx, 1);
		removedColumn.removeMovieClip();

		var effectsColumn: MovieClip;
		for (var i: Number = columnIdx; i < _effectsColumns.length; i++) {
			effectsColumn = _effectsColumns[i];
			effectsColumn.index = i;
			TweenLite.to(effectsColumn, 1, {_x: i * (128 + COLUMN_SPACING), overwrite: "AUTO", easing: Linear.easeNone});
		}	
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


	private function onIntervalUpdate(): Void
	{
		
		///* // TEST: Uncomment when testing.
		effectDataArray.splice(0);
		skse.RequestActivePlayerEffects(effectDataArray);

		if (_sortFlag) {
			// Make sure oldest effects are at the top
			effectDataArray.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			_sortFlag = false;
		}//*/

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
				effectClip.update(effectData);
			}

			effectClip.marker = _marker;
		}

		for (var s: String in _effectsHash) {
			effectClip = _effectsHash[s];

			if (effectClip.marker != _marker) {
				// Three ways to do this
				/*
				effectClip.remove();
				TweenLite.to(effectClip, 1, {_alpha: 0, onCompleteScope: effectClip._parent, onComplete: effectClip._parent.onEffectRemoved, onCompleteParams: [effectClip], overwrite: "AUTO", easing: Linear.easeNone});
				*/
				effectsColumn = effectClip._parent;
				effectsColumn.removeEffect(effectClip);
				
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

			if (effectsColumn.length < EFFECT_LIST_LENGTH) {
				freeEffectsColumn = effectsColumn;
				break;
			}
		}

		if (freeEffectsColumn == undefined) {
			effectsColumn = attachMovie("ActiveEffectsColumn", "effectsColumn" + newColumnIdx, getNextHighestDepth(), {index: newColumnIdx, _x: newColumnIdx * (128 + COLUMN_SPACING)});
			_effectsColumns.push(effectsColumn);

			freeEffectsColumn = effectsColumn;
		}

		return freeEffectsColumn;
	}

}