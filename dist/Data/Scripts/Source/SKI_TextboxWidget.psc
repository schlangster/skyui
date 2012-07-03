scriptname SKI_TextboxWidget extends SKI_WidgetBase

; PRIVATE VARIABLES ---------------------

float		_widgetWidth		= 200.0
int			_backgroundColor	= 0x333333
float		_backgroundAlpha	= 10.0
float		_borderWidth		= 5.0
int			_borderColor		= 0x000000
float		_borderAlpha		= 10.0

bool		_borderRounded		= true

string		_labelText			= ""
string		_labelTextFont		= "$SkyrimBooks"
int			_labelTextColor		= 0xFFFFFF
int			_labelTextSize		= 22

string		_valueText			= ""
string		_valueTextFont		= "$SkyrimBooks"
int			_valueTextColor		= 0xFFFFFF
int			_valueTextSize		= 22


; PROPERTIES ----------------------------

; Set once before widget is initialised
float property WidgetWidth
	float function get()
		return _widgetWidth
	endFunction
	
	function set(float a_val)
		if (!Initialized)
			_widgetWidth = a_val
		endIf
	endFunction
endProperty

int property BackgroundColor
	int function get()
		return _backgroundColor
	endFunction
	
	function set(int a_val)
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
			;UpdateBackgroundAlpha()
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
			;UpdateBorderWidth()
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
			;UpdateBorderColor()
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
			;UpdateBorderAlpha()
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
			;UpdateBorderRounded()
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
			UpdateLabelText()
		endIf
	endFunction
endProperty

int property LabelTextColor
	int function get()
		return _labelTextColor
	endFunction
	
	function set(int a_val)
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
			UpdateValueText()
		endIf
	endFunction
endProperty

int property ValueTextColor
	int function get()
		return _valueTextColor
	endFunction
	
	function set(int a_val)
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
		if (Initialized)
			UI.InvokeString(HUD_MENU, WidgetRoot + "setWidgetValueTextFont", _valueTextFont) 
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

function ResetCustomProperties()
	SetParams(_widgetWidth, _backgroundColor, _backgroundAlpha, _borderWidth, _borderColor, _borderAlpha, _borderRounded)
	SetTextFormats(_labelTextFont, _labelTextColor, _labelTextSize, _valueTextFont, _valueTextColor, _valueTextSize)
	SetTexts(_labelText, _valueText)
endFunction

; WIDGET SPECIFIC FUNCS -------------

function SetParams(float a_widgetWidth, int a_backgroundColor, float a_backgroundAlpha, float a_borderWidth, int a_borderColor, float a_borderAlpha, bool a_borderRounded)
	float[] args = new float[7]
	args[0] = a_widgetWidth
	args[1] = a_backgroundColor as float
	args[2] = a_backgroundAlpha
	args[3] = a_borderWidth
	args[4] = a_borderColor as float
	args[5] = a_borderAlpha
	args[6] = a_borderRounded as float
	
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

function UpdateLabelText()
	; Do stuff here
endFunction

function UpdateValueText()
	; Do stuff here
endFunction

