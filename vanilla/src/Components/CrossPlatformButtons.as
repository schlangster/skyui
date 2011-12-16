class Components.CrossPlatformButtons extends gfx.controls.Button
{
	var CurrentPlatform;
	var PS3Swapped;
	var ButtonArt;
	var PCButton;
	var getNextHighestDepth;
	var ButtonArt_mc;
	var XBoxButton;
	var PS3Button;
	var border;
	
	function CrossPlatformButtons()
	{
		super();
	}
	
	function onLoad()
	{
		super.onLoad();
		if (_parent.onButtonLoad != undefined)
		{
			_parent.onButtonLoad(this);
		}
	}
	
	function SetPlatform(aiPlatform, aSwapPS3)
	{
		if (aiPlatform != undefined)
		{
			CurrentPlatform = aiPlatform;
		}
		if (aSwapPS3 != undefined)
		{
			PS3Swapped = aSwapPS3;
		}
		RefreshArt();
	}
	
	function RefreshArt()
	{
		if (ButtonArt != undefined)
		{
			ButtonArt.removeMovieClip();
		}
		
		switch (CurrentPlatform)
		{
			case Shared.ButtonChange.PLATFORM_PC:
			{
				if (PCButton != "None")
				{
					ButtonArt_mc = this.attachMovie(PCButton, "ButtonArt", this.getNextHighestDepth());
				}
				break;
			} 
			case Shared.ButtonChange.PLATFORM_PC_GAMEPAD:
			case Shared.ButtonChange.PLATFORM_360:
			{
				ButtonArt_mc = this.attachMovie(XBoxButton, "ButtonArt", this.getNextHighestDepth());
				break;
			} 
			case Shared.ButtonChange.PLATFORM_PS3:
			{
				var _loc2 = PS3Button;
				if (PS3Swapped)
				{
					if (_loc2 == "PS3_A")
					{
						_loc2 = "PS3_B";
					}
					else if (_loc2 == "PS3_B")
					{
						_loc2 = "PS3_A";
					}
				}
				ButtonArt_mc = this.attachMovie(_loc2, "ButtonArt", this.getNextHighestDepth());
				break;
			} 
		}
		ButtonArt_mc._x = ButtonArt_mc._x - ButtonArt_mc._width;
		ButtonArt_mc._y = (_height - ButtonArt_mc._height) / 2;
		border._visible = false;
	}
	
	function GetArt()
	{
		return ({PCArt: PCButton, XBoxArt: XBoxButton, PS3Art: PS3Button});
	}
	
	function SetArt(aPlatformArt)
	{
		this.PCArt = aPlatformArt.PCArt;
		this.XBoxArt = aPlatformArt.XBoxArt;
		this.PS3Art = aPlatformArt.PS3Art;
		this.RefreshArt();
	}
	function get XBoxArt()
	{
		return null;
	}
	
	function set XBoxArt(aValue)
	{
		if (aValue != "")
		{
			XBoxButton = aValue;
		}
	}
	function get PS3Art()
	{
		return null;
	}
	
	function set PS3Art(aValue)
	{
		if (aValue != "")
		{
			PS3Button = aValue;
		}
	}
	
	function get PCArt()
	{
		return null;
	}
	
	function set PCArt(aValue)
	{
		if (aValue != "")
		{
			PCButton = aValue;
		}
	}
}
