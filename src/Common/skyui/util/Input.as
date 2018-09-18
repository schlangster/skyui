import skyui.util.Debug;

class skyui.util.Input
{
	//----------------------------------------------------------------------
	// Utility functions
	//
	// This is for picking the right ButtonArt given a map and a platform enum.
	// It expect the same format the vanilla game uses to specify keys.
	// This makes it relatively straighforward to port changes over.
	//
	//---------------------------------------------------------------------
	static function pickButtonArt(a_platform: Number, buttonNames: Object): String
	{
		switch(a_platform) {

   		case Shared.Platforms.CONTROLLER_PC:
   			return buttonNames["PCArt"];

   		case Shared.Platforms.CONTROLLER_PCGAMEPAD:
   		case Shared.Platforms.CONTROLLER_DURANGO:
   		case Shared.Platforms.CONTROLLER_ORBIS:
   			return buttonNames["XBoxArt"];

   		case Shared.Platforms.CONTROLLER_VIVE:
   		case Shared.Platforms.CONTROLLER_VIVE_KNUCKLES:
   			return buttonNames["ViveArt"];

   		case Shared.Platforms.CONTROLLER_ORBIS_MOVE:
   			return buttonNames["MoveArt"];

   		case Shared.Platforms.CONTROLLER_OCULUS:
   			return buttonNames["OculusArt"];

   		case Shared.Platforms.CONTROLLER_WINDOWS_MR:
   			return buttonNames["WindowsMRArt"];

   		default:
   			return buttonNames["XBoxArt"];
		}
	}

	static function pickControls(a_platform: Number, buttonNames: Object): Object
	{
		var val = {namedKey: pickButtonArt(a_platform, buttonNames)};
		return val;
	}

	// Helper function to perform rate limiting
	static function rateLimit(a_obj: Object, a_fieldname: String, delayTime: Number)
	{
		a_obj[a_fieldname] = true;
		setTimeout(function() {
				a_obj[a_fieldname] = false;
				},
				delayTime);
	}
}
