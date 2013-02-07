import Shared.GlobalFunc;

class InputMappingArt extends MovieClip
{
  /* PRIVATE VARIABLES */

	private var _keyCodes: Array;


	
	
	private var _buttonNameMap: Object = {esc:			1,
									//1:				2,
									//2:				3,
									//3:				4,
									//4:				5,
									//5:				6,
									//6:				7,
									//7:				8,
									//8:				9,
									//9:				10,
									//0:				11,
										hyphen:			12,
										equal:			13,
										backspace:		14,
										tab:			15,
										q:				16,
										w:				17,
										e:				18,
										r:				19,
										t:				20,
										y:				21,
										u: 				22,
										i:				23,
										o:				24,
										p:				25,
										bracketleft:	26,
										bracketright:	27,
										enter:			28,
									//l-ctrl:			29,
										a:				30,
										s:				31,
										d:				32,
										f:				33,
										g:				34,
										h:				35,
										j:				36,
										k:				37,
										l:				38,
										semicolon:		39,
										quotesingle: 	40,
										tilde:			41,
									//l-shift:			42,
										backslash:		43,
										z:				44,
										x:				45,
										c:				46,
										v:				47,
										b:				48,
										n:				49,
										m: 				50,
										comma:			51,
										period:			52,
										slash:			53,
									//r-shift:			54,
										numpadmult:		55,
									//l-alt:			56,
										space:			57,
										capslock:		58,
										f1:				59,
										f2:				60,
										f3:				61,
										f4:				62,
										f5:				63,
										f6:				64,
										f7:				65,
										f8:				66,
										f9:				67,
										f10:			68,
										numlock:		69,
										scrolllock:		70,
										numpad7:		71,
										numpad8:		72,
										numpad9:		73,
										numpadminus:	74,
										numpad4:		75,
										numpad5:		76,
										numpad6:		77,
										numpadplus:		78,
										numpad1:		79,
										numpad2:		80,
										numpad3:		81,
										numpad0:		82,
										numpaddec:		83,
										f11:			87,
										f12:			88,
										numpadenter:	156,
									//r-ctrl:			157,
										numpaddivide:	158,
										printsrc:		183,
									//r-alt:			184,
										pause:			197,
										home:			199,
										up:				200,
										pgup:			201,
										left:			203,
										right:			205,
										end:			207,
										down:			208,
										pgdn:			209,
										insert:			210,
									//delete:			211,
										// Mouse
										mouse1:			256,
										mouse2:			257,
										mouse3:			258,
										mouse4:			259,
										mouse5:			260,
										mouse6:			261,
										mouse7:			262,
										mouse8:			263,
										mousewheelup:	264,
										mousewheeldown:	265,
										// Controller
									//360_start:		270,
									//360_back:			271,
									//360_l3:			272,
									//360_r3:			273,
									//360_lb:			274,
									//360_rb:			275,
									//360_a:			276,
									//360_b:			277,
									//360_x:			278,
									//360_y:			279,
									//360_lt:			280,
									//360_rt:			281,
										// PS3 buttons = 360 buttons
										ps3_start:		270,
										ps3_back:		271,
										ps3_l3:			272,
										ps3_r3:			273,
										ps3_lb:			274,
										ps3_rb:			275,
										ps3_a:			276,
										ps3_b:			277,
										ps3_x:			278,
										ps3_y:			279,
										ps3_lt:			280,
										ps3_rt:			281
										};

	
  /* STAGE ELEMENTS */
	
	public var background: MovieClip;
	public var textField: TextField;
	
	
  /* PROPERTIES */
  
  	public function set hiddenBackground(a_flag: Boolean)
	{
		background._visible = !a_flag;
	}
	
	public function get hiddenBackground(): Boolean
	{
		return background._visible;
	}
	
	public function get width(): Number
	{
		return background._width;
	}
	
	public function set width(a_value: Number)
	{
		background._width = a_value;
	}
  
  	public var buttonArt: Array;


  /* INITIALIZATION */

	function MappedButton()
	{
		super();

		GlobalFunc.MaintainTextFormat();
	}

	public function onLoad(): Void
	{
		buttonArt = [];
		_keyCodes = [];

		textField.textAutoSize = "shrink";
		
		textField._visible = false;
		background._visible = false;

		for (var i=0; this["buttonArt" + i] != undefined; i++) {
			this["buttonArt" + i]._visible = false;
			buttonArt.push(this["buttonArt" + i]);
		}

		// These Button names can't be set in the object constructor since they're 'invalid' names
		_buttonNameMap["1"]			= 2;
		_buttonNameMap["2"]			= 3;
		_buttonNameMap["3"]			= 4;
		_buttonNameMap["4"]			= 5;
		_buttonNameMap["5"]			= 6;
		_buttonNameMap["6"]			= 7;
		_buttonNameMap["7"]			= 8;
		_buttonNameMap["8"]			= 9;
		_buttonNameMap["9"]			= 10;
		_buttonNameMap["0"]			= 11;
		_buttonNameMap["l-ctrl"]	= 29;
		_buttonNameMap["l-shift"]	= 42;
		_buttonNameMap["r-shift"]	= 54;
		_buttonNameMap["l-alt"]		= 56;
		_buttonNameMap["r-ctrl"]	= 157;
		_buttonNameMap["r-alt"]		= 184;
		_buttonNameMap["delete"]	= 211;
		_buttonNameMap["360_start"]	= 270;
		_buttonNameMap["360_back"]	= 271;
		_buttonNameMap["360_l3"]	= 272;
		_buttonNameMap["360_r3"]	= 273;
		_buttonNameMap["360_lb"]	= 274;
		_buttonNameMap["360_rb"]	= 275;
		_buttonNameMap["360_a"]		= 276;
		_buttonNameMap["360_b"]		= 277;
		_buttonNameMap["360_x"]		= 278;
		_buttonNameMap["360_y"]		= 279;
		_buttonNameMap["360_lt"]	= 280;
		_buttonNameMap["360_rt"]	= 281;
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function setButtonName(a_buttonName: String): Void
	{
		textField._visible = false;

		var keyCodes = _buttonNameMap[a_buttonName.toLowerCase()];

		if (keyCodes instanceof Array)
			_keyCodes = keyCodes;
		else
			_keyCodes = [keyCodes];


		if (_keyCodes[0] == null) {
			for (var i: Number = 0; i < buttonArt.length; i++)
				buttonArt[i]._visible = false;
			textField.SetText(a_buttonName);
			textField._width = textField.getLineMetrics(0).width;
			textField._visible = true;
			background._width = textField._width;
			return;
		}


		var xOffset: Number = 0;
		for (var i: Number = 0; i < buttonArt.length; i++) {
			var icon: MovieClip = buttonArt[i];
			
			if (_keyCodes[i] > 0) {
				icon._visible = true;			
				icon.gotoAndStop(_keyCodes[i]);
				icon._x = xOffset;
				icon._y = 0; //(0 - icon._height) / 2; // Center it
				xOffset += icon._width;
			} else {
				icon._visible = false;
			}
		}
		
		background._width = xOffset;
	}
}
