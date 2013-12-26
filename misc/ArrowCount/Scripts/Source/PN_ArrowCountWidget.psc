scriptname PN_ArrowCountWidget extends SKI_WidgetBase  

; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool	_visible			= false
int		_count				= 0


; PROPERTIES --------------------------------------------------------------------------------------

bool Property Visible
	bool function get()
		return _visible
	endFunction

	function set(bool a_val)
		_visible = a_val
		if (Ready)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", _visible) 
		endIf
	endFunction
endProperty

int property Count
	int function get()
		return _count
	endFunction

	function set(int a_val)
		_count = a_val
		if (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setCount", _count) 
		endIf
	endFunction
endProperty


; EVENTS ------------------------------------------------------------------------------------------

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()
	
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", _visible)
	UI.InvokeInt(HUD_MENU, WidgetRoot + ".setCount", _count)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetSource()
	return "skyui/arrowcount.swf"
endFunction

; @overrides SKI_WidgetBase
string function GetWidgetType()
	; Must be the same as scriptname
	return "SKI_ArrowCountWidget"
endFunction