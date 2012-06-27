class WidgetLoader
{
  /* PROPERTIES */
	
	public static var skyuiWidgetExtensions: Boolean = false;


  /* PRIVATE VARIABLES */
	
	private static var _widgetContainer: MovieClip;
	private static var _widgetDirectory: String = "./widgets/";
	
	
  /* PUBILC FUNCTIONS */
	
	public static function loadWidgets(/* widgetTypes (128) */): Void
	{
		skse.Log("WidgetLoader.as: loadWidgets(widgetTypes[] = " + arguments + ")");
		if (_widgetContainer != undefined) {
			for(i: String in _widgetContainer)
				if (i instanceof MovieClip && _root.HUDMovieBaseInstance.HudElements[i] != undefined)
					delete(_root.HUDMovieBaseInstance.HudElements[i])

			_widgetContainer.swapDepths(_root.getNextHighestDepth());
			_widgetContainer.removeMovieClip();
			_widgetContainer = undefined;
		}
		
		for (var i: Number = 0; i < arguments.length; i++)
			if (arguments[i] != undefined && arguments[i] != "None")
				loadWidget(String(i), arguments[i]);
	}

	public static function loadWidget(a_widgetID: String, a_widgetType: String): Void
	{
		skse.Log("WidgetLoader.as: loadWidget(a_widgetID = " + a_widgetID + ", a_widgetType = " + a_widgetType + ")");
		if (_widgetContainer == undefined)
			createWidgetContainer();
		
		var widget: MovieClip = _widgetContainer.createEmptyMovieClip(a_widgetID, _widgetContainer.getNextHighestDepth());
		widget.loadMovie(_widgetDirectory + a_widgetType + ".swf");
	}
	 
	 
  /* PRIVATE FUNCTIONS */
  
	private static function createWidgetContainer(): Void
	{
		skyui.util.GlobalFunctions.addArrayFunctions();

		// -16384 places the WidgetContainer beneath all elements which were added to the stage in Flash.
		_widgetContainer = _root.createEmptyMovieClip("WidgetContainer", -16384);

		// Locks _widgetContainer to the safe top left of the Stage, for all child elements {_x = 0, _y = 0} is the top left of the stage
		_widgetContainer.Lock("TL");
	}
}