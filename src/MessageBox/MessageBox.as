import gfx.io.GameDelegate;
import gfx.controls.Button;

class MessageBox extends MovieClip
{
  /* CONSTANTS */
	
	private static var WIDTH_MARGIN: Number = 20;
	private static var HEIGHT_MARGIN: Number = 30;
	private static var MESSAGE_TO_BUTTON_SPACER: Number = 10;
	private static var SELECTION_INDICATOR_WIDTH: Number = 25;
	
	
  /* PRIVATE VARIABLES */
  
	private var _buttonContainer: MovieClip;
	private var _defaultTextFormat: TextFormat;
	private var _buttons: Array;
	
	
  /* STAGE ELEMENTS */
  
	public var messageText: TextField;
	public var divider: MovieClip;
	public var background: MovieClip;
	

  /* INITIALIZATION */
	
	public function MessageBox()
	{
		super();
		
		messageText.noTranslate = true;
		_buttons = new Array();
		_buttonContainer = undefined;
		_defaultTextFormat = messageText.getTextFormat();
		Key.addListener(this);
		GameDelegate.addCallBack("setMessageText", this, "SetMessage");
		GameDelegate.addCallBack("setButtons", this, "setupButtons");
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @API
	public function setupButtons(): Void
	{
		if (_buttonContainer != null) {
			_buttonContainer.removeMovieClip();
			_buttonContainer = null;
		}
		
		_buttons.length = 0; // This truncates the array to 0
		var controllerOrConsole: Boolean = arguments[0];
		
		if (arguments.length > 1) {
			_buttonContainer = createEmptyMovieClip("Buttons", getNextHighestDepth());
			var buttonXOffset: Number = 0;
			
			for (var i: Number = 1; i < arguments.length; i++) {
				if (arguments[i] == " ")
					continue;
				var buttonIdx: Number = i - 1;
				var button: Button = Button(_buttonContainer.attachMovie("MessageBoxButton", "Button" + buttonIdx, _buttonContainer.getNextHighestDepth()));
				var buttonText: TextField = button.ButtonText;
				buttonText.autoSize = "center";
				buttonText.verticalAlign = "center";
				buttonText.verticalAutoSize = "center";
				buttonText.html = true;
				buttonText.SetText(arguments[i], true);
				button.SelectionIndicatorHolder.SelectionIndicator._width = buttonText._width + MessageBox.SELECTION_INDICATOR_WIDTH;
				button.SelectionIndicatorHolder.SelectionIndicator._y = buttonText._y + buttonText._height / 2;
				button._x = buttonXOffset + button._width / 2;
				buttonXOffset = buttonXOffset + (button._width + MessageBox.SELECTION_INDICATOR_WIDTH);
				_buttons.push(button);
			}
			
			initButtons();
			resetDimensions();
			
			if (controllerOrConsole) {
				Selection.setFocus(_buttons[0]);
			}
		}
	}
	
	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		if (a_platform != 0 && _buttons.length > 0) {
			Selection.setFocus(_buttons[0]);
		}
	}

	// @API
	public function SetMessage(aText: String, abHTML: Boolean): Void
	{
		messageText.autoSize = "center";
		messageText.setTextFormat(_defaultTextFormat);
		messageText.setNewTextFormat(_defaultTextFormat);
		messageText.html = abHTML;
		if (abHTML)
			messageText.htmlText = aText;
		else
			messageText.SetText(aText);
		resetDimensions();
		processMessage(aText);
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function initButtons(): Void
	{
		for (var i: Number = 0; i < _buttons.length; i++) {
			_buttons[i].handlePress = function () {};
			_buttons[i].addEventListener("press", clickCallback);
			_buttons[i].addEventListener("focusIn", focusCallback);
			_buttons[i].ButtonText.noTranslate = true;
		}
	}
  
	private function resetDimensions(): Void
	{
		positionElements();
		var parentBounds: Object = getBounds(_parent);
		var i: Number = Stage.height * 0.85 - parentBounds.yMax;
		if (i < 0) {
			messageText.autoSize = false;
			var extraHeight: Number = i * 100 / _yscale;
			messageText._height = messageText._height + extraHeight;
			positionElements();
		}
	}
  
	private function positionElements(): Void
	{
		var maxLineWidth: Number = 0;
		
		for (var i: Number = 0; i < messageText.numLines; i++)
			maxLineWidth = Math.max(maxLineWidth, messageText.getLineMetrics(i).width);
		
		var buttonContainerWidth = 0;
		var buttonContainerHeight = 0;
		if (_buttonContainer != undefined) {
			buttonContainerWidth = _buttonContainer._width;
			buttonContainerHeight = _buttonContainer._height;
		}
		background._width = Math.max(maxLineWidth + 60, buttonContainerWidth + MessageBox.WIDTH_MARGIN * 2);
		background._height = messageText._height + buttonContainerHeight + MessageBox.HEIGHT_MARGIN * 2 + MessageBox.MESSAGE_TO_BUTTON_SPACER;
		messageText._y = (0 - background._height) / 2 + MessageBox.HEIGHT_MARGIN;
		_buttonContainer._y = background._height / 2 - MessageBox.HEIGHT_MARGIN - _buttonContainer._height / 2;
		_buttonContainer._x = (0 - _buttonContainer._width) / 2;
		
		divider._width = background._width - MessageBox.WIDTH_MARGIN * 2;
		divider._y = _buttonContainer._y - _buttonContainer._height / 2 - MessageBox.MESSAGE_TO_BUTTON_SPACER / 2;
	}

	private function clickCallback(aEvent: Object): Void
	{
		GameDelegate.call("buttonPress", [Number(aEvent.target._name.substr(-1))]);
	}

	private function focusCallback(aEvent: Object): Void
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	private function onKeyDown(): Void
	{
		if (Key.getCode() == 89 && _buttons[0].ButtonText.text == "Yes") {
			GameDelegate.call("buttonPress", [0]);
			return;
		}
		if (Key.getCode() == 78 && _buttons[1].ButtonText.text == "No") {
			GameDelegate.call("buttonPress", [1]);
			return;
		}
		if (Key.getCode() == 65 && _buttons[2].ButtonText.text == "Yes to All") {
			GameDelegate.call("buttonPress", [2]);
		}
	}
	
	private function processMessage(a_text: String): Void
	{
		if (a_text.slice(0,2) != "$$" || a_text.slice(a_text.length-2, a_text.length) != "$$")
			return;
		
		var command = a_text.slice(2, a_text.length-2);
		
		var key = command.slice(0, command.indexOf("="));
		if (key == null)
			return;

		var val = command.slice(command.indexOf("=") + 1);
		if (val == null)
			return;

		if (key.toLowerCase() == "loadmovie") {
			var oldMenu = _root.MessageMenu;
			oldMenu._visible = false;
			oldMenu.enabled = false;

			var newMenu = _root.createEmptyMovieClip("menuContainer", _root.getNextHighestDepth());
			skse.Log("Loading " + val);
			newMenu.loadMovie(val);
		}
	}
}
