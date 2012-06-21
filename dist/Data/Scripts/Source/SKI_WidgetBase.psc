scriptname SKI_WidgetBase extends SKI_QuestBase

; CONSTANTS------------------------------

string	HUD_MENU = "HUD Menu"


; PRIVATE VARIABLES ---------------------

bool		_initialized = false
int			_widgetID = -1
string		_type = ""
string		_widgetRoot = ""
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
			SyncWidgetModes()
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
			SyncWidgetPositionX()
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
			SyncWidgetPositionY()
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
			SyncWidgetAlpha()
		endIf
	endFunction
endProperty


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
			_widgetRoot = "_root.WidgetContainer." + _widgetID + "."
			OnWidgetInit()
			WidgetManager.CreateWidget(_widgetID, _type)
			_initialized = true
		endIf
	endEvent
endState


; FUNCTIONS -------------------------

function Sync()
	SyncWidgetClientInfo()
	SyncWidgetPositionX()
	SyncWidgetPositionY()
	SyncWidgetAlpha()
endFunction

function SyncWidgetClientInfo()
	UI.InvokeString(HUD_MENU, _widgetRoot + "setClientInfo", self as string)
endFunction

function SyncWidgetPositionX()
	UI.InvokeNumber(HUD_MENU, _widgetRoot + "setPositionX", _x)
endFunction

function SyncWidgetPositionY()
	UI.InvokeNumber(HUD_MENU, _widgetRoot + "setPositionY", _y)
endFunction

function SyncWidgetAlpha()
	UI.InvokeNumber(HUD_MENU, _widgetRoot + "setAlpha", _alpha)
endFunction

function SyncWidgetModes()
	UI.InvokeStringA(HUD_MENU, _widgetRoot + "setModes", _modes)
endFunction

function InvokeCallback(string a_funcName)
	UI.Invoke(HUD_MENU, _widgetRoot + a_funcName)
endFunction

function InvokeCallbackBool(string a_funcName, bool a_arg)
	UI.InvokeBool(HUD_MENU, _widgetRoot + a_funcName, a_arg)
endFunction

function InvokeCallbackNumber(string a_funcName, float a_arg)
	UI.InvokeNumber(HUD_MENU, _widgetRoot + a_funcName, a_arg)
endFunction

function InvokeCallbackString(string a_funcName, string a_arg)
	UI.InvokeString(HUD_MENU, _widgetRoot + a_funcName, a_arg)
endFunction

function InvokeCallbackBoolA(string a_funcName, bool[] a_args)
	UI.InvokeBoolA(HUD_MENU, _widgetRoot + a_funcName, a_args)
endFunction

function InvokeCallbackNumberA(string a_funcName, float[] a_args)
	UI.InvokeNumberA(HUD_MENU, _widgetRoot + a_funcName, a_args)
endFunction

function InvokeCallbackStringA(string a_funcName, string[] a_args)
	UI.InvokeStringA(HUD_MENU, _widgetRoot + a_funcName, a_args)
endFunction
