import Shared.ButtonChange;
import gfx.controls.Button;
import skyui.defines.Input;
import skyui.util.GlobalFunctions;
import skyui.defines.ButtonArtNames;

class skyui.components.MappedButton extends Button
{
  /* PRIVATE VARIABLES */

	private static var _arrayWrap = [];

	private var _platform: Number;

	private var _controlInfos: Array;


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

		_controlInfos = [];

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


	private function updateAfterStateChange(): Void
	{
		if (textField != null && _label != null) {
			textField.autoSize = "left";
			textField.text = _label;
			textField._width = textField.getLineMetrics(0).width;
		}

		update();

		dispatchEvent({type:"stateChange", state:state});
	}

  /* PUBLIC FUNCTIONS */

	public function setPlatform(a_platform: Number): Void
	{
		_platform = a_platform;
		if (label != null && label.length > 0)
			update();
	}

	public function setButtonData(a_buttonData: Object): Void
	{
		textField.autoSize = "left";

		label = a_buttonData.text;
		// Update textfield size - autoSize doesn't work reliably for large resolutions
		textField._width = textField.getLineMetrics(0).width;

		setMappedControls(a_buttonData.controls);
	}

	public function setMappedControls(a_controls): Void
	{
		// FIXME? a_controls is now stored directly
		// This means the caller may potentially change the data and mess things up.
		// If this becomes a problem, duplicate the incoming controls data
		constraints=null;

		_controlInfos.splice(0);

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
			if (controlInfo == null)
				continue;

			resolveControlInfoKeyCode(controlInfo);

			_controlInfos.push(controlInfo);
		}

		update();
	}

	private function resolveControlInfoKeyCode(controlInfo: Object): Void
	{
		var keyCode = null;

		if (controlInfo.namedKey != null) {
			keyCode = ButtonArtNames.lookup(controlInfo.namedKey);

		} else if (controlInfo.keyCode != null) {
			keyCode = controlInfo.keyCode;

		} else {
			var name: String = String(controlInfo.name);
			var context: Number = Number(controlInfo.context);
			keyCode = GlobalFunctions.getMappedKey(name, context, _platform != 0);
		}

		if (keyCode != null)
			controlInfo.keyCode = keyCode;
		else
			controlInfo.keyCode = 282; // ???
	}

	public function update(): Void
	{
		var xOffset = 0;

		for (var i=0; i<buttonArt.length; i++) {
			var icon: MovieClip = buttonArt[i];

			if (_controlInfos[i].keyCode > 0) {
				icon._visible = true;
				icon.gotoAndStop(_controlInfos[i].keyCode);
				icon._x = xOffset
				icon._y = (_height - icon._height) / 2;
				xOffset += icon._width - 2;
			} else {
				icon._visible = false;
			}
		}

		textField._x = xOffset + 1;
		xOffset += textField._width + 6;

		background._width = xOffset;
	}
}
