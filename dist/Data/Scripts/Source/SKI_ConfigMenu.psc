scriptname SKI_ConfigMenu extends SKI_ConfigBase

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; Lists
string[]	_alignments

string[]	_sizes

string[]	_corners
string[]	_cornerValues

string[]	_orientations

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_itemlistFontSizeOID_T

int			_itemcardAlignOID_T
int			_itemcardXOffsetOID_S
int			_itemcardYOffsetOID_S

int			_3DItemXOffsetOID_S
int			_3DItemYOffsetOID_S
int			_3DItemScaleOID_S

int			_AEEnabledOID_B
int			_AEEffectSizeOID_T
int			_AEClampCornerOID_M
int			_AEGroupEffectCountOID_S
int			_AEOffsetXOID_S
int			_AEOffsetYOID_S
int			_AEOrientationOID_T

int			_checkHUDMenuOID_B
int			_checkInventoryMenuOID_B
int			_checkMagicMenuOID_B
int			_checkBarterMenuOID_B
int			_checkContainerMenuOID_B
int			_checkGiftMenuOID_B

; State
int			_itemlistFontSizeIdx	= 1

int			_itemcardAlignIdx		= 2
float		_itemcardXOffset		= 0.0
float		_itemcardYOffset		= 0.0

float		_3DItemXOffset			= 0.0
float		_3DItemYOffset			= 0.0
float		_3DItemScale			= 1.5

bool		_AEEnabled				= false
float[]		_AEEffectSizeValues
int			_AEEffectSizeIdx		= 1
int			_AEClampCornerIdx		= 1
int			_AEGroupEffectCount		= 8
float[]		_AEBaseXValues
float		_AEOffsetX				= 0.0
float[]		_AEBaseYValues
float		_AEOffsetY				= 0.0
int			_AEOrientationIdx		= 1

; Internal
float		_itemXBase


; PROPERTIES --------------------------------------------------------------------------------------

SKI_SettingsManager property		SKI_SettingsManagerInstance auto
SKI_ActiveEffectsWidget property	SKI_ActiveEffectsWidgetInstance auto
SKI_Main property					SKI_MainInstance auto


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnInit()
	parent.OnInit()

	_alignments = new string[3]
	_alignments[0] = "Left"
	_alignments[1] = "Right"
	_alignments[2] = "Center"

	_sizes = new string[3]
	_sizes[0] = "Small"
	_sizes[1] = "Medium"
	_sizes[2] = "Large"

	_corners = new string[4]
	_corners[0] = "Top Left"
	_corners[1] = "Top Right"
	_corners[2] = "Bottom Right"
	_corners[3] = "Bottom Left"

	_cornerValues = new string[4]
	_cornerValues[0] = "TL"
	_cornerValues[1] = "TR"
	_cornerValues[2] = "BR"
	_cornerValues[3] = "BL"

	_orientations = new String[2]
	_orientations[0] = "Horizontal"
	_orientations[1] = "Vertical"

	_AEEffectSizeValues = new float[3]
	_AEEffectSizeValues[0] = 32.0
	_AEEffectSizeValues[1] = 48.0
	_AEEffectSizeValues[2] = 64.0

	_AEBaseXValues = new float[4]
	_AEBaseXValues[0] = 0.0
	_AEBaseXValues[1] = 1280.0
	_AEBaseXValues[2] = 1280.0
	_AEBaseXValues[3] = 0.0

	_AEBaseYValues = new float[4]
	_AEBaseYValues[0] = 0.0
	_AEBaseYValues[1] = 30.05
	_AEBaseYValues[2] = 720.0
	_AEBaseYValues[3] = 720.0

	ApplySettings()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; @implements SKI_QuestBase
event OnGameReload()
	parent.OnGameReload()
	
	ApplySettings()
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnPageReset(string a_page)

	; Load custom .swf for animated logo
	if (a_page == "")
		LoadCustomContent("skyui/skyui_splash.swf")
		return
	else
		UnloadCustomContent()
	endIf

	; -------------------------------------------------------
	if (a_page == "General")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Item List")
		_itemlistFontSizeOID_T		= AddTextOption("Font Size", _sizes[_itemlistFontSizeIdx])

		SetCursorPosition(1)

		; Disabled for now until icons are done
		AddHeaderOption("Active Effects HUD")
		_AEEnabledOID_B				= AddToggleOption("Enabled", _AEEnabled, OPTION_FLAG_DISABLED)
		_AEEffectSizeOID_T			= AddTextOption("Effect Size", _sizes[_AEEffectSizeIdx])

	; -------------------------------------------------------
	elseIf (a_page == "Advanced")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("Item Card")
		_itemcardAlignOID_T			= AddTextOption("Align", _alignments[_itemcardAlignIdx])
		_itemcardXOffsetOID_S		= AddSliderOption("Horizontal Offset", _itemcardXOffset)
		_itemcardYOffsetOID_S		= AddSliderOption("Vertical Offset", _itemcardYOffset)

		AddEmptyOption()

		AddHeaderOption("Active Effects HUD")
		_AEOrientationOID_T			= AddTextOption("Orientation", _orientations[_AEOrientationIdx])
		_AEClampCornerOID_M			= AddMenuOption("Clamp to Corner", _corners[_AEClampCornerIdx])
		_AEGroupEffectCountOID_S	= AddSliderOption("Max Effect Width", _AEGroupEffectCount, "{0}")
		_AEOffsetXOID_S				= AddSliderOption("X Offset", _AEOffsetX)
		_AEOffsetYOID_S				= AddSliderOption("Y Offset", _AEOffsetY)

		SetCursorPosition(1)

		AddHeaderOption("3D Item")
		_3DItemXOffsetOID_S			= AddSliderOption("Horizontal Offset", _3DItemXOffset)
		_3DItemYOffsetOID_S			= AddSliderOption("Vertical Offset", _3DItemYOffset)
		_3DItemScaleOID_S			= AddSliderOption("Scale", _3DItemScale, "{1}")

		AddEmptyOption()

		AddHeaderOption("SWF Version Checking")
		_checkHUDMenuOID_B			= AddToggleOption("HUD Menu", SKI_MainInstance.HUDMenuCheckEnabled)
		_checkInventoryMenuOID_B	= AddToggleOption("Inventory Menu", SKI_MainInstance.InventoryMenuCheckEnabled)
		_checkMagicMenuOID_B		= AddToggleOption("Magic Menu", SKI_MainInstance.MagicMenuCheckEnabled)
		_checkBarterMenuOID_B		= AddToggleOption("Barter Menu", SKI_MainInstance.BarterMenuCheckEnabled)
		_checkContainerMenuOID_B	= AddToggleOption("Container Menu", SKI_MainInstance.ContainerMenuCheckEnabled)
		_checkGiftMenuOID_B			= AddToggleOption("Gift Menu", SKI_MainInstance.GiftMenuCheckEnabled)
		
	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionDefault(int a_option)

	; -------------------------------------------------------
	if (a_option == _itemlistFontSizeOID_T)
		_itemlistFontSizeIdx = 1
		SetTextOptionValue(a_option, _sizes[_itemlistFontSizeIdx])
		ApplyItemListFontSize()

	; -------------------------------------------------------
	elseIf (a_option == _itemcardAlignOID_T)
		_itemcardAlignIdx = 2
		SetTextOptionValue(a_option, _alignments[_itemcardAlignIdx])
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignments[_itemcardAlignIdx])

	elseIf (a_option == _itemcardXOffsetOID_S)
		_itemcardXOffset = 0.0
		SetSliderOptionValue(a_option, _itemcardXOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset)

	elseIf (a_option == _itemcardYOffsetOID_S)
		_itemcardYOffset = 0.0
		SetSliderOptionValue(a_option, _itemcardYOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset)

	; -------------------------------------------------------
	elseIf (a_option == _3DItemXOffsetOID_S)
		_3DItemXOffset = 0.0
		SetSliderOptionValue(a_option, _3DItemXOffset)
		Apply3DItemXOffset()

	elseIf (a_option == _3DItemYOffsetOID_S)
		_3DItemYOffset = 0.0
		SetSliderOptionValue(a_option, _3DItemYOffset)
		Apply3DItemYOffset()

	elseIf (a_option == _3DItemScaleOID_S)
		_3DItemScale = 1.5
		SetSliderOptionValue(a_option, _3DItemScale, "{1}")
		Apply3DItemScale()

	; -------------------------------------------------------
	elseIf (a_option == _AEEnabledOID_B)
		_AEEnabled = false
		SetToggleOptionValue(a_option, _AEEnabled)
		SKI_ActiveEffectsWidgetInstance.Enabled = _AEEnabled

	elseIf (a_option == _AEEffectSizeOID_T)
		_AEEffectSizeIdx = 1
		SetTextOptionValue(a_option, _sizes[_AEEffectSizeIdx])
		SKI_ActiveEffectsWidgetInstance.EffectSize = _AEEffectSizeValues[_AEEffectSizeIdx]

	elseIf (a_option == _AEClampCornerOID_M)
		_AEClampCornerIdx = 1
		SetMenuOptionValue(a_option, _corners[_AEClampCornerIdx])
		SKI_ActiveEffectsWidgetInstance.ClampCorner = _cornerValues[_AEClampCornerIdx]
		SKI_ActiveEffectsWidgetInstance.X = _AEBaseXValues[_AEClampCornerIdx] + _AEOffsetX
		SKI_ActiveEffectsWidgetInstance.Y = _AEBaseYValues[_AEClampCornerIdx] + _AEOffsetY

	elseIf (a_option == _AEGroupEffectCountOID_S)
		_AEGroupEffectCount = 8
		SetSliderOptionValue(a_option, _AEGroupEffectCount)
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = _AEGroupEffectCount

	elseIf (a_option == _AEOffsetXOID_S)
		_AEOffsetX = 0.0
		SetSliderOptionValue(a_option, _AEOffsetX)
		SKI_ActiveEffectsWidgetInstance.X = _AEBaseXValues[_AEClampCornerIdx] + _AEOffsetX

	elseIf (a_option == _AEOffsetYOID_S)
		_AEOffsetY = 0.0
		SetSliderOptionValue(a_option, _AEOffsetY)
		SKI_ActiveEffectsWidgetInstance.Y = _AEBaseYValues[_AEClampCornerIdx] + _AEOffsetY

	elseIf (a_option == _AEOrientationOID_T)
		_AEOrientationIdx = 1
		SetTextOptionValue(a_option, _orientations[_AEOrientationIdx])
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientations[_AEOrientationIdx]

	; -------------------------------------------------------
	elseIf (a_option == _checkHUDMenuOID_B)
		SKI_MainInstance.HUDMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	elseIf (a_option == _checkInventoryMenuOID_B)
		SKI_MainInstance.InventoryMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	elseIf (a_option == _checkMagicMenuOID_B)
		SKI_MainInstance.MagicMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	elseIf (a_option == _checkBarterMenuOID_B)
		SKI_MainInstance.BarterMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	elseIf (a_option == _checkContainerMenuOID_B)
		SKI_MainInstance.ContainerMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	elseIf (a_option == _checkGiftMenuOID_B)
		SKI_MainInstance.GiftMenuCheckEnabled = true
		SetToggleOptionValue(a_option, true)

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)

	if (a_option == _itemlistFontSizeOID_T)

		if (_itemlistFontSizeIdx < _sizes.length - 1)
			_itemlistFontSizeIdx += 1
		else
			_itemlistFontSizeIdx = 0
		endif
		SetTextOptionValue(a_option, _sizes[_itemlistFontSizeIdx])
		ApplyItemListFontSize()

	elseIf (a_option == _AEEnabledOID_B)
		_AEEnabled = !_AEEnabled
		SetToggleOptionValue(a_option, _AEEnabled)
		SKI_ActiveEffectsWidgetInstance.Enabled = _AEEnabled

	elseIf (a_option == _itemcardAlignOID_T)
		if (_itemcardAlignIdx < _alignments.length - 1)
			_itemcardAlignIdx += 1
		else
			_itemcardAlignIdx = 0
		endif
		SetTextOptionValue(a_option, _alignments[_itemcardAlignIdx])
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignments[_itemcardAlignIdx])
	
	elseif (a_option == _AEEffectSizeOID_T)
		if (_AEEffectSizeIdx < _sizes.length - 1)
			_AEEffectSizeIdx += 1
		else
			_AEEffectSizeIdx = 0
		endIf
		SetTextOptionValue(a_option, _sizes[_AEEffectSizeIdx])
		SKI_ActiveEffectsWidgetInstance.EffectSize = _AEEffectSizeValues[_AEEffectSizeIdx]

	elseIf (a_option == _AEOrientationOID_T)
		if (_AEOrientationIdx < _orientations.length - 1)
			_AEOrientationIdx += 1
		else
			_AEOrientationIdx = 0
		endIf
		SetTextOptionValue(a_option, _orientations[_AEOrientationIdx])
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientations[_AEOrientationIdx]
	
	elseIf (a_option == _checkHUDMenuOID_B)
		bool newVal = !SKI_MainInstance.HUDMenuCheckEnabled
		SKI_MainInstance.HUDMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	elseIf (a_option == _checkInventoryMenuOID_B)
		bool newVal = !SKI_MainInstance.InventoryMenuCheckEnabled
		SKI_MainInstance.InventoryMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	elseIf (a_option == _checkMagicMenuOID_B)
		bool newVal = !SKI_MainInstance.MagicMenuCheckEnabled
		SKI_MainInstance.MagicMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	elseIf (a_option == _checkBarterMenuOID_B)
		bool newVal = !SKI_MainInstance.BarterMenuCheckEnabled
		SKI_MainInstance.BarterMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	elseIf (a_option == _checkContainerMenuOID_B)
		bool newVal = !SKI_MainInstance.ContainerMenuCheckEnabled
		SKI_MainInstance.ContainerMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	elseIf (a_option == _checkGiftMenuOID_B)
		bool newVal = !SKI_MainInstance.GiftMenuCheckEnabled
		SKI_MainInstance.GiftMenuCheckEnabled = newVal
		SetToggleOptionValue(a_option, newVal)

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)

	if (a_option == _itemcardXOffsetOID_S)
		SetSliderDialogStartValue(_itemcardXOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(1)

	elseIf (a_option == _itemcardYOffsetOID_S)
		SetSliderDialogStartValue(_itemcardYOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(1)

	elseIf (a_option == _3DItemXOffsetOID_S)
		SetSliderDialogStartValue(_3DItemXOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-128, 128)
		SetSliderDialogInterval(1)

	elseIf (a_option == _3DItemYOffsetOID_S)
		SetSliderDialogStartValue(_3DItemYOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-128, 128)
		SetSliderDialogInterval(1)
		
	elseIf (a_option == _3DItemScaleOID_S)
		SetSliderDialogStartValue(_3DItemScale)
		SetSliderDialogDefaultValue(1.5)
		SetSliderDialogRange(0.5, 5)
		SetSliderDialogInterval(0.1)

	elseIf (a_option == _AEGroupEffectCountOID_S)
		SetSliderDialogStartValue(_AEGroupEffectCount)
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(1, 16)
		SetSliderDialogInterval(1)

	elseIf (a_option == _AEOffsetXOID_S)
		SetSliderDialogStartValue(_AEOffsetX)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1280, 1280)
		SetSliderDialogInterval(1)

	elseIf (a_option == _AEOffsetYOID_S)
		SetSliderDialogStartValue(_AEOffsetY)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-720, 720)
		SetSliderDialogInterval(1)
	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)

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
		Apply3DItemXOffset()

	elseIf (a_option == _3DItemYOffsetOID_S)
		_3DItemYOffset = a_value
		SetSliderOptionValue(a_option, _3DItemYOffset)
		Apply3DItemYOffset()

	elseIf (a_option == _3DItemScaleOID_S)
		_3DItemScale = a_value
		SetSliderOptionValue(a_option, _3DItemScale, "{1}")
		Apply3DItemScale()

	elseIf (a_option == _AEGroupEffectCountOID_S)
		_AEGroupEffectCount = a_value as int
		SetSliderOptionValue(a_option, _AEGroupEffectCount)
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = _AEGroupEffectCount

	elseIf (a_option == _AEOffsetXOID_S)
		_AEOffsetX = a_value
		SetSliderOptionValue(a_option, _AEOffsetX)
		SKI_ActiveEffectsWidgetInstance.X = _AEBaseXValues[_AEClampCornerIdx] + _AEOffsetX

	elseIf (a_option == _AEOffsetYOID_S)
		_AEOffsetY = a_value
		SetSliderOptionValue(a_option, _AEOffsetY)
		SKI_ActiveEffectsWidgetInstance.Y = _AEBaseYValues[_AEClampCornerIdx] + _AEOffsetY

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)

	if (a_option == _AEClampCornerOID_M)
		SetMenuDialogStartIndex(_AEClampCornerIdx)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(_corners)

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	
	if (a_option == _AEClampCornerOID_M)
		_AEClampCornerIdx = a_index
		SetMenuOptionValue(a_option, _corners[_AEClampCornerIdx])
		SKI_ActiveEffectsWidgetInstance.ClampCorner = _cornerValues[_AEClampCornerIdx]
		SKI_ActiveEffectsWidgetInstance.X = _AEBaseXValues[_AEClampCornerIdx] + _AEOffsetX
		SKI_ActiveEffectsWidgetInstance.Y = _AEBaseYValues[_AEClampCornerIdx] + _AEOffsetY

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)

	if (a_option == _itemlistFontSizeOID_T)
		SetInfoText("Default: Medium")

	elseIf (a_option == _itemcardAlignOID_T)
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

	elseIf (a_option == _AEEnabledOID_B)
		SetInfoText("Default: No")
	elseIf (a_option == _AEEffectSizeOID_T)
		SetInfoText("Default: Medium")
	elseif (a_option == _AEClampCornerOID_M)
		SetInfoText("Default: Top Right")
	elseIf (a_option == _AEGroupEffectCountOID_S)
		SetInfoText("Default: 8")
	elseif (a_option == _AEOffsetXOID_S)
		SetInfoText("Default: 0")
	elseif (a_option == _AEOffsetYOID_S)
		SetInfoText("Default: 0")
	elseif (a_option == _AEOrientationOID_T)
		SetInfoText("Default: Vertical")

	elseIf (a_option == _checkHUDMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	elseIf (a_option == _checkInventoryMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	elseIf (a_option == _checkMagicMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	elseIf (a_option == _checkBarterMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	elseIf (a_option == _checkContainerMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	elseIf (a_option == _checkGiftMenuOID_B)
		SetInfoText("Incompatible or outdated SWFs may break SkyUI functionality. This only disables the warning message!\nDefault: On")
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function ApplySettings()
	float h = Utility.GetINIInt("iSize H:Display")
	float w = Utility.GetINIInt("iSize W:Display")
	if ((w / h) == 1.6)
		_itemXBase = -32.458335876465
	else
		_itemXBase = -29.122497558594
	endIf

	Apply3DItemXOffset()
	Apply3DItemYOffset()
	Apply3DItemScale()
endFunction

function ApplyItemListFontSize()
	; Small
	if (_itemlistFontSizeIdx == 0)
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "13")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "16")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.3, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-25")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 2, 2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 2, 2>")
	; Medium
	elseIf (_itemlistFontSizeIdx == 1)
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 1.1, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-28")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3, 3>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 3, 3>")
	; Large
	else
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "20")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.4, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-30")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3.2, 3.2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 4, 3.2, 3.2>")
	endIf
endFunction

function Apply3DItemXOffset()
	Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
	Utility.SetINIFloat("fInventory3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBase + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosX:Interface", (-38.453338623047 + _3DItemXOffset))
endFunction

function Apply3DItemYOffset()
	Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", (12 + _3DItemYOffset))
	Utility.SetINIFloat("fInventory3DItemPosZ:Interface", (16 + _3DItemYOffset))
	Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", (12 + _3DItemYOffset))
	Utility.SetINIFloat("fMagic3DItemPosZ:Interface", (16 + _3DItemYOffset))
endFunction

function Apply3DItemScale()
	Utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _3DItemScale)
	Utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _3DItemScale)
	Utility.SetINIFloat("fInventory3DItemPosScale:Interface", _3DItemScale)
	Utility.SetINIFloat("fMagic3DItemPosScale:Interface", _3DItemScale)
endFunction