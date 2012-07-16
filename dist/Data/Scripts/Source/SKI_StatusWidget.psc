scriptname SKI_StatusWidget extends SKI_WidgetBase

; PRIVATE VARIABLES ---------------------
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

; PROPERTIES ----------------------------

; Set once before widget is initialised
float property Width
	{Width of the text box (excluding border) in pixels at a resolution of 1280x720}
	float function get()
		return _widgetWidth
	endFunction
	
	function set(float a_val)
		_widgetWidth = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetWidth", _widgetWidth)
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBackgroundColor", _backgroundColor) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBackgroundAlpha", _backgroundAlpha) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBorderColor", _borderColor) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBorderWidth", _borderWidth) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBorderAlpha", _borderAlpha) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetBorderRounded", _borderRounded as int) 
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
			UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetLabelText", _labelText) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetLabelTextColor", _labelTextColor) 
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
			UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetLabelTextFont", _labelTextFont) 
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
			UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetValueText", _valueText) 
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
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetValueTextColor", _valueTextColor) 
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
			UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetValueTextFont", _valueTextFont) 
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

; EVENTS ----------------------------

event OnWidgetInit()
endEvent

; FUNCTIONS -------------------------

string function GetWidgetType()
	return "textbox"
endFunction

function OnWidgetReset()
	parent.OnWidgetReset()
	InitNumbers(_widgetWidth, _backgroundColor, _backgroundAlpha, _borderWidth, _borderColor, \
						_borderAlpha, _borderRounded, _paddingTop, _paddingRight, _paddingBottom, \
						_paddingLeft, _labelTextColor, _labelTextSize, _valueTextColor, _valueTextSize, \
						_iconSize, _iconColor, _iconSpacing, _textAlign, _iconAlign, \
						_meterPadding, _meterScale, _meterColorA, _meterColorB, _meterFlashColor)
	InitStrings(_labelTextFont, _valueTextFont, _labelText, _valueText, _iconSource, \
						_iconName, _meterFillMode)
	UI.Invoke(HUD_MENU, WidgetRoot + "initWidgetCommit")
	
	; DEBUG
	RegisterForSingleUpdate(1)
endFunction

; WIDGET SPECIFIC FUNCS -------------

function InitNumbers(float a_widgetWidth, int a_backgroundColor, float a_backgroundAlpha, float a_borderWidth, int  a_borderColor, \
							float a_borderAlpha, bool a_borderRounded, float a_paddingTop, float a_paddingRight, float a_paddingBottom, \
							float a_paddingLeft, int a_labelTextColor, float a_labelTextSize, int a_valueTextColor, float a_valueTextSize, \
							float a_iconSize, int a_iconColor, float a_iconSpacing, int a_textAlign, int a_iconAlign, \
							float a_meterPadding, float a_meterScale, int a_meterColorA, int a_meterColorB, int a_meterFlashColor)
	float[] args = new float[25]
	
	args[0] = a_widgetWidth
	args[1] = a_backgroundColor as float
	args[2] = a_backgroundAlpha
	args[3] = a_borderWidth
	args[4] = a_borderColor as float
	args[5] = a_borderAlpha
	args[6] = a_borderRounded as float
	args[7] = a_paddingTop
	args[8] = a_paddingRight
	args[9] = a_paddingBottom
	args[10] = a_paddingLeft
	args[11] = a_labelTextColor as float
	args[12] = a_labelTextSize
	args[13] = a_valueTextColor as float
	args[14] = a_valueTextSize
	args[15] = a_iconSize
	args[16] = a_iconColor as float
	args[17] = a_iconSpacing
	args[18] = a_textAlign as float
	args[19] = a_iconAlign as float
	args[20] = a_meterPadding
	args[21] = a_meterScale
	args[22] = a_meterColorA as float
	args[23] = a_meterColorB as float
	args[24] = a_meterFlashColor as float
	
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "initWidgetNumbers", args)
endFunction

function InitStrings(string a_labelTextFont, string a_valueTextFont, string a_labelText, string a_valueText, string a_iconSource, \
							string a_iconName, string a_meterFillMode)
	string[] args = new string[7]
	args[0] = a_labelTextFont
	args[1] = a_valueTextFont
	args[2] = a_labelText
	args[3] = a_valueText
	args[4] = a_iconSource
	args[5] = a_iconName
	args[6] = a_meterFillMode
	
	UI.InvokeStringA(HUD_MENU, WidgetRoot + "initWidgetStrings", args)
endFunction

function SetTexts(string a_labelText, string a_valueText)
	string[] args = new string[2]
	args[0] = a_labelText
	args[1] = a_valueText
	
	UI.InvokeStringA(HUD_MENU, WidgetRoot + "setWidgetTexts", args)
endFunction

function UpdatePadding()
	float[] args = new float[4]
	args[0] = _paddingTop
	args[1] = _paddingRight
	args[2] = _paddingBottom
	args[3] = _paddingLeft
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "setWidgetPadding", args)
endFunction

event OnUpdate()
	UI.InvokeNumber(HUD_MENU, WidgetRoot + "setMeterPercent", 75)
endEvent
