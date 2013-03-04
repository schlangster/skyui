import Components.CrossPlatformButtons;
import Components.Meter;
import gfx.io.GameDelegate;

import skyui.components.ButtonPanel;
import skyui.defines.Input;

class JournalBottomBar extends MovieClip
{
	/*var Button1_mc: CrossPlatformButtons;
	var Button2_mc: CrossPlatformButtons;*/

	var ButtonRect: MovieClip;
	var DateText: TextField;
	var LevelMeter_mc: Meter;

	public var LevelMeterRect: MovieClip;
	public var buttonPanel: ButtonPanel;
	public var deleteButton: MovieClip;

	public function JournalBottomBar()
	{
		super();
	}

	public function InitBar(): Void
	{
		LevelMeter_mc = new Meter(LevelMeterRect.LevelProgressBar);
		GameDelegate.call("RequestPlayerInfo", [], this, "SetPlayerInfo");
	}

	public function SetPlayerInfo(): Void
	{
		DateText.SetText(arguments[0]);
		LevelMeterRect.LevelNumberLabel.textAutoSize = "shrink";
		LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
		LevelMeter_mc.SetPercent(arguments[2]);
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}

}
