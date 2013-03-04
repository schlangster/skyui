import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import skyui.defines.Input;
import skyui.util.GlobalFunctions;


class gfx.managers.InputDelegate extends EventDispatcher
{
  /* SINGLETON */
	
	private static var _instance: InputDelegate;
	
	public static function get instance(): InputDelegate
	{
		if (_instance == null) 
			_instance = new InputDelegate();
			
		return _instance;
	}
	
	
  /* PRIVATE VARIABLES */
	
	private var _keyRepeatStateLookup: Object;
	private var _keyRepeatSuppressLookup: Object;
	
	private var _bEnableControlFixup: Boolean = false;
	private var _acceptKeycode: Number = -1;
	
	
  /* PROPERTIES */
  
  	public var isGamepad: Boolean = false;


  /* INITIALIZATION */

	public function InputDelegate()
	{
		super();
		
		Key.addListener(this);
		_keyRepeatSuppressLookup = {};
		_keyRepeatStateLookup = {};
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	// Certain menus wont receive navEquiv's, i.e. ENTER for activate in MapMenu
	// Has to be disabled manually for skse.AllowTextInput
	public function enableControlFixup(a_bEnabled: Boolean): Void
	{
		if (a_bEnabled)
			_acceptKeycode = GlobalFunctions.getMappedKey("Accept", Input.CONTEXT_MENUMODE, isGamepad);
			
		_bEnableControlFixup = a_bEnabled;
	}

	public function setKeyRepeat(a_code: Number, a_value, a_controllerIdx: Number): Void
	{
		var suppressState = this.getKeyRepeatSuppress(a_controllerIdx);
		suppressState[a_code] = !a_value;
	}

	public function readInput(type, code, scope, callBack)
	{
		return null;
	}

	public function onKeyDown(a_controllerIdx: Number): Void
	{
		var code = Key.getCode(a_controllerIdx);
		var repeatState = getKeyRepeatState(a_controllerIdx);
		
		if (!repeatState[code]) {
			handleKeyPress("keyDown", code, a_controllerIdx, skse.GetLastControl(true), skse.GetLastKeycode(true));
			repeatState[code] = true;
			
		} else {
			var suppressState = getKeyRepeatSuppress(a_controllerIdx);
			if (!suppressState[code])
				handleKeyPress("keyHold", code, a_controllerIdx, skse.GetLastControl(true), skse.GetLastKeycode(true));
		}
	}

	public function onKeyUp(a_controllerIdx: Number): Void
	{
		var code = Key.getCode(a_controllerIdx);
		var repeatState = getKeyRepeatState(a_controllerIdx);
		repeatState[code] = false;
		
		handleKeyPress("keyUp", code, a_controllerIdx, skse.GetLastControl(false), skse.GetLastKeycode(false));
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function handleKeyPress(a_type: String, a_code: Number, a_controllerIdx: Number, a_control: String, a_skseKeycode: Number): Void
	{
		var navEquivalent: String = inputToNav(a_code);

		if (navEquivalent != null) {
			switch (navEquivalent) {
				case NavigationCode.UP:
				case NavigationCode.DOWN:
				case NavigationCode.LEFT:
				case NavigationCode.RIGHT:
					a_control = null;
					a_skseKeycode = null;
					break;
			}
		
		// For != null, attempt fixup?
		} else if (_bEnableControlFixup) {
			if (a_skseKeycode == _acceptKeycode) {
				navEquivalent = NavigationCode.ENTER;
			}
		}

		var details = new InputDetails("key", a_code, a_type, navEquivalent, a_controllerIdx, a_control, a_skseKeycode);
		dispatchEvent({type: "input", details: details});
	}

	private function getKeyRepeatState(a_controllerIdx: Number): Object
	{
		var obj = this._keyRepeatStateLookup[a_controllerIdx];
		if (!obj) {
			obj = new Object();
			_keyRepeatStateLookup[a_controllerIdx] = obj;
		}
		return obj;
	}

	private function getKeyRepeatSuppress(a_controllerIdx: Number): Object
	{
		var obj = _keyRepeatSuppressLookup[a_controllerIdx];
		if (!obj) {
			obj = new Object();
			_keyRepeatSuppressLookup[a_controllerIdx] = obj;
		}
		return obj;
	}
	
	private function inputToNav(a_code: Number): String
	{
		switch (a_code)
		{
			case 38:	return NavigationCode.UP;
			case 40:	return NavigationCode.DOWN;
			case 37:	return NavigationCode.LEFT;
			case 39:	return NavigationCode.RIGHT;
			case 13:	return NavigationCode.ENTER;
			case 8:		return NavigationCode.BACK;
			case 9:		return Key.isDown(16) ? NavigationCode.SHIFT_TAB : NavigationCode.TAB;
			case 36:	return NavigationCode.HOME;
			case 35:	return NavigationCode.END;
			case 34:	return NavigationCode.PAGE_DOWN;
			case 33:	return NavigationCode.PAGE_UP;
			case 27:	return NavigationCode.ESCAPE;


// TODO: should ignore these if platform != 0
			case 96:	return NavigationCode.GAMEPAD_A;
			case 97:	return NavigationCode.GAMEPAD_B;
			case 98:	return NavigationCode.GAMEPAD_X;
			case 99:	return NavigationCode.GAMEPAD_Y;
			case 100:	return NavigationCode.GAMEPAD_L1;
			case 101:	return NavigationCode.GAMEPAD_L2;
			case 102:	return NavigationCode.GAMEPAD_L3;
			case 103:	return NavigationCode.GAMEPAD_R1;
			case 104:	return NavigationCode.GAMEPAD_R2;
			case 105:	return NavigationCode.GAMEPAD_R3;
			case 106:	return NavigationCode.GAMEPAD_START;
			case 107:	return NavigationCode.GAMEPAD_BACK;
		}
		
		return null;
	}
}
