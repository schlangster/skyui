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
		widget._lockroot = true;
		widget.loadMovie(_widgetDirectory + a_widgetType + ".swf");
	}
	 
	private static function createWidgetContainer(): Void
	{
		skyui.util.GlobalFunctions.addArrayFunctions();
		
		_widgetContainer = _root.createEmptyMovieClip("WidgetContainer", -16384);
		// -16384 places the WidgetContainer beneath all elements which were added to the stage in Flash.
		// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/2/help.html?content=00001303.html - duplicateMovieClip (MovieClip.duplicateMovieClip method)
		// depth: Number - A unique integer specifying the depth at which the new movie clip is placed. Use depth -16384 to place the new movie clip instance beneath all content that is created in the authoring environment. Values between -16383 and -1, inclusive, are reserved for use by the authoring environment and should not be used with this method. The remaining valid depth values range from 0 to 1048575, inclusive.
		_widgetContainer.Lock("TL");
		// Locks _widgetContainer to the safe top left of the Stage, for all child elements {_x = 0, _y = 0} is the top left of the stage
		
		var setWidgetXFunc = function(a_x: Number): Void
		{
			var widget = this;
			skse.Log("WidgetLoader.as: setWidgetXFunc(a_x = " + a_x + ") for widgetID " + widget.widgetID);
			widget._x = a_x;
		};
		
		var setWidgetYFunc = function(a_y: Number): Void
		{
			var widget = this;
			skse.Log("WidgetLoader.as: setWidgetXFunc(a_y = " + a_y + ") for widgetID " + widget.widgetID);
			widget._y = a_y;
		};
		
		var setWidgetAlphaFunc = function(a_alpha: Number): Void
		{
			var widget = this;
			skse.Log("WidgetLoader.as: setWidgetAlphaFunc(a_alpha = " + a_alpha + ") for widgetID " + widget.widgetID);
			widget._alpha = a_alpha;
		};
		
		var setWidgetModesFunc = function(/* a_visibleModes [] */): Void
		{
			var widget = this;
			skse.Log("WidgetLoader.as: setWidgetModesFunc(a_visibleModes = " + arguments + ") for widgetID " + widget.widgetID);
			var _availableModes: Array = ["All", "StealthMode"];
			
			for (var i=0; i<_availableModes.length; i++)
				delete(widget[_availableModes[i]]);
				
			for (var i=0; i<arguments.length; i++) {
				var m = arguments[i];
				if (_availableModes.indexOf(m) != undefined)
					widget[arguments[i]] = true;
				else
					skse.SendModEvent("widgetWarning", "WidgetID: " + widget.widgetID+ " Invalid widget mode: " + m);
			}
			
			
			var hudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
			widget._visible = widget.hasOwnProperty(hudMode);
				if (widget.onModeChange != undefined)
					widget.onModeChange(hudMode);
			_root.HUDMovieBaseInstance.HudElements.push(widget);
		};
		
		var setWidgetClientInfoFunc = function(a_clientString: String): Void
		{
			var widget = this;
			var clientInfo: Object = new Object();
			//[ScriptName <formName (formID)>]
			var lBrackIdx: Number = 0;
			var lInequIdx: Number = a_clientString.indexOf("<");
			var lParenIdx: Number = a_clientString.indexOf("(");
			var rParenIdx: Number = a_clientString.indexOf(")");
			
			clientInfo["scriptName"] = a_clientString.slice(lBrackIdx + 1, lInequIdx - 1);
			clientInfo["formName"] = a_clientString.slice(lInequIdx + 1, lParenIdx - 1);
			clientInfo["formID"] = a_clientString.slice(lParenIdx + 1, rParenIdx);
			
			widget.clientInfo = clientInfo;
		};

		_widgetContainer.onWidgetLoad = function(a_widget: MovieClip, a_widgetID: String): Void
		{
			skse.Log("WidgetLoader.as: _widgetContainer.onWidgetLoad(a_widget = " + a_widget + ", a_widgetID = " + a_widgetID + ")");
			a_widget._visible = false;
			
			a_widget.clientInfo = new Object();
			a_widget.widgetID = Number(a_widgetID);
			
			if (a_widget.setWidgetClientInfo == undefined)
				a_widget.setWidgetClientInfo = setWidgetClientInfoFunc;
			if (a_widget.setWidgetX == undefined)
				a_widget.setWidgetX = setWidgetXFunc;
			if (a_widget.setWidgetY == undefined)
				a_widget.setWidgetY = setWidgetYFunc;
			if (a_widget.setWidgetAlpha == undefined)
				a_widget.setWidgetAlpha = setWidgetAlphaFunc;
			if (a_widget.setWidgetModes == undefined)
				a_widget.setWidgetModes = setWidgetModesFunc;

			skse.SendModEvent("widgetLoaded", a_widgetID);
		};
	}
}