import Shared.ButtonChange;

class skyui.components.MappedButton extends gfx.controls.Button
{
  /* PRIVATE VARIABLES */

	private var _platform: Number;
	
	private var _keyCodes: Array;
	
	private var _iconCount: Number = 0;
	private var _icons: Array;
	
	private var _bShowBackground = false;
	
	
  /* STAGE ELEMENTS */
	
	public var background: MovieClip;
	public var textField: TextField;
	
	
  /* PROPERTIES */
  
  	public var iconRenderer: MovieClip;


  /* INITIALIZATION */

	function MappedButton(a_bShowBackground: Boolean)
	{
		super();
		_bShowBackground = a_bShowBackground;
		_keyCodes = [];
		_icons = [];
	}

	function onLoad(): Void
	{
		super.onLoad();
		if (_parent.onButtonLoad != undefined)
			_parent.onButtonLoad(this);
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function setPlatform(a_platform: Number): Void
	{
		if (a_platform != null) 
			_platform = a_platform;
		refreshArt();
	}

	public function setMappedControls(/* a_name1: String, a_context1: Number, ... */): Void
	{
		_keyCode = -1;
		if (_platform == 1) {
			_keyCode = skse.GetMappedKey(a_name, skse.kDevice_Gamepad, a_context);
		} else {
			_keyCode = skse.GetMappedKey(a_name, skse.kDevice_Mouse, a_context);
			if (keyCode == -1)
				_keyCode = skse.GetMappedKey(a_controlName, skse.kDevice_Keyboard, a_context);
		}
		refreshArt();
	}


  /* PRIVATE FUNCTIONS */
	
	private function refreshArt(): Void
	{
		if (!_buttonArt)
			_buttonArt = attachMovie("ButtonArt", "ButtonArt", getNextHighestDepth());
		
		_buttonArt.gotoAndStop(keyCode);
		_buttonArt._x = _buttonArt._x - _buttonArt._width;
		_buttonArt._y = (_height - _buttonArt._height) / 2;

		background._visible = _bShowBackground;
	}
}
