scriptname SKI_ConfigManager extends SKI_QuestBase hidden 

; CONSTANTS ---------------------------------------------------------------------------------------

string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MENU_ROOT		= "_root.ConfigPanelFader.configPanel" autoReadonly
string property		DIALOG_SLIDER	= 0 autoReadonly
string property		DIALOG_MENU		= 1 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_ConfigBase[]	_modConfigs
string[]			_modNames
int					_curConfigID
int					_configCount

SKI_ConfigBase		_activeConfig


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_modConfigs		= new SKI_ConfigBase[128]
	_modNames		= new string[128]
	_curConfigID	= 0
	_configCount	= 0
	
	RegisterForModEvent("SKICP_modSelected", "OnModSelect")
	RegisterForModEvent("SKICP_pageSelected", "OnPageSelect")
	RegisterForModEvent("SKICP_optionHighlighted", "OnOptionHighlight")
	RegisterForModEvent("SKICP_optionSelected", "OnOptionSelect")
	RegisterForModEvent("SKICP_sliderSelected", "OnSliderSelect")
	RegisterForModEvent("SKICP_sliderAccepted", "OnSliderAccept")
	RegisterForModEvent("SKICP_menuSelected", "OnMenuSelect")
	RegisterForModEvent("SKICP_menuAccepted", "OnMenuAccept")
	RegisterForModEvent("SKICP_dialogCanceled", "OnDialogCancel")
	RegisterForMenu(JOURNAL_MENU)
	
	; Wait a few seconds until any initial menus have registered for events
	RegisterForSingleUpdate(3)
endEvent

event OnUpdate()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	CleanUp()
	SendModEvent("SKICP_configManagerReady")
endEvent

function CleanUp()
	_configCount = 0
	int i = 0
	while (i < _modConfigs.length)
		if (_modConfigs[i] == none || !(_modConfigs[i].GetFormID() > 0))
			_modConfigs[i] = none
			_modNames[i] = none
		else
			_configCount += 1
		endIf
		
		i += 1
	endWhile
endFunction


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	_activeConfig = none
	UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setModNames", _modNames);
endEvent

event OnMenuClose(string a_menuName)
	_activeConfig = none
endEvent

event OnModSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int configIndex = a_numArg as int
	if (configIndex > -1)
		_activeConfig = _modConfigs[configIndex]
		UI.InvokeStringA(JOURNAL_MENU, MENU_ROOT + ".setPageNames", _activeConfig.Pages)
		_activeConfig.SetPage("")
	endIf
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnPageSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	string page = a_strArg
	_activeConfig.SetPage(page)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent

event OnOptionHighlight(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.HighlightOption(optionIndex)
endEvent

event OnOptionSelect(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int optionIndex = a_numArg as int
	_activeConfig.OnOptionSelect(optionIndex)
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

event OnDialogCancel(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	UI.InvokeBool(JOURNAL_MENU, MENU_ROOT + ".unlock", true)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

int function RegisterMod(SKI_ConfigBase a_menu, string a_modName)
	if (_configCount >= 128)
		return -1
	endIf

	int configID = NextID()
	_modConfigs[configID] = a_menu
	_modNames[configID] = a_modName
	
	_configCount += 1
	
	return configID
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
