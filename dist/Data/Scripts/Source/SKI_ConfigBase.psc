scriptname SKI_ConfigBase extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MENU_ROOT		= "_root.ConfigPanelFader.configPanel" autoReadonly

int property		OPTION_EMPTY	= 0 autoReadonly
int property		OPTION_HEADER	= 1 autoReadonly
int property		OPTION_TEXT		= 2 autoReadonly
int property		OPTION_TOGGLE	= 3 autoReadonly
int property 		OPTION_SLIDER	= 4 autoReadonly
int property		OPTION_MENU		= 5 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_ConfigManager	_configPanel
bool				_initialized	= false
int					_configID		= -1
int					_optionCount	= 0

; Local buffers
float[]				_optionTypeBuf
string[]			_textBuf
string[]			_strValueBuf
float[]				_numValueBuf

float[]				_sliderParams
float[]				_menuParams

int					_activeOption	= -1


; PROPERTIES --------------------------------------------------------------------------------------

string property		ModName auto
string[] property	Pages auto
string property		CurrentPage auto hidden


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_configPanel = Game.GetFormFromFile(0x00000802, "SkyUI.esp") As SKI_ConfigManager
	
	_optionTypeBuf	= new float[128]
	_textBuf		= new string[128]
	_strValueBuf	= new string[128]
	_numValueBuf	= new float[128]

	; 0 startValue
	; 1 defaultValue
	; 2 minValue
	; 3 maxValue
	; 4 interval
	; 5 decimal
	_sliderParams	= new float[6]

	; 0 startIndex
	; 1 defaultIndex
	_menuParams		= new float[2]
	
	gotoState("_INIT")
	RegisterForSingleUpdate(3)
endEvent

state _INIT
	event OnUpdate()
		gotoState("")
		_configID = _configPanel.RegisterMod(self, ModName)
		if (_configID != -1)
			OnConfigRegister()
			_initialized = true
		endIf
	endEvent
endState


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnConfigRegister()
endEvent

; @interface
event OnPageReset(string a_page)
endEvent

; @interface
event OnOptionHighlight(int a_option)
endEvent

; @interface
event OnOptionSelect(int a_option)
endEvent

; @interface
event OnOptionDefault(int a_option)
endEvent

; @interface
event OnOptionSliderOpen(int a_option)
endEvent

; @interface
event OnOptionSliderAccept(int a_option, float a_value)
endEvent

; @interface
event OnOptionMenuOpen(int a_option)
endEvent

; @interface
event OnOptionMenuAccept(int a_option, int a_menu)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function SetPage(string a_page)
	CurrentPage = a_page
	
	; Set default title, can be overridden in OnPageReset
	if (a_page != "")
		SetTitleText(a_page)
	else
		SetTitleText(ModName)
	endIf
	
	OnPageReset(a_page)
	FlushOptionBuffers()
endFunction

int function AddOption(int a_optionType, string a_text, string a_strValue, float a_numValue)
	
	if (_optionCount >= 127)
		return -1
	endIf
	
	int id = _optionCount
	
	_optionTypeBuf[id] = a_optionType
	_textBuf[id] = a_text
	_strValueBuf[id] = a_strValue
	_numValueBuf[id] = a_numValue
	
	_optionCount += 1
	
	return id
endFunction

function FlushOptionBuffers()
	string menu = JOURNAL_MENU
	string root = MENU_ROOT
	
	UI.InvokeNumberA(menu, root + ".setOptionTypeBuffer", _optionTypeBuf)
	UI.InvokeStringA(menu, root + ".setOptionTextBuffer", _textBuf)
	UI.InvokeStringA(menu, root + ".setOptionStrValueBuffer", _strValueBuf)
	UI.InvokeNumberA(menu, root + ".setOptionNumValueBuffer", _numValueBuf)
	UI.InvokeNumber(menu, root + ".flushOptionBuffers", _optionCount)
	
	_optionCount = 0
endFunction

function SetOptionStrValue(int a_option, string a_strValue)
	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	UI.Invoke(menu, root + ".invalidateOptionData")
endFunction

function SetOptionNumValue(int a_option, float a_numValue)
	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetNumber(menu, root + ".optionCursor.numValue", a_numValue)
	UI.Invoke(menu, root + ".invalidateOptionData")
endFunction

function SetOptionValues(int a_option, string a_strValue, float a_numValue)
	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetNumber(menu, root + ".optionCursorIndex", a_option)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	UI.SetNumber(menu, root + ".optionCursor.numValue", a_numValue)
	UI.Invoke(menu, root + ".invalidateOptionData")
endFunction

function RequestSliderDialogData(int a_index)
	_activeOption = a_index

	; Defaults
	_sliderParams[0] = 0
	_sliderParams[1] = 0
	_sliderParams[2] = 0
	_sliderParams[3] = 1
	_sliderParams[4] = 1
	_sliderParams[5] = 0

	OnOptionSliderOpen(a_index)

	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setSliderDialogParams", _sliderParams)
endFunction

function RequestMenuDialogData(int a_index)
	_activeOption = a_index

	; Defaults
	_menuParams[0] = -1
	_menuParams[1] = -1

	OnOptionMenuOpen(a_index)

	UI.InvokeNumberA(JOURNAL_MENU, MENU_ROOT + ".setMenuDialogParams", _menuParams)
endFunction

function SetSliderValue(float a_value)
	OnOptionSliderAccept(_activeOption, a_value)
	_activeOption = -1
endFunction

function SetMenuIndex(int a_index)
	OnOptionSliderAccept(_activeOption, a_index)
	_activeOption = -1
endFunction

; @interface
function SetTitleText(string a_text)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".setTitleText", a_text)
endFunction

; @interface
function SetInfoText(string a_text)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".setInfoText", a_text)
endFunction

; @interface
int function AddEmptyOption()
	return AddOption(OPTION_EMPTY, none, none, 0)
endFunction

; @interface
int function AddHeaderOption(string a_text)
	return AddOption(OPTION_HEADER, a_text, none, 0)
endFunction

; @interface
int function AddTextOption(string a_text, string a_value)
	return AddOption(OPTION_TEXT, a_text, a_value, 0)
endFunction

; @interface
int function AddToggleOption(string a_text, bool a_checked)
	return AddOption(OPTION_TOGGLE, a_text, none, a_checked as int)
endfunction

; @interface
int function AddSliderOption(string a_text, float a_value, string a_displayValue = "")
	return AddOption(OPTION_SLIDER, a_text, none, a_value)
endFunction

; @interface
int function AddMenuOption(string a_text, string a_value)
	return AddOption(OPTION_MENU, a_text, a_value, 0)
endFunction

; @interface
function LoadCustomContent(string a_source)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".loadCustomContent", a_source)
endFunction

; @interface
function UnloadCustomContent()
	UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".unloadCustomContent")
endFunction

; @interface
function SetTextOptionValue(int a_option, string a_value)
	SetOptionStrValue(a_option, a_value)
endFunction

; @interface
function SetToggleOptionValue(int a_option, bool a_checked)
	SetOptionNumValue(a_option, a_checked as int)
endfunction

; @interface
function SetSliderOptionValue(int a_option, float a_value, string a_displayValue = "")
	SetOptionValues(a_option, a_displayValue, a_value)
endFunction

; @interface
function SetMenuOptionValue(int a_option, string a_value)
	SetOptionStrValue(a_option, a_value)
endFunction

; @interface
function SetSliderDialogStartValue(float a_value)
	_sliderParams[0] = a_value
endFunction

; @interface
function SetSliderDialogDefaultValue(float a_value)
	_sliderParams[1] = a_value
endFunction

; @interface
function SetSliderDialogMinValue(float a_value)
	_sliderParams[2] = a_value
endFunction

; @interface
function SetSliderDialogMaxValue(float a_value)
	_sliderParams[3] = a_value
endFunction

; @interface
function SetSliderDialogInterval(float a_value)
	_sliderParams[4] = a_value
endFunction

; @interface
function SetSliderDialogDecimal(int a_value)
	_sliderParams[5] = a_value
endFunction

; @interface
function SetMenuDialogStartIndex(int a_value)
	_menuParams[0] = a_value
endFunction

; @interface
function SetMenuDialogDefaultIndex(int a_value)
	_menuParams[1] = a_value
endFunction

; @interface
function SetMenuDialogOptions(string[] a_options)
	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setMenuDialogOptions", a_options)
endFunction