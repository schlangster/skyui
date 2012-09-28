scriptname SKI_ActiveEffectsWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; Config
; Make sure defaults match those in ConfigMenuInstance
float	_effectSize				= 48.0
int		_groupEffectCount	= 8
string	_orientation		= "vertical"
string	_clampCorner		= "TR"

string function GetWidgetType()
	return "activeeffects"
endFunction

; @overrides SKI_WidgetBase
;event onInit()
;	parent.onInit()
;endEvent

float property EffectSize
	{Size of each effect in pixels at a resolution of 1280x720}
	float function get()
		return _effectSize
	endFunction

	function set(float a_val)
		_effectSize = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setEffectSize", _effectSize) 
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
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setGroupEffectCount", _groupEffectCount) 
		endIf
	endFunction
endProperty

string property ClampCorner
	{Corner at which the first effect is}
	string function get()
		return _clampCorner
	endFunction

	function set(string a_val)
		_clampCorner = a_val
		if (Initialized)

			if (_clampCorner == "BR")
				HAlign = "right"
				VAlign = "bottom"
			elseIf (_clampCorner == "BL")
				HAlign = "left"
				VAlign = "bottom"
			elseIf (_clampCorner == "TL")
				HAlign = "left"
				VAlign = "top"
			else
				_clampCorner == "TR"
				HAlign = "right"
				VAlign = "top"
			endIf

			UI.InvokeString(HUD_MENU, WidgetRoot + ".setClampCorner", _clampCorner) 
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
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setOrientation", _orientation) 
		endIf
	endFunction
endProperty

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	float[] numberArgs = new float[2]
	numberArgs[0] = _effectSize
	numberArgs[1] = _groupEffectCount
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init strings
	string[] stringArgs = new string[2]
	stringArgs[0] = _clampCorner
	stringArgs[1] = _orientation
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent