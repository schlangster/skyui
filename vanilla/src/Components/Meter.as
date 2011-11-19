class Components.Meter
{
    var Empty:Number;
	var Full:Number;
	var CurrentPercent:Number;
	var TargetPercent:Number;
	var FillSpeed:Number;
	var EmptySpeed:Number;
	var meterMovieClip:MovieClip;
	
    function Meter(aMovieClip:MovieClip)
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
	
    function SetPercent(aPercent:Number)
    {
        CurrentPercent = Math.min(100, Math.max(aPercent, 0));
        TargetPercent = CurrentPercent;
        var _loc2 = Math.floor(Shared.GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent));
        meterMovieClip.gotoAndStop(_loc2);
    }
	
    function SetTargetPercent(aPercent:Number)
    {
        TargetPercent = Math.min(100, Math.max(aPercent, 0));
    }
	
    function SetFillSpeed(aSpeed:Number)
    {
        FillSpeed = aSpeed;
    }
	
    function SetEmptySpeed(aSpeed:Number)
    {
        EmptySpeed = aSpeed;
    }
	
    function Update()
    {
        if (TargetPercent > 0 && TargetPercent > CurrentPercent)
        {
            if (TargetPercent - CurrentPercent > FillSpeed)
            {
                CurrentPercent = CurrentPercent + FillSpeed;
                var _loc3 = Shared.GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent);
                meterMovieClip.gotoAndStop(_loc3);
            }
            else
            {
                this.SetPercent(TargetPercent);
            }
        }
        else if (TargetPercent <= CurrentPercent)
        {
            var _loc2 = CurrentPercent - TargetPercent > EmptySpeed;
			
            if (TargetPercent > 0 && _loc2 || CurrentPercent > EmptySpeed)
            {
                if (_loc2)
                {
                    CurrentPercent = CurrentPercent - EmptySpeed;
                }
                else
                {
                    CurrentPercent = TargetPercent;
                }
				
                _loc3 = Shared.GlobalFunc.Lerp(Empty, Full, 0, 100, CurrentPercent);
                meterMovieClip.gotoAndStop(_loc3);
            }
            else if (CurrentPercent >= 0)
            {
                this.SetPercent(TargetPercent);
            }
        }
    }
}
