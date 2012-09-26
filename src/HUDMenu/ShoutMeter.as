import Shared.GlobalFunc;

class ShoutMeter
{
	var FlashClip: MovieClip;
	var MeterEmtpy: Number;
	var MeterFull: Number;
	var ProgressClip: MovieClip;

	function ShoutMeter(aProgressClip: MovieClip, aFlashClip: MovieClip)
	{
		ProgressClip = aProgressClip;
		FlashClip = aFlashClip;
		ProgressClip.gotoAndStop("Empty");
		MeterEmtpy = ProgressClip._currentframe;
		ProgressClip.gotoAndStop("Full");
		MeterFull = ProgressClip._currentframe;
		ProgressClip.gotoAndStop("Normal");
	}

	function SetPercent(aPercent: Number): Void
	{
		if (aPercent >= 100) {
			ProgressClip.gotoAndStop("Normal");
			return;
		}
		var aPercent: Number = Math.min(100, Math.max(aPercent, 0));
		var aPercentFrame: Number = Math.floor(GlobalFunc.Lerp(MeterEmtpy, MeterFull, 0, 100, aPercent));
		ProgressClip.gotoAndStop(aPercentFrame);
	}

	function FlashMeter(): Void
	{
		FlashClip.gotoAndPlay("StartFlash");
	}

}
