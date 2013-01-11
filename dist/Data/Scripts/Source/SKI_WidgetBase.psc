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
string				_hAlign				= "left"
string				_vAlign				= "top"
float				_x					= 0.0
float				_y					= 0.0
float				_alpha				= 100.0


; PROPERTIES --------------------------------------------------------------------------------------

bool property RequireExtend				= true	auto
	{Require extending the widget type instead of using it directly.}

; Read-only
int property WidgetID
	{Unique ID of the widget. ReadOnly}
	int function get()
		return _widgetID
	endFunction
endProperty

; Read-only
bool property Ready
	{True once the widget has registered. ReadOnly}
	bool function get()
		return  _initialized
	endFunction
endProperty

; Read-only
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

string property HAlign
	{Horizontal registration point of the widget ["left", "center", "right"]. Default: "left"}
	string function get()
		return _hAlign
	endFunction
	
	function set(string a_val)
		_hAlign = a_val
		if (Ready)
			UpdateWidgetHAlign()
		endIf
	endFunction
endProperty

string property VAlign
	{Vertical registration point of the widget ["top", "center", "bottom"]. Default: "top"}
	string function get()
		return _vAlign
	endFunction
	
	function set(string a_val)
		_vAlign = a_val
		if (Ready)
			UpdateWidgetVAlign()
		endIf
	endFunction
endProperty

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
	RegisterForModEvent("SKIWF_widgetManagerReady", "OnWidgetManagerReady")

	if (!IsExtending() && RequireExtend)
		Debug.MessageBox("WARNING!\n" + self as string + " must extend base script types")
	endIf

	if (!_initialized)
		_initialized = true

		; Default Modes if not set via property
		if (!_modes)
			_modes = new string[2]
			_modes[0] = "All"
			_modes[1] = "StealthMode"
		endIf

		OnWidgetInit()

		Debug.Trace(self + " INITIALIZED")
	endIf
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
		_ready = true
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
	OnWidgetReset()
	
	; Before that the widget was still hidden.
	; Now that everything is done, set modes to show it eventually.
	UpdateWidgetModes()
endEvent

event OnWidgetReset()
	; Reset base properties except modes to prevent widget from being drawn too early.
	UpdateWidgetClientInfo()
	UpdateWidgetHAlign()
	UpdateWidgetVAlign()
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

function UpdateWidgetPositionX()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setPositionX", X)
endFunction

function UpdateWidgetPositionY()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setPositionY", Y)
endFunction

function UpdateWidgetAlpha()
	UI.InvokeFloat(HUD_MENU, _widgetRoot + ".setAlpha", Alpha)
endFunction

function UpdateWidgetHAlign()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setHAlign", HAlign)
endFunction

function UpdateWidgetVAlign()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setVAlign", VAlign)
endFunction

function UpdateWidgetModes()
	UI.InvokeStringA(HUD_MENU, _widgetRoot + ".setModes", Modes)
endFunction