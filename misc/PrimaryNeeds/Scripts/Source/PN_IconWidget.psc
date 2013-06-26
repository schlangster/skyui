scriptname PN_IconWidget extends SKI_WidgetBase  

; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool	_enabled			= false
int		_iconSize			= 32
string	_orientation		= "vertical"


; PROPERTIES --------------------------------------------------------------------------------------

bool Property Enabled
	bool function get()
		return _enabled
	endFunction

	function set(bool a_val)
		_enabled = a_val
		if (Ready)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setEnabled", _enabled) 
		endIf
	endFunction
endProperty

int property IconSize
	int function get()
		return _iconSize
	endFunction

	function set(int a_val)
		_iconSize = a_val
		if (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setIconSize", _iconSize) 
		endIf
	endFunction
endProperty

string property Orientation
	function set(string a_val)
		_orientation = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setOrientation", _orientation) 
		endIf
	endFunction
endProperty

PN_NeedsManager property		NeedsManagerInstance	auto


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_WidgetBase
event OnGameReload()
	parent.OnGameReload()
	RegisterForModEvent("PNX_statusUpdated", "OnStatusUpdate")
endEvent

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	int[] numberArgs = new int[2]
	numberArgs[0] = _enabled as int
	numberArgs[1] = _iconSize as int
	UI.InvokeIntA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init strings
	string[] stringArgs = new string[1]
	stringArgs[0] = _orientation
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")

	UpdateStatus()
endEvent

event OnStatusUpdate(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	UpdateStatus()
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetSource()
	return "pnx/statusicons.swf"
endFunction

; @overrides SKI_WidgetBase
string function GetWidgetType()
	; Must be the same as scriptname
	return "PN_IconWidget"
endFunction

function UpdateStatus()
	; We have to pull the data for compatiblity
	if (Ready)
		int[] args = new int[6]
		args[0] = NeedsManagerInstance.HungerPercent
		args[1] = NeedsManagerInstance.ThirstPercent
		args[2] = NeedsManagerInstance.FatiguePercent
		args[3] = NeedsManagerInstance.HungerLevel
		args[4] = NeedsManagerInstance.ThirstLevel
		args[5] = NeedsManagerInstance.FatigueLevel
		UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setStatus", args)
	endIf
endFunction