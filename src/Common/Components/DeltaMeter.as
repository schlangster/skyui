import Shared.GlobalFunc;

class Components.DeltaMeter extends Components.Meter
{
	var DeltaEmpty: Number;
	var DeltaFull: Number;
	var DeltaMeterMovieClip: MovieClip;

	function DeltaMeter(aMovieClip: MovieClip)
	{
		super(aMovieClip);
		DeltaMeterMovieClip = aMovieClip.DeltaIndicatorInstance;
		DeltaMeterMovieClip.gotoAndStop("Empty");
		DeltaEmpty = DeltaMeterMovieClip._currentframe;
		DeltaMeterMovieClip.gotoAndStop("Full");
		DeltaFull = DeltaMeterMovieClip._currentframe;
	}

	function SetDeltaPercent(aiPercent: Number): Void
	{
		var iPercent: Number = Math.min(100, Math.max(aiPercent, 0));
		var iMeterFrame: Number = Math.floor(GlobalFunc.Lerp(DeltaEmpty, DeltaFull, 0, 100, iPercent));
		DeltaMeterMovieClip.gotoAndStop(iMeterFrame);
	}

}
