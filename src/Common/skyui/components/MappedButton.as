import Shared.ButtonChange;
import gfx.controls.Button;

class skyui.components.MappedButton extends Button
{
  /* PRIVATE VARIABLES */

	private static var _arrayWrap = [];

	private var _platform: Number;
	
	private var _keyCodes: Array;
	
	
  /* STAGE ELEMENTS */
	
	public var background: MovieClip;
	public var textField: TextField;
	
	
  /* PROPERTIES */
  
  	public function set hiddenBackground(a_flag: Boolean)
	{
		background._visible = !a_flag;
	}
	
	public function get hiddenBackground(): Boolean
	{
		return background._visible;
	}
	
	public function get width(): Number
	{
		return background._width;
	}
	
	public function set width(a_value: Number)
	{
		background._width = a_value;
	}
  
  	public var buttonArt: Array;


  /* INITIALIZATION */

	function MappedButton()
	{
		super();
		
		textField.autoSize = "left";
		
		_keyCodes = [];
		
		buttonArt = [];
		for (var i=0; this["buttonArt" + i] != undefined; i++)
			buttonArt.push(this["buttonArt" + i]);
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
		_platform = a_platform;
		if (label != null && label.length > 0)
			update();
	}
	
	public function setButtonData(a_buttonData: Object)
	{
		label = a_buttonData.text;
		setMappedControls(a_buttonData.controls);
	}

	public function setMappedControls(a_controls): Void
	{
		_keyCodes.splice(0);
		
		// Accept either single object or array for multiple icons
		var controls: Array;
		if (a_controls instanceof Array) {
			controls = a_controls;
		} else {
			_arrayWrap[0] = a_controls;
			controls = _arrayWrap;
		}
		
		for (var i=0; i<controls.length; i++) {
			var controlInfo = controls[i];
			
			// Setting keycode manually overrides auto-detection
			if (controlInfo.keyCode != null) {
				_keyCodes.push(controlInfo.keyCode);
				continue;
			}
			
			var name = controlInfo.name;
			var context = controlInfo.context;
			
			var keyCode = -1;
			if (_platform == 0) {
				keyCode = skse.GetMappedKey(name, InputDefines.DEVICE_KEYBOARD, context);
				if (keyCode == -1)
					keyCode = skse.GetMappedKey(name, InputDefines.DEVICE_MOUSE, context);

			} else {
				keyCode = skse.GetMappedKey(name, InputDefines.DEVICE_GAMEPAD, context);
			}
			_keyCodes.push(keyCode);
		}
		
		update();
	}
	
	public function update(): Void
	{
		var xOffset = 0;
		
		for (var i=0; i<buttonArt.length; i++) {
			var icon: MovieClip = buttonArt[i];
			
			if (_keyCodes[i] > 0) {
				icon._visible = true;			
				icon.gotoAndStop(_keyCodes[i]);
				icon._x = xOffset
				icon._y = (_height - icon._height) / 2;
				xOffset += icon._width - 2;
			} else {
				icon._visible = false;
			}
		}
		
		textField._x = xOffset + 1;
		xOffset += textField.getLineMetrics(0).width + 6;
		
		background._width = xOffset;
	}
}
