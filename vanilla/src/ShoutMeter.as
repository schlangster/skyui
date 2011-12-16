import Shared.GlobalFunc;

class ShoutMeter extends MovieClip
{
	var FlashClip:MovieClip;
	var ProgressClip:MovieClip;
	var MeterEmtpy:Number;
	var MeterFull:Number;
	
	function ShoutMeter(aProgressClip, aFlashClip)
	{
		super();
		ProgressClip = aProgressClip;
		FlashClip = aFlashClip;
		ProgressClip.gotoAndStop("Empty");
		MeterEmtpy = ProgressClip._currentframe;
		ProgressClip.gotoAndStop("Full");
		MeterFull = ProgressClip._currentframe;
		ProgressClip.gotoAndStop("Normal");
		FlashClip.gotoAndStop("Warning Start");
	}
	
	function SetPercent(aPercent:Number)
	{
		if (aPercent >= 100)
		{
			ProgressClip.gotoAndStop("Normal");
		}
		else
		{
			var _loc2 = Math.min(100, Math.max(aPercent, 0));
			var _loc3 = Math.floor(GlobalFunc.Lerp(MeterEmtpy, MeterFull, 0, 100, _loc2));
			ProgressClip.gotoAndStop(_loc3);
		} // end else if
	}
	
	function FlashMeter()
	{
		FlashClip.gotoAndPlay("Warning Start");
	}
}
