scriptname SKI_ConfigManager extends SKI_QuestBase hidden 

; SCRIPT VERSION ----------------------------------------------------------------------------------
;
; History
;
; 1:	- Initial version
;
; 2:	- Added lock for API functions

int function GetVersion()
	return 2
endFunction


; CONSTANTS ---------------------------------------------------------------------------------------

string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MENU_ROOT		= "_root.ConfigPanelFader.configPanel" autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

SKI_ConfigBase[]	_modConfigs
string[]			_modNames
int					_curConfigID	= 0
int					_configCount	= 0

SKI_ConfigBase		_activeConfig

; -- Version 2 --

bool				_lockInit		= false
Form				_lockHolder		= none
int					_lockCount		= 0


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_modConfigs	= new SKI_ConfigBase[128]
	_modNames	= new string[128]

	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKICP_modSelected", "OnModSelect")
	RegisterForModEvent("SKICP_pageSelected", "OnPageSelect")
	RegisterForModEvent("SKICP_optionHighlighted", "OnOptionHighlight")
	RegisterForModEvent("SKICP_optionSelected", "OnOptionSelect")
	RegisterForModEvent("SKICP_optionDefaulted", "OnOptionDefault")
	RegisterForModEvent("SKICP_keymapChanged", "OnKeymapChange")
	RegisterForModEvent("SKICP_sliderSelected", "OnSliderSelect")
	RegisterForModEvent("SKICP_sliderAccepted", "OnSliderAccept")
	RegisterForModEvent("SKICP_menuSelected", "OnMenuSelect")
	RegisterForModEvent("SKICP_menuAccepted", "OnMenuAccept")
	RegisterForModEvent("SKICP_colorSelected", "OnColorSelect")
	RegisterForModEvent("SKICP_colorAccepted", "OnColorAccept")
	RegisterForModEvent("SKICP_dialogCanceled", "OnDialogCancel")
	
	RegisterForMenu(JOURNAL_MENU)

	; Must be set before cleanup!!
	_lockInit = true

	CleanUp()
endEvent

function CleanUp()
	AcquireLock()

	_configCount = 0
	int i = 0
	while (i < _modConfigs.length)
		if (_modConfigs[i] == none || _modConfigs[i].GetFormID() == 0)
			_modConfigs[i] = none
			_modNames[i] = ""
		else
			_configCount += 1
		endIf
		
		i += 1
	endWhile

	ReleaseLock()
endFunction


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	_activeConfig = none
	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setModNames", _modNames);
endEvent

event OnMenuClose(string a_menuName)

	if (_activeConfig)
		_activeConfig.CloseConfig()
	endIf

	_activeConfig = none
endEvent

event OnModSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int configIndex = a_numArg as int
	if (configIndex > -1)

		; We can clean the buffers of the previous menu now
		if (_activeConfig)
			_activeConfig.CloseConfig()
		endIf

		_activeConfig = _modConfigs[configIndex]
		_activeConfig.OpenConfig()
	endIf
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnPageSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	string page = a_strArg
	int index = a_numArg as int
	_activeConfig.SetPage(page, index)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnOptionHighlight(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.HighlightOption(optionIndex)
endEvent

event OnOptionSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.SelectOption(optionIndex)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnOptionDefault(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.ResetOption(optionIndex)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnKeymapChange(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	int keyCode = UI.GetInt(JOURNAL_MENU, MENU_ROOT + ".selectedKeyCode")

	; First test vanilla controls
	string conflictControl = Input.GetMappedControl(keyCode)
	string conflictName = ""

	; Then test mod controls
	int i = 0
	while (conflictControl == "" && i < _modConfigs.length)
		if (_modConfigs[i] != none)
			conflictControl = _modConfigs[i].GetCustomControl(keyCode)
			if (conflictControl != "")
				conflictName = _modNames[i]
			endIf
		endIf
			
		i += 1
	endWhile

	_activeConfig.RemapKey(optionIndex, keyCode, conflictControl, conflictName)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnSliderSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.RequestSliderDialogData(optionIndex)
endEvent

event OnSliderAccept(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	float value = a_numArg
	_activeConfig.SetSliderValue(value)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnMenuSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.RequestMenuDialogData(optionIndex)
endEvent

event OnMenuAccept(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int value = a_numArg as int
	_activeConfig.SetMenuIndex(value)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnColorSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.RequestColorDialogData(optionIndex)
endEvent

event OnColorAccept(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int color = a_numArg as int
	_activeConfig.SetColorValue(color)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnDialogCancel(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
int function RegisterMod(SKI_ConfigBase a_menu, string a_modName)
	AcquireLock()

	Log("Registering config menu: " + a_menu + "(" + a_modName + ")")

	if (_configCount >= 128)
		ReleaseLock()
		return -1
	endIf

	; Already registered?
	int i = 0
	while (i < _modConfigs.length)
		if (_modConfigs[i] == a_menu)
			ReleaseLock()
			return i
		endIf
			
		i += 1
	endWhile

	; New registration
	int configID = NextID()
	_modConfigs[configID] = a_menu
	_modNames[configID] = a_modName
	
	_configCount += 1
	
	ReleaseLock()
	return configID
endFunction

; @interface
bool function UnregisterMod(SKI_ConfigBase a_menu)
	AcquireLock()

	Log("Unregistering config menu: " + a_menu)

	int i = 0
	while (i < _modConfigs.length)
		if (_modConfigs[i] == a_menu)
			_modConfigs[i] = none
			_modNames[i] = ""
			_configCount -= 1

			ReleaseLock()
			return true
		endIf
			
		i += 1
	endWhile

	ReleaseLock()
	return false
endFunction

; @interface
function ForceReset()
	AcquireLock()

	Log("Forcing config manager reset...")
	SendModEvent("SKICP_configManagerReset")

	int i = 0
	while (i < _modConfigs.length)
		_modConfigs[i] = none
		_modNames[i] = ""
		i += 1
	endWhile

	_curConfigID = 0
	_configCount = 0

	SendModEvent("SKICP_configManagerReady")

	ReleaseLock()
endFunction

int function NextID()
	int startIdx = _curConfigID
	
	while (_modConfigs[_curConfigID] != none)
		_curConfigID += 1
		if (_curConfigID >= 128)
			_curConfigID = 0
		endIf
		if (_curConfigID == startIdx)
			return -1 ; Just to be sure. 
		endIf
	endWhile
	
	return _curConfigID
endFunction

function AcquireLock()
	while (_lockInit == true && _lockHolder != self && _lockCount > 0)
		Debug.GetPlatformName() ; using this over Utility.Wait to avoid menu mode issues
	endWhile

	_lockHolder = self
	_lockCount += 1
endFunction

function ReleaseLock()
	_lockCount -= 1
	if (_lockCount == 0)
		_lockHolder = none
	endif
endFunction

function Log(string a_msg)
	Debug.Trace(self + ": " + a_msg)
endFunction


