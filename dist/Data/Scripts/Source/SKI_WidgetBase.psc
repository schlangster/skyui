scriptname SKI_WidgetBase extends SKI_QuestBase

; PRIVATE VARIABLES ---------------------

bool		_initialized = false
int			_widgetID = -1
string		_type = ""
string[]	_modes ;Default modes set in OnInit
float		_x = 0.0
float		_y = 0.0
int			_alpha = 100

; PROPERTIES ----------------------------

SKI_WidgetManager property WidgetManager auto

; Read-only
int property WidgetID
	int function get()
		return _widgetID
	endFunction
endProperty

; Can only be set once. Has to be set early; either in OnWidgetInit, or as property in the editor.
string property Type
	string function get()
		return  _type
	endFunction
	
	function set(string a_val)
		if (_type == "")
			_type = a_val
		endIf
	endFunction
endProperty

string[] property Modes
	string[] function get()
		return  _modes
	endFunction
	
	function set(string[] a_val)
		_modes = a_val
		if (_initialized)
			WidgetManager.SetWidgetModes(_widgetID, a_val)
		endIf
	endFunction
endProperty

float property X
	float function get()
		return _x
	endFunction
	
	function set(float a_val)
		_x = a_val
		if (_initialized)
			WidgetManager.SetWidgetPositionX(_widgetID, a_val)
		endIf
	endFunction
endProperty

float property Y
	float function get()
		return _y
	endFunction
	
	function set(float a_val)
		_y = a_val
		if (_initialized)
			WidgetManager.SetWidgetPositionY(_widgetID, a_val)
		endIf
	endFunction
endProperty

int property Alpha
	int function get()
		return _alpha
	endFunction
	
	function set(int a_val)
		_alpha = a_val
		if (_initialized)
			WidgetManager.SetWidgetAlpha(_widgetID, a_val)
		endIf
	endFunction
endProperty

; FUNCTIONS -------------------------


; EVENTS ----------------------------

event OnInit()
	; Default Modes
	_modes = new string[2]
	_modes[0] = "All"
	_modes[1] = "StealthMode"
	
	gotoState("_INIT")
	RegisterForSingleUpdate(3)
endEvent

; Do any custom widget initialization here
; Executed the first time the widget is loaded by the superclass
event OnWidgetInit()
endEvent

; Executed after each game reload by widget manager
event OnWidgetReset()
endEvent

; Executed whenever a hudModeChange is observed
event OnHudModeChange(string a_eventName, string a_hudMode)
endEvent

; Wrap this in a non-default state so later clients can override OnUpdate() without issues
state _INIT
	event OnUpdate()
		gotoState("")
		RegisterForModEvent("hudModeChange", "OnHudModeChange")
		_widgetID = WidgetManager.RequestWidgetID(self)
		if (_widgetID != -1)
			OnWidgetInit()
			WidgetManager.CreateWidget(_widgetID, _type)
			_initialized = true
		endIf
	endEvent
endState
