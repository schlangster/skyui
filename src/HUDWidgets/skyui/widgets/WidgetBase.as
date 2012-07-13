class skyui.widgets.WidgetBase extends MovieClip
{
  /* CONSTANTS */
  
	private var MODES = ["All", "StealthMode"];
	
	
  /* PRIVATE VARIABLES */
  
	private var _clientInfo: Object;
	private var _widgetID: String;
	private var _widgetHolder: MovieClip;
	
	
  /* INITIALIZATION */
	
	public function WidgetBase()
	{
		_clientInfo = {};
		_widgetHolder = _parent;
		_widgetID = _widgetHolder._name;
		
		// Allows for preview in Flash Player
		if (_root != _widgetHolder)
			_widgetHolder._visible = false;
		else
			_global.gfxExtensions = true;
	}
	
	// @override MovieClip
	public function onLoad(): Void
	{
		skse.SendModEvent("widgetLoaded", _widgetID);
	}
		
		
  /* PUBLIC FUNCTIONS */
  
  	// @Papyrus
	public function setModes(/* a_visibleModes [] */): Void
	{	
		// Clear all modes
		for (var i=0; i<MODES.length; i++)
			delete(_widgetHolder[MODES[i]]);
			
		for (var i=0; i<arguments.length; i++) {
			var m = arguments[i];
			if (MODES.indexOf(m) != undefined)
				_widgetHolder[arguments[i]] = true;
			else
				skse.SendModEvent("widgetWarning", "WidgetID: " + _widgetID + " Invalid widget mode: " + m);
		}
		
		
		var hudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		_widgetHolder._visible = _widgetHolder.hasOwnProperty(hudMode);
			
		_root.HUDMovieBaseInstance.HudElements.push(_widgetHolder);
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