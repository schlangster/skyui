import skyui.util.GlobalFunctions;

class WidgetLoader
{
  /* CONSTANTS */

	private static var WIDGET_PATH = "./widgets/";
	
	
  /* PRIVATE VARIABLES */

	private var _widgetContainer: MovieClip;
	
	private var _widgetLoader: MovieClipLoader;
	
	
  /* PROPERTIES */
  
	static private var _instance: WidgetLoader;
	
	static function get instance(): WidgetLoader
	{
		if (_instance == undefined)
			_instance = new WidgetLoader();
			
		return _instance;
	}
	
	
  /* INITIALIZATION */
	
	private function WidgetLoader()
	{
		_widgetLoader = new MovieClipLoader();
		_widgetLoader.addListener(this);
		
		GlobalFunctions.addArrayFunctions();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoadInit(a_widgetHolder: MovieClip): Void
	{
		skse.SendModEvent("widgetLoaded", a_widgetHolder._name);
	}
	
	public function onLoadError(a_widgetHolder:MovieClip, a_errorCode: String): Void
	{
		skse.SendModEvent("widgetError", "WidgetLoadFailure", Number(a_widgetHolder._name));
	}
	
	public function loadWidgets(/* widgetTypes (128) */): Void
	{
		skse.Log("WidgetLoader.as: loadWidgets(widgetTypes[] = " + arguments + ")");
		if (_widgetContainer != undefined) {
			for(var i: String in _widgetContainer) {
				if (_widgetContainer[i] instanceof MovieClip) {
					_widgetLoader.unloadClip(_widgetContainer[i]);
					if (_root.HUDMovieBaseInstance.HudElements.hasOwnProperty(i))
						delete(_root.HUDMovieBaseInstance.HudElements[i]); 
				}
			}
		}
		
		for (var i: Number = 0; i < arguments.length; i++)
			if (arguments[i] != undefined && arguments[i] != "None")
				loadWidget(String(i), arguments[i]);
	}

	public function loadWidget(a_widgetID: String, a_widgetType: String): Void
	{
		skse.Log("WidgetLoader.as: loadWidget(a_widgetID = " + a_widgetID + ", a_widgetType = " + a_widgetType + ")");
		if (_widgetContainer == undefined)
			createWidgetContainer();
		
		var widgetHolder: MovieClip = _widgetContainer.createEmptyMovieClip(a_widgetID, _widgetContainer.getNextHighestDepth());
		_widgetLoader.loadClip(WIDGET_PATH + a_widgetType + ".swf", widgetHolder);
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