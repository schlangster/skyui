dynamic class gfx.managers.InputDelegate extends gfx.events.EventDispatcher
{
	var dispatchEvent;
	var keyRepeatStateLookup;
	var keyRepeatSuppressLookup;

	function InputDelegate()
	{
		super();
		Key.addListener(this);
		this.keyRepeatSuppressLookup = {};
		this.keyRepeatStateLookup = {};
	}

	static function get instance()
	{
		if (gfx.managers.InputDelegate._instance == null) 
		{
			gfx.managers.InputDelegate._instance = new gfx.managers.InputDelegate();
		}
		return gfx.managers.InputDelegate._instance;
	}

	function setKeyRepeat(code, value, controllerIdx)
	{
		var __reg2 = this.getKeyRepeatSuppress(controllerIdx);
		__reg2[code] = !value;
	}

	function readInput(type, code, scope, callBack)
	{
		return null;
	}

	function inputToNav(type, code, value)
	{
		if (type == "key") 
		{
			if ((__reg0 = code) === 38) 
			{
				return gfx.ui.NavigationCode.UP;
			}
			else if (__reg0 === 40) 
			{
				return gfx.ui.NavigationCode.DOWN;
			}
			else if (__reg0 === 37) 
			{
				return gfx.ui.NavigationCode.LEFT;
			}
			else if (__reg0 === 39) 
			{
				return gfx.ui.NavigationCode.RIGHT;
			}
			else if (__reg0 === 13) 
			{
				return gfx.ui.NavigationCode.ENTER;
			}
			else if (__reg0 === 8) 
			{
				return gfx.ui.NavigationCode.BACK;
			}
			else if (__reg0 === 9) 
			{
				return Key.isDown(16) ? gfx.ui.NavigationCode.SHIFT_TAB : gfx.ui.NavigationCode.TAB;
			}
			else if (__reg0 === 36) 
			{
				return gfx.ui.NavigationCode.HOME;
			}
			else if (__reg0 === 35) 
			{
				return gfx.ui.NavigationCode.END;
			}
			else if (__reg0 === 34) 
			{
				return gfx.ui.NavigationCode.PAGE_DOWN;
			}
			else if (__reg0 === 33) 
			{
				return gfx.ui.NavigationCode.PAGE_UP;
			}
			else if (__reg0 === 27) 
			{
				return gfx.ui.NavigationCode.ESCAPE;
			}
			else if (__reg0 === 96) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_A;
			}
			else if (__reg0 === 97) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_B;
			}
			else if (__reg0 === 98) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_X;
			}
			else if (__reg0 === 99) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_Y;
			}
			else if (__reg0 === 100) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_L1;
			}
			else if (__reg0 === 101) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_L2;
			}
			else if (__reg0 === 102) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_L3;
			}
			else if (__reg0 === 103) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_R1;
			}
			else if (__reg0 === 104) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_R2;
			}
			else if (__reg0 === 105) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_R3;
			}
			else if (__reg0 === 106) 
			{
				return gfx.ui.NavigationCode.GAMEPAD_START;
			}
			else if (__reg0 !== 107) 
			{
				return;
			}
			return gfx.ui.NavigationCode.GAMEPAD_BACK;
		}
	}

	function onKeyDown(controllerIdx)
	{
		var __reg2 = Key.getCode(controllerIdx);
		var __reg4 = this.getKeyRepeatState(controllerIdx);
		if (__reg4[__reg2]) 
		{
			var __reg5 = this.getKeyRepeatSuppress(controllerIdx);
			if (!__reg5[__reg2]) 
			{
				this.handleKeyPress("keyHold", __reg2, controllerIdx);
			}
			return;
		}
		this.handleKeyPress("keyDown", __reg2, controllerIdx);
		__reg4[__reg2] = true;
	}

	function onKeyUp(controllerIdx)
	{
		var __reg2 = Key.getCode(controllerIdx);
		var __reg4 = this.getKeyRepeatState(controllerIdx);
		__reg4[__reg2] = false;
		this.handleKeyPress("keyUp", __reg2, controllerIdx);
	}

	function handleKeyPress(type, code, controllerIdx)
	{
		var __reg3 = new gfx.ui.InputDetails("key", code, type, this.inputToNav("key", code), controllerIdx);
		this.dispatchEvent({type: "input", details: __reg3});
	}

	function getKeyRepeatState(controllerIdx)
	{
		var __reg2 = this.keyRepeatStateLookup[controllerIdx];
		if (!__reg2) 
		{
			__reg2 = new Object();
			this.keyRepeatStateLookup[controllerIdx] = __reg2;
		}
		return __reg2;
	}

	function getKeyRepeatSuppress(controllerIdx)
	{
		var __reg2 = this.keyRepeatSuppressLookup[controllerIdx];
		if (!__reg2) 
		{
			__reg2 = new Object();
			this.keyRepeatSuppressLookup[controllerIdx] = __reg2;
		}
		return __reg2;
	}

}
