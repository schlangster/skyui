import Components.CrossPlatformButtons;
import Components.Meter;
import gfx.io.GameDelegate;

class JournalBottomBar extends MovieClip
{
	var Button1_mc: CrossPlatformButtons;
	var Button2_mc: CrossPlatformButtons;
	var ButtonRect: MovieClip;
	var DateText: TextField;
	var LevelMeterRect: MovieClip;
	var LevelMeter_mc: Meter;

	function JournalBottomBar()
	{
		super();
		Button1_mc = ButtonRect.Button1;
		Button2_mc = ButtonRect.Button2;
	}

	function InitBar(): Void
	{
		LevelMeter_mc = new Meter(LevelMeterRect.LevelProgressBar);
		GameDelegate.call("RequestPlayerInfo", [], this, "SetPlayerInfo");
	}

	function SetPlayerInfo(): Void
	{
		DateText.SetText(arguments[0]);
		LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
		LevelMeter_mc.SetPercent(arguments[2]);
	}

	function SetMode(aiTab: Number): Void
	{
		LevelMeterRect._visible = aiTab == 1 || aiTab == 2;
		Button1_mc._visible = Button2_mc._visible = aiTab == 0;
		if (aiTab === 0) {
			Button1_mc.label = "$Toggle Active";
			Button1_mc.SetArt({PCArt: "Enter", XBoxArt: "360_A", PS3Art: "PS3_A"});
			Button2_mc.label = "$Show on Map";
			Button2_mc.SetArt({PCArt: "M", XBoxArt: "360_X", PS3Art: "PS3_X"});
			PositionButtons();
			return;
		} else if (aiTab !== 2) {
			return;
		}
		Button1_mc.label = "$Delete";
		Button1_mc.SetArt({PCArt: "X", XBoxArt: "360_X", PS3Art: "PS3_X"});
		PositionButtons();
		return;
	}

	function PositionButtons(): Void
	{
		var ixOffset: Number = 20;
		Button1_mc._x = Button1_mc.ButtonArt._width;
		Button2_mc._x = Button1_mc._x + Button1_mc.textField.getLineMetrics(0).width + ixOffset + Button2_mc.ButtonArt._width;
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		Button1_mc.SetPlatform(aiPlatform, abPS3Switch);
		Button2_mc.SetPlatform(aiPlatform, abPS3Switch);
	}

	function SetButtonVisibility(aiButtonIndex: Number, abVisible: Boolean, afAlpha: Number): Void
	{
		if (abVisible != undefined) {
			ButtonRect["Button" + aiButtonIndex]._visible = abVisible;
		}
		if (afAlpha != undefined) {
			ButtonRect["Button" + aiButtonIndex]._alpha = afAlpha;
		}
	}

	function IsButtonVisible(aiButtonIndex: Number): Boolean
	{
		return ButtonRect["Button" + aiButtonIndex]._visible == true && ButtonRect["Button" + aiButtonIndex]._alpha == 100;
	}

	function SetButtonInfo(aiButtonIndex: Number, astrText: String, aArtInfo: Array): Void
	{
		ButtonRect["Button" + aiButtonIndex].label = astrText;
		ButtonRect["Button" + aiButtonIndex].SetArt(aArtInfo);
		PositionButtons();
	}

}
