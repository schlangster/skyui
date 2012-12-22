class SkyUISplash extends MovieClip {
	#include "../version.as"

  /* STAGE ELEMENTS */

	public var versionText: TextField;

	public function SkyUISplash()
	{
	}

	// @override MovieClip
	private function onLoad(): Void
	{
		super.onLoad();

		versionText.text = ("v" + SKYUI_VERSION_STRING);
	}
}