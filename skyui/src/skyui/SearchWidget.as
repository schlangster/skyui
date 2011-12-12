import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class skyui.SearchWidget extends MovieClip
{
	private var _previousFocus:Object;
	private var _currentInput:String;
	private var _bActive:Boolean;
	
	// Children
	var textField:TextField;
	var icon:MovieClip;
	
	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	function SearchWidget()
	{
		super();
		EventDispatcher.initialize(this);
		
		_currentInput = undefined;
		
		textField.onKillFocus = function(a_newFocus:Object)
		{
			if (a_newFocus != _parent) {
				_parent.endInput();
			}
		}
	}
	
	function onPress(a_mouseIndex, a_keyboardOrMouse)
	{
		skse.Log("pressed textInput");
		
		if (!_bActive) {
			startInput();
		} else {
			
			// Check if the cancel button was pressed first
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent) {
				if (e == icon) {
					endInput();
					return;
				}
			}
			
			Selection.setFocus(textField,0);
		}
	}

	function startInput()
	{
		if (_bActive) {
			return;
		}
		
		skse.Log("Entered TextSearch()");
		_previousFocus = FocusHandler.instance.getFocus(0);
		
		textField.SetText("");
		textField.type = "input";
		textField.noTranslate = true;
		textField.selectable = true;
		
		Selection.setFocus(textField,0);
		Selection.setSelection(0,0);
		
		_bActive = true;
		skse.AllowTextInput(true);
		icon.gotoAndStop("on");
		
		dispatchEvent({type: "inputStart"});
	}

	function endInput()
	{
		if (!_bActive) {
			return;
		}
		
		skse.Log("Entered EndTextSearch()");
		textField.type = "dynamic";
		textField.noTranslate = false;
		textField.selectable = false;
		textField.maxChars = null;
		
		var _loc2 = _previousFocus.focusEnabled;
		_previousFocus.focusEnabled = true;
		Selection.setFocus(_previousFocus,0);
		_previousFocus.focusEnabled = _loc2;

		_bActive = false;
		skse.AllowTextInput(false);
		icon.gotoAndStop("off");

		refreshInput();

		if (_currentInput != undefined()) {
			dispatchEvent({type: "inputEnd", data: _currentInput});
		} else {
			textField.SetText("FILTER");
			dispatchEvent({type: "inputEnd", data: ""});
		}
	}

	function handleInput(details, pathToFocus)
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
			
			if (details.navEquivalent == NavigationCode.ENTER && details.code != 32) {
				skse.Log("pressed enter in textInput");
				endInput();
				
			} else if (details.navEquivalent == NavigationCode.TAB) {
				skse.Log("pressed tab in textInput");
				clearText();
				endInput();
				
			} else if (details.navEquivalent == NavigationCode.ESCAPE) {
				skse.Log("pressed esc in textInput");
				clearText();
				endInput();
			}

			if (!bCaught) {
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		
		return bCaught;
	}
	
	function clearText()
	{
		textField.SetText("");
	}
	
	function refreshInput()
	{
		var t =  GlobalFunc.StringTrim(textField.text);
		
		skse.Log("Processing: " + t);
		
		if (t != undefined && t != "" && t != "FILTER") {
			_currentInput = t;
		} else {
			_currentInput = undefined;
		}
	}
}