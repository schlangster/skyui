import Shared.GlobalFunc;

class SkyUISplash extends MovieClip {
	#include "../version.as"

  /* STAGE ELEMENTS */

	public var versionText: TextField;

	public function SkyUISplash()
	{
		GlobalFunc.MaintainTextFormat();
	}

	// @override MovieClip
	private function onLoad(): Void
	{
		super.onLoad();

		versionText.SetText("v" + SKYUI_VERSION_STRING);
	}
}