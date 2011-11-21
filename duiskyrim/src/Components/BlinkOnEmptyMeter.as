class Components.BlinkOnEmptyMeter extends Components.Meter
{
    function BlinkOnEmptyMeter(aMeterClip:MovieClip)
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
