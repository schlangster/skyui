scriptname SKI_ActiveEffectsWidget extends SKI_WidgetBase

; SCRIPT VERSION ----------------------------------------------------------------------------------
;
; History
;
; 1:	- Initial version
;
; 2:	- Updated hudModes
;
; 3:	- Added MinimumTimeLeft

int function GetVersion()
	return 3
endFunction

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

; Make sure defaults match those in ConfigMenuInstance
bool	_enabled			= false
float	_effectSize			= 48.0
int		_groupEffectCount	= 8
string	_orientation		= "vertical"

; -- Version 3 --

int		_minimumTimeLeft	= 180

; PROPERTIES --------------------------------------------------------------------------------------

bool Property Enabled
	{Whether the active effects are displayed or not}
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

float property EffectSize
	{Size of each effect icon in pixels at a resolution of 1280x720}
	float function get()
		return _effectSize
	endFunction

	function set(float a_val)
		_effectSize = a_val
		if (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setEffectSize", _effectSize) 
		endIf
	endFunction
endProperty

int property GroupEffectCount
	{Maximum number of widgets displayed until a new group (column, or row) is created}
	int function get()
		return _groupEffectCount
	endFunction

	function set(int a_val)
		_groupEffectCount = a_val
		if (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setGroupEffectCount", _groupEffectCount) 
		endIf
	endFunction
endProperty

string property Orientation
	{The axis in which new effects will be added to after the total number of effects > GroupEffectCount}
	string function get()
		return _orientation
	endFunction

	function set(string a_val)
		_orientation = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setOrientation", _orientation) 
		endIf
	endFunction
endProperty

int property MinimumTimeLeft
	{The minimum time left for an effect to be displayed}
	int function get()
		return _minimumTimeLeft
	endFunction

	function set(int a_val)
		_minimumTimeLeft = a_val
		if (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setMinTimeLeft", _minimumTimeLeft) 
		endIf
	endFunction
endProperty

; INITIALIZATION ----------------------------------------------------------------------------------

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
	
	; Version 2
	if (a_version >= 2 && CurrentVersion < 2)
		Debug.Trace(self + ": Updating to script version 2")

		string[] hudModes = new string[6]
		hudModes[0] = "All"
		hudModes[1] = "StealthMode"
		hudModes[2] = "Favor"
		hudModes[3] = "Swimming"
		hudModes[4] = "HorseMode"
		hudModes[5] = "WarHorseMode"

		Modes = hudModes
	endIf
endEvent

; EVENTS ------------------------------------------------------------------------------------------

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	float[] numberArgs = new float[4]
	numberArgs[0] = _enabled as float
	numberArgs[1] = _effectSize
	numberArgs[2] = _groupEffectCount as float
	numberArgs[3] = _minimumTimeLeft as float
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init strings
	string[] stringArgs = new string[1]
	stringArgs[0] = _orientation
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetSource()
	return "skyui/activeeffects.swf"
endFunction

; @overrides SKI_WidgetBase
string function GetWidgetType()
 return "SKI_ActiveEffectsWidget"
endFunction