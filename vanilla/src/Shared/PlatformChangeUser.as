import Shared.PlatformChangeUser.PlatformChange;

class Shared.PlatformChangeUser extends MovieClip
{
    static var PlatformChange;
	
    function PlatformChangeUser()
    {
        super();
        PlatformChange = new Shared.ButtonChange();
    }
	
    function RegisterPlatformChangeListener(aCrossPlatformButton)
    {
        PlatformChange.addEventListener("platformChange", aCrossPlatformButton, "SetPlatform");
        PlatformChange.addEventListener("SwapPS3Button", aCrossPlatformButton, "SetPS3Swap");
    }
}
