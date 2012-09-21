import Shared.GlobalFunc;

class skyui.widgets.WidgetBase extends MovieClip
{
  /* CONSTANTS */
	
	private static var MODES: Array = ["All", "Favor", "DialogueMode", "StealthMode", "Swimming", "HorseMode", "WarHorseMode"];

	private static var ALIGN_LEFT: String = "left";
	private static var ALIGN_RIGHT: String = "right";
	private static var ALIGN_CENTER: String = "center";
	private static var ALIGN_TOP: String = "top";
	private static var ALIGN_BOTTOM: String = "bottom";
	
	
  /* PRIVATE VARIABLES */
  
	private var _clientInfo: Object;
	private var _widgetID: String;
	private var _widgetHolder: MovieClip;

	private var _vAlign: String;
	private var _hAlign: String;
	
	
  /* INITIALIZATION */
  
	public function WidgetBase()
	{
		_clientInfo = {};
		_widgetHolder = _parent;
		_widgetID = _widgetHolder._name;
		
		// Allows for preview in Flash Player
		if (_global.gfxPlayer)
			_global.gfxExtensions = true;
		else
			_widgetHolder._visible = false;
	}
	
		
  /* PUBLIC FUNCTIONS */
  
	// @Papyrus
	public function setModes(/* a_visibleMode0: String, a_visibleMode1: String, ... */): Void
	{
		var numValidModes: Number = 0;
		// Clear all modes
		for (var i=0; i<MODES.length; i++)
			delete(_widgetHolder[MODES[i]]);
			
		for (var i=0; i<arguments.length; i++) {
			var m = arguments[i];
			if (MODES.indexOf(m) != undefined) {
				_widgetHolder[arguments[i]] = true;
				numValidModes++;
			}
		}
		if (numValidModes == 0) // TODO
			skse.SendModEvent("widgetWarning", "NoValidModes", Number(_widgetID));
		
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

	// @Papyrus
	public function setVAlign(a_vAlign: String): Void
	{
		var vAlign: String = a_vAlign.toLowerCase();

		if (_vAlign == vAlign)
			return;

		_vAlign = vAlign;

		invalidateSize();
	}

	// @Papyrus
	public function setHAlign(a_hAlign: String): Void
	{
		var hAlign: String = a_hAlign.toLowerCase();

		if (_hAlign == hAlign)
			return;

		_hAlign = hAlign;

		invalidateSize();
	}

	// @Papyrus
	public function setPositionX(a_positionX: Number): Void
	{
		var minX: Number = 0; //Stage.visibleRect.x + Stage.safeRect.x;
		var maxX: Number = Stage.visibleRect.width - 2*Stage.safeRect.x; //Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		var newX: Number = GlobalFunc.Lerp(minX, maxX, 0, 1280, a_positionX, true);

		_x = newX;
	}

	// @Papyrus
	public function setPositionY(a_positionY: Number): Void
	{
		var minY: Number = 0; //Stage.visibleRect.y + Stage.safeRect.y;
		var maxY: Number = Stage.visibleRect.height - 2*Stage.safeRect.y; //Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y;
		var newY: Number = GlobalFunc.Lerp(minY, maxY, 0, 720, a_positionY, true);

		_y = newY;
	}

  /* PRIVATE FUNCTIONS */
	// Override if widget dimensions depend properties other than _width and _height
	private function getWidth(): Number {
		return _width
	}

	private function getHeight(): Number {
		return _height;
	}

	private function invalidateSize(): Void
	{
		updateAlign();
	}

	private function updateAlign(): Void
	{
		var xOffset: Number = getWidth();
		var yOffset: Number = getHeight();
		
		if (_hAlign == ALIGN_RIGHT)
			_widgetHolder._x = -xOffset;
		else if (_hAlign == ALIGN_CENTER)
			_widgetHolder._x = -xOffset/2;
		else
			_widgetHolder._x = 0;

		if (_vAlign == ALIGN_BOTTOM)
			_widgetHolder._y = -yOffset;
		else if (_vAlign == ALIGN_CENTER)
			_widgetHolder._y = -yOffset/2;
		else
			_widgetHolder._y = 0;
	}
}