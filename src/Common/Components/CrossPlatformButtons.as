import Shared.ButtonChange;

class Components.CrossPlatformButtons extends gfx.controls.Button
{
    var border: MovieClip;
	var ButtonArt: MovieClip;
	var ButtonArt_mc: MovieClip;
	var CurrentPlatform: Number;
	var PCButton: String;
	var PS3Button: String;
	var PS3Swapped: Boolean;
	var XBoxButton: String;

	function CrossPlatformButtons()
	{
		super();
	}

	function onLoad(): Void
	{
		super.onLoad();
		if (_parent.onButtonLoad != undefined)
			_parent.onButtonLoad(this);
	}

	function SetPlatform(aiPlatform: Number, aSwapPS3: Boolean): Void
	{
		if (aiPlatform != undefined) 
			CurrentPlatform = aiPlatform;
		if (aSwapPS3 != undefined) 
			PS3Swapped = aSwapPS3;
		RefreshArt();
	}

	function RefreshArt(): Void
	{
		if (undefined != ButtonArt) 
			ButtonArt.removeMovieClip();
		var iCurrentPlatform: Number = CurrentPlatform;
		if (iCurrentPlatform === ButtonChange.PLATFORM_PC) {
			if (PCButton != "None") 
				ButtonArt_mc = attachMovie(PCButton, "ButtonArt", getNextHighestDepth());
		} else if (iCurrentPlatform === ButtonChange.PLATFORM_PC_GAMEPAD) {
			ButtonArt_mc = attachMovie(XBoxButton, "ButtonArt", getNextHighestDepth());
		} else if (iCurrentPlatform === ButtonChange.PLATFORM_360) {
			ButtonArt_mc = attachMovie(XBoxButton, "ButtonArt", getNextHighestDepth());
		} else if (iCurrentPlatform === ButtonChange.PLATFORM_PS3) {
			var strPS3Button: String = PS3Button;
			if (PS3Swapped) {
				if (strPS3Button == "PS3_A") 
					strPS3Button = "PS3_B";
				else if (strPS3Button == "PS3_B") 
					strPS3Button = "PS3_A";
			}
			ButtonArt_mc = attachMovie(strPS3Button, "ButtonArt", getNextHighestDepth());
		}
		ButtonArt_mc._x = ButtonArt_mc._x - ButtonArt_mc._width;
		ButtonArt_mc._y = (_height - ButtonArt_mc._height) / 2;
		border._visible = false;
	}

	function GetArt(): Object
	{
		return {PCArt: PCButton, XBoxArt: XBoxButton, PS3Art: PS3Button};
	}

	function SetArt(aPlatformArt: Object): Void
	{
		PCArt = aPlatformArt.PCArt;
		XBoxArt = aPlatformArt.XBoxArt;
		PS3Art = aPlatformArt.PS3Art;
		RefreshArt();
	}

	function get XBoxArt(): String
	{
		return null;
	}

	function set XBoxArt(aValue: String): Void
	{
		if (aValue != "") 
			XBoxButton = aValue;
	}

	function get PS3Art(): String
	{
		return null;
	}

	function set PS3Art(aValue: String): Void
	{
		if (aValue != "") 
			PS3Button = aValue;
	}

	function get PCArt(): String
	{
		return null;
	}

	function set PCArt(aValue: String): Void
	{
		if (aValue != "") 
			PCButton = aValue;
	}

}
