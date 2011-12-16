import gfx.io.GameDelegate;


class Components.UniformTimeMeter extends Components.Meter
{
	var FinishSound;
	var AnimClip;
	var AnimStart;
	var FrameNumber;
	var CurrentPercent;
	var bFinished;
	var FrameCount;
	var TargetPercent;
	var Full;
	var Empty;
	var meterMovieClip;
	
	function UniformTimeMeter(aMovieClip:MovieClip, aFinishSound, aClip, aAnimStart)
	{
		super(aMovieClip);
		FinishSound = aFinishSound;
		AnimClip = aClip;
		AnimStart = aAnimStart;
		FrameNumber = 48;
	}
	
	function SetTargetPercent(aPercent)
	{
		super.SetTargetPercent(aPercent);
		bFinished = aPercent >= 100 && CurrentPercent < 100;
		FrameCount = 0;
	}
	
	function Update()
	{
		if (FrameCount <= FrameNumber)
		{
			var _loc2 = Shared.GlobalFunc.Lerp(CurrentPercent, TargetPercent, 0, FrameNumber, FrameCount);
			var _loc3 = Shared.GlobalFunc.Lerp(Empty, Full, 0, 100, _loc2);
			meterMovieClip.gotoAndStop(_loc3);
			++FrameCount;
			if (FrameCount == FrameNumber && bFinished)
			{
				GameDelegate.call("PlaySound", [FinishSound]);
				if (AnimClip != undefined)
				{
					AnimClip.gotoAndPlay(AnimStart);
				}
			}
		}
	}
}
