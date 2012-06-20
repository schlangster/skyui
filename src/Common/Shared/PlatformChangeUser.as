import Shared.ButtonChange;
import Shared.PlatformChangeUser.PlatformChange;

class Shared.PlatformChangeUser extends MovieClip
{
	static var PlatformChange: ButtonChange;
	
	function PlatformChangeUser()
	{
		super();
		PlatformChange = new ButtonChange();
	}

	function RegisterPlatformChangeListener(aCrossPlatformButton: Object): Void
	{
		PlatformChange.addEventListener("platformChange", aCrossPlatformButton, "SetPlatform");
		PlatformChange.addEventListener("SwapPS3Button", aCrossPlatformButton, "SetPS3Swap");
	}

}
