dynamic class JournalBottomBar extends MovieClip
{
	var Button1_mc: Components.CrossPlatformButtons;
	var Button2_mc: Components.CrossPlatformButtons;
	var ButtonRect;
	var DateText;
	var LevelMeterRect;
	var LevelMeter_mc;

	function JournalBottomBar()
	{
		super();
		this.Button1_mc = this.ButtonRect.Button1;
		this.Button2_mc = this.ButtonRect.Button2;
	}

	function InitBar()
	{
		this.LevelMeter_mc = new Components.Meter(this.LevelMeterRect.LevelProgressBar);
		gfx.io.GameDelegate.call("RequestPlayerInfo", [], this, "SetPlayerInfo");
	}

	function SetPlayerInfo()
	{
		this.DateText.SetText(arguments[0]);
		this.LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
		this.LevelMeter_mc.SetPercent(arguments[2]);
	}

	function SetMode(aiTab)
	{
		this.LevelMeterRect._visible = aiTab == 1 || aiTab == 2;
		this.Button1_mc._visible = this.Button2_mc._visible = aiTab == 0;
		if ((__reg0 = aiTab) === 0) 
		{
			this.Button1_mc.label = "$Toggle Active";
			this.Button1_mc.SetArt({PCArt: "Enter", XBoxArt: "360_A", PS3Art: "PS3_A"});
			this.Button2_mc.label = "$Show on Map";
			this.Button2_mc.SetArt({PCArt: "M", XBoxArt: "360_X", PS3Art: "PS3_X"});
			this.PositionButtons();
			return;
		}
		else if (__reg0 !== 2) 
		{
			return;
		}
		this.Button1_mc.label = "$Delete";
		this.Button1_mc.SetArt({PCArt: "X", XBoxArt: "360_X", PS3Art: "PS3_X"});
		this.PositionButtons();
		return;
	}

	function PositionButtons()
	{
		var __reg2 = 20;
		this.Button1_mc._x = this.Button1_mc.ButtonArt._width;
		this.Button2_mc._x = this.Button1_mc._x + this.Button1_mc.textField.getLineMetrics(0).width + __reg2 + this.Button2_mc.ButtonArt._width;
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		this.Button1_mc.SetPlatform(aiPlatform, abPS3Switch);
		this.Button2_mc.SetPlatform(aiPlatform, abPS3Switch);
	}

	function SetButtonVisibility(aiButtonIndex, abVisible, afAlpha)
	{
		if (abVisible != undefined) 
		{
			this.ButtonRect["Button" + aiButtonIndex]._visible = abVisible;
		}
		if (afAlpha != undefined) 
		{
			this.ButtonRect["Button" + aiButtonIndex]._alpha = afAlpha;
		}
	}

	function IsButtonVisible(aiButtonIndex)
	{
		return this.ButtonRect["Button" + aiButtonIndex]._visible == true && this.ButtonRect["Button" + aiButtonIndex]._alpha == 100;
	}

	function SetButtonInfo(aiButtonIndex, astrText, aArtInfo)
	{
		this.ButtonRect["Button" + aiButtonIndex].label = astrText;
		this.ButtonRect["Button" + aiButtonIndex].SetArt(aArtInfo);
		this.PositionButtons();
	}

}
