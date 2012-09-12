import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsColumn extends MovieClip
{
	static private var ICON_LOCATION: String = "./skyui/skyui_icons_psychosteve.swf"; // TEST: Change to ../skyui/... when testing

	static private var EFFECT_FADE_IN_DURATION: Number = 0.25;
	static private var EFFECT_FADE_OUT_DURATION: Number = 0.75;
	static private var EFFECT_SPACING: Number = 10;

	private var _effectsArray: Array

	public var index: Number;

	public function ActiveEffectsColumn()
	{
		super();
		_effectsArray = new Array();
	}

	public function get length(): Number
	{
		return _effectsArray.length;
	}

	// Used if you want to access effectsColumn.effects[effectIndex]; for instance
	/*
	public function get effects(): Array
	{
		return _effectsArray;
	}
	*/

	public function addEffect(a_effectData: Object): MovieClip
	{
		var effectIdx: Number = _effectsArray.length;
		var initObject: Object = {index: _effectsArray.length,
									iconLocation: ICON_LOCATION,
									effectData: a_effectData,
									_y: effectIdx * (128 + EFFECT_SPACING)};
		var effectClip: MovieClip = attachMovie("ActiveEffect", a_effectData.id, getNextHighestDepth(), initObject);
		_effectsArray.push(effectClip);

		TweenLite.from(effectClip, EFFECT_FADE_IN_DURATION, {_alpha: 0, overwrite: "AUTO", easing: Linear.easeNone})

		return effectClip;
	}

	public function removeEffect(a_effectClip: MovieClip): Void
	{
		var effectClip: MovieClip = a_effectClip;
		TweenLite.to(effectClip, EFFECT_FADE_OUT_DURATION, {_alpha: 0, onCompleteScope: this, onComplete: onEffectRemoved, onCompleteParams: [effectClip], overwrite: "AUTO", easing: Linear.easeNone});
	}

	private function onEffectRemoved(a_effectClip: MovieClip): Void
	{
		var removedEffectClip: MovieClip = a_effectClip;
		var effectIdx: Number = a_effectClip.index;

		_effectsArray.splice(effectIdx, 1);
		removedEffectClip.removeMovieClip();

		if (_effectsArray.length > 0){
			var effectClip: MovieClip;

			for (var i: Number = effectIdx; i < _effectsArray.length; i++) {
				effectClip = _effectsArray[i];
				effectClip.index = i;

				TweenLite.to(effectClip, 1, {_y:  i * (128 + EFFECT_SPACING), overwrite: "AUTO", easing: Linear.easeNone});
			}
		} else {
			_parent.removeColumn(this);
		}
	}
}