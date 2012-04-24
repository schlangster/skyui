import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.Config;
import skyui.Translator;


class skyui.SearchWidget extends MovieClip
{
  /* PRIVATE VARIABLES */
  
	private var _previousFocus: Object;
	private var _currentInput: String;
	private var _lastInput: String;
	private var _bActive: Boolean;
	private var _bRestoreFocus: Boolean;
	private var _bEnableAutoupdate: Boolean;
	private var _updateDelay: Number;
	private var _filterString: String;
	
	private var _updateTimerId: Number;
	
	private var _config: Config;
	
	
  /* STAGE ELEMENTS */
  
	public var textField: TextField;
	public var icon: MovieClip;
	
	
  /* CONSTRUCTORS */
	
	public function SearchWidget()
	{
		super();
		EventDispatcher.initialize(this);
		
		_currentInput = undefined;
		_bRestoreFocus = false;
		
		textField.onKillFocus = function(a_newFocus: Object)
		{
			_parent.endInput();
		};

		Config.instance.addEventListener("configLoad", this, "onConfigLoad");
		Translator.instance.addEventListener("translationLoad", this, "onTranslationLoad");
	}
	
	
  /* PUBLIC FUNCTIONS */

	// mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
	// mixin by gfx.events.EventDispatcher
	public var addEventListener: Function;
	
	public function onConfigLoad(event): Void
	{
		_config = event.config;
		_bEnableAutoupdate = _config.SearchBox.autoupdate.enable;
		_updateDelay = _config.SearchBox.autoupdate.delay;
	}
	
	public function onTranslationLoad(event): Void
	{
		_filterString = Translator.translate("$FILTER");
		textField.SetText(_filterString);
	}
	
	public function onPress(a_mouseIndex, a_keyboardOrMouse)
	{
		startInput();
	}

	public function startInput(): Void
	{
		if (_bActive) {
			return;
		}
		
		_previousFocus = FocusHandler.instance.getFocus(0);

		_currentInput = _lastInput = undefined;
		
		textField.SetText("");
		textField.type = "input";
		textField.noTranslate = true;
		textField.selectable = true;
		
		Selection.setFocus(textField,0);
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
	
	public function updateInput()
	{
		if (_updateTimerId != undefined) {
			clearInterval(_updateTimerId);
			_updateTimerId = undefined;
			
			if (_currentInput != undefined()) {
				dispatchEvent({type: "inputChange", data: _currentInput});
			} else {
				dispatchEvent({type: "inputChange", data: ""});
			}
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

		if (_currentInput != undefined())
			dispatchEvent({type: "inputEnd", data: _currentInput});
		else {
			textField.SetText(Translator.translate("$FILTER"));
			dispatchEvent({type: "inputEnd", data: ""});
		}
	}

	// GFx
	public function handleInput(details, pathToFocus)
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
			
			if (details.navEquivalent == NavigationCode.ENTER && details.code != 32) {
				endInput();
				
			} else if (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.ESCAPE) {
				clearText();
				endInput();
			}

			if (!bCaught) {
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		
		return bCaught;
	}
	
	public function clearText(): Void
	{
		textField.SetText("");
	}
	
	public function refreshInput(): Void
	{
		var t =  GlobalFunc.StringTrim(textField.text);
		
		if (t != undefined && t != "" && t != _filterString) {
			_currentInput = t;
		} else {
			_currentInput = undefined;
		}
	}
}