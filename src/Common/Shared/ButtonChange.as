import gfx.events.EventDispatcher;

class Shared.ButtonChange extends gfx.events.EventDispatcher
{
	// Not sure why this is being duplicated from Shared.Platforms
	static var PLATFORM_PC: Number = 0;
	static var PLATFORM_PC_GAMEPAD: Number = 1;
	static var PLATFORM_360: Number = 2;
	static var PLATFORM_PS3: Number = 3;
  static var PLATFORM_VIVE: Number = 4;
  static var PLATFORM_MOVE: Number = 5;
  static var PLATFORM_OCULUS: Number = 6;
  static var PLATFORM_WINDOWS_MR: Number = 8;

	var iCurrPlatform: Number = Shared.ButtonChange.PLATFORM_360;
	var dispatchEvent: Function;

	function ButtonChange()
	{
		super();
		EventDispatcher.initialize(this);
	}

	function get Platform(): Number
	{
		return iCurrPlatform;
	}

	function IsGamepadConnected(): Boolean
	{
		return iCurrPlatform == Shared.ButtonChange.PLATFORM_PC_GAMEPAD || iCurrPlatform == Shared.ButtonChange.PLATFORM_360 || iCurrPlatform == Shared.ButtonChange.PLATFORM_PS3;
	}

	function SetPlatform(aSetPlatform: Number, aSetSwapPS3: Boolean): Void
	{
		iCurrPlatform = aSetPlatform;
		dispatchEvent({target: this, type: "platformChange", aPlatform: aSetPlatform, aSwapPS3: aSetSwapPS3});
	}

	function SetPS3Swap(aSwap: Boolean): Void
	{
		dispatchEvent({target: this, type: "SwapPS3Button", Boolean: aSwap});
	}

}
