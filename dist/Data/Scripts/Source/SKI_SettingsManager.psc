scriptname SKI_SettingsManager extends SKI_QuestBase  

; CONSTANTS ---------------------------------------------------------------------------------------

string property		MENU_ROOT		= "_global.skyui.util.ConfigManager" autoReadonly

string property		INVENTORY_MENU	= "InventoryMenu" autoReadonly
string property		MAGIC_MENU		= "MagicMenu" autoReadonly
string property		CONTAINER_MENU	= "ContainerMenu" autoReadonly
string property		BARTER_MENU		= "BarterMenu" autoReadonly
string property		GIFT_MENU		= "GiftMenu" autoReadonly
string property		CRAFTING_MENU	= "Crafting Menu" autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

int			_overrideCount	= 0
string[]	_overrideKeys
string[]	_overrideValues

string		_currentMenu


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_overrideKeys	= new string[128]
	_overrideValues	= new string[128]

	int i = 0
	while (i<128)
		_overrideKeys[i] = ""
		_overrideValues[i] = ""
		i += 1
	endWhile

	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForMenu(INVENTORY_MENU)
	RegisterForMenu(MAGIC_MENU)
	RegisterForMenu(CONTAINER_MENU)
	RegisterForMenu(BARTER_MENU)
	RegisterForMenu(GIFT_MENU)
	RegisterForMenu(CRAFTING_MENU)
	RegisterForModEvent("SKICO_setConfigOverride", "OnSetConfigOverride")
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	GotoState("LOCKED")
	; Check if it's still open
	if (UI.IsMenuOpen(a_menuName))
		_currentMenu = a_menuName
		UI.InvokeStringA(a_menuName, MENU_ROOT + ".setExternalOverrideKeys", _overrideKeys)
		UI.InvokeStringA(a_menuName, MENU_ROOT + ".setExternalOverrideValues", _overrideValues)
	endIf
	GotoState("")
endEvent

event OnSetConfigOverride(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	string overrideKey = a_strArg
	string overrideValue = UI.GetString(_currentMenu, MENU_ROOT + ".out_overrides." + overrideKey)

	SetOverride(overrideKey, overrideValue)
endEvent

; ----------------------------------------------
state LOCKED

event OnMenuOpen(string a_menuName)
endEvent

endState


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
bool function SetOverride(string a_key, string a_value)
	if (a_key == "")
		return false
	endIf

	; Existing override?
	int index = _overrideKeys.Find(a_key)
	if (index != -1)
		_overrideValues[index] = a_value

		return true

	; New override
	else
		if (_overrideCount >= 128)
			return false
		endIf

		index = NextFreeIndex()
		if (index == -1)
			return false
		endIf

		_overrideKeys[index] = a_key
		_overrideValues[index] = a_value
		_overrideCount += 1

		return true
	endIf

endFunction

; @interface
bool function ClearOverride(string a_key)
	if (a_key == "")
		return false
	endIf

	int index = _overrideKeys.Find(a_key)
	if (index == -1)
		return false
	endIf
	
	_overrideKeys[index] = ""
	_overrideValues[index] = ""
	_overrideCount -= 1
	
	return true
endFunction

int function NextFreeIndex()
	int i = 0
	
	while (i < _overrideKeys.length)
		if (_overrideKeys[i] == "")
			return i
		endIf
		i += 1
	endWhile

	return -1
endFunction
