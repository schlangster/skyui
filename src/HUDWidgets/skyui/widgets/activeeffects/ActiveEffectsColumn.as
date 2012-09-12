import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsColumn extends MovieClip
{
  /* PRIVATE VARIABLES */
	private var _effectsArray: Array

  /* PUBLIC VARIABLES */
  	// initObject
	public var index: Number;
	public var iconLocation: String;
	public var effectFadeInDuration: Number;
	public var effectFadeOutDuration: Number;
	public var effectSpacing: Number;

	public function ActiveEffectsColumn()
	{
		super();
		
		_effectsArray = new Array();
	}

  /* PUBLIC FUNCTIONS */

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
									effectData: a_effectData,
									iconLocation: iconLocation,
									_y: effectIdx * (128 + effectSpacing)};
		var effectClip: MovieClip = attachMovie("ActiveEffect", a_effectData.id, getNextHighestDepth(), initObject);
		_effectsArray.push(effectClip);

		TweenLite.from(effectClip, effectFadeInDuration, {_alpha: 0, overwrite: "AUTO", easing: Linear.easeNone})

		return effectClip;
	}

	public function removeEffect(a_effectClip: MovieClip): Void
	{
		var effectClip: MovieClip = a_effectClip;
		TweenLite.to(effectClip, effectFadeOutDuration, {_alpha: 0, onCompleteScope: this, onComplete: onEffectRemoved, onCompleteParams: [effectClip], overwrite: "AUTO", easing: Linear.easeNone});
	}

  /* PRIVATE FUNCTIONS */

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

				TweenLite.to(effectClip, 1, {_y:  i * (128 + effectSpacing), overwrite: "AUTO", easing: Linear.easeNone});
			}
		} else {
			_parent.removeColumn(this);
		}
	}
}