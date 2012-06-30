scriptname SKI_TextboxWidget extends SKI_WidgetBase

; PRIVATE VARIABLES ---------------------

float		_widgetWidth		= 200.0
int			_backgroundColor	= 0xFF0000
float		_backgroundAlpha	= 10.0
float		_borderWidth		= 5.0
int			_borderColor		= 0xFFFF00
float		_borderAlpha		= 10.0

bool		_borderRounded		= true

string		_labelText			= ""
string		_valueText			= ""


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
			_backgroundColor = a_val
		if (Initialized)
			;UpdateBackgroundColor()
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

; EVENTS ----------------------------
;public function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number,
; a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number)

event OnWidgetInit()
endEvent

; FUNCTIONS -------------------------

string function GetWidgetType()
	return "textbox"
endFunction

function ResetCustomProperties()
	SetParams(_widgetWidth, _backgroundColor, _backgroundAlpha, _borderWidth, _borderColor, _borderAlpha, _borderRounded)
	SetTextFormat()
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

function SetTextFormat()
	; TODO labelFontFace, labelFontColor, etc.
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

