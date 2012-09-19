import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsGroup extends MovieClip
{
  /* PRIVATE VARIABLES */
	private var _effectsArray: Array

  /* PUBLIC VARIABLES */
  	// initObject
	public var index: Number;
	public var groupMoveDuration: Number;
	public var groupSpacing: Number;
	public var iconLocation: String;
	public var effectBaseSize: Number;
	public var effectSpacing: Number;
	public var effectFadeInDuration: Number;
	public var effectFadeOutDuration: Number;
	public var effectMoveDuration: Number;

	public var hGrowDirection: String;

	public function ActiveEffectsGroup()
	{
		super();

		_effectsArray = new Array();
		// Stage right - effectSize + yOffset - (index * (effect size + groupPadding))
		//_x = (Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x) - effectBaseSize - groupSpacing - (index * (effectBaseSize + groupSpacing));

		// _y is set by initObject since it's constant
		/*
		_y = Stage.safeRect.width;
		//*/
	}

	public function onLoad()
	{
		_x = determinePosition(index);
	}

  /* PUBLIC FUNCTIONS */

	public function get length(): Number
	{
		return _effectsArray.length;
	}

	// Used if you want to access effectsGroup.effects[effectIndex]; for instance
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
		//var x: Number = Stage.safeRect.width - effectBaseSize - (index * (effectBaseSize + groupSpacing));

		TweenLite.to(this, 1, {_x: determinePosition(index), overwrite: 0, easing: Linear.easeNone});
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
			// If the group had a background, for example, we'd call
			// this.remove()
			// which would fade out the group then, onComplete, call
			// _parent.onGroupRemoved(this);
			_parent.onGroupRemoved(this);
		}
	}

  /* PRIVATE FUNCTIONS */
  	// Not needed, see onEffectRemoved();
  	/*
  	private function remove(): Void
  	{
		TweenLite.to(this, effectFadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onGroupRemoved, onCompleteParams: [this], overwrite: 2, easing: Linear.easeNone});
  	}
  	*/

	private function determinePosition(a_index: Number): Number
	{
  		var newX: Number;

		if (hGrowDirection == "right")
			newX = +(index * (effectBaseSize + groupSpacing));
		else if (hGrowDirection == "left")
			newX = -(index * (effectBaseSize + groupSpacing));

		return newX
  	}
}