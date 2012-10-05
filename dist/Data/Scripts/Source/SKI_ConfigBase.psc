scriptname SKI_ConfigBase extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MENU_ROOT		= "_root.ConfigPanelFader.configPanel" autoReadonly

int property		STATE_DEFAULT	= 0 autoReadonly
int property		STATE_RESET		= 1 autoReadonly
int property		STATE_SLIDER	= 2 autoReadonly
int property		STATE_MENU		= 3 autoReadonly
int property		STATE_COLOR		= 4 autoReadonly

int property		OPTION_TYPE_EMPTY	= 0x00 autoReadonly
int property		OPTION_TYPE_HEADER	= 0x01 autoReadonly
int property		OPTION_TYPE_TEXT	= 0x02 autoReadonly
int property		OPTION_TYPE_TOGGLE	= 0x03 autoReadonly
int property 		OPTION_TYPE_SLIDER	= 0x04 autoReadonly
int property		OPTION_TYPE_MENU	= 0x05 autoReadonly
int property		OPTION_TYPE_COLOR	= 0x06 autoReadonly
int property		OPTION_TYPE_KEYMAP	= 0x07 autoReadonly

int property		OPTION_FLAG_NONE		= 0x0000 autoReadonly
int property		OPTION_FLAG_DISABLED	= 0x0100 autoReadonly

int property		LEFT_TO_RIGHT	= 1	autoReadonly
int property		TOP_TO_BOTTOM	= 2 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_ConfigManager	_configManager
bool				_initialized	= false
int					_configID		= -1

; Keep track of what we're doing at the moment for stupidity checks
int					_state			= 0

int					_cursorPosition	= 0
int					_cursorFillMode	= 1 ;LEFT_TO_RIGHT

; Local buffers
float[]				_optionFlagsBuf	; byte 1 type, byte 2 flags
string[]			_textBuf
string[]			_strValueBuf
float[]				_numValueBuf

float[]				_sliderParams
float[]				_menuParams
float[]				_colorParams

int					_activeOption	= -1

string				_infoText


; PROPERTIES --------------------------------------------------------------------------------------

string property		ModName auto
string[] property	Pages auto
string property		CurrentPage auto hidden


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_optionFlagsBuf	= new float[128]
	_textBuf		= new string[128]
	_strValueBuf	= new string[128]
	_numValueBuf	= new float[128]

	; 0 startValue
	; 1 defaultValue
	; 2 minValue
	; 3 maxValue
	; 4 interval
	_sliderParams	= new float[5]

	; 0 startIndex
	; 1 defaultIndex
	_menuParams		= new float[2]

	; 0 currentColor
	; 1 defaultColor
	_colorParams	= new float[2]
	
	RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReady")
endEvent

event OnConfigManagerReady(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	SKI_ConfigManager newManager = a_sender as SKI_ConfigManager

	; Already registered?
	if (_configManager == newManager)
		return
	endIf
	
	_configManager =  newManager
	
	_configID = _configManager.RegisterMod(self, ModName)
	if (_configID != -1)
		OnConfigRegister()
		_initialized = true
	endIf
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnConfigRegister()
endEvent

; @interface
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}
endEvent

; @interface
event OnOptionHighlight(int a_option)
	{Called when highlighting an option}
endEvent

; @interface
event OnOptionSelect(int a_option)
	{Called when a non-interactive option has been selected}
endEvent

; @interface
event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}
endEvent

; @interface
event OnOptionSliderOpen(int a_option)
	{Called when a slider option has been selected}
endEvent

; @interface
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when a new slider value has been accepted}
endEvent

; @interface
event OnOptionMenuOpen(int a_option)
	{Called when a menu option has been selected}
endEvent

; @interface
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when a menu entry has been accepted}
endEvent

; @interface
event OnOptionColorOpen(int a_option)
	{Called when a color option has been selected}
endEvent

; @interface
event OnOptionColorAccept(int a_option, int a_color)
	{Called when a new color has been accepted}
endEvent

; @interface
event OnOptionKeyMapChange(int a_option, int a_keyCode)
	{Called when a key has been remapped}
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Error(string a_msg)
	Debug.Trace(self + " ERROR: " +  a_msg)
endFunction

function SetPage(string a_page)
	CurrentPage = a_page
	
	; Set default title, can be overridden in OnPageReset
	if (a_page != "")
		SetTitleText(a_page)
	else
		SetTitleText(ModName)
	endIf
	
	_state = STATE_RESET
	OnPageReset(a_page)
	_state = STATE_DEFAULT
	FlushOptionBuffers()
endFunction

int function AddOption(int a_optionType, string a_text, string a_strValue, float a_numValue, int a_flags)
	if (_state != STATE_RESET)
		Error("Cannot add option " + a_text + " outside of OnPageReset()")
		return -1
	endIf

	int id = _cursorPosition
	if (id == -1)
		return -1
	endIf
	
	_optionFlagsBuf[id] = a_optionType + a_flags
	_textBuf[id] = a_text
	_strValueBuf[id] = a_strValue
	_numValueBuf[id] = a_numValue
	
	; Just use numerical value of fill mode
	_cursorPosition += _cursorFillMode
	if (_cursorPosition >= 128)
		_cursorPosition = -1
	endIf
	
	return id
endFunction

function FlushOptionBuffers()
	string menu = JOURNAL_MENU
	string root = MENU_ROOT
	int t = OPTION_TYPE_EMPTY
	int i = 0
	int optionCount = 0;

	; Tell UI where to cut off the buffer
	i = 0
	while (i < 128)
		if (_optionFlagsBuf[i] != t)
			optionCount = i + 1
		endif
		i += 1
	endWhile
	
	UI.InvokeNumberA(menu, root + ".setOptionFlagsBuffer", _optionFlagsBuf)
	UI.InvokeStringA(menu, root + ".setOptionTextBuffer", _textBuf)
	UI.InvokeStringA(menu, root + ".setOptionStrValueBuffer", _strValueBuf)
	UI.InvokeNumberA(menu, root + ".setOptionNumValueBuffer", _numValueBuf)
	UI.InvokeNumber(menu, root + ".flushOptionBuffers", optionCount)

	i = 0
	while (i < 128)
		_optionFlagsBuf[i] = t
		_textBuf[i] = none
		_strValueBuf[i] = none
		_numValueBuf[i] = 0
		i += 1
	endWhile

	_cursorPosition	= 0
	_cursorFillMode	= LEFT_TO_RIGHT
endFunction

function SetOptionStrValue(int a_option, string a_strValue, bool noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	if (!noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function SetOptionNumValue(int a_option, float a_numValue, bool noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetNumber(menu, root + ".optionCursor.numValue", a_numValue)
	if (!noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function SetOptionValues(int a_option, string a_strValue, float a_numValue, bool noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	UI.SetNumber(menu, root + ".optionCursor.numValue", a_numValue)
	if (!noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function RequestSliderDialogData(int a_index)
	_activeOption = a_index

	; Defaults
	_sliderParams[0] = 0
	_sliderParams[1] = 0
	_sliderParams[2] = 0
	_sliderParams[3] = 1
	_sliderParams[4] = 1

	_state = STATE_SLIDER
	OnOptionSliderOpen(a_index)
	_state = STATE_DEFAULT

	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setSliderDialogParams", _sliderParams)
endFunction

function RequestMenuDialogData(int a_index)
	_activeOption = a_index

	; Defaults
	_menuParams[0] = -1
	_menuParams[1] = -1

	_state = STATE_MENU
	OnOptionMenuOpen(a_index)
	_state = STATE_DEFAULT

	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setMenuDialogParams", _menuParams)
endFunction

function RequestColorDialogData(int a_index)
	_activeOption = a_index

	; Defaults
	_colorParams[0] = -1
	_colorParams[1] = -1

	_state = STATE_COLOR
	OnOptionColorOpen(a_index)
	_state = STATE_DEFAULT

	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setColorDialogParams", _colorParams)
endFunction

function SetSliderValue(float a_value)
	OnOptionSliderAccept(_activeOption, a_value)
	_activeOption = -1
endFunction

function SetMenuIndex(int a_index)
	OnOptionMenuAccept(_activeOption, a_index)
	_activeOption = -1
endFunction

function SetColorValue(int a_color)
	OnOptionColorAccept(_activeOption, a_color)
	_activeOption = -1
endFunction

function HighlightOption(int a_index)
	_infoText = ""
	OnOptionHighlight(a_index)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".setInfoText", _infoText)
endFunction

; @interface
function SetTitleText(string a_text)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".setTitleText", a_text)
endFunction

; @interface
function SetInfoText(string a_text)
	_infoText = a_text
endFunction

; @interface
function SetCursorPosition(int a_position)
	if (a_position < 128)
		_cursorPosition = a_position
	endIf
endFunction

; @interface
function SetCursorFillMode(int a_fillMode)
	if (a_fillMode == LEFT_TO_RIGHT || a_fillMode == TOP_TO_BOTTOM)
		_cursorFillMode = a_fillMode
	endIf
endFunction

; @interface
int function AddEmptyOption()
	return AddOption(OPTION_TYPE_EMPTY, none, none, 0, 0)
endFunction

; @interface
int function AddHeaderOption(string a_text, int a_flags = 0)
	return AddOption(OPTION_TYPE_HEADER, a_text, none, 0, a_flags)
endFunction

; @interface
int function AddTextOption(string a_text, string a_value, int a_flags = 0)
	return AddOption(OPTION_TYPE_TEXT, a_text, a_value, 0, a_flags)
endFunction

; @interface
int function AddToggleOption(string a_text, bool a_checked, int a_flags = 0)
	return AddOption(OPTION_TYPE_TOGGLE, a_text, none, a_checked as int, a_flags)
endfunction

; @interface
int function AddSliderOption(string a_text, float a_value, string a_formatString = "", int a_flags = 0)
	return AddOption(OPTION_TYPE_SLIDER, a_text, a_formatString, a_value, a_flags)
endFunction

; @interface
int function AddMenuOption(string a_text, string a_value, int a_flags = 0)
	return AddOption(OPTION_TYPE_MENU, a_text, a_value, 0, a_flags)
endFunction

; @interface
int function AddColorOption(string a_text, int a_color, int a_flags = 0)
	return AddOption(OPTION_TYPE_COLOR, a_text, none, a_color, a_flags)
endFunction

; @interface
int function AddKeyMapOption(string a_text, int a_keyCode, int a_flags = 0)
	return AddOption(OPTION_TYPE_KEYMAP, a_text, none, a_keyCode, a_flags)
endFunction

; @interface
function LoadCustomContent(string a_source, float a_x = 0.0, float a_y = 0.0)
	float[] params = new float[2]
	params[0] = a_x
	params[1] = a_y
	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setCustomContentParams", params)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".loadCustomContent", a_source)
endFunction

; @interface
function UnloadCustomContent()
	UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".unloadCustomContent")
endFunction

; @interface
function SetOptionFlags(int a_option, int a_flags, bool noUpdate = false)
	if (_state == STATE_RESET)
		Error("Cannot set option flags while in OnPageReset(). Pass flags to AddOption instead")
		return
	endIf

	float[] params = new float[2]
	params[0] = a_option
	params[1] = a_flags
	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setOptionFlags", params)
	if (!noUpdate)
		UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".invalidateOptionData")
	endIf
endFunction

; @interface
function SetTextOptionValue(int a_option, string a_value, bool noUpdate = false)
	SetOptionStrValue(a_option, a_value, noUpdate)
endFunction

; @interface
function SetToggleOptionValue(int a_option, bool a_checked, bool noUpdate = false)
	SetOptionNumValue(a_option, a_checked as int, noUpdate)
endfunction

; @interface
function SetSliderOptionValue(int a_option, float a_value, string a_formatString = "", bool noUpdate = false)
	SetOptionValues(a_option, a_formatString, a_value, noUpdate)
endFunction

; @interface
function SetMenuOptionValue(int a_option, string a_value, bool noUpdate = false)
	SetOptionStrValue(a_option, a_value, noUpdate)
endFunction

; @interface
function SetColorOptionValue(int a_option, int a_color, bool noUpdate = false)
	SetOptionNumValue(a_option, a_color, noUpdate)
endFunction

; @interface
function SetKeyMapOptionValue(int a_option, int a_keyCode, bool noUpdate = false)
	SetOptionNumValue(a_option, a_keyCode, noUpdate)
endFunction

; @interface
function SetSliderDialogStartValue(float a_value)
	if (_state != STATE_SLIDER)
		Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return
	endIf

	_sliderParams[0] = a_value
endFunction

; @interface
function SetSliderDialogDefaultValue(float a_value)
	if (_state != STATE_SLIDER)
		Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return
	endIf

	_sliderParams[1] = a_value
endFunction

; @interface
function SetSliderDialogRange(float a_minValue, float a_maxValue)
	if (_state != STATE_SLIDER)
		Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return
	endIf

	_sliderParams[2] = a_minValue
	_sliderParams[3] = a_maxValue
endFunction

; @interface
function SetSliderDialogInterval(float a_value)
	if (_state != STATE_SLIDER)
		Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return
	endIf

	_sliderParams[4] = a_value
endFunction

; @interface
function SetMenuDialogStartIndex(int a_value)
	if (_state != STATE_MENU)
		Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return
	endIf

	_menuParams[0] = a_value
endFunction

; @interface
function SetMenuDialogDefaultIndex(int a_value)
	if (_state != STATE_MENU)
		Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return
	endIf

	_menuParams[1] = a_value
endFunction

; @interface
function SetMenuDialogOptions(string[] a_options)
	if (_state != STATE_MENU)
		Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return
	endIf

	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setMenuDialogOptions", a_options)
endFunction

; @interface
function SetColorDialogStartColor(int a_color)
	if (_state != STATE_COLOR)
		Error("Cannot set color dialog params while outside OnOptionColorOpen()")
		return
	endIf

	_colorParams[0] = a_color
endFunction

; @interface
function SetColorDialogDefaultColor(int a_color)
	if (_state != STATE_COLOR)
		Error("Cannot set color dialog params while outside OnOptionColorOpen()")
		return
	endIf

	_colorParams[1] = a_color
endFunction