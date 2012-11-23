scriptname SKI_MeterWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

float	_width		= 292.8
float	_height		= 25.2
int		_lightColor	= 0xFF0000
int		_darkColor	= -1
int		_flashColor	= -1
string 	_fillMode	= "center"
float	_percent	= 100.0


; PROPERTIES --------------------------------------------------------------------------------------

float property Width
	{Width of the meter in pixels at a resolution of 1280x720}
	float function get()
		return _width
	endFunction
	
	function set(float a_val)
		_width = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setWidth", _width)
		endIf
	endFunction
endProperty

float property Height
	{Height of the meter in pixels at a resolution of 1280x720}
	float function get()
		return _height
	endFunction
	
	function set(float a_val)
		_height = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setHeight", _height)
		endIf
	endFunction
endProperty

int property LightColor
	{Light color of the meter gradient}
	int function get()
		return _lightColor
	endFunction
	
	function set(int a_val)
		_lightColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setColor", _lightColor)
		endIf
	endFunction
endProperty

int property DarkColor
	{Dark color of the meter gradient, set as undefined, or negative and a dark colour will be chosen automatically.}
	int function get()
		return _darkColor
	endFunction
	
	function set(int a_val)
		_lightColor = a_val
		if (Initialized)
			int[] args = new int[2]
			args[0] = _lightColor
			args[1] = _darkColor
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setColors", args)
		endIf
	endFunction
endProperty

int property FlashColor
	{Color of the meter flash gradient, set as undefined, or negative and colours will be equal to LightColor}
	int function get()
		return _flashColor
	endFunction
	
	function set(int a_val)
		_flashColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setFlashColor", _flashColor)
		endIf
	endFunction
endProperty

string property FillMode
	{Fill direction of the meter, left, right or center}
	string function get()
		return _fillMode
	endFunction
	
	function set(string a_val)
		_fillMode = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setFillMode", _fillMode)
		endIf
	endFunction
endProperty

float property Percent
	{Fill direction of the meter, left, right or center}
	float function get()
		return _percent
	endFunction
	
	function set(float a_val)
		_fillMode = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setPercent", _percent)
		endIf
	endFunction
endProperty


; EVENTS ------------------------------------------------------------------------------------------

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()
	
	; Init numbers
	float[] numberArgs = new float[6]
	numberArgs[0] = _width
	numberArgs[1] = _height
	numberArgs[2] = _lightColor as float
	numberArgs[3] = _darkColor as float
	numberArgs[4] = _flashColor as float
	numberArgs[5] = _percent
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)
	
	; Init strings
	string[] stringArgs = new string[1]
	stringArgs[0] = _fillMode
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)
	
	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetType()
	return "meter"
endFunction

function SetMeterPercent(float a_percent, bool a_force = false)
	{a_force boolean sets the meter percent without animation}
	float[] args = new float[2]
	args[0] = a_percent as float
	args[1] = a_force as float
	
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setMeterPercent", args)
endFunction

function ForcetMeterPercent(float a_percent)
	{Sets the meter percent without animation, convenience function}
	SetMeterPercent(a_percent, true)
endFunction


function StartMeterFlash(bool a_force = false)
	{a_force boolean starts the meter flashint even if it's already flashing}
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".startMeterFlash", a_force)
endFunction


function ForceMeterFlash(bool a_force)
	{Starts the meter flashint even if it's already flashing, convenience function}
	StartMeterFlash(true)
endFunction