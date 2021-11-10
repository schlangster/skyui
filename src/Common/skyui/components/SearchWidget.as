import flash.utils.Timer;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.util.ConfigManager;
import skyui.util.Debug;
import skyui.VRInput;


class skyui.components.SearchWidget extends MovieClip
{
  /* CONSTANTS */

	private static var S_FILTER = "$FILTER";


  /* PRIVATE VARIABLES */

	private var _previousFocus: Object;
	private var _currentInput: String;
	private var _lastInput: String;
	private var _bActive: Boolean;
	private var _bRestoreFocus: Boolean = false;
	private var _bEnableAutoupdate: Boolean;
	private var _updateDelay: Number;

	private var _updateTimerId: Number;


  /* STAGE ELEMENTS */

	public var textField: TextField;
	public var icon: MovieClip;

  /* PROPERTIES */

	public var isDisabled: Boolean = false;


  /* INITIALIZATION */

	public function SearchWidget()
	{
		super();
		EventDispatcher.initialize(this);

		textField.onKillFocus = function(a_newFocus: Object)
		{
			_parent.endInput();
		};

		textField.SetText(S_FILTER);

		ConfigManager.registerLoadCallback(this, "onConfigLoad");
	}


  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;

	public function onConfigLoad(event): Void
	{
		var config = event.config;
		_bEnableAutoupdate = config.SearchBox.autoupdate.enable;
		_updateDelay = config.SearchBox.autoupdate.delay;
	}

	public function onPress(a_mouseIndex, a_keyboardOrMouse)
	{
		Debug.log("In onPress!");
	}

	public function onRelease(a_mouseIndex, a_keyboardOrMouse)
	{
		Debug.log("In onRelease!");
		//setTimeout(startInput, 100);
		startInput();
	}

	public function startInput(): Void
	{
		Debug.log("SearchWidget::startInput()");
		if (_bActive || isDisabled)
			return;

		Debug.log("SearchWidget::startInput() rest");
		_previousFocus = FocusHandler.instance.getFocus(0);

		_currentInput = _lastInput = undefined;

		textField.SetText("");
		textField.type = "input";
		textField.noTranslate = true;
		textField.selectable = true;

		Selection.setFocus(textField);
		Selection.setSelection(0,0);

		_bActive = true;

		// We're about to switch control over to the virtual keyboard
		// While the keyboard is up and running, we'll want to stop processing input
		// so we're not accidentally operating on something in the menu while entering text.
		VRInput.instance.pauseInput("all");

		// Show the keyboard
		skse["plugins"]["skyui"].ShowVirtualKeyboard("skyui", "Search", "Item name", "", this, recvVirtualKeyboardInput);

		Debug.log("sending inputStart event and entering autoupdate loop");
		dispatchEvent({type: "inputStart"});

		if ( _bEnableAutoupdate) {
			this.onEnterFrame = function()
			{
				refreshInput();

				if (_currentInput != _lastInput) {
					_lastInput = _currentInput;

					if (_updateTimerId != undefined) {
						clearInterval(_updateTimerId);
					}
					_updateTimerId = setInterval(this, "updateInput", _updateDelay);
				}
			};
		}
	}

	private function recvVirtualKeyboardInput(text:String, err:Number): Void
	{
		Debug.log("recvVirtualKeyboardInput: ", text, err);
		textField.text = text;
		endInput();
	}

	public function endInput(): Void
	{
		Debug.log("SearchWidget::endInput()");
		if (!_bActive)
			return;

		Debug.log("SearchWidget::endInput() rest");
		delete this.onEnterFrame;

		VRInput.instance.resumeInput("all");

		textField.type = "dynamic";
		textField.noTranslate = false;
		textField.selectable = false;
		textField.maxChars = null;

		var bPrevEnabled = _previousFocus.focusEnabled;
		_previousFocus.focusEnabled = true;
		Selection.setFocus(_previousFocus,0);
		_previousFocus.focusEnabled = bPrevEnabled;

		_bActive = false;
		//skse.AllowTextInput(false);

		refreshInput();

		if (_currentInput != undefined) {
			dispatchEvent({type: "inputEnd", data: _currentInput});
		} else {
			textField.SetText(S_FILTER);
			dispatchEvent({type: "inputEnd", data: ""});
		}
	}

	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		Debug.log("search widget handle input");
		Debug.dump("InputDetails", details, false, 0);

		if (GlobalFunc.IsKeyPressed(details)) {


			/*
			if (details.navEquivalent == NavigationCode.ENTER) {
				Debug.log("Ending: enter key detected");
				endInput();

			}
			else if (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.ESCAPE) {
				Debug.log("Ending: tab or escape");
				clearText();
				endInput();
			}
			*/

			var nextClip = pathToFocus.shift();
			if (nextClip.handleInput(details, pathToFocus))
				return true;
		}

		return false;
	}


  /* PRIVATE FUNCTIONS */

	private function clearText(): Void
	{
		textField.SetText("");
	}

	private function refreshInput(): Void
	{
		var t =  GlobalFunc.StringTrim(textField.text);

		if (t != undefined && t != "" && t != S_FILTER) {
			_currentInput = t;
		} else {
			_currentInput = undefined;
		}
	}

	private function updateInput(): Void
	{
		if (_updateTimerId != undefined) {
			clearInterval(_updateTimerId);
			_updateTimerId = undefined;

			if (_currentInput != undefined) {
				dispatchEvent({type: "inputChange", data: _currentInput});
			} else {
				dispatchEvent({type: "inputChange", data: ""});
			}
		}
	}
}
