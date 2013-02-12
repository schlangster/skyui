scriptname SKI_WidgetManager extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_WidgetBase[]	_widgets
string[]			_widgetSources
int					_curWidgetID		= 0
int					_widgetCount		= 0


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_widgets		= new SKI_WidgetBase[128]
	_widgetSources	= new string[128]

	; Wait until all widgets have registered their callbacks
	Utility.Wait(0.5)
	
	OnGameReload()
endEvent

event OnGameReload()
	RegisterForModEvent("SKIWF_widgetLoaded", "OnWidgetLoad")
	RegisterForModEvent("SKIWF_widgetError", "OnWidgetError")

	CleanUp()

	; Init now, or delay until hudmenu has been loaded
	if (UI.IsMenuOpen(HUD_MENU))
		InitWidgetLoader()
	else
		RegisterForMenu(HUD_MENU)
	endIf
endEvent

event OnMenuOpen(string a_menuName)
	if (a_menuName == HUD_MENU)
		UnregisterForMenu(HUD_MENU)
		InitWidgetLoader()
	endIf
endEvent

function CleanUp()
	_widgetCount = 0
	int i = 0
	
	while (i < _widgets.length)
		if (_widgets[i] == none || _widgets[i].GetFormID() == 0)
			; Widget no longer exists
			_widgets[i] = none
			_widgetSources[i] = ""
		else
			_widgetCount += 1
		endIf
		i += 1
	endWhile
endFunction

function InitWidgetLoader()
    Debug.Trace("InitWidgetLoader()")

	int releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")

	; Not injected yet
	if (releaseIdx == 0)
 
 		; Interface/
		string rootPath = ""

		string[] args = new string[2]
		args[0] = "widgetLoaderContainer"
		args[1] = "-1000"
		
		; Create empty container clip
		UI.InvokeStringA(HUD_MENU, "_root.createEmptyMovieClip", args)

		; Try to load from Interface/exported/hudmenu.gfx
		UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "skyui/widgetloader.swf")
		Utility.Wait(0.5)
		releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")

		; If failed, try to load from Interface/hudmenu.swf
		if (releaseIdx == 0)
			; Interface/exported
			rootPath = "exported/"
			UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "exported/skyui/widgetloader.swf")	
			Utility.Wait(0.5)
			releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")
		endIf

		; Injection failed
		if (releaseIdx == 0)
			Debug.Trace("InitWidgetLoader(): load failed")
			return
		endIf

		UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.setRootPath", rootPath)
	endIf

	; Load already registered widgets
	UI.InvokeStringA(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidgets", _widgetSources)
	
	SendModEvent("SKIWF_widgetManagerReady")
endFunction


; EVENTS ------------------------------------------------------------------------------------------

event OnWidgetLoad(string a_eventName, string a_strArg, float a_numArg, form a_sender)
	int widgetID = a_strArg as int
	SKI_WidgetBase client = _widgets[widgetID]
	
	if (client != none)
		client.OnWidgetLoad()
	endIf
endEvent

event OnWidgetError(string a_eventName, string a_strArg, float a_numArg, form a_sender)
	int widgetID = a_numArg as int
	string errorType = a_strArg
	
	Debug.Trace("WidgetError: " + (_widgets[widgetID] as string) + ": " + errorType)
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

function CreateWidget(int a_widgetID, string a_widgetSource)
	_widgetSources[a_widgetID] = a_widgetSource
	string[] args = new string[2]
	args[0] = a_widgetID as string
	args[1] = a_widgetSource
	UI.InvokeStringA(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidget", args);
endFunction

SKI_WidgetBase[] function GetWidgets()
	; Return a copy
	SKI_WidgetBase[] widgetsCopy = new SKI_WidgetBase[128]
	int i = 0
	
	while (i < _widgets.length)
		widgetsCopy[i] = _widgets[i]
		i += 1
	endWhile

	return widgetsCopy
endFunction
