scriptname ExampleConfigMenu extends SKI_ConfigBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Lists
string[]	_difficultyList

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_toggle1OID_B
int			_toggle2OID_B
int			_toggle3OID_B

int			_textOID_T
int			_counterOID_T
int			_sliderFormatOID_S
int			_difficultyMenuOID_M

; State
bool		_toggleState1 = false
bool		_toggleState2 = false
bool		_toggleState3 = false
int			_counter = 0
float		_sliderPercent = 50.0
int			_curDifficulty = 0


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnConfigInit()
	Pages = new string[2]
	Pages[0] = "Example Page"
	Pages[1] = "Another Page"

	_difficultyList = new string[4]
	_difficultyList[0] = "Casual"
	_difficultyList[1] = "Easy"
	_difficultyList[2] = "Normal"
	_difficultyList[3] = "Hard"
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}

	; Load custom .swf for animated logo
	if (a_page == "")
		LoadCustomContent("skyui/skyui_splash.swf")
		return
	else
		UnloadCustomContent()
	endIf

	if (a_page == "Example Page")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Toggle Options")
		_toggle1OID_B		= AddToggleOption("Toggle Option 1", _toggleState1)
		_toggle2OID_B		= AddToggleOption("Toggle Option 2", _toggleState2)
		_toggle3OID_B		= AddToggleOption("On or Off?", _toggleState3)
		AddEmptyOption()

		AddHeaderOption("Text Options")
		_textOID_T			= AddTextOption("Text Option 1", "CLICK ME")
		_counterOID_T		= AddTextOption("Number of Clicks", _counter)

		SetCursorPosition(1)

		AddHeaderOption("All option types")
		AddTextOption("Text", "VALUE")
		AddToggleOption("Toggle", false)
		AddSliderOption("Slider", 1.75)
		_sliderFormatOID_S = AddSliderOption("Slider (format string)", _sliderPercent, "At {0}%")
		_difficultyMenuOID_M = AddMenuOption("Difficulty", _difficultyList[_curDifficulty])
	
	elseIf (a_page == "Another Page")

		SetTitleText("Custom title text")
		SetCursorFillMode(LEFT_TO_RIGHT)

		AddHeaderOption("Hitpoints")
		AddEmptyOption()
		AddSliderOption("Player Endurance Multiplier", 10)
		AddSliderOption("NPC Endurance Multiplier", 7)
		AddSliderOption("Player Level Multiplier", 0)
		AddSliderOption("NPC Level Multiplier", 0)
		
	endIf
endEvent


; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
	{Called when the user selects a non-dialog option}
	
	if (a_option == _toggle1OID_B)
		_toggleState1 = !_toggleState1
		SetToggleOptionValue(a_option, _toggleState1)

	elseIf (a_option == _toggle2OID_B)
		_toggleState2 = !_toggleState2
		SetToggleOptionValue(a_option, _toggleState2)

	elseIf (a_option == _toggle3OID_B)
		_toggleState3 = !_toggleState3
		SetToggleOptionValue(a_option, _toggleState3)

	elseIf (a_option == _textOID_T)
		; Do something
		SetTextOptionValue(a_option, "WELL DONE")

	elseIf (a_option == _counterOID_T)
		_counter += 1
		SetTextOptionValue(a_option, _counter)
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when the user selects a slider option}

	if (a_option == _sliderFormatOID_S)
		SetSliderDialogStartValue(_sliderPercent)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(2)
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when the user accepts a new slider value}
		
	if (a_option == _sliderFormatOID_S)
		_sliderPercent = a_value
		SetSliderOptionValue(a_option, a_value, "At {0}%")
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}

	if (a_option == _difficultyMenuOID_M)
		SetMenuDialogStartIndex(_curDifficulty)
		SetMenuDialogDefaultIndex(5)
		SetMenuDialogOptions(_difficultyList)
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}

	if (a_option == _difficultyMenuOID_M)
		_curDifficulty = a_index
		SetMenuOptionValue(a_option, _difficultyList[_curDifficulty])
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}
	
	if (a_option == _toggle1OID_B)
		SetInfoText("Info text for toggle option 1.")
	elseIf (a_option == _toggle2OID_B)
		SetInfoText("Info text for toggle option 2.")
	elseIf (a_option == _toggle3OID_B)
		SetInfoText("Sometimes choice can be a burden...")
	endIf
endEvent
