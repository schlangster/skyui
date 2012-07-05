class Components.BlinkOnEmptyMeter extends Components.Meter
{
	var iCurrentPercent: Number;
	var iEmpty: Number;
	var meterMovieClip: MovieClip;

	function BlinkOnEmptyMeter(aMeterClip: MovieClip)
	{
		super(aMeterClip);
	}

	function Update(): Void
	{
		super.Update();
		var iCurrentFrame = meterMovieClip._currentframe;
		if (iCurrentPercent <= 0) {
			if (iCurrentFrame == iEmpty) {
				meterMovieClip.gotoAndPlay(iEmpty + 1);
				var iCurrentFrame1: Number = meterMovieClip._currentframe;
			}
		}
	}

}
