Scriptname SKI_MeterWidget extends SKI_WidgetBase  

float _percent = 50.0
bool _forced = false
bool _alwaysVisible = true
int _meterType = 3
int _orientation = 1
int _gradientStart = 0xFF00FF;0x565618
int _gradientEnd = 0x00FFFF;0xDFDF20
int _blinkColor = 0x00FFFF

function OnWidgetReset()
	parent.OnWidgetReset()
	;setGradient(_gradientStart, _gradientEnd)
	UpdateWidgetMeterType()
	UpdateWidgetMeterOrientation()
	UpdateWidgetAlwaysVisible()
	UpdateWidgetPercent()

	; Initialization has to happen in one go otherwise it gets all mucked for for some reason...
	SetParams(_meterType, _orientation, _forced, _alwaysVisible, _percent, _gradientStart, _gradientEnd, _blinkColor)
	
	; Debug
	RegisterForSingleUpdate(1)
endFunction

float property Percent
	float function get()
		return _percent
	endFunction
	
	function set(float a_val)
		_percent = a_val
		if (Initialized)
			UpdateWidgetPercent()
		endIf
	endFunction
endProperty

bool property Forced
	bool function get()
		return _forced
	endFunction
	
	function set(bool a_val)
		_forced = a_val
		if (Initialized)
			UpdateWidgetForced()
		endIf
	endFunction
endProperty

bool property AlwaysVisible
	bool function get()
		return _alwaysVisible
	endFunction
	
	function set(bool a_val)
		_alwaysVisible = a_val
		if (Initialized)
			UpdateWidgetAlwaysVisible()
		endIf
	endFunction
endProperty

int property MeterType
	int function get()
		return _meterType
	endFunction
	
	function set(int a_val)
		_meterType = a_val
		if (Initialized)
			UpdateWidgetMeterType()
		endIf
	endFunction
endProperty

int property Orientation
	int function get()
		return _orientation
	endFunction
	
	function set(int a_val)
		_orientation = a_val
		if (Initialized)
			UpdateWidgetMeterOrientation()
		endIf
	endFunction
endProperty

int property CustomFillStart
	int function get()
		return _gradientStart
	endFunction
	
	function set(int a_val)
		_gradientStart = a_val
		if (Initialized)
			setGradient(_gradientStart, _gradientEnd)
		endIf
	endFunction
endProperty

int property CustomFillEnd
	int function get()
		return _gradientEnd
	endFunction
	
	function set(int a_val)
		_gradientEnd = a_val
		if (Initialized)
			setGradient(_gradientStart, _gradientEnd)
		endIf
	endFunction
endProperty

int property CustomBlink
	int function get()
		return _blinkColor
	endFunction
	
	function set(int a_val)
		_blinkColor = a_val
		if (Initialized)
			UpdateWidgetMeterBlinkColor(_blinkColor)
		endIf
	endFunction
endProperty

; FUNCTIONS -------------------------

string function GetWidgetType()
	return "meter"
endFunction

function UpdateWidgetAlwaysVisible()
	UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetMeterAlwaysVisible", _alwaysVisible as float)
	Debug.Trace("UpdateWidgetAlwaysVisible - " + (_alwaysVisible as float))
endFunction

function UpdateWidgetForced()
	UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetMeterForced", _forced as float)
	Debug.Trace("UpdateWidgetForced - " + (_forced as float))
endFunction

function UpdateWidgetPercent()
	UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetMeterPercent", _percent)
	Debug.Trace("UpdateWidgetPercent - " + _percent)
endFunction

function UpdateWidgetMeterType()
	UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetMeterType", _meterType)
	Debug.Trace("UpdateWidgetPercent - " + _meterType)
endFunction

function UpdateWidgetMeterOrientation()
	UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetMeterOrientation", _orientation)
	Debug.Trace("UpdateWidgetMeterOrientation - " + _orientation)
endFunction

function UpdateWidgetMeterBlinkColor(int color)
	UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetMeterBlinkColor", _blinkColor)
endFunction

function startBlinking()
	UI.Invoke(HUD_MENU, WidgetRoot + "startWidgetMeterBlinking")
endFunction

function SetParams(int a_type, int a_orient, bool a_forced, bool a_alwaysShown, float a_percent, int a_fillStart, int a_fillEnd, int a_blinkColor)
	float[] args = new float[7]
	args[0] = a_type as float
	args[1] = a_orient as float
	args[2] = a_forced as float
	args[3] = a_alwaysShown as float
	args[4] = a_percent
	args[5] = a_fillStart as float
	args[6] = a_fillEnd as float
	args[7] = a_blinkColor as float
	
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "setWidgetMeterParams", args)
endFunction

function setGradient(int beginFill, int EndFill)
	float[] params = new float[2]
	params[0] = beginFill as float
	params[1] = EndFill as float
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "setWidgetMeterGradient", params)
endFunction

int st = 0

event OnUpdate()
	MeterType = Utility.RandomInt(0, 3)
	Orientation = Utility.RandomInt(0, 2)
	int randStart = Utility.RandomInt(0x000000, 0xFFFFFF)
	int randEnd = Utility.RandomInt(0x000000, 0xFFFFFF)
	setGradient(randStart, randEnd)
	Percent = Utility.RandomFloat(25, 100)
	CustomBlink = randEnd
	startBlinking()
	RegisterForSingleUpdate(1)
endEvent
