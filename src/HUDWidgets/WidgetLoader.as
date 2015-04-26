import skyui.util.GlobalFunctions;

class WidgetLoader extends MovieClip
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */
  
	private var _rootPath: String = "";

	private var _widgetContainer: MovieClip;
	
	private var _mcLoader: MovieClipLoader;

	private var _hudMetrics: Object

	private var _hudModeDispatcher: MovieClip;
	

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
		var hudMinXY: Object = {x: Stage.safeRect.x, y: Stage.safeRect.y};
		var hudMaxXY: Object = {x: Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.height - Stage.safeRect.y};
		_root.globalToLocal(hudMinXY);
		_root.globalToLocal(hudMaxXY);

		_hudMetrics = {hMin: hudMinXY.x,
						//hCenter: (hudMaxXY.x - hudMinXY.x)/2,
						hMax: hudMaxXY.x,
						vMin: hudMinXY.y,
						//vCenter: (hudMaxXY.y - hudMinXY.y)/2,
						vMax: hudMaxXY.y}

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

		// Fixes for elements which become visible for large resolutions
		_root.HUDMovieBaseInstance.WeightTranslated._alpha = 0;
		_root.HUDMovieBaseInstance.ValueTranslated._alpha = 0;
		_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.LevelUpTextInstance._alpha = 0;
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
		
		a_widgetHolder.widget.setHudMetrics(_hudMetrics);
		a_widgetHolder.widget.setRootPath(_rootPath);
		
		skse.SendModEvent("SKIWF_widgetLoaded", a_widgetHolder._name);
	}
	
	public function onLoadError(a_widgetHolder:MovieClip, a_errorCode: String): Void
	{
		skse.SendModEvent("SKIWF_widgetError", "WidgetLoadFailure", Number(a_widgetHolder._name));
	}
	
	public function setRootPath(a_path: String): Void
	{
		skse.Log("WidgetLoader.as: setRootPath(a_path = " + a_path + ")");
		_rootPath = a_path;
	}
	
	public function loadWidgets(/* widgetSources (128) */): Void
	{
		if (_widgetContainer != undefined) {
			for (var s: String in _widgetContainer) {
				var widget = _widgetContainer[s];
				if (widget != null && widget instanceof MovieClip) {
					_mcLoader.unloadClip(widget);
					
					var index = _root.HUDMovieBaseInstance.HudElements.indexOf(widget);
					if (index != undefined)
						_root.HUDMovieBaseInstance.HudElements.splice(index,1); 
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
		_mcLoader.loadClip(_rootPath + "widgets/" + a_widgetSource, widgetHolder);
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