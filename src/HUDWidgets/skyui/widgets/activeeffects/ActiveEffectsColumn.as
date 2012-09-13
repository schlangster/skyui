import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsColumn extends MovieClip
{
  /* PRIVATE VARIABLES */
	private var _effectsArray: Array

  /* PUBLIC VARIABLES */
  	// initObject
	public var index: Number;
	public var columnMoveDuration: Number;
	public var columnSpacing: Number;
	public var iconLocation: String;
	public var effectBaseSize: Number;
	public var effectSpacing: Number;
	public var effectFadeInDuration: Number;
	public var effectFadeOutDuration: Number;
	public var effectMoveDuration: Number;

	public function ActiveEffectsColumn()
	{
		super();
		
		_effectsArray = new Array();

		_x = Stage.safeRect.width - effectBaseSize - (index * (effectBaseSize + columnSpacing));
		// _y is set by initObject since it's constant
		/*
		_y = Stage.safeRect.width;
		//*/

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
									effectBaseSize: effectBaseSize,
									effectSpacing: effectSpacing,
									effectFadeInDuration: effectFadeInDuration,
									effectFadeOutDuration: effectFadeOutDuration,
									effectMoveDuration: effectMoveDuration};
		var effectClip: MovieClip = attachMovie("ActiveEffect", a_effectData.id, getNextHighestDepth(), initObject);
		_effectsArray.push(effectClip);

		return effectClip;
	}

	public function updatePosition(a_newIndex: Number): Void
	{
		index = a_newIndex;
		var x: Number = Stage.safeRect.width - effectBaseSize - (index * (effectBaseSize + columnSpacing));

		TweenLite.to(this, 1, {_x: x, overwrite: "AUTO", easing: Linear.easeNone});
	}

	public function onEffectRemoved(a_effectClip: MovieClip): Void
	{
		var removedEffectClip: MovieClip = a_effectClip;
		var effectIdx: Number = removedEffectClip.index;

		_effectsArray.splice(effectIdx, 1);
		removedEffectClip.removeMovieClip();

		if (_effectsArray.length > 0){
			var effectClip: MovieClip;

			for (var i: Number = effectIdx; i < _effectsArray.length; i++) {
				effectClip = _effectsArray[i];
				effectClip.updatePosition(i);
			}
		} else {
			// If the column had a background, for example, we'd call
			// this.remove()
			// which would fade out the column then, onComplete, call
			// _parent.onColumnRemoved(this);
			_parent.onColumnRemoved(this);
		}
	}

  /* PRIVATE FUNCTIONS */
  	// Not needed, see onEffectRemoved();
  	/*
  	private function remove(): Void
  	{
		TweenLite.to(this, effectFadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onColumnRemoved, onCompleteParams: [this], overwrite: "AUTO", easing: Linear.easeNone});
  	}
  	*/
}