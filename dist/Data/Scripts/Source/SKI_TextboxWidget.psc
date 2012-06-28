scriptname SKI_TextboxWidget extends SKI_WidgetBase

; PRIVATE VARIABLES ---------------------

string		_labelText
string		_valueText


; PROPERTIES ----------------------------

string property LabelText
	string function get()
		return _labelText
	endFunction
	
	function set(string a_val)
		_labelText = a_val
		if (Initialized)
			UpdateWidgetLabelText()
		endIf
	endFunction
endProperty

string property ValueText
	string function get()
		return _valueText
	endFunction
	
	function set(string a_val)
		_valueText = a_val
		if (Initialized)
			UpdateWidgetLabelText()
		endIf
	endFunction
endProperty

; EVENTS ----------------------------

event OnWidgetInit()
	Type = "textbox"
endEvent

; FUNCTIONS -------------------------

function ResetCustomProperties()
endFunction

function UpdateWidgetLabelText()
	; Do stuff here
endFunction


