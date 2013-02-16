scriptname SKI_MiniMapWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Make sure defaults match those in ConfigMenuInstance
bool	_enabled			= false


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

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()

	; Init numbers
	float[] numberArgs = new float[1]
	numberArgs[0] = _enabled as float
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetSource()
	return "skyui/minimap.swf"
endFunction

; @overrides SKI_WidgetBase
string function GetWidgetType()
 return "SKI_MiniMapWidget"
endFunction