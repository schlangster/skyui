import skyui.util.GlobalFunctions;

class WidgetLoader extends MovieClip
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */
  
	private var _widgetPath: String = "widgets/";

	private var _widgetContainer: MovieClip;
	
	private var _mcLoader: MovieClipLoader;
	

  /* INITIALIZATION */
	
	public function WidgetLoader()
	{
		_mcLoader = new MovieClipLoader();
		_mcLoader.addListener(this);
		
		GlobalFunctions.addArrayFunctions();	
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function onLoad(): Void
	{
		// Dispatch event with initial hudMode
		var currentHudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		skse.SendModEvent("SKIWF_hudModeChanged", currentHudMode);

		// Create dummy movieclip which dispatches events when hudMode is changed
		_hudModeDispatcher = new MovieClip();
		_hudModeDispatcher.onModeChange = function (a_hudMode: String): Void
		{
			skse.SendModEvent("SKIWF_hudModeChanged", a_hudMode);
		}
		_root.HUDMovieBaseInstance.HudElements.push(_hudModeDispatcher);
	}
	
	public function onLoadInit(a_widgetHolder: MovieClip): Void
	{
		if (a_widgetHolder.widget == undefined) {
			// Widgets need to have main MovieClip on the root with an instance name of "widget" (i.e. _root.widget for the widget swf)
			skse.SendModEvent("SKIWF_widgetError", "WidgetInitFailure", Number(a_widgetHolder._name));
			return;
		}
		
		a_widgetHolder.onModeChange = function (a_hudMode: String): Void
		{
			var widgetHolder: MovieClip = this;
			if (widgetHolder.widget.onModeChange != undefined)
				widgetHolder.widget.onModeChange(a_hudMode);
		}
		
		skse.SendModEvent("SKIWF_widgetLoaded", a_widgetHolder._name);
	}
	
	public function onLoadError(a_widgetHolder:MovieClip, a_errorCode: String): Void
	{
		skse.SendModEvent("SKIWF_widgetError", "WidgetLoadFailure", Number(a_widgetHolder._name));
	}
	
	public function setWidgetPath(a_path: String): Void
	{
		skse.Log("WidgetLoader.as: setWidgetPath(a_path = " + a_path + ")");
		_widgetPath = a_path;
	}
	
	public function loadWidgets(/* widgetSources (128) */): Void
	{
		if (_widgetContainer != undefined) {
			for(var s: String in _widgetContainer) {
				if (_widgetContainer[s] instanceof MovieClip) {
					_mcLoader.unloadClip(_widgetContainer[s]);
					if (_root.HUDMovieBaseInstance.HudElements.hasOwnProperty(s))
						delete(_root.HUDMovieBaseInstance.HudElements[s]); 
				}
			}
		}
		
		for (var i: Number = 0; i < arguments.length; i++)
			if (arguments[i] != undefined && arguments[i] != "")
				loadWidget(String(i), arguments[i]);
	}

	public function loadWidget(a_widgetID: String, a_widgetSource: String): Void
	{
		skse.Log("WidgetLoader.as: loadWidget(a_widgetID = " + a_widgetID + ", a_widgetSource = " + a_widgetSource + ")");
		if (_widgetContainer == undefined)
			createWidgetContainer();
		
		var widgetHolder: MovieClip = _widgetContainer.createEmptyMovieClip(a_widgetID, _widgetContainer.getNextHighestDepth());
		_mcLoader.loadClip(_widgetPath + a_widgetSource, widgetHolder);
	}
	 
	 
  /* PRIVATE FUNCTIONS */
  
	private function createWidgetContainer(): Void
	{
		// -16384 places the WidgetContainer beneath all elements which were added to the stage in Flash.
		_widgetContainer = _root.createEmptyMovieClip("WidgetContainer", -16384);
		
		// Locks _widgetContainer to the safe top left of the Stage, for all child elements {_x = 0, _y = 0} is the top left of the stage
		_widgetContainer.Lock("TL");
	}
}