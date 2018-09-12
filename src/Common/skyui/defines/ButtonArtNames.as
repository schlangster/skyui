
// Provides a mapping from keyname => keycode
// The keyCodes correspond directly to the animation/timeline frames in ButtonArt.
class skyui.defines.ButtonArtNames
{
	private static var _buttonNameMap = null;

	private static function nameMap(): Object
	{
		if(_buttonNameMap != null && _buttonNameMap != undefined) {
			return _buttonNameMap;
		}

		var nameMap = {
			esc:			1,
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

		insertAdditionalNames(nameMap);

		insertNamesStartingAtKeyCode(nameMap, 325, [
	  	// 325 - 329
			"360_Y", "360_X", "360_Start", "360_RS", "360_RB",

			// 330 - 339
			"360_R3", "360_LTRT", "360_LS", "360_LB", "360_LS", "360_Back", "360_B", "360_A", "MR MOTION", "MR MENU_RIGHT",

			// 340 - 349
			"MR MENU_LEFT", "MR MENU_HOLD", "ME MENU", "trigger_Right", "trigger_LR", "trigger_Left", "trigger_Hold", "trigger", "thumb_Right_Up", "thumb_Right_UD",

			// 350 - 359
			"thumb_Right_Right", "thumb_Right_Press", "thumb_Right_LR", "thumb_Right_Left", "thumb_Right_Down",
			"thumb_Right_Any", "thumb_Left_Up", "thumb_Left_UD", "thumb_Left_Right", "thumb_Left_Press",

			// 360 - 369
			"thumb_Left_LR", "thumb_Left_Left", "thumb_Left_Down", "thumb_Left_Any", "radial_Right_Up",
			"radial_Right_UD", "radial_Right_Right", "radial_Right_NoCenter", "radial_Right_LR", "radial_Right_Left",

			// 370 - 379
			"radial_Right_Down", "radial_Right_Center", "radial_Right_Any", "radial_Left_Up", "radial_Left_UD",
			"radial_Left_Right", "radial_Left_NoCenter", "radial_Left_LR", "radial_Left_Left", "radial_Left_Down",

			// 380 - 389
			"radial_Left_Center", "radial_Left_Any", "radial_Either_UpDown", "radial_Either_Up", "radial_Either_NoCenter_Hold",
			"radial_Either_NoCenter", "radial_Either_LeftRight", "radial_Either_Down", "radial_Either_Center", "radial_Either_Any_Hold",

			// 390 - 399
			"radial_Either_Any", "grip_Right", "grip_Left", "grip_Hold", "grip",
			"grab_Right", "grab_Left", "grab_Hold", "grab", "VIVE MOTION",

			// 400 - 409
			"VIVE MENU_RIGHT", "VIVE MENU_LEFT", "VIVE MENU_HOLD", "VIVE MENU", "PS3_Y_RIGHT",
			"PS3_Y_LEFT", "PS3_XY_RIGHT", "PS3_XY_LEFT", "PS3_XY", "PS3_X_RIGHT",

			// 410 - 419
			"PS3_X_LEFT", "PS3_Back", "PS3_TELEPORT", "PS3_START", "PS3_Select",
			"PS3_RS", "PS3_RB", "PS3_R3", "PS3_P_SWING_RIGHT", "PS3_P_SWING_LEFT",

			// 420 - 429
			"PS3_P_SWING", "PS3_OPTIONS", "PS3_NAV_UD_RIGHT", "PS3_NAV_UD_LEFT", "PS3_NAV_UD",
			"PS3_NAV_RIGHT", "PS3_NAV_LR_RIGHT", "PS3_NAV_LR_LEFT", "PS3_NAV_LR", "PS3_NAV_LEFT",

			// 430 - 439
			"PS3_NAV", "PS3_Move_Select_RIGHT", "PS3_Move_Select_LEFT", "PS3_Move_Select", "PS3_Move_RIGHT",
			"PS3_Move_LEFT", "PS3_Move", "PS3_MOTION_RIGHT", "PS3_MOTION_LEFT", "PS3_MOTION",

			// 440 - 449
			"PS3_LTRT", "PS3_LS", "PS3_LBRB", "PS3_LB", "PS3_L3",
			"PS3_CON_RIGHT", "PS3_CON_LEFT", "PS3_B_RIGHT", "PS3_B_LEFT", "PS3_B",

			// 450 - 455
			"PS3_AB_RIGHT", "PS3_AB_LEFT", "PS3_AB", "PS3_A_RIGHT", "PS3_A_LEFT", "PS3_A"
		]);
	}

	public static function lookup(keyName: String): Number
	{
		var nameMap = nameMap();
		return nameMap[keyName.toLowerCase()];
	}


	private static function insertAdditionalNames(nameMap: Object): Void
	{
		// These Button names can't be set in the object constructor since they're 'invalid' names
		nameMap["1"]			= 2;
		nameMap["2"]			= 3;
		nameMap["3"]			= 4;
		nameMap["4"]			= 5;
		nameMap["5"]			= 6;
		nameMap["6"]			= 7;
		nameMap["7"]			= 8;
		nameMap["8"]			= 9;
		nameMap["9"]			= 10;
		nameMap["0"]			= 11;
		nameMap["l-ctrl"]	= 29;
		nameMap["l-shift"]	= 42;
		nameMap["r-shift"]	= 54;
		nameMap["l-alt"]		= 56;
		nameMap["r-ctrl"]	= 157;
		nameMap["r-alt"]		= 184;
		nameMap["delete"]	= 211;
		nameMap["360_start"]	= 270;
		nameMap["360_back"]	= 271;
		nameMap["360_l3"]	= 272;
		nameMap["360_r3"]	= 273;
		nameMap["360_lb"]	= 274;
		nameMap["360_rb"]	= 275;
		nameMap["360_a"]		= 276;
		nameMap["360_b"]		= 277;
		nameMap["360_x"]		= 278;
		nameMap["360_y"]		= 279;
		nameMap["360_lt"]	= 280;
		nameMap["360_rt"]	= 281;
	}

	private static function insertNamesStartingAtKeyCode(nameMap: Object, startKeyCode: Number, namesArr: Array): Void
	{
		for(var i = 0; i < namesArr.length; i++) {
			nameMap[ namesArr[i].toLowerCase() ] = i + startKeyCode;
		}
	}
}
