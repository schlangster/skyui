class Components.BlinkOnDemandMeter extends Components.Meter
{
	var BlinkMovieClip: MovieClip;
	var meterMovieClip: MovieClip;

	function BlinkOnDemandMeter(aMeterMovieClip: MovieClip, aBlinkMovieClip: MovieClip)
	{
		super(aMeterMovieClip);
		BlinkMovieClip = aBlinkMovieClip;
		BlinkMovieClip.gotoAndStop("StartFlash");
	}

	function StartBlinking(): Void
	{
		meterMovieClip._parent.PlayForward(meterMovieClip._parent._currentframe);
		BlinkMovieClip.gotoAndPlay("StartFlash");
	}

}
