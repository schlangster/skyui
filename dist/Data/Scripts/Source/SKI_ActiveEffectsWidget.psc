scriptname SKI_ActiveEffectsWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------
; Make sure defaults match those in ConfigMenuInstance
float	_effectSize	= 48.0

string function GetWidgetType()
	return "activeeffects"
endFunction

; @overrides SKI_WidgetBase
event onInit()
	parent.onInit()
endEvent

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

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	float[] numberArgs = new float[1]
	numberArgs[0] = _effectSize

	UI.InvokeNumberA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent