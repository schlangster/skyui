import Shared.GlobalFunc;
import skyui.defines.ButtonArtNames;

class InputMappingArt extends MovieClip
{
  /* PRIVATE VARIABLES */

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

		GlobalFunc.MaintainTextFormat();
	}

	public function onLoad(): Void
	{
		buttonArt = [];
		_keyCodes = [];

		textField.textAutoSize = "shrink";

		textField._visible = false;
		background._visible = false;

		for (var i=0; this["buttonArt" + i] != undefined; i++) {
			this["buttonArt" + i]._visible = false;
			buttonArt.push(this["buttonArt" + i]);
		}
	}


  /* PUBLIC FUNCTIONS */

	public function setButtonName(a_buttonName: String): Void
	{
		textField._visible = false;

		var keyCodes = ButtonArtNames.lookup(a_buttonName);

		if (keyCodes instanceof Array)
			_keyCodes = keyCodes;
		else
			_keyCodes = [keyCodes];


		if (_keyCodes[0] == null) {
			for (var i: Number = 0; i < buttonArt.length; i++)
				buttonArt[i]._visible = false;
			textField.SetText(a_buttonName);
			textField._width = textField.getLineMetrics(0).width;
			textField._visible = true;
			background._width = textField._width;
			return;
		}


		var xOffset: Number = 0;
		for (var i: Number = 0; i < buttonArt.length; i++) {
			var icon: MovieClip = buttonArt[i];

			if (_keyCodes[i] > 0) {
				icon._visible = true;
				icon.gotoAndStop(_keyCodes[i]);
				icon._x = xOffset;
				icon._y = 0; //(0 - icon._height) / 2; // Center it
				xOffset += icon._width;
			} else {
				icon._visible = false;
			}
		}

		background._width = xOffset;
	}
}
