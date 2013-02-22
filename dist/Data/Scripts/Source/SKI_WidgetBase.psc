scriptname SKI_WidgetBase extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_WidgetManager	_widgetManager

bool				_initialized		= false
bool				_ready				= false
int					_widgetID			= -1
string				_widgetRoot			= ""
string[]			_modes
string				_hAnchor			= "left"
string				_vAnchor			= "top"
float				_x					= 0.0
float				_y					= 0.0
float				_alpha				= 100.0


; PROPERTIES --------------------------------------------------------------------------------------

bool property RequireExtend				= true	auto
	{Require extending the widget type instead of using it directly.}

; @interface
string property WidgetName				= "I-forgot-to-set-the-widget name" auto
	{Name of the widget. Used to identify it in the user interface.}

; @interface
int property WidgetID
	{Unique ID of the widget. ReadOnly}
	int function get()
		return _widgetID
	endFunction
endProperty

; @interface
bool property Ready
	{True once the widget has registered. ReadOnly}
	bool function get()
		return  _initialized
	endFunction
endProperty

; @interface
string property WidgetRoot
	{Path to the root of the widget from _root of HudMenu. ReadOnly}
	string function get()
		return  _widgetRoot
	endFunction
endProperty

string[] property Modes
	{HUDModes in which the widget is visible, see readme for available modes}
	string[] function get()
		return  _modes
	endFunction
	
	function set(string[] a_val)
		_modes = a_val
		if (Ready)
			UpdateWidgetModes()
		endIf
	endFunction
endProperty

; @interface
string property HAnchor
	{Horizontal anchor point of the widget ["left", "center", "right"]. Default: "left"}
	string function get()
		return _hAnchor
	endFunction
	
	function set(string a_val)
		_hAnchor = a_val
		if (Ready)
			UpdateWidgetHAnchor()
		endIf
	endFunction
endProperty

; @interface
string property VAnchor
	{Vertical anchor point of the widget ["top", "center", "bottom"]. Default: "top"}
	string function get()
		return _vAnchor
	endFunction
	
	function set(string a_val)
		_vAnchor = a_val
		if (Ready)
			UpdateWidgetVAnchor()
		endIf
	endFunction
endProperty

; @interface
float property X
	{Horizontal position of the widget in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
	float function get()
		return _x
	endFunction
	
	function set(float a_val)
		_x = a_val
		if (Ready)
			UpdateWidgetPositionX()
		endIf
	endFunction
endProperty

; @interface
float property Y
	{Vertical position of the widget in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
	float function get()
		return _y
	endFunction
	
	function set(float a_val)
		_y = a_val
		if (Ready)
			UpdateWidgetPositionY()
		endIf
	endFunction
endProperty

; @interface
float property Alpha
	{Opacity of the widget [0.0, 100.0]. Default: 0.0}
	float function get()
		return _alpha
	endFunction
	
	function set(float a_val)
		_alpha = a_val
		if (Ready)
			UpdateWidgetAlpha()
		endIf
	endFunction
endProperty


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	_ready = false
	RegisterForModEvent("SKIWF_widgetManagerReady", "OnWidgetManagerReady")

	if (!IsExtending() && RequireExtend)
		Debug.MessageBox("WARNING!\n" + self as string + " must extend a base script type.")
	endIf

	if (!_initialized)
		_initialized = true

		; Default Modes if not set via property
		if (!_modes)
			_modes = new string[6]
			_modes[0] = "All"
			_modes[1] = "StealthMode"
			_modes[2] = "Favor"
			_modes[3] = "Swimming"
			_modes[4] = "HorseMode"
			_modes[5] = "WarHorseMode"
		endIf

		OnWidgetInit()

		Debug.Trace(self + " INITIALIZED")
	endIf

	CheckVersion()
endEvent

event OnWidgetManagerReady(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	SKI_WidgetManager newManager = a_sender as SKI_WidgetManager
	
	; Already registered?
	if (_widgetManager == newManager)
		return
	endIf
	
	_widgetManager =  newManager
	
	_widgetID = _widgetManager.RequestWidgetID(self)
	if (_widgetID != -1)
		_widgetRoot = "_root.WidgetContainer." + _widgetID + ".widget"
		_widgetManager.CreateWidget(_widgetID, GetWidgetSource())
	else
		Debug.Trace("WidgetWarning: " + self as string + ": could not be loaded, too many widgets. Max is 128")
	endIf
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnWidgetInit()
	{Handles any custom widget initialization}
endEvent

; Executed after each game reload by widget manager.
event OnWidgetLoad()
	_ready = true

	OnWidgetReset()
	
	; Before that the widget was still hidden.
	; Now that everything is done, set modes to show it eventually.
	UpdateWidgetModes()
endEvent

event OnWidgetReset()
	; Reset base properties except modes to prevent widget from being drawn too early.
	UpdateWidgetClientInfo()
	UpdateWidgetHAnchor()
	UpdateWidgetVAnchor()
	UpdateWidgetPositionX()
	UpdateWidgetPositionY()
	UpdateWidgetAlpha()
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
string function GetWidgetSource()
	return ""
endFunction

; @interface
string function GetWidgetType()
	; Must be the same as scriptname
	return ""
endFunction

; @interface
float[] function GetDimensions()
	{Return the dimensions of the widget (width,height).}
	float[] dim = new float[2]
	dim[0] = 0
	dim[1] = 0
	return dim
endFunction

; @interface
function TweenToX(float a_x, float a_duration)
	{Moves the widget to a new x position over time}
	TweenTo(a_x, _y, a_duration)
endFunction

; @interface
function TweenToY(float a_y, float a_duration)
	{Moves the widget to a new y position over time}
	TweenTo(_x, a_y, a_duration)
endFunction

; @interface
function TweenTo(float a_x, float a_y, float a_duration)
	{Moves the widget to a new x, y position over time}
	float[] args = new float[3]
	args[0] = a_x
	args[1] = a_y
	args[2] = a_duration
	UI.InvokeFloatA(HUD_MENU, _widgetRoot + ".tweenTo", args)
endFunction

; @interface
function FadeTo(float a_alpha, float a_duration)
	{Fades the widget to a new alpha over time}
	float[] args = new float[2]
	args[0] = a_alpha
	args[1] = a_duration
	UI.InvokeFloatA(HUD_MENU, _widgetRoot + ".fadeTo", args)
endFunction

bool function IsExtending()
	string s = self as string
	string sn = GetWidgetType() + " "
	s = StringUtil.Substring(s, 1, StringUtil.GetLength(sn))
	if (s == sn)
		return false
	endIf
	return true
endFunction

function UpdateWidgetClientInfo()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setClientInfo", self as string)
endFunction

function UpdateWidgetAlpha()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setAlpha", Alpha)
endFunction

function UpdateWidgetHAnchor()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setHAnchor", HAnchor)
endFunction

function UpdateWidgetVAnchor()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setVAnchor", VAnchor)
endFunction

function UpdateWidgetPositionX()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setPositionX", X)
endFunction

function UpdateWidgetPositionY()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setPositionY", Y)
endFunction

function UpdateWidgetModes()
	UI.InvokeStringA(HUD_MENU, _widgetRoot + ".setModes", Modes)
endFunction