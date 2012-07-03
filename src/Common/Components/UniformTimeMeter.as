import Shared.GlobalFunc;
import gfx.io.GameDelegate;

class Components.UniformTimeMeter extends Components.Meter
{
	var AnimClip: MovieClip;
	var AnimStart: String;
	var CurrentPercent: Number;
	var Empty: Number;
	var FinishSound: String;
	var FrameCount: Number;
	var FrameNumber: Number;
	var Full: Number;
	var TargetPercent: Number;
	var bFinished: Boolean;
	var meterMovieClip: MovieClip;

	function UniformTimeMeter(aMovieClip, aFinishSound: String, aClip: MovieClip, aAnimStart: String)
	{
		super(aMovieClip);
		this.FinishSound = aFinishSound;
		this.AnimClip = aClip;
		this.AnimStart = aAnimStart;
		this.FrameNumber = 48;
	}

	function SetTargetPercent(aPercent: Number): Void
	{
		super.SetTargetPercent(aPercent);
		this.bFinished = aPercent >= 100 && this.CurrentPercent < 100;
		this.FrameCount = 0;
	}

	function Update(): Void
	{
		if (this.FrameCount <= this.FrameNumber) {
			var iCurrentFrame: Number = GlobalFunc.Lerp(this.CurrentPercent, this.TargetPercent, 0, this.FrameNumber, this.FrameCount);
			var iActualFrame: Number = GlobalFunc.Lerp(this.Empty, this.Full, 0, 100, iCurrentFrame);
			this.meterMovieClip.gotoAndStop(iActualFrame);
			++this.FrameCount;
			if (this.FrameCount == this.FrameNumber && this.bFinished) {
				GameDelegate.call("PlaySound", [this.FinishSound]);
				if (this.AnimClip != undefined) 
					this.AnimClip.gotoAndPlay(this.AnimStart);
			}
		}
	}

}
