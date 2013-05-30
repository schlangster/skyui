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

int property		OPTION_FLAG_NONE		= 0x00 autoReadonly
int property		OPTION_FLAG_DISABLED	= 0x01 autoReadonly
int property		OPTION_FLAG_HIDDEN		= 0x02 autoReadonly
int property		OPTION_FLAG_WITH_UNMAP	= 0x04 autoReadonly

int property		LEFT_TO_RIGHT	= 1	autoReadonly
int property		TOP_TO_BOTTOM	= 2 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_ConfigManager	_configManager
bool				_initialized		= false
int					_configID			= -1
string				_currentPage		= ""
int					_currentPageNum		= 0			; 0 for "", real pages start at 1

; Keep track of what we're doing at the moment for stupidity checks
int					_state				= 0

int					_cursorPosition		= 0
int					_cursorFillMode		= 1			;LEFT_TO_RIGHT

; Local buffers
int[]				_optionFlagsBuf					; byte 1 type, byte 2 flags
string[]			_textBuf
string[]			_strValueBuf
float[]				_numValueBuf

float[]				_sliderParams
int[]				_menuParams
int[]				_colorParams

int					_activeOption		= -1

string				_infoText

bool				_messageResult		= false
bool				_waitForMessage		= false

string[]			_stateOptionMap


; PROPERTIES --------------------------------------------------------------------------------------

string property		ModName auto

string[] property	Pages auto

string property		CurrentPage
	string function get()
		return  _currentPage
	endFunction
endProperty


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	if (!_initialized)
		_initialized = true

		; Buffer alloc/free on config open/close
		;_optionFlagsBuf	= new int[128]
		;_textBuf		= new string[128]
		;_strValueBuf	= new string[128]
		;_numValueBuf	= new float[128]

		; 0 startValue
		; 1 defaultValue
		; 2 minValue
		; 3 maxValue
		; 4 interval
		_sliderParams	= new float[5]

		; 0 startIndex
		; 1 defaultIndex
		_menuParams		= new int[2]

		; 0 currentColor
		; 1 defaultColor
		_colorParams	= new int[2]

		OnConfigInit()

		Debug.Trace(self + " INITIALIZED")
	endIf

	RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReady")
	RegisterForModEvent("SKICP_configManagerReset", "OnConfigManagerReset")

	CheckVersion()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnConfigInit()
	{Called when this config menu is initialized}
endEvent

; @interface
event OnConfigRegister()
	{Called when this config menu registered at the control panel}
endEvent

; @interface
event OnConfigOpen()
	{Called when this config menu is opened}
endEvent

; @interface
event OnConfigClose()
	{Called when this config menu is closed}
endEvent

; @interface(SKI_QuestBase)
event OnVersionUpdate(int a_version)
	{Called when a version update of this script has been detected}
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
event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}
endEvent

; @interface
event OnHighlightST()
	{Called when highlighting a state option}
endEvent

; @interface
event OnSelectST()
	{Called when a non-interactive state option has been selected}
endEvent

; @interface
event OnDefaultST()
	{Called when resetting a state option to its default value}
endEvent

; @interface
event OnSliderOpenST()
	{Called when a slider state option has been selected}
endEvent

; @interface
event OnSliderAcceptST(float a_value)
	{Called when a new slider state value has been accepted}
endEvent

; @interface
event OnMenuOpenST()
	{Called when a menu state option has been selected}
endEvent

; @interface
event OnMenuAcceptST(int a_index)
	{Called when a menu entry has been accepted for this state option}
endEvent

; @interface
event OnColorOpenST()
	{Called when a color state option has been selected}
endEvent

; @interface
event OnColorAcceptST(int a_color)
	{Called when a new color has been accepted for this state option}
endEvent

; @interface
event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped for this state option}
endEvent

event OnConfigManagerReset(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	_configManager = none
endEvent

event OnConfigManagerReady(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	SKI_ConfigManager newManager = a_sender as SKI_ConfigManager
	; Already registered?
	if (_configManager == newManager || newManager == none)
		return
	endIf

	_configID = newManager.RegisterMod(self, ModName)

	; Success
	if (_configID >= 0)
		_configManager = newManager
		OnConfigRegister()
		Debug.Trace(self + ": Registered " + ModName + " at MCM.")
	endIf
 endEvent

event OnMessageDialogClose(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	_messageResult = a_numArg as bool
	_waitForMessage = false
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface(SKI_QuestBase)
int function GetVersion()
	{Returns version of this script}
	return 1
endFunction

; @interface
string function GetCustomControl(int a_keyCode)
	{Returns the name of a custom control mapped to given keyCode, or "" if the key is not in use by this config}
	return ""
endFunction

; @interface
function ForcePageReset()
	{Forces a full reset of the current page}
	UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".forcePageReset")
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
int function AddSliderOption(string a_text, float a_value, string a_formatString = "{0}", int a_flags = 0)
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
function AddTextOptionST(string a_stateName, string a_text, string a_value, int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_TEXT, a_text, a_value, 0, a_flags)
endFunction

; @interface
function AddToggleOptionST(string a_stateName, string a_text, bool a_checked, int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_TOGGLE, a_text, none, a_checked as int, a_flags)
endfunction

; @interface
function AddSliderOptionST(string a_stateName, string a_text, float a_value, string a_formatString = "{0}", int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_SLIDER, a_text, a_formatString, a_value, a_flags)
endFunction

; @interface
function AddMenuOptionST(string a_stateName, string a_text, string a_value, int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_MENU, a_text, a_value, 0, a_flags)
endFunction

; @interface
function AddColorOptionST(string a_stateName, string a_text, int a_color, int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_COLOR, a_text, none, a_color, a_flags)
endFunction

; @interface
function AddKeyMapOptionST(string a_stateName, string a_text, int a_keyCode, int a_flags = 0)
	AddOptionST(a_stateName, OPTION_TYPE_KEYMAP, a_text, none, a_keyCode, a_flags)
endFunction

; @interface
function LoadCustomContent(string a_source, float a_x = 0.0, float a_y = 0.0)
	float[] params = new float[2]
	params[0] = a_x
	params[1] = a_y
	UI.InvokeFloatA(JOURNAL_MENU, MENU_ROOT + ".setCustomContentParams", params)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".loadCustomContent", a_source)
endFunction

; @interface
function UnloadCustomContent()
	UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".unloadCustomContent")
endFunction

; @interface
function SetOptionFlags(int a_option, int a_flags, bool a_noUpdate = false)
	if (_state == STATE_RESET)
		Error("Cannot set option flags while in OnPageReset(). Pass flags to AddOption instead")
		return
	endIf

	int index = a_option % 0x100

	; Update flags buffer
	int oldFlags = _optionFlagsBuf[index] as int
	oldFlags %= 0x100 			; Clear upper bytes, keep type
	oldFlags += a_flags * 0x100	; Set new flags

	; Update display
	int[] params = new int[2]
	params[0] = index
	params[1] = a_flags
	UI.InvokeIntA(JOURNAL_MENU, MENU_ROOT + ".setOptionFlags", params)

	if (!a_noUpdate)
		UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".invalidateOptionData")
	endIf
endFunction

; @interface
function SetTextOptionValue(int a_option, string a_value, bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_TEXT)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected text option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected text option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionStrValue(index, a_value, a_noUpdate)
endFunction

; @interface
function SetToggleOptionValue(int a_option, bool a_checked, bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_TOGGLE)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected toggle option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected toggle option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionNumValue(index, a_checked as int, a_noUpdate)
endfunction

; @interface
function SetSliderOptionValue(int a_option, float a_value, string a_formatString = "{0}", bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_SLIDER)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected slider option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected slider option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionValues(index, a_formatString, a_value, a_noUpdate)
endFunction

; @interface
function SetMenuOptionValue(int a_option, string a_value, bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_MENU)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected menu option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected menu option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionStrValue(index, a_value, a_noUpdate)
endFunction

; @interface
function SetColorOptionValue(int a_option, int a_color, bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_COLOR)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected color option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected color option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionNumValue(index, a_color, a_noUpdate)
endFunction

; @interface
function SetKeyMapOptionValue(int a_option, int a_keyCode, bool a_noUpdate = false)
	int index = a_option % 0x100
	int type = _optionFlagsBuf[index] % 0x100

	if (type != OPTION_TYPE_KEYMAP)
		int pageIdx = ((a_option / 0x100) as int) - 1
		if (pageIdx != -1)
			Error("Option type mismatch. Expected keymap option, page \"" + Pages[pageIdx] + "\", index " + index)
		else
			Error("Option type mismatch. Expected keymap option, page \"\", index " + index)
		endIf
		return
	endIf

	SetOptionNumValue(index, a_keyCode, a_noUpdate)
endFunction

; @interface
function SetOptionFlagsST(int a_flags, bool a_noUpdate = false, string a_stateName = "")
	if (_state == STATE_RESET)
		Error("Cannot set option flags while in OnPageReset(). Pass flags to AddOption instead")
		return
	endIf

	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetOptionFlagsST outside a valid option state")
		return
	endIf

	SetOptionFlags(index, a_flags, a_noUpdate)
endFunction

; @interface
function SetTextOptionValueST(string a_value, bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetTextOptionValueST outside a valid option state")
		return
	endIf

	SetTextOptionValue(index, a_value, a_noUpdate)
endFunction

; @interface
function SetToggleOptionValueST(bool a_checked, bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetToggleOptionValueST outside a valid option state")
		return
	endIf

	SetToggleOptionValue(index, a_checked, a_noUpdate)
endFunction

; @interface
function SetSliderOptionValueST(float a_value, string a_formatString = "{0}", bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetSliderOptionValueST outside a valid option state")
		return
	endIf

	SetSliderOptionValue(index, a_value, a_formatString, a_noUpdate)
endFunction

; @interface
function SetMenuOptionValueST(string a_value, bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetMenuOptionValueST outside a valid option state")
		return
	endIf

	SetMenuOptionValue(index, a_value, a_noUpdate)
endFunction

; @interface
function SetColorOptionValueST(int a_color, bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetColorOptionValueST outside a valid option state")
		return
	endIf

	SetColorOptionValue(index, a_color, a_noUpdate)
endFunction

; @interface
function SetKeyMapOptionValueST(int a_keyCode, bool a_noUpdate = false, string a_stateName = "")
	int index = GetStateOptionIndex(a_stateName)
	if (index < 0)
		Error("Cannot use SetKeyMapOptionValueST outside a valid option state")
		return
	endIf

	SetKeyMapOptionValue(index, a_keyCode, a_noUpdate)
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

; @interface
bool function ShowMessage(string a_message, bool a_withCancel = true, string a_acceptLabel = "$Accept", string a_cancelLabel = "$Cancel")
	if (_waitForMessage)
		Error("Called ShowMessage() while another message was already open")
		return false
	endIf

	_waitForMessage = true
	_messageResult = false

	string[] params = new string[3]
	params[0] = a_message
	params[1] = a_acceptLabel
	if (a_withCancel)
		params[2] = a_cancelLabel
	else
		params[2] = ""
	endIf

	RegisterForModEvent("SKICP_messageDialogClosed", "OnMessageDialogClose")
	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".showMessageDialog", params)

	; Wait for result
	while (_waitForMessage)
		Utility.WaitMenuMode(0.1)
	endWhile

	UnregisterForModEvent("SKICP_messageDialogClosed")
	
	return _messageResult
endFunction

function Error(string a_msg)
	Debug.Trace(self + " ERROR: " +  a_msg)
endFunction

function OpenConfig()
	; Alloc
	_optionFlagsBuf	= new int[128]
	_textBuf		= new string[128]
	_strValueBuf	= new string[128]
	_numValueBuf	= new float[128]
	_stateOptionMap	= new string[128]

	SetPage("", -1)

	OnConfigOpen()

	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setPageNames", Pages)
endFunction

function CloseConfig()
	OnConfigClose()	
	ClearOptionBuffers()
	_waitForMessage = false

	; Free
	_optionFlagsBuf	= new int[1]
	_textBuf		= new string[1]
	_strValueBuf	= new string[1]
	_numValueBuf	= new float[1]
	_stateOptionMap	= new string[1]
endFunction

function SetPage(string a_page, int a_index)
	_currentPage = a_page
	_currentPageNum = 1+a_index
	
	; Set default title, can be overridden in OnPageReset
	if (a_page != "")
		SetTitleText(a_page)
	else
		SetTitleText(ModName)
	endIf
	
	ClearOptionBuffers()
	_state = STATE_RESET
	OnPageReset(a_page)
	_state = STATE_DEFAULT
	WriteOptionBuffers()
endFunction

int function AddOption(int a_optionType, string a_text, string a_strValue, float a_numValue, int a_flags)
	if (_state != STATE_RESET)
		Error("Cannot add option " + a_text + " outside of OnPageReset()")
		return -1
	endIf

	int pos = _cursorPosition
	if (pos == -1)
		return -1 ; invalid
	endIf
	
	_optionFlagsBuf[pos] = a_optionType + a_flags * 0x100
	_textBuf[pos] = a_text
	_strValueBuf[pos] = a_strValue
	_numValueBuf[pos] = a_numValue
	
	; Just use numerical value of fill mode
	_cursorPosition += _cursorFillMode
	if (_cursorPosition >= 128)
		_cursorPosition = -1
	endIf
	
	; byte 1 - position
	; byte 2 - page
	return pos + _currentPageNum * 0x100
endFunction

function AddOptionST(string a_stateName, int a_optionType, string a_text, string a_strValue, float a_numValue, int a_flags)
	if (_stateOptionMap.find(a_stateName) != -1)
		Error("State option name " + a_stateName + " is already in use")
		return
	endIf
	
	int index = AddOption(a_optionType, a_text, a_strValue, a_numValue, a_flags) % 0x100
	if (index < 0)
		return
	endIf

	if (_stateOptionMap[index] != "")
		Error("State option index " + index + " already in use")
		return
	endIf

	_stateOptionMap[index] = a_stateName
endFunction

int function GetStateOptionIndex(string a_stateName)
	if (a_stateName == "")
		a_stateName = GetState()
	endIf

	if (a_stateName == "")
		return -1
	endIf

	return _stateOptionMap.find(a_stateName)
endFunction

function WriteOptionBuffers()
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
	
	UI.InvokeIntA(menu, root + ".setOptionFlagsBuffer", _optionFlagsBuf)
	UI.InvokeStringA(menu, root + ".setOptionTextBuffer", _textBuf)
	UI.InvokeStringA(menu, root + ".setOptionStrValueBuffer", _strValueBuf)
	UI.InvokeFloatA(menu, root + ".setOptionNumValueBuffer", _numValueBuf)
	UI.InvokeInt(menu, root + ".flushOptionBuffers", optionCount)
endFunction

function ClearOptionBuffers()
	int t = OPTION_TYPE_EMPTY
	int i = 0
	while (i < 128)
		_optionFlagsBuf[i] = t
		_textBuf[i] = ""
		_strValueBuf[i] = ""
		_numValueBuf[i] = 0

		; Also clear state map as it's tied to the buffers
		_stateOptionMap[i] = ""
		i += 1
	endWhile

	_cursorPosition	= 0
	_cursorFillMode	= LEFT_TO_RIGHT
endFunction

function SetOptionStrValue(int a_index, string a_strValue, bool a_noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetInt(menu, root + ".optionCursorIndex", a_index)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	if (!a_noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function SetOptionNumValue(int a_index, float a_numValue, bool a_noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetInt(menu, root + ".optionCursorIndex", a_index)
	UI.SetFloat(menu, root + ".optionCursor.numValue", a_numValue)
	if (!a_noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function SetOptionValues(int a_index, string a_strValue, float a_numValue, bool a_noUpdate)
	if (_state == STATE_RESET)
		Error("Cannot modify option data while in OnPageReset()")
		return
	endIf

	string menu = JOURNAL_MENU
	string root = MENU_ROOT

	UI.SetInt(menu, root + ".optionCursorIndex", a_index)
	UI.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	UI.SetFloat(menu, root + ".optionCursor.numValue", a_numValue)
	if (!a_noUpdate)
		UI.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function RequestSliderDialogData(int a_index)
	_activeOption = a_index + _currentPageNum * 0x100

	; Defaults
	_sliderParams[0] = 0
	_sliderParams[1] = 0
	_sliderParams[2] = 0
	_sliderParams[3] = 1
	_sliderParams[4] = 1

	_state = STATE_SLIDER

	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnSliderOpenST()
		gotoState(oldState)
	else
		OnOptionSliderOpen(_activeOption)
	endIf

	_state = STATE_DEFAULT

	UI.InvokeFloatA(JOURNAL_MENU, MENU_ROOT + ".setSliderDialogParams", _sliderParams)
endFunction

function RequestMenuDialogData(int a_index)
	_activeOption = a_index + _currentPageNum * 0x100

	; Defaults
	_menuParams[0] = -1
	_menuParams[1] = -1

	_state = STATE_MENU

	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnMenuOpenST()
		gotoState(oldState)
	else
		OnOptionMenuOpen(_activeOption)
	endIf

	_state = STATE_DEFAULT

	UI.InvokeIntA(JOURNAL_MENU, MENU_ROOT + ".setMenuDialogParams", _menuParams)
endFunction

function RequestColorDialogData(int a_index)
	_activeOption = a_index + _currentPageNum * 0x100

	; Defaults
	_colorParams[0] = -1
	_colorParams[1] = -1

	_state = STATE_COLOR

	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnColorOpenST()
		gotoState(oldState)
	else
		OnOptionColorOpen(_activeOption)
	endIf

	_state = STATE_DEFAULT

	UI.InvokeIntA(JOURNAL_MENU, MENU_ROOT + ".setColorDialogParams", _colorParams)
endFunction

function SetSliderValue(float a_value)
	string optionState = _stateOptionMap[_activeOption % 0x100]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnSliderAcceptST(a_value)
		gotoState(oldState)
	else
		OnOptionSliderAccept(_activeOption, a_value)
	endIf
	_activeOption = -1
endFunction

function SetMenuIndex(int a_index)
	string optionState = _stateOptionMap[_activeOption % 0x100]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnMenuAcceptST(a_index)
		gotoState(oldState)
	else
		OnOptionMenuAccept(_activeOption, a_index)
	endIf
	_activeOption = -1
endFunction

function SetColorValue(int a_color)
	string optionState = _stateOptionMap[_activeOption % 0x100]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnColorAcceptST(a_color)
		gotoState(oldState)
	else
		OnOptionColorAccept(_activeOption, a_color)
	endIf
	_activeOption = -1
endFunction

function SelectOption(int a_index)
	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnSelectST()
		gotoState(oldState)
	else
		int option = a_index + _currentPageNum * 0x100
		OnOptionSelect(option)
	endIf
endFunction

function ResetOption(int a_index)
	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnDefaultST()
		gotoState(oldState)
	else
		int option = a_index + _currentPageNum * 0x100
		OnOptionDefault(option)
	endIf
endFunction

function HighlightOption(int a_index)
	_infoText = ""

	if (a_index != -1)
		string optionState = _stateOptionMap[a_index]
		if (optionState != "")
			string oldState = GetState()
			gotoState(optionState)
			OnHighlightST()
			gotoState(oldState)
		else
			int option = a_index + _currentPageNum * 0x100
			OnOptionHighlight(option)
		endIf
	endIf

	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".setInfoText", _infoText)
endFunction

function RemapKey(int a_index, int a_keyCode, string a_conflictControl, string a_conflictName)
	string optionState = _stateOptionMap[a_index]
	if (optionState != "")
		string oldState = GetState()
		gotoState(optionState)
		OnKeyMapChangeST(a_keyCode, a_conflictControl, a_conflictName)
		gotoState(oldState)
	else
		int option = a_index + _currentPageNum * 0x100
		OnOptionKeyMapChange(option, a_keyCode, a_conflictControl, a_conflictName)
	endIf
endFunction
