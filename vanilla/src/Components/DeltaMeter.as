class Components.DeltaMeter extends Components.Meter
{
    var DeltaMeterMovieClip:MovieClip;
	var DeltaEmpty:Number;
	var DeltaFull:Number;
	
    function DeltaMeter(aMovieClip)
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
        var _loc3 = Math.min(100, Math.max(aPercent, 0));
        var _loc2 = Math.floor(Shared.GlobalFunc.Lerp(DeltaEmpty, DeltaFull, 0, 100, _loc3));
        DeltaMeterMovieClip.gotoAndStop(_loc2);
    }
}
