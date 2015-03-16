//import mx.transitions.Tween;
//import mx.transitions.easing.None;

class skyui.util.Tween
{
	public static function LinearTween(a_obj: MovieClip, a_prop: String, a_start: Number, a_end: Number, a_duration: Number, a_onFinish: Function, a_overwrite: Boolean): mx.transitions.Tween
	{
		var tweenPropName: String = "__tween_" + a_prop + "__";

		if (a_obj.hasOwnProperty(tweenPropName))
		{
			var tween: mx.transitions.Tween = a_obj[tweenPropName];
			if (tween.isPlaying)
			{
				if (a_overwrite)
				{
					tween.stop();
					delete tween;
				} else {
					return;
				}
			}
		}

		var current: Number = a_obj[a_prop];
		var duration = Math.abs((a_end - current)/(a_end - a_start)) * a_duration;

		a_obj[tweenPropName] = new mx.transitions.Tween(a_obj, a_prop, mx.transitions.easing.None.easeNone, current, a_end, duration, true);

		if (a_onFinish)
		{
			a_obj[tweenPropName].onMotionFinished = a_onFinish;
		}

		return a_obj[tweenPropName];
	}
}