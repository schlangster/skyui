import Shared.GlobalFunc;

class Components.Meter
{
	var CurrentPercent: Number;
	var Empty: Number;
	var EmptySpeed: Number;
	var FillSpeed: Number;
	var Full: Number;
	var TargetPercent: Number;
	var meterMovieClip: MovieClip;

	function Meter(aMovieClip: MovieClip)
	{
		Empty = 0;
		Full = 0;
		CurrentPercent = 100;
		TargetPercent = 100;
		FillSpeed = 2;
		EmptySpeed = 3;
		meterMovieClip = aMovieClip;
		meterMovieClip.gotoAndStop("Empty");
		Empty = meterMovieClip._currentframe;
		meterMovieClip.gotoAndStop("Full");
		Full = meterMovieClip._currentframe;
	}

	function SetPercent(aPercent: Number): Void
	{
		CurrentPercent = Math.min(100, Math.max(aPercent, 0));
		TargetPercent = CurrentPercent;
		var iMeterFrame: Number = Math.floor(GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent));
		meterMovieClip.gotoAndStop(iMeterFrame);
	}

	function SetTargetPercent(aPercent: Number): Void
	{
		TargetPercent = Math.min(100, Math.max(aPercent, 0));
	}

	function SetFillSpeed(aSpeed: Number): Void
	{
		FillSpeed = aSpeed;
	}

	function SetEmptySpeed(aSpeed: Number): Void
	{
		EmptySpeed = aSpeed;
	}

	function Update(): Void
	{
		if (TargetPercent > 0 && TargetPercent > CurrentPercent) {
			if (TargetPercent - CurrentPercent > FillSpeed) {
				CurrentPercent = CurrentPercent + FillSpeed;
				var iMeterFrame: Number = GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent);
				meterMovieClip.gotoAndStop(iMeterFrame);
			} else {
				SetPercent(TargetPercent);
			}
			return;
		}
		if (TargetPercent <= CurrentPercent) {
			var bAnim: Boolean = CurrentPercent - TargetPercent > EmptySpeed;
			if ((TargetPercent > 0 && bAnim) || CurrentPercent > EmptySpeed) {
				if (bAnim) 
					CurrentPercent = CurrentPercent - EmptySpeed;
				else 
					CurrentPercent = TargetPercent;
				var iMeterFrame: Number = GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent);
				meterMovieClip.gotoAndStop(iMeterFrame);
				return;
			}
			if (CurrentPercent >= 0) 
				SetPercent(TargetPercent);
		}
	}

}
