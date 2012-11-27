scriptname SKI_WidgetBase extends SKI_QuestBase

;##################################################################################################
; File Version:		0.0
; Documentation:	https://github.com/schlangster/skyui/wiki/
;##################################################################################################
;
; Base script for custom widgets menus.
;
; This file contains the public interface of SKI_WidgetBase so you're able to extend it.
;
; DO NOT MODIFY THIS SCRIPT!
; DO NOT RECOMPILE THIS SCRIPT!
;
;##################################################################################################

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly

; PROPERTIES --------------------------------------------------------------------------------------

; Read-only
int property WidgetID
	{Unique ID of the widget. ReadOnly}
	int function get()
		Guard()
		return 0
	endFunction
endProperty

; Read-only
bool property Initialized
	{True when the widget has finished initializing. ReadOnly}
	bool function get()
		Guard()
		return false
	endFunction
endProperty

; Read-only
string property WidgetRoot
	{Path to the root of the widget from _root of HudMenu. ReadOnly}
	string function get()
		Guard()
		return ""
	endFunction
endProperty

string[] property Modes
	{HUDModes in which the widget is visible, see readme for available modes}
	string[] function get()
		Guard()
		string[] retVal = new string[1]
		return retVal
	endFunction
	
	function set(string[] a_val)
		Guard()
	endFunction
endProperty

string property HAlign
	{Horizontal registration point of the widget ["left", "center", "right"]. Default: "left"}
	string function get()
		Guard()
		return ""
	endFunction
	
	function set(string a_val)
		Guard()
	endFunction
endProperty

string property VAlign
	{Vertical registration point of the widget ["top", "center", "bottom"]. Default: "top"}
	string function get()
		Guard()
		return ""
	endFunction
	
	function set(string a_val)
		Guard()
	endFunction
endProperty

float property X
	{Horizontal position of the widget in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty

float property Y
	{Vertical position of the widget in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty

float property Alpha
	{Opacity of the widget [0.0, 100.0]. Default: 0.0}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty


; INITIALIZATION ----------------------------------------------------------------------------------

; @interface
event OnWidgetInit()
	{Handles any custom widget initialization}
	Guard()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; Executed after each game reload by widget manager.
event OnWidgetLoad()
	Guard()
endEvent

event OnWidgetReset()
	; Reset base properties except modes to prevent widget from being drawn too early.
	Guard()
endEvent

; Executed whenever a hudModeChange is observed
; TODO
event OnHudModeChange(string a_eventName, string a_hudMode, float a_numArg, Form sender)
	Guard()
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
string function GetWidgetType()
	Guard()
	return ""
endFunction

function UpdateWidgetClientInfo()
	Guard()
endFunction

function UpdateWidgetPositionX()
	Guard()
endFunction

function UpdateWidgetPositionY()
	Guard()
endFunction

function UpdateWidgetAlpha()
	Guard()
endFunction

function UpdateWidgetHAlign()
	Guard()
endFunction

function UpdateWidgetVAlign()
	Guard()
endFunction

function UpdateWidgetModes()
	Guard()
endFunction

function Guard()
	Debug.MessageBox("SKI_WidgetBase: Don't recompile this script!")
endFunction