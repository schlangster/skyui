scriptname SKI_StatusWidget extends SKI_WidgetBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

float		_width						= 200.0
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
int			_iconColor					= 0xFFFFFF ;0xFF32FF
float		_iconAlpha					= 100.0
float		_iconSpacing				= 5.0

float		_meterScale					= 50.0
int			_meterColorA				= 0x660000 ;0xFF00FF
int			_meterColorB				= 0xCC3333 ;0xFF99FF
float		_meterAlpha					= 100.0
float		_meterSpacing				= 5.0

int			_meterFlashColor			= 0x990000 ;0x990099

string		_labelText					= " "; "Vampire Sparkle"
string		_labelTextFont				= "$EverywhereFont"

string		_valueText					= " " ;"100%"
string		_valueTextFont				= "$EverywhereFont"


string		_textAlign					= "border"

string		_iconSource					= "" ;"./skyui/skyui_icons_psychosteve.swf"
string		_iconName					= "" ;"mag_conjuration"
string		_iconAlign					= "left"

string		_meterFillMode				= "right"


; PROPERTIES --------------------------------------------------------------------------------------

; Set once before widget is initialised
float property Width
	{Width of the widget (excluding border) in pixels at a resolution of 1280x720}
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

int property BackgroundColor
	{Color of the background as a decimal integer}
	int function get()
		return _backgroundColor
	endFunction
	
	function set(int a_val)
		_backgroundColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBackgroundColor", _backgroundColor) 
		endIf
	endFunction
endProperty

float property BackgroundAlpha
	{Opacity of the background as a percent}
	float function get()
		return _backgroundAlpha
	endFunction
	
	function set(float a_val)
		_backgroundAlpha = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setBackgroundAlpha", _backgroundAlpha) 
		endIf
	endFunction
endProperty

float property BorderWidth
	{Width of the border in pixels at a resolution of 1280x720}
	float function get()
		return _borderWidth
	endFunction
	
	function set(float a_val)
		_borderWidth = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setBorderWidth", _borderWidth) 
		endIf
	endFunction
endProperty

int property BorderColor
	{Color of the border as a decimal integer}
	int function get()
		return _borderColor
	endFunction
	
	function set(int a_val)
		_borderColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBorderColor", _borderColor) 
		endIf
	endFunction
endProperty

float property BorderAlpha
	{Opacity of the background as a percent}
	float function get()
		return _borderAlpha
	endFunction
	
	function set(float a_val)
		_borderAlpha = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setBorderAlpha", _borderAlpha) 
		endIf
	endFunction
endProperty

bool property BorderRounded
	{"True" gives the border round corners, "False" gives it square ones}
	bool function get()
		return _borderRounded
	endFunction
	
	function set(bool a_val)
		_borderRounded = a_val
		if (Initialized)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setBorderRounded", _borderRounded) 
		endIf
	endFunction
endProperty

float property PaddingTop
	{Distance between the top of the widget, excluding border, and the largest TextField in pixels at a resolution of 1280x720}
	float function get()
		return _paddingTop
	endFunction
	
	function set(float a_val)
		_paddingTop = a_val
		if (Initialized)
			SetPadding(_paddingTop, _paddingRight, _paddingBottom, _paddingLeft)
		endIf
	endFunction
endProperty

float property PaddingRight
	{Distance between the right of the widget, excluding border, and the value TextField in pixels at a resolution of 1280x720}
	float function get()
		return _paddingRight
	endFunction
	
	function set(float a_val)
		_paddingRight = a_val
		if (Initialized)
			SetPadding(_paddingTop, _paddingRight, _paddingBottom, _paddingLeft)
		endIf
	endFunction
endProperty

float property PaddingBottom
	{Distance between the bottom of the widget, excluding border, and the meter in pixels at a resolution of 1280x720}
	float function get()
		return _paddingBottom
	endFunction
	
	function set(float a_val)
		_paddingBottom = a_val
		if (Initialized)
			SetPadding(_paddingTop, _paddingRight, _paddingBottom, _paddingLeft)
		endIf
	endFunction
endProperty

float property PaddingLeft
	{Distance between the left of the widget, excluding border, and the label TextField in pixels at a resolution of 1280x720}
	float function get()
		return _paddingLeft
	endFunction
	
	function set(float a_val)
		_paddingLeft = a_val
		if (Initialized)
			SetPadding(_paddingTop, _paddingRight, _paddingBottom, _paddingLeft)
		endIf
	endFunction
endProperty

int property LabelTextColor
	{Color of the label text as a decimal integer}
	int function get()
		return _labelTextColor
	endFunction
	
	function set(int a_val)
		_labelTextColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setLabelTextColor", _labelTextColor) 
		endIf
	endFunction
endProperty

float property LabelTextSize
	{Font size of the label text}
	float function get()
		return _labelTextSize
	endFunction
	
	function set(float a_val)
		_labelTextSize = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setLabelTextSize", _labelTextSize) 
		endIf
	endFunction
endProperty

int property ValueTextColor
	{Color of the value text as a decimal integer}
	int function get()
		return _valueTextColor
	endFunction
	
	function set(int a_val)
		_valueTextColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setValueTextColor", _valueTextColor) 
		endIf
	endFunction
endProperty

float property ValueTextSize
	{Font size of the label text}
	float function get()
		return _valueTextSize
	endFunction
	
	function set(float a_val)
		_valueTextSize = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setValueTextSize", _valueTextSize) 
		endIf
	endFunction
endProperty

float property IconSize
	{Height, and width, of the icon in pixels at a resolution of 1280x720}
	float function get()
		return _iconSize
	endFunction
	
	function set(float a_val)
		_iconSize = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setIconSize", _iconSize) 
		endIf
	endFunction
endProperty

int property IconColor
	{Color of the icon as a decimal integer}
	int function get()
		return _iconColor
	endFunction
	
	function set(int a_val)
		_iconColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setIconColor", _iconColor) 
		endIf
	endFunction
endProperty

float property IconAlpha
	{Opacity of the icon as a percent}
	float function get()
		return _iconAlpha
	endFunction
	
	function set(float a_val)
		_iconAlpha = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setIconAlpha", _iconAlpha) 
		endIf
	endFunction
endProperty

float property IconSpacing
	{Distance between the icon and the label TextField in pixels at a resolution of 1280x720}
	float function get()
		return _iconSpacing
	endFunction
	
	function set(float a_val)
		_iconSpacing = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setIconSpacing", _iconSpacing) 
		endIf
	endFunction
endProperty

float property MeterScale
	{Scale of the meter as a percentage}
	float function get()
		return _meterScale
	endFunction
	
	function set(float a_val)
		_meterScale = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setMeterScale", _meterScale) 
		endIf
	endFunction
endProperty

int property MeterColorA
	{Initial color of the meter gradient fill as a decimal integer}
	int function get()
		return _meterColorA
	endFunction
	
	function set(int a_val)
		_meterColorA = a_val
		if (Initialized)
			SetMeterColors(_meterColorA, _meterColorB)
		endIf
	endFunction
endProperty

int property MeterColorB
	{Final color of the meter gradient fill as a decimal integer}
	int function get()
		return _meterColorB
	endFunction
	
	function set(int a_val)
		_meterColorB = a_val
		if (Initialized)
			SetMeterColors(_meterColorA, _meterColorB)
		endIf
	endFunction
endProperty

float property MeterAlpha
	{Opacity of the meter as a percentage}
	float function get()
		return _meterAlpha
	endFunction
	
	function set(float a_val)
		_meterAlpha = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setMeterAlpha", _meterAlpha) 
		endIf
	endFunction
endProperty

float property MeterSpacing
	{Distance between the icon and the label TextField in pixels at a resolution of 1280x720}
	float function get()
		return _meterSpacing
	endFunction
	
	function set(float a_val)
		_meterSpacing = a_val
		if (Initialized)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setMeterSpacing", _meterSpacing) 
		endIf
	endFunction
endProperty

int property MeterFlashColor
	{Color of the meter flash overlay}
	int function get()
		return _meterFlashColor
	endFunction
	
	function set(int a_val)
		_meterFlashColor = a_val
		if (Initialized)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setMeterFlashColor", _meterFlashColor)
		endIf
	endFunction
endProperty

string property LabelText
	{Text for the label TextField}
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

string property LabelTextFont
	{Fontface for the label TextField}
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
	{Text for the value TextField}
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

string property ValueTextFont
	{Fontface for the value TextField}
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

string property TextAlign
	{Align mode of the TextFields, either border, left, right, or center}
	string function get()
		return _textAlign
	endFunction
	
	function set(string a_val)
		_textAlign = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setTextAlign", _textAlign) 
		endIf
	endFunction
endProperty

string property IconSource
	{Path to icon swf relative to \skyrim_dir\Data\Interface}
	string function get()
		return _iconSource
	endFunction
	
	function set(string a_val)
		_iconSource = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setIconSource", _iconSource) 
		endIf
	endFunction
endProperty

string property IconName
	{Frame label of the icon swf}
	string function get()
		return _iconName
	endFunction
	
	function set(string a_val)
		_iconName = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setIconName", _iconName) 
		endIf
	endFunction
endProperty

string property IconAlign
	{Align mode of the icon, either left, or right}
	string function get()
		return _iconAlign
	endFunction
	
	function set(string a_val)
		_iconAlign = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setIconAlign", _iconAlign) 
		endIf
	endFunction
endProperty

string property MeterFillMode
	{Fill mode of the meter, either left, right, or center}
	string function get()
		return _meterFillMode
	endFunction
	
	function set(string a_val)
		_meterFillMode = a_val
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setMeterFillMode", _meterFillMode) 
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
	numberArgs[0] = _width
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
	numberArgs[17] = _iconAlpha
	numberArgs[18] = _iconSpacing
	numberArgs[19] = _meterScale
	numberArgs[20] = _meterColorA as float
	numberArgs[21] = _meterColorB as float
	numberArgs[22] = _meterAlpha
	numberArgs[23] = _meterSpacing
	numberArgs[24] = _meterFlashColor as float
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)
	
	; Init strings
	string[] stringArgs = new string[9]
	stringArgs[0] = _labelText
	stringArgs[1] = _labelTextFont
	stringArgs[2] = _valueText
	stringArgs[3] = _valueTextFont
	stringArgs[4] = _textAlign
	stringArgs[5] = _iconSource
	stringArgs[6] = _iconName
	stringArgs[7] = _iconAlign
	stringArgs[8] = _meterFillMode
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)
	
	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")
	
	; DEBUG
	;RegisterForSingleUpdate(10)
endEvent

event OnUpdate()
	;UI.InvokeNumber(HUD_MENU, WidgetRoot + ".setMeterPercent", 75)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetType()
	return "status"
endFunction

function SetPadding(float a_paddingTop, float a_paddingRight, float a_paddingBottom, float a_paddingLeft)
	float[] args = new float[4]
	args[0] = a_paddingTop
	args[1] = a_paddingRight
	args[2] = a_paddingBottom
	args[3] = a_paddingLeft
	
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setPadding", args)
endFunction

function SetTexts(string a_labelText, string a_valueText)
	string[] args = new string[2]
	args[0] = a_labelText
	args[1] = a_valueText
	
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".setTexts", args)
endFunction

; INTERFACE ------------------------------------------------------------

function SetMeterColors(int a_meterColorA, int a_meterColorB)
	int[] args = new int[2]
	args[0] = a_meterColorA
	args[1] = a_meterColorB
	
	UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setMeterColors", args)
endFunction

function SetMeterPercent(float a_percent, bool a_force = false)
	{a_force boolean sets the meter percent without animation}
	float[] args = new float[2]
	args[0] = a_percent as float
	args[1] = a_force as float
	
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setMeterPercent", args)
endFunction

function StartMeterFlash(bool a_force = false)
	{a_force boolean starts the flashing animation from the beginning even if it's already flashing}
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".startMeterFlash", a_force)
endFunction
