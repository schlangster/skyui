scriptname SKI_MeterWidget extends SKI_WidgetBase

;##################################################################################################
; File Version:		0.0
; Documentation:	https://github.com/schlangster/skyui/wiki/
;##################################################################################################
;
; This file contains the public interface of SKI_MeterWidget
;
; DO NOT MODIFY THIS SCRIPT!
; DO NOT RECOMPILE THIS SCRIPT!
;
;##################################################################################################


; PROPERTIES --------------------------------------------------------------------------------------

float property Width
	{Width of the meter in pixels at a resolution of 1280x720. Default: 292.8}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty

float property Height
	{Height of the meter in pixels at a resolution of 1280x720. Default: 25.2}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty

int property PrimaryColor
	{Primary color of the meter gradient RRGGBB [0x000000, 0xFFFFFF]. Default: 0xFF0000. Convert to decimal when editing this in the CK}
	int function get()
		Guard()
		return 0
	endFunction
	
	function set(int a_val)
		Guard()
	endFunction
endProperty

int property SecondaryColor
	{Secondary color of the meter gradient, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	int function get()
		Guard()
		return 0
	endFunction
	
	function set(int a_val)
		Guard()
	endFunction
endProperty

int property FlashColor
	{Color of the meter warning flash, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	int function get()
		Guard()
		return 0
	endFunction
	
	function set(int a_val)
		Guard()
	endFunction
endProperty

string property FillOrigin
	{The position at which the meter fills from, ["left", "center", "right"] . Default: center}
	string function get()
		Guard()
		return ""
	endFunction
	
	function set(string a_val)
		Guard()
	endFunction
endProperty

float property Percent
	{Percent of the meter [0.0, 1.0]. Default: 0.0}
	float function get()
		Guard()
		return 0.0
	endFunction
	
	function set(float a_val)
		Guard()
	endFunction
endProperty


; EVENTS ------------------------------------------------------------------------------------------

; @override SKI_WidgetBase
event OnWidgetReset()
	Guard()
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetType()
	Guard()
	return ""
endFunction

function SetPercent(float a_percent, bool a_force = false)
	{Sets the meter percent, a_force sets the meter percent without animation}
	Guard()
endFunction

function ForcePercent(float a_percent)
	{Convenience function for SetPercent(a_percent, true)}
	Guard()
endFunction


function StartFlash(bool a_force = false)
	{Starts meter flashing. a_force starts the meter flashing if it's already animating}
	Guard()
endFunction


function ForceFlash(bool a_force)
	{Convenience function for StartFlash(true)}
	Guard()
endFunction

function SetColors(int a_primaryColor, int a_secondaryColor = -1, int a_flashColor = -1)
	{Sets the meter percent, a_force sets the meter percent without animation}
	Guard()
endFunction

function Guard()
	Debug.MessageBox("SKI_MeterWidget: Don't recompile this script!")
endFunction