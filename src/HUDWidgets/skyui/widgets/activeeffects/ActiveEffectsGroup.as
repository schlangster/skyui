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
	public var vGrowDirection: String;
	public var orientation: String;


  /* INITIALIZATION */
  
	public function ActiveEffectsGroup()
	{
		super();

		_effectsArray = new Array();

		_x = determinePosition(index)[0];
		_y = determinePosition(index)[1];
	}


  /* PROPERTIES */
  
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


  /* PUBLIC FUNCTIONS */
  
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
									effectMoveDuration: effectMoveDuration,
									hGrowDirection: hGrowDirection,
									vGrowDirection: vGrowDirection,
									orientation: orientation};
		var effectClip: MovieClip = attachMovie("ActiveEffect", a_effectData.id, getNextHighestDepth(), initObject);
		_effectsArray.push(effectClip);

		return effectClip;
	}

	public function updatePosition(a_newIndex: Number): Void
	{
		index = a_newIndex;

		TweenLite.to(this, 1, {_x: determinePosition(index)[0], _y: determinePosition(index)[1], overwrite: 0, easing: Linear.easeNone});
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
  
	private function determinePosition(a_index: Number): Array
	{
		// defaults to vertical
		//             vertical -> left
		//          or horizontal -> down

		var newX: Number = 0;
		var newY: Number = 0;

		// orientation the axis in which new effects will be added to after the total number of effects > GroupEffectCount
		if (orientation == "vertical") {
			// Orientation is vertical so...
			// Group is a column, so next group will be shifted horizontally
			if (hGrowDirection == "left") {
				newX = -(index * (effectBaseSize + groupSpacing));
			} else {
				newX = +(index * (effectBaseSize + groupSpacing));
			}
		} else {
			// Group is a row, so next group will be shifted vertically
			if (vGrowDirection == "up") {
				newY = -(index * (effectBaseSize + groupSpacing));
			} else {
				newY = +(index * (effectBaseSize + groupSpacing));
			}

		}

		return [newX, newY];
	}

  	// Not needed, see onEffectRemoved();
  	/*
  	private function remove(): Void
  	{
		TweenLite.to(this, effectFadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onGroupRemoved, onCompleteParams: [this], overwrite: 2, easing: Linear.easeNone});
  	}
  	*/
}


