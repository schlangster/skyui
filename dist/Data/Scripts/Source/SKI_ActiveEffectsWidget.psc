scriptname SKI_ActiveEffectsWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; Config
; Make sure defaults match those in ConfigMenuInstance
float	_effectSize				= 48.0

; private
int		_groupEffectCount	= 8
string	_hGrowDirection		= "left"
string	_vGrowDirection		= "down"
string	_growAxis			= "horizontal"
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

string property HGrowDirection
	{Direction in which new effects get added on the vertical axis}
	string function get()
		return _hGrowDirection
	endFunction

	function set(string a_val)
		_hGrowDirection = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setHGrowDirection", _hGrowDirection) 
		endIf
	endFunction
endProperty

string property VGrowDirection
	{Direction in which new effects get added on the horizontal axis}
	string function get()
		return _vGrowDirection
	endFunction

	function set(string a_val)
		_vGrowDirection = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setVGrowDirection", _vGrowDirection) 
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
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setClampCorner", _clampCorner) 
		endIf
	endFunction
endProperty

string property GrowAxis
	{The axis in which new effects will be added to after the total number of effects > GroupEffectCount}
	string function get()
		return _growAxis
	endFunction

	function set(string a_val)
		_growAxis = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setGrowAxis", _growAxis) 
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
	stringArgs[1] = _growAxis
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent