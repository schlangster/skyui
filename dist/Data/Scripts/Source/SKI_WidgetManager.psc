scriptname SKI_WidgetManager extends SKI_QuestBase  

; CONSTANTS------------------------------

string	HUD_MENU = "HUD Menu"


; PRIVATE VARIABLES ---------------------

SKI_WidgetBase[]	_widgets
string[]			_widgetTypes	; Cache these so they can be passed instantly
int					_curWidgetID
int					_widgetCount

; PROPERTIES ----------------------------

; FUNCTIONS -------------------------

function CleanUp()
	Debug.Trace("SKI_WidgetManager: CleanUp()")
	string[] args = new string[2]
	_widgetCount = 0
	int i = 0
	while (i < _widgets.length)
		if (_widgets[i] == none)
			_widgetTypes[i] = none
		else
			_widgetCount += 1
		endIf
		
		i += 1
	endWhile
endFunction

int function RequestWidgetID(SKI_WidgetBase a_client)
	Debug.Trace("SKI_WidgetManager: RequestWidgetID(a_client = " + a_client + ")")
	if (_widgetCount >= 128)
		return -1 ;TODO 20120919 need to check for these
	endIf

	int widgetID = NextWidgetID()
	_widgets[widgetID] = a_client
	_widgetCount += 1
	
	Debug.Trace("SKI_WidgetManager: RequestWidgetID() returning " + widgetID as string)
	return widgetID
endFunction

int function NextWidgetID()
	Debug.Trace("SKI_WidgetManager: NextWidgetID()")
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
	
	Debug.Trace("SKI_WidgetManager: NextWidgetID returned " + _curWidgetID)
	return _curWidgetID
endFunction

function CreateWidget(int a_widgetID, string a_widgetType)
	Debug.Trace("SKI_WidgetManager: CreateWidget(a_widgetID = " + a_widgetID + ", a_widgetType = " + a_widgetType + ")")
	_widgetTypes[a_widgetID] = a_widgetType
	string[] args = new string[2]
	args[0] = a_widgetID as string
	args[1] = a_widgetType
	UI.InvokeStringA(HUD_MENU, "_global.WidgetLoader.loadWidget", args);
endFunction

; EVENTS ----------------------------

event OnInit()
	Debug.Trace("SKI_WidgetManager: OnInit")
	_widgets		= new SKI_WidgetBase[128]
	_widgetTypes	= new string[128]
	_curWidgetID	= 0
	_widgetCount	= 0
	
	OnGameReload()
endEvent

event OnGameReload()
	Debug.Trace("SKI_WidgetManager: OnGameReload()")
	RegisterForModEvent("widgetLoaded", "OnWidgetLoad")
	
	CleanUp()
	
	; Load already registered widgets
	UI.InvokeStringA(HUD_MENU, "_global.WidgetLoader.loadWidgets", _widgetTypes);
endEvent

event OnWidgetLoad(string a_eventName, String a_msg)
	Debug.Trace("SKI_WidgetManager: event OnWidgetLoaded(a_eventName = " + a_eventName + ", a_msg = " + a_msg + ")")
	int widgetID = a_msg as int
	SKI_WidgetBase client = _widgets[widgetID]
	
	if (client != none)
		client.OnWidgetLoad()
	endIf
endEvent
