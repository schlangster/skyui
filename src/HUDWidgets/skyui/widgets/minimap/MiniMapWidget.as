import gfx.io.GameDelegate;

import skyui.widgets.WidgetBase;
import skyui.util.GlobalFunctions;

class skyui.widgets.minimap.MiniMapWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */
	
	private var _initialized: Boolean = false;

	private var _enabled: Boolean = false;


  /* STAGE ELEMENTS */
	
	var playerMarker: MovieClip
	

  /* INITIALIZATION */
	
	public function MeterWidget()
	{
		super();
	}

	// @papyrus
	public function initNumbers(a_enabled: Boolean): Void
	{
		_enabled = a_enabled;
	}

	// @papyrus
	public function initCommit(): Void
	{
		installHooks();
		
		
		_initialized = true;
	}

	// @Papyrus
	public function setEnabled(a_enabled: Boolean): Void
	{
		_enabled = a_enabled;
	}

	// @papyrus
	public function setWidth(a_width: Number): Void
	{
		_width = a_width;
		invalidateSize();
	}

	// @papyrus
	public function setHeight(a_height: Number): Void
	{
		_height = a_height;
		invalidateSize();
	}

	// @papyrus
	public function setSize(a_width: Number, a_height: Number): Void
	{
		_width = a_width;
		_height = a_height;
		invalidateSize();
	}

  /* PRIVATE FUNCTIONS */

	private function installHooks(): Void
	{
		if (GlobalFunctions.hookFunction(_root.HUDMovieBaseInstance, "SetCompassAngle", this, "setAngle"))
			skyui.util.Debug.log("Hooked _root.HUDMovieBaseInstance.SetCompassAngle()");
		else
			skyui.util.Debug.log("Could not hook _root.HUDMovieBaseInstance.SetCompassAngle()");
	}

	private function setAngle(a_playerAngle: Number, a_compassAngle: Number, a_showCompass: Boolean)
	{
		if (!_enabled)
			return;

		playerMarker._rotation = a_playerAngle;
	}
}