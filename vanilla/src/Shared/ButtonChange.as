class Shared.ButtonChange extends gfx.events.EventDispatcher
{
    //var dispatchEvent;
	//var __get__Platform;
	
	static var PLATFORM_PC:Number = 0;
    static var PLATFORM_PC_GAMEPAD:Number = 1;
    static var PLATFORM_360:Number = 2;
    static var PLATFORM_PS3:Number = 3;
	
    var iCurrPlatform:Number = Shared.ButtonChange.PLATFORM_360;
	
    function ButtonChange()
    {
        super();
        gfx.events.EventDispatcher.initialize(this);
    }
	
    function get Platform()
    {
        return iCurrPlatform;
    }
    function IsGamepadConnected()
    {
        return (iCurrPlatform == Shared.ButtonChange.PLATFORM_PC_GAMEPAD || iCurrPlatform == Shared.ButtonChange.PLATFORM_360 || iCurrPlatform == Shared.ButtonChange.PLATFORM_PS3);
    }
	
    function SetPlatform(aSetPlatform, aSetSwapPS3)
    {
        iCurrPlatform = aSetPlatform;
        dispatchEvent({target: this, type: "platformChange", aPlatform: aSetPlatform, aSwapPS3: aSetSwapPS3});
    }
	
    function SetPS3Swap(aSwap)
    {
        dispatchEvent({target: this, type: "SwapPS3Button", Boolean: aSwap});
    }
}
