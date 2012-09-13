scriptname SKI_ConfigMenu extends SKI_ConfigBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Lists
string[]	_alignments

string[]	_effectSizes
float[]		_AEEffectSizeValues

; OIDs (T:Text B:Toggle S:Slider M:Menu)
int			_itemcardAlignOID_T
int			_itemcardXOffsetOID_S
int			_itemcardYOffsetOID_S

int			_3DItemXOffsetOID_S
int			_3DItemYOffsetOID_S
int			_3DItemScaleOID_S

int			_AEEffectSizeOID_T

; State
int			_itemcardAlignIdx	= 2
float		_itemcardXOffset	= 0.0
float		_itemcardYOffset	= 0.0

float		_3DItemXOffset		= 0.0
float		_3DItemYOffset		= 0.0
float		_3DItemScale		= 1.5

int			_AEEffectSizeIdx	= 1

; Internal
float		_itemXBase


; PROPERTIES --------------------------------------------------------------------------------------

; @autoFill
SKI_SettingsManager property SKI_SettingsManagerInstance auto

SKI_ActiveEffectsWidget property SKI_ActiveEffectsWidgetInstance auto


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnInit()
	parent.OnInit()

	_alignments = new string[3]
	_alignments[0] = "Left"
	_alignments[1] = "Right"
	_alignments[2] = "Center"

	_effectSizes = new string[3]
	_effectSizes[0] = "Small"
	_effectSizes[1] = "Medium"
	_effectSizes[2] = "Large"

	_AEEffectSizeValues = new float[3]
	_AEEffectSizeValues[0] = 32.0
	_AEEffectSizeValues[1] = 48.0
	_AEEffectSizeValues[2] = 64.0

	ApplySettings()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_QuestBase
event OnGameReload()
	ApplySettings()
endEvent

function ApplySettings()
	float h = Utility.GetINIInt("iSize H:Display")
	float w = Utility.GetINIInt("iSize W:Display")
	if ((w / h) == 1.6)
		_itemXBase = -32.458335876465
	else
		_itemXBase = -29.122497558594
	endIf

	; Item
	Utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _3DItemScale)
	Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
	Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", (12 + _3DItemYOffset))
	Utility.SetINIFloat("fInventory3DItemPosScale:Interface", _3DItemScale)
	Utility.SetINIFloat("fInventory3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
	Utility.SetINIFloat("fInventory3DItemPosZ:Interface", (16 + _3DItemYOffset))

	; Magic
	Utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _3DItemScale)
	Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", (12 + _3DItemYOffset))
	Utility.SetINIFloat("fMagic3DItemPosScale:Interface", _3DItemScale)
	Utility.SetINIFloat("fMagic3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosZ:Interface", (16 + _3DItemYOffset))
endFunction

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

	if (a_page == Pages[0])
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Item Card")
		_itemcardAlignOID_T		= AddTextOption("Align", _alignments[_itemcardAlignIdx])
		_itemcardXOffsetOID_S	= AddSliderOption("Horizontal Offset", _itemcardXOffset)
		_itemcardYOffsetOID_S	= AddSliderOption("Vertical Offset", _itemcardYOffset)

		AddEmptyOption()

		AddHeaderOption("3D Item")
		_3DItemXOffsetOID_S		= AddSliderOption("Horizontal Offset", _3DItemXOffset)
		_3DItemYOffsetOID_S		= AddSliderOption("Vertical Offset", _3DItemYOffset)
		_3DItemScaleOID_S		= AddSliderOption("Scale", _3DItemScale, "{1}")

		SetCursorPosition(1)
	elseIf (a_page == Pages[1])
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Active Effects")

		_AEEffectSizeOID_T = AddTextOption("Effect Size", _effectSizes[_AEEffectSizeIdx])
	endIf
endEvent


; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
	{Called when the user selects a non-dialog option}

	string page = CurrentPage
	
	if (page == Pages[0])
		if (a_option == _itemcardAlignOID_T)
			if (_itemcardAlignIdx < _alignments.length - 1)
				_itemcardAlignIdx += 1
			else
				_itemcardAlignIdx = 0
			endif
			SetTextOptionValue(a_option, _alignments[_itemcardAlignIdx])
			SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignments[_itemcardAlignIdx])
		endIf

	elseIf (page == Pages[1])
		if (a_option == _AEEffectSizeOID_T)
			if (_AEEffectSizeIdx < _effectSizes.length - 1)
				_AEEffectSizeIdx += 1
			else
				_AEEffectSizeIdx = 0
			endif
			SetTextOptionValue(a_option, _effectSizes[_AEEffectSizeIdx])
			;SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignments[_itemcardAlignIdx])
			SKI_ActiveEffectsWidgetInstance.EffectSize = _AEEffectSizeValues[_AEEffectSizeIdx]
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when the user selects a slider option}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _itemcardXOffsetOID_S)
			SetSliderDialogStartValue(_itemcardXOffset)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogMinValue(-1000)
			SetSliderDialogMaxValue(1000)
			SetSliderDialogInterval(1)
		elseIf (a_option == _itemcardYOffsetOID_S)
			SetSliderDialogStartValue(_itemcardYOffset)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogMinValue(-1000)
			SetSliderDialogMaxValue(1000)
			SetSliderDialogInterval(1)

		elseIf (a_option == _3DItemXOffsetOID_S)
			SetSliderDialogStartValue(_3DItemXOffset)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogMinValue(-128)
			SetSliderDialogMaxValue(128)
			SetSliderDialogInterval(1)
		elseIf (a_option == _3DItemYOffsetOID_S)
			SetSliderDialogStartValue(_3DItemYOffset)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogMinValue(-128)
			SetSliderDialogMaxValue(128)
			SetSliderDialogInterval(1)
		elseIf (a_option == _3DItemScaleOID_S)
			SetSliderDialogStartValue(_3DItemScale)
			SetSliderDialogDefaultValue(1.5)
			SetSliderDialogMinValue(0.5)
			SetSliderDialogMaxValue(5)
			SetSliderDialogInterval(0.1)

		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when the user accepts a new slider value}

	string page = CurrentPage

	if (page == Pages[0])
		if (a_option == _itemcardXOffsetOID_S)
			_itemcardXOffset = a_value
			SetSliderOptionValue(a_option, _itemcardXOffset)
			SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset)
		elseIf (a_option == _itemcardYOffsetOID_S)
			_itemcardYOffset = a_value
			SetSliderOptionValue(a_option, _itemcardYOffset)
			SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset)

		elseIf (a_option == _3DItemXOffsetOID_S)
			_3DItemXOffset = a_value
			SetSliderOptionValue(a_option, _3DItemXOffset)
			Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
			Utility.SetINIFloat("fInventory3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
			Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
			Utility.SetINIFloat("fMagic3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
		elseIf (a_option == _3DItemYOffsetOID_S)
			_3DItemYOffset = a_value
			SetSliderOptionValue(a_option, _3DItemYOffset)
			Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", (12 + _3DItemYOffset))
			Utility.SetINIFloat("fInventory3DItemPosZ:Interface", (16 + _3DItemYOffset))
			Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", (12 + _3DItemYOffset))
			Utility.SetINIFloat("fMagic3DItemPosZ:Interface", (16 + _3DItemYOffset))
		elseIf (a_option == _3DItemScaleOID_S)
			_3DItemScale = a_value
			SetSliderOptionValue(a_option, _3DItemScale, "{1}")
			Utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _3DItemScale)
			Utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _3DItemScale)
			Utility.SetINIFloat("fInventory3DItemPosScale:Interface", _3DItemScale)
			Utility.SetINIFloat("fMagic3DItemPosScale:Interface", _3DItemScale)
		endIf
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}

	string page = CurrentPage

	if (page == Pages[0])
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}

	string page = CurrentPage

	if (page == Pages[0])
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}

	string page = CurrentPage
	
	; Options
	if (page == Pages[0])
		if (a_option == _itemcardAlignOID_T)
			SetInfoText("Default: Center")
		elseIf (a_option == _itemcardXOffsetOID_S)
			SetInfoText("Default: 0")
		elseIf (a_option == _itemcardYOffsetOID_S)
			SetInfoText("Default: 0")

		elseIf (a_option == _3DItemXOffsetOID_S)
			SetInfoText("Default: 0")
		elseIf (a_option == _3DItemYOffsetOID_S)
			SetInfoText("Default: 0")
		elseIf (a_option == _3DItemScaleOID_S)
			SetInfoText("Default: 1.5")
		endIf
	elseIf (page == Pages[1])
		If (a_option == _AEEffectSizeOID_T)
			SetInfoText("Default: Medium")
		endIf
	endIf
endEvent
