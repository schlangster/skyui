scriptname SKI_ConfigBase extends SKI_QuestBase

;##################################################################################################
; File Version:		1.0
; Documentation:	https://github.com/schlangster/skyui/wiki/MCM-API-Reference
;##################################################################################################
;
; Base script for custom config menus.
;
; This file contains the public interface of SKI_ConfigBase so you're able to extend it.
;
; DO NOT MODIFY THIS SCRIPT!
; DO NOT RECOMPILE THIS SCRIPT!
;
;##################################################################################################


; CONSTANTS ---------------------------------------------------------------------------------------

int property		OPTION_FLAG_NONE		= 0x00 autoReadonly
int property		OPTION_FLAG_DISABLED	= 0x01 autoReadonly

int property		LEFT_TO_RIGHT	= 1	autoReadonly
int property		TOP_TO_BOTTOM	= 2 autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

string property		ModName auto
string[] property	Pages auto
string property CurrentPage
	string function get()
		Guard()
		return  ""
	endFunction
endProperty


; EVENTS ------------------------------------------------------------------------------------------

event OnConfigRegister()
	{Called when this config menu registered at the control panel}
	Guard()
endEvent

event OnConfigOpen()
	{Called when this config menu is opened}
	Guard()
endEvent

event OnConfigClose()
	{Called when this config menu is closed}
	Guard()
endEvent

event OnVersionUpdate(int a_version)
	{Called when a version update of this script has been detected}
	Guard()
endEvent

event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}
	Guard()
endEvent

event OnOptionHighlight(int a_option)
	{Called when highlighting an option}
	Guard()
endEvent

event OnOptionSelect(int a_option)
	{Called when a non-interactive option has been selected}
	Guard()
endEvent

event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}
	Guard()
endEvent

event OnOptionSliderOpen(int a_option)
	{Called when a slider option has been selected}
	Guard()
endEvent

event OnOptionSliderAccept(int a_option, float a_value)
	{Called when a new slider value has been accepted}
	Guard()
endEvent

event OnOptionMenuOpen(int a_option)
	{Called when a menu option has been selected}
	Guard()
endEvent

event OnOptionMenuAccept(int a_option, int a_index)
	{Called when a menu entry has been accepted}
	Guard()
endEvent

event OnOptionColorOpen(int a_option)
	{Called when a color option has been selected}
	Guard()
endEvent

event OnOptionColorAccept(int a_option, int a_color)
	{Called when a new color has been accepted}
	Guard()
endEvent

event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}
	Guard()
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

int function GetVersion()
	{Returns version of this script. Override if necessary}
	Guard()
endFunction

string function GetCustomControl(int a_keyCode)
	{Returns the name of a custom control mapped to given keyCode, or "" if the key is not in use by this config. Override if necessary}
	Guard()
endFunction

function ForcePageReset()
	{Forces a full reset of the current page}
	Guard()
endFunction

function SetTitleText(string a_text)
	{Sets the title text of the control panel}
	Guard()
endFunction

function SetInfoText(string a_text)
	{Sets the text for the info text field below the option panel}
	Guard()
endFunction

function SetCursorPosition(int a_position)
	{Sets the position of the cursor used for the option setters}
	Guard()
endFunction

function SetCursorFillMode(int a_fillMode)
	{Sets the fill direction of the cursor used for the option setters}
	Guard()
endFunction

int function AddEmptyOption()
	{Adds an empty option, which can be used for padding instead of manually re-positioning the cursor}
	Guard()
endFunction

int function AddHeaderOption(string a_text, int a_flags = 0)
	{Adds a header option to group several options together}
	Guard()
endFunction

int function AddTextOption(string a_text, string a_value, int a_flags = 0)
	{Adds a generic text/value option}
	Guard()
endFunction

int function AddToggleOption(string a_text, bool a_checked, int a_flags = 0)
	{Adds a check box option that can be toggled on and off}
	Guard()
endfunction

int function AddSliderOption(string a_text, float a_value, string a_formatString = "{0}", int a_flags = 0)
	{Adds an option that opens a slider dialog when selected}
	Guard()
endFunction

int function AddMenuOption(string a_text, string a_value, int a_flags = 0)
	{Adds an option that opens a menu dialog when selected}
	Guard()
endFunction

int function AddColorOption(string a_text, int a_color, int a_flags = 0)
	{Adds an option that opens a color swatch dialog when selected}
	Guard()
endFunction

int function AddKeyMapOption(string a_text, int a_keyCode, int a_flags = 0)
	{Adds a key mapping option}
	Guard()
endFunction

function LoadCustomContent(string a_source, float a_x = 0.0, float a_y = 0.0)
	{Loads an external file into the option panel}
	Guard()
endFunction

function UnloadCustomContent()
	{Clears any custom content and re-enables the original option list}
	Guard()
endFunction

function SetOptionFlags(int a_option, int a_flags, bool a_noUpdate = false)
	{Sets the option flags}
	Guard()
endFunction

function SetTextOptionValue(int a_option, string a_value, bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endFunction

function SetToggleOptionValue(int a_option, bool a_checked, bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endfunction

function SetSliderOptionValue(int a_option, float a_value, string a_formatString = "{0}", bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endFunction

function SetMenuOptionValue(int a_option, string a_value, bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endFunction

function SetColorOptionValue(int a_option, int a_color, bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endFunction

function SetKeyMapOptionValue(int a_option, int a_keyCode, bool a_noUpdate = false)
	{Sets the value(s) of an existing option}
	Guard()
endFunction

function SetSliderDialogStartValue(float a_value)
	{Sets slider dialog parameter(s)}
	Guard()
endFunction

function SetSliderDialogDefaultValue(float a_value)
	{Sets slider dialog parameter(s)}
	Guard()
endFunction

function SetSliderDialogRange(float a_minValue, float a_maxValue)
	{Sets slider dialog parameter(s)}
	Guard()
endFunction

function SetSliderDialogInterval(float a_value)
	{Sets slider dialog parameter(s)}
	Guard()
endFunction

function SetMenuDialogStartIndex(int a_value)
	{Sets menu dialog parameter(s)}
	Guard()
endFunction

function SetMenuDialogDefaultIndex(int a_value)
	{Sets menu dialog parameter(s)}
	Guard()
endFunction

function SetMenuDialogOptions(string[] a_options)
	{Sets menu dialog parameter(s)}
	Guard()
endFunction

function SetColorDialogStartColor(int a_color)
	{Sets menu color parameter(s)}
	Guard()
endFunction

function SetColorDialogDefaultColor(int a_color)
	{Sets menu color parameter(s)}
	Guard()
endFunction

bool function ShowMessage(string a_message, bool a_withCancel = true, string a_acceptLabel = "$Accept", string a_cancelLabel = "$Cancel")
	{Shows a message dialog and waits until the user has closed it}
	Guard()
endFunction

function Guard()
	Debug.MessageBox("SKI_ConfigBase: Don't recompile this script!")
endFunction