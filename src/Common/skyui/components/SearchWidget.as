import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.util.ConfigManager;


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
		startInput();
	}

	public function startInput(): Void
	{
		if (_bActive || isDisabled)
			return;
		
		_previousFocus = FocusHandler.instance.getFocus(0);

		_currentInput = _lastInput = undefined;
		
		textField.SetText("");
		textField.type = "input";
		textField.noTranslate = true;
		textField.selectable = true;
		
		Selection.setFocus(textField);
		Selection.setSelection(0,0);
		
		_bActive = true;
		skse.AllowTextInput(true);
		
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

	public function endInput(): Void
	{
		if (!_bActive)
			return;

		delete this.onEnterFrame;
		
		textField.type = "dynamic";
		textField.noTranslate = false;
		textField.selectable = false;
		textField.maxChars = null;
		
		var bPrevEnabled = _previousFocus.focusEnabled;
		_previousFocus.focusEnabled = true;
		Selection.setFocus(_previousFocus,0);
		_previousFocus.focusEnabled = bPrevEnabled;

		_bActive = false;
		skse.AllowTextInput(false);

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
		if (GlobalFunc.IsKeyPressed(details)) {
			
			if (details.navEquivalent == NavigationCode.ENTER) {
				endInput();
				
			} else if (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.ESCAPE) {
				clearText();
				endInput();
			}

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