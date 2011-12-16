class Components.DeltaMeter extends Components.Meter
{
	var DeltaMeterMovieClip:MovieClip;
	var DeltaEmpty:Number;
	var DeltaFull:Number;
	
	function DeltaMeter(aMovieClip:MovieClip)
	{
		super(aMovieClip);
		
		DeltaMeterMovieClip = aMovieClip.DeltaIndicatorInstance;
		DeltaMeterMovieClip.gotoAndStop("Empty");
		DeltaEmpty = DeltaMeterMovieClip._currentframe;
		DeltaMeterMovieClip.gotoAndStop("Full");
		DeltaFull = DeltaMeterMovieClip._currentframe;
	}
	
	function SetDeltaPercent(aPercent)
	{
		var perc = Math.min(100, Math.max(aPercent, 0));
		var frame = Math.floor(Shared.GlobalFunc.Lerp(DeltaEmpty, DeltaFull, 0, 100, perc));
		DeltaMeterMovieClip.gotoAndStop(frame);
	}
}
