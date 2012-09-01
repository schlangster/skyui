scriptname SKI_WidgetManager extends SKI_QuestBase hidden

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_WidgetBase[]	_widgets
string[]			_widgetTypes
int					_curWidgetID
int					_widgetCount


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_widgets		= new SKI_WidgetBase[128]
	_widgetTypes	= new string[128]
	_curWidgetID	= 0
	_widgetCount	= 0
	
	RegisterForModEvent("widgetLoaded", "OnWidgetLoad")
	RegisterForModEvent("widgetWarning", "OnWidgetWarning")
	
	; Wait a few seconds until all widgets have registered their callbacks
	RegisterForSingleUpdate(3)
endEvent

event OnUpdate()
	OnGameReload()
endEvent

event OnGameReload()
	CleanUp()
	
	; Load already registered widgets
	UI.InvokeStringA(HUD_MENU, "_global.WidgetLoader.loadWidgets", _widgetTypes)
	
	SendModEvent("widgetManagerReady")
endEvent

function CleanUp()
	_widgetCount = 0
	int i = 0
	
	while (i < _widgets.length)
		if (_widgets[i] == none || !(_widgets[i].GetFormID() > 0))
			; Widget no longer exists
			_widgets[i] = none
			_widgetTypes[i] = none
		else
			_widgetCount += 1
		endIf
		i += 1
	endWhile
endFunction


; EVENTS ------------------------------------------------------------------------------------------

event OnWidgetLoad(string a_eventName, string a_strArg, float a_numArg, form a_sender)
	int widgetID = a_strArg as int
	SKI_WidgetBase client = _widgets[widgetID]
	
	if (client != none)
		client.OnWidgetLoad()
	endIf
endEvent

event OnWidgetWarning(string a_eventName, string a_strArg, float a_numArg, form a_sender)
	int widgetID = a_numArg as int
	string errorType = a_strArg
	string errorStr;
	
	SKI_WidgetBase client = _widgets[widgetID]
	errorStr = "WidgetWarning: " + client as string + ": " + errorType
	
	Debug.Trace(errorStr)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

int function RequestWidgetID(SKI_WidgetBase a_client)
	if (_widgetCount >= 128)
		return -1
	endIf

	int widgetID = NextWidgetID()
	_widgets[widgetID] = a_client
	_widgetCount += 1
	
	return widgetID
endFunction

int function NextWidgetID()
	int startIdx = _curWidgetID
	
	while (_widgets[_curWidgetID] != none)
		_curWidgetID += 1
		if (_curWidgetID >= 128)
			_curWidgetID = 0
		endIf
		if (_curWidgetID == startIdx)
			return -1 ; Should never happen because we have widgetCount. Just to be sure. 
		endIf
	endWhile
	
	return _curWidgetID
endFunction

function CreateWidget(int a_widgetID, string a_widgetType)
	_widgetTypes[a_widgetID] = a_widgetType
	string[] args = new string[2]
	args[0] = a_widgetID as string
	args[1] = a_widgetType
	UI.InvokeStringA(HUD_MENU, "_global.WidgetLoader.loadWidget", args);
endFunction
