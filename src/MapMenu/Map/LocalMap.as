import gfx.io.GameDelegate;
import Map.MapMenu;
import Map.LocationFinder;

class Map.LocalMap extends MovieClip
{ 
  /* CONSTANTS */
  
	private static var STATE_HIDDEN = 0;
	private static var STATE_LOCALMAP = 1;
	private static var STATE_FINDLOCATION = 2;
	

  /* PRIVATE VARIABLES */
  
	private var _mapImageLoader: MovieClipLoader;
	
	private var _bUpdated: Boolean = false;
  
	private var _bottomBar: MovieClip;
	
	// The local map has to manage visiblity of the location finder as well.
	private var _locationFinder: LocationFinder;
	
	private var _bShow: Boolean = false;
	
	private var _state: Number = STATE_HIDDEN;
	
	private var _bRequestFindLoc: Boolean = false;
	
	
  /* STAGE ELEMENTS */
	
	public var LocalMapHolder_mc: MovieClip;
	public var LocationTextClip: MovieClip;
	public var ClearedText: TextField;
	

  /* PROPERTIES */
  
	// @API
	public var IconDisplay: MapMenu;
	
	public var TextureHolder: MovieClip;
	public var LocationDescription: TextField;
	public var ClearedDescription: TextField;
	
	private var _textureWidth: Number = 800;

	function get TextureWidth(): Number
	{
		return _textureWidth;
	}
	
	private var _textureHeight: Number = 450;

	function get TextureHeight(): Number
	{
		return _textureHeight;
	}
	

  /* INITIALIZATION */

	public function LocalMap()
	{
		super();
		IconDisplay = new MapMenu(this);
		
		_mapImageLoader = new MovieClipLoader();
		_mapImageLoader.addListener(this);
		
		LocationDescription = LocationTextClip.LocationText;
		LocationDescription.noTranslate = true;
		
		LocationTextClip.swapDepths(3);
		
		ClearedDescription = ClearedText;
		ClearedDescription.noTranslate = true;
		
		TextureHolder = LocalMapHolder_mc;
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function InitMap(): Void
	{
		if (!_bUpdated) {
			_mapImageLoader.loadClip("img://Local_Map", TextureHolder);
			_bUpdated = true;
		}
		
		updateLocalMapExtends(true);
	}

	// @API
	public function Show(a_bShow: Boolean): Void
	{
		_bShow = a_bShow;
		
		if (a_bShow) {
			if (_bRequestFindLoc)
				setState(STATE_FINDLOCATION);
			else
				setState(STATE_LOCALMAP);
		} else {
			setState(STATE_HIDDEN);
		}
		
		_bRequestFindLoc = false;
	}

	// @API
	public function SetTitle(a_name: String, a_cleared: String): Void
	{
		LocationDescription.text = a_name == undefined ? "" : a_name;
		ClearedDescription.text = a_cleared == undefined ? "" : "(" + a_cleared + ")";
	}
	
	public function showLocationFinder(): Void
	{
		// Local map mode
		if (_state == STATE_LOCALMAP) {
			setState(STATE_FINDLOCATION);

		// World map mode - delay state update for Show()
		} else if (_state == STATE_HIDDEN) {
			_bRequestFindLoc = true;
			GameDelegate.call("ToggleMapCallback", []);			
		}
		
		// Ignore if state == STATE_FINDLOCATION already
	}
	
	public function setBottomBar(a_bottomBar: MovieClip): Void
	{
		_bottomBar = a_bottomBar;
	}
	
	public function setLocationFinder(a_locationFinder: LocationFinder): Void
	{
		_locationFinder = a_locationFinder;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function onLoadInit(a_targetClip: MovieClip): Void
	{
		a_targetClip._width = _textureWidth;
		a_targetClip._height = _textureHeight;
	}
	
	private function setState(a_newState: Number): Void
	{
		var oldState = _state;
		
		var buttonPanel = _bottomBar.buttonPanel;
		
		if (a_newState == STATE_LOCALMAP) {
			updateLocalMapExtends(true);
			_parent.gotoAndPlay("fadeIn");
			_parent._visible = true;
			
			buttonPanel.button0.label = "$World Map";
			buttonPanel.button2.visible = true;
			buttonPanel.button3.visible = true;
			if (!buttonPanel.button4.disabled)
				buttonPanel.button4.visible = true;
			buttonPanel.button5.visible = false;
			buttonPanel.button6.visible = false;
			
		} else if (a_newState == STATE_FINDLOCATION) {
			updateLocalMapExtends(false);
			
			if (oldState == STATE_LOCALMAP) {
				_parent.gotoAndPlay("fadeOut");
				_parent._visible = true;
			} else {
				_parent._visible = false;
			}
			
			_locationFinder.show();
			
			buttonPanel.button0.label = "$World Map";
			buttonPanel.button2.visible = false;
			buttonPanel.button3.visible = false;
			buttonPanel.button4.visible = false;
			buttonPanel.button5.visible = false;
			buttonPanel.button6.visible = true;
			
		} else if (a_newState == STATE_HIDDEN) {
			if (oldState == STATE_LOCALMAP) {
				_parent.gotoAndPlay("fadeOut");
			} else if (oldState == STATE_FINDLOCATION) {
				_locationFinder.hide();
			}
			_parent._visible = true;
			
			buttonPanel.button0.label = "$Local Map";
			buttonPanel.button2.visible = true;
			buttonPanel.button3.visible = true;
			if (!buttonPanel.button4.disabled)
				buttonPanel.button4.visible = true;
			buttonPanel.button5.visible = true;
			buttonPanel.button6.visible = false;
		}
		
		buttonPanel.updateButtons(true); // Label length changed
		
		_state = a_newState;
	}
	
	private function updateLocalMapExtends(a_bEnabled: Boolean): Void
	{
		if (a_bEnabled) {
			var textureTopLeft: Object = {x: _x, y: _y};
			var textureBottomRight: Object = {x: _x + _textureWidth, y: _y + _textureHeight};
			_parent.localToGlobal(textureTopLeft);
			_parent.localToGlobal(textureBottomRight);
			
			GameDelegate.call("SetLocalMapExtents", [textureTopLeft.x, textureTopLeft.y, textureBottomRight.x, textureBottomRight.y]);
		} else {
			GameDelegate.call("SetLocalMapExtents", [0, 0, 0, 0]);
		}
	}
}
