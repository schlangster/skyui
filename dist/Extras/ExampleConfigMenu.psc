scriptname ExampleConfigMenu extends SKI_ConfigBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Option IDs
int	_toggleOption1
int	_toggleOption2
int	_toggleOption3
int _textOption1
int _counterOption
int _sliderFormatOption
int _difficultyMenuOption

; State
bool	_toggleState1 = false
bool	_toggleState2 = false
bool	_toggleState3 = false
int		_counter = 0
float	_sliderPercent = 50.0
int		_curDifficulty = 5

; Submenu options
string[]	_difficultyList


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnInit()
	parent.OnInit()

	_difficultyList = new string[8]
	_difficultyList[0] = "Casual"
	_difficultyList[1] = "Very Easy"
	_difficultyList[2] = "Easy"
	_difficultyList[3] = "What used to be Easy"
	_difficultyList[4] = "Normal"
	_difficultyList[5] = "Hard"
	_difficultyList[6] = "Very Hard"
	_difficultyList[7] = "Why am I doing this?"
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}

	; Load custom .swf for animated logo
	if (a_page == "")
		LoadCustomContent("skyui_splash.swf")
		return
	else
		UnloadCustomContent()
	endIf

	if (a_page == Pages[0])
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Toggle Options")
		_toggleOption1		= AddToggleOption("Toggle Option 1", _toggleState1)
		_toggleOption2		= AddToggleOption("Toggle Option 2", _toggleState2)
		_toggleOption3		= AddToggleOption("On or Off?", _toggleState3)
		AddEmptyOption()

		AddHeaderOption("Text Options")
		_textOption1		= AddTextOption("Text Option 1", "CLICK ME")
		_counterOption		= AddTextOption("Number of Clicks", _counter)

		SetCursorPosition(1)

		AddHeaderOption("All option types")
		AddTextOption("Text", "VALUE")
		AddToggleOption("Toggle", false)
		AddSliderOption("Slider", 1.75)
		_sliderFormatOption = AddSliderOption("Slider (format string)", _sliderPercent, "At {0}%")
		_difficultyMenuOption = AddMenuOption("Difficulty", _difficultyList[_curDifficulty])
	
	elseIf (a_page == Pages[1])
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

	string page = CurrentPage
	
	if (page == Pages[0])
		if (a_option == _toggleOption1)
			_toggleState1 = !_toggleState1
			SetToggleOptionValue(a_option, _toggleState1)

		elseIf (a_option == _toggleOption2)
			_toggleState2 = !_toggleState2
			SetToggleOptionValue(a_option, _toggleState2)

		elseIf (a_option == _toggleOption3)
			_toggleState3 = !_toggleState3
			SetToggleOptionValue(a_option, _toggleState3)

		elseIf (a_option == _textOption1)
			; Do something
			SetTextOptionValue(a_option, "GOOD BOY")

		elseIf (a_option == _counterOption)
			_counter += 1
			SetTextOptionValue(a_option, _counter)
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when the user selects a slider option}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _sliderFormatOption)
			SetSliderDialogStartValue(_sliderPercent)
			SetSliderDialogDefaultValue(50)
			SetSliderDialogMinValue(0)
			SetSliderDialogMaxValue(100)
			SetSliderDialogInterval(2)
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when the user accepts a new slider value}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _sliderFormatOption)
			_sliderPercent = a_value
			SetSliderOptionValue(a_option, a_value, "At {0}%")
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _difficultyMenuOption)
			SetMenuDialogStartIndex(_curDifficulty)
			SetMenuDialogDefaultIndex(5)
			SetMenuDialogOptions(_difficultyList)
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _difficultyMenuOption)
			_curDifficulty = a_index
			SetMenuOptionValue(a_option, _difficultyList[_curDifficulty])
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}

	string page = CurrentPage
	
	; Options
	if (page == Pages[0])
		if (a_option == _toggleOption1)
			SetInfoText("Info text for toggle option 1.")
		elseIf (a_option == _toggleOption2)
			SetInfoText("Info text for toggle option 2.")
		elseIf (a_option == _toggleOption3)
			SetInfoText("Sometimes choice can be a burden...")
		endIf
	endIf
endEvent
