class skyui.widgets.WidgetBase extends MovieClip
{
  /* CONSTANTS */
  
	private var MODES = ["All", "StealthMode"];
	
	
  /* PRIVATE VARIABLES */
  
	private var _clientInfo: Object;
	private var _widgetID: String;
	private var _container: MovieClip;
	
	
  /* INITIALIZATION */
	
	public function WidgetBase()
	{
		_clientInfo = {};
		_container = _parent;
		_widgetID = _container._name;
	}
	
	// @override MovieClip
	public function onLoad(): Void
	{
		_visible = false;
		skse.SendModEvent("widgetLoaded", _widgetID);
	}
		
		
  /* PUBLIC FUNCTIONS */
  
  	// @Papyrus
	public function setModes(/* a_visibleModes [] */): Void
	{		
		// Clear all modes
		for (var i=0; i<MODES.length; i++)
			delete(_container[MODES[i]]);
			
		for (var i=0; i<arguments.length; i++) {
			var m = arguments[i];
			if (MODES.indexOf(m) != undefined)
				_container[arguments[i]] = true;
			else
				skse.SendModEvent("widgetWarning", "WidgetID: " + _widgetID + " Invalid widget mode: " + m);
		}
		
		
		var hudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		_visible = _container.hasOwnProperty(hudMode);
			
		_root.HUDMovieBaseInstance.HudElements.push(_container);
	}

  	// @Papyrus
	public function setClientInfo(a_clientString: String): Void
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
	}
}