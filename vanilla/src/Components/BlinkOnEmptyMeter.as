class Components.BlinkOnEmptyMeter extends Components.Meter
{
    var meterMovieClip;
	var CurrentPercent;
	var Empty;
	
    function BlinkOnEmptyMeter(aMeterClip)
    {
        super(aMeterClip);
    }
	
    function Update()
    {
        super.Update();
        var _loc3 = meterMovieClip._currentframe;
        if (CurrentPercent <= 0)
        {
            if (_loc3 == Empty)
            {
                meterMovieClip.gotoAndPlay(Empty + 1);
                var _loc4 = meterMovieClip._currentframe;
            }
        }
    }
}
