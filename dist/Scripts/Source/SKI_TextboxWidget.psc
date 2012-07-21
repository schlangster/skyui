scriptname SKI_TextboxWidget extends SKI_WidgetBase

; PRIVATE VARIABLES ---------------------

float		_width				= 100.0

string		_labelText			= ""
string		_labelTextFont		= "$EverywhereFont"
int			_labelTextColor		= 0xFFFFFF
float		_labelTextSize		= 18.0

string		_valueText			= ""
string		_valueTextFont		= "$EverywhereFont"
int			_valueTextColor		= 0xFFFFFF
float		_valueTextSize		= 18.0

float		_paddingTop			= 0.0
float		_paddingRight		= 10.0
float		_paddingBottom		= 0.0
float		_paddingLeft		= 10.0

float		_borderWidth		= 5.0
int			_borderColor		= 0x000000
float		_borderAlpha		= 100.0
bool		_borderRounded		= true

int			_backgroundColor	= 0x333333
float		_backgroundAlpha	= 100.0


; PROPERTIES ----------------------------

; Set once before widget is initialised
float property Width
	{Width of the text box (excluding border) in pixels at a resolution of 1280x720}
	float function get()
		return _width
	endFunction
	
	function set(float a_val)
		_width = a_val
		if (Initialized)
			UI.InvokeNumber(HUD_MENU, WidgetRoot + "setWidgetWidth", _width)
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
	SetParams(_width, _backgroundColor, _backgroundAlpha, _borderWidth, _borderColor, _borderAlpha, _borderRounded, _paddingTop, _paddingRight, _paddingBottom, _paddingLeft)
	SetTextFormats(_labelTextFont, _labelTextColor, _labelTextSize, _valueTextFont, _valueTextColor, _valueTextSize)
	SetTexts(_labelText, _valueText)
endFunction

; WIDGET SPECIFIC FUNCS -------------

function SetParams(float a_widgetWidth, int a_backgroundColor, float a_backgroundAlpha, float a_borderWidth, int a_borderColor, float a_borderAlpha, bool a_borderRounded, float a_paddingTop, float a_paddingRight, float a_paddingBottom, float a_paddingLeft)
	float[] args = new float[11]
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
	
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "setWidgetParams", args)
endFunction

function SetTextFormats(string a_labelTextFont, int a_labelTextColor, float a_labelTextSize, string a_valueTextFont, int a_valueTextColor, float a_valueTextSize)
	; TODO labelFontFace, labelFontColor, etc.
	string[] args0 = new string[2]
	args0[0] = a_labelTextFont
	args0[1] = a_valueTextFont
	
	UI.InvokeStringA(HUD_MENU, WidgetRoot + "setWidgetTextFonts", args0)
	
	float[] args1 = new float[4]
	args1[0] = a_labelTextColor as float
	args1[1] = a_labelTextSize;
	args1[2] = a_valueTextColor as float
	args1[3] = a_valueTextSize;
	
	UI.InvokeNumberA(HUD_MENU, WidgetRoot + "setWidgetTextFormats", args1)
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

