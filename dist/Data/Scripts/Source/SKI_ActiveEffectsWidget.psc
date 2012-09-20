scriptname SKI_ActiveEffectsWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; Config
; Make sure defaults match those in ConfigMenuInstance
float	_effectSize				= 48.0

; private
int		_maxEffectsGroupLength	= 8

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

int property MaxEffectsGroupLength
	{Maximum number of widgets displayed until a new group (column, or row) is created}
	int function get()
		return _maxEffectsGroupLength
	endFunction

	function set(int a_val)
		_maxEffectsGroupLength = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setMaxEffectsGroupLength", _maxEffectsGroupLength) 
		endIf
	endFunction
endProperty

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	float[] numberArgs = new float[2]
	numberArgs[0] = _effectSize
	numberArgs[1] = _maxEffectsGroupLength
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init strings
	string[] stringArgs = new string[2]
	stringArgs[0] = "left"
	stringArgs[1] = "down"
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent