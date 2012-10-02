scriptname MyConfigMenu extends SKI_ConfigBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_myTextOID_T
int			_myToggle_S
int			_mySliderOID_S
int			_myMenuOID_S
int			_myColorOID_S
int			_myKeyOID_S

; State

; ...


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnInit()
	parent.OnInit()

	; ...
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}

	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when highlighting an option}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
	{Called when a non-interactive option has been selected}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when a slider option has been selected}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when a new slider value has been accepted}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when a menu option has been selected}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when a menu entry has been accepted}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionColorOpen(int a_option)
	{Called when a color option has been selected}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionColorAccept(int a_option, int a_color)
	{Called when a new color has been accepted}

	string page = CurrentPage
	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionKeyMapChange(int a_option, int a_keyCode)
	{Called when a key has been remapped}

	string page = CurrentPage
	; ...
endEvent
