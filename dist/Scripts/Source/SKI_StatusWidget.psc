scriptname SKI_StatusWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

float		_widgetWidth				= 200.0
int			_backgroundColor 			= 0x333333
float		_backgroundAlpha			= 50.0

float		_borderWidth				= 5.0
int			_borderColor				= 0x000000
float		_borderAlpha				= 60.0
bool		_borderRounded				= true

float		_paddingTop					= 5.0
float		_paddingRight				= 5.0
float		_paddingBottom				= 5.0
float		_paddingLeft				= 5.0

int			_labelTextColor				= 0xFFFFFF
float		_labelTextSize				= 20.0
int			_valueTextColor				= 0xFFFFFF
float		_valueTextSize				= 20.0

float		_iconSize					= 25.0
int			_iconColor					= 0xFF32FF
float		_iconSpacing				= 5.0

int			_textAlign					= 0
int			_iconAlign					= 1

float		_meterPadding				= 5.0
float		_meterScale					= 50.0

int			_meterColorA				= 0xFF00FF
int			_meterColorB				= 0xFF99FF
int			_meterFlashColor			= 0x009900

string		_labelTextFont				= "$EverywhereFont"
string		_valueTextFont				= "$EverywhereFont"
string		_labelText					= "Vampire Sparkle"
string		_valueText					= "75%"
string		_iconSource					= "./skyui/skyui_icons_psychosteve.swf"
string		_iconName					= "mag_conjuration"
string		_meterFillMode				= "right"


; PROPERTIES --------------------------------------------------------------------------------------

; Set once before widget is initialised
float property Width
	{Width of the text box (excluding border) in pixels at a resolution of 1280x720}
	float function get()
		return _widgetWidth
	endFunction
	
	function set(float a_val)
		_widgetWidth = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setWidgetWidth", _widgetWidth)
		endIf
	endFunction
endProperty

int property BackgroundColor
	int function get()
		return _backgroundColor
	endFunction
	
	function set(int a_val)
		_backgroundColor = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBackgroundColor", _backgroundColor) 
		endIf
	endFunction
endProperty

float property BackgroundAlpha
	float function get()
		return _backgroundAlpha
	endFunction
	
	function set(float a_val)
		_backgroundAlpha = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBackgroundAlpha", _backgroundAlpha) 
		endIf
	endFunction
endProperty

int property BorderColor
	int function get()
		return _borderColor
	endFunction
	
	function set(int a_val)
		_borderColor = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBorderColor", _borderColor) 
		endIf
	endFunction
endProperty

float property BorderWidth
	float function get()
		return _borderWidth
	endFunction
	
	function set(float a_val)
		_borderWidth = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBorderWidth", _borderWidth) 
		endIf
	endFunction
endProperty

float property BorderAlpha
	float function get()
		return _borderAlpha
	endFunction
	
	function set(float a_val)
		_borderAlpha = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBorderAlpha", _borderAlpha) 
		endIf
	endFunction
endProperty

bool property BorderRounded
	bool function get()
		return _borderRounded
	endFunction
	
	function set(bool a_val)
		_borderRounded = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setBorderRounded", _borderRounded as int) 
		endIf
	endFunction
endProperty

string property LabelText
	string function get()
		return _labelText
	endFunction
	
	function set(string a_val)
		_labelText = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setLabelText", _labelText) 
		endIf
	endFunction
endProperty

int property LabelTextColor
	int function get()
		return _labelTextColor
	endFunction
	
	function set(int a_val)
		_labelTextColor = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setLabelTextColor", _labelTextColor) 
		endIf
	endFunction
endProperty

string property LabelTextFont
	string function get()
		return _labelTextFont
	endFunction
	
	function set(string a_val)
		_labelTextFont = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setLabelTextFont", _labelTextFont) 
		endIf
	endFunction
endProperty

string property ValueText
	string function get()
		return _valueText
	endFunction
	
	function set(string a_val)
		_valueText = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setValueText", _valueText) 
		endIf
	endFunction
endProperty

int property ValueTextColor
	int function get()
		return _valueTextColor
	endFunction
	
	function set(int a_val)
		_valueTextColor = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setValueTextColor", _valueTextColor) 
		endIf
	endFunction
endProperty

string property ValueTextFont
	string function get()
		return _valueTextFont
	endFunction
	
	function set(string a_val)
		_valueTextFont = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setValueTextFont", _valueTextFont) 
		endIf
	endFunction
endProperty
	
float property PaddingTop
	float function get()
		return _paddingTop
	endFunction
	
	function set(float a_val)
		_paddingTop = a_val
		if (Initialized)
			UpdatePadding()
		endIf
	endFunction
endProperty

float property PaddingRight
	float function get()
		return _paddingRight
	endFunction
	
	function set(float a_val)
		_paddingRight = a_val
		if (Initialized)
			UpdatePadding()
		endIf
	endFunction
endProperty

float property PaddingBottom
	float function get()
		return _paddingBottom
	endFunction
	
	function set(float a_val)
		_paddingBottom = a_val
		if (Initialized)
			UpdatePadding()
		endIf
	endFunction
endProperty

float property PaddingLeft
	float function get()
		return _paddingLeft
	endFunction
	
	function set(float a_val)
		_paddingLeft = a_val
		if (Initialized)
			UpdatePadding()
		endIf
	endFunction
endProperty

; EVENTS ------------------------------------------------------------------------------------------

; @override SKI_WidgetBase
event OnWidgetInit()
endEvent

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()
	
	; Init numbers
	float[] numberArgs = new float[25]
	numberArgs[0] = _widgetWidth
	numberArgs[1] = _backgroundColor as float
	numberArgs[2] = _backgroundAlpha
	numberArgs[3] = _borderWidth
	numberArgs[4] = _borderColor as float
	numberArgs[5] = _borderAlpha
	numberArgs[6] = _borderRounded as float
	numberArgs[7] = _paddingTop
	numberArgs[8] = _paddingRight
	numberArgs[9] = _paddingBottom
	numberArgs[10] = _paddingLeft
	numberArgs[11] = _labelTextColor as float
	numberArgs[12] = _labelTextSize
	numberArgs[13] = _valueTextColor as float
	numberArgs[14] = _valueTextSize
	numberArgs[15] = _iconSize
	numberArgs[16] = _iconColor as float
	numberArgs[17] = _iconSpacing
	numberArgs[18] = _textAlign as float
	numberArgs[19] = _iconAlign as float
	numberArgs[20] = _meterPadding
	numberArgs[21] = _meterScale
	numberArgs[22] = _meterColorA as float
	numberArgs[23] = _meterColorB as float
	numberArgs[24] = _meterFlashColor as float
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)
	
	; Init strings
	string[] stringArgs = new string[7]
	stringArgs[0] = _labelTextFont
	stringArgs[1] = _valueTextFont
	stringArgs[2] = _labelText
	stringArgs[3] = _valueText
	stringArgs[4] = _iconSource
	stringArgs[5] = _iconName
	stringArgs[6] = _meterFillMode
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)
	
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
	
	; DEBUG
	RegisterForSingleUpdate(1)
endEvent

event OnUpdate()
	UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setMeterPercent", 75)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @override SKI_WidgetBase
string function GetWidgetType()
	return "status"
endFunction

function SetTexts(string a_labelText, string a_valueText)
	string[] args = new string[2]
	args[0] = a_labelText
	args[1] = a_valueText
	
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".setTexts", args)
endFunction

function UpdatePadding()
	float[] args = new float[4]
	args[0] = _paddingTop
	args[1] = _paddingRight
	args[2] = _paddingBottom
	args[3] = _paddingLeft
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + ".setPadding", args)
endFunction


