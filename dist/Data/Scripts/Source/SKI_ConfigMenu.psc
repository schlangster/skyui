scriptname SKI_ConfigMenu extends SKI_ConfigBase

; SCRIPT VERSION ----------------------------------------------------------------------------------
;
; History
;
; 1:	- Initial version
;
; 2:	- Added category icon theme option
;		- Added noIconColor option
;		- Added controls section for gamepad

int function GetVersion()
	return 2
endFunction


; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

; Lists
string[]	_alignments
string[]	_sizes

string[]	_alignmentValues

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_itemlistFontSizeOID_T
int			_itemlistQuantityMinCountOID_S

int			_itemcardAlignOID_T
int			_itemcardXOffsetOID_S
int			_itemcardYOffsetOID_S

int			_3DItemXOffsetOID_S
int			_3DItemYOffsetOID_S
int			_3DItemScaleOID_S

int			_checkInventoryMenuOID_B
int			_checkMagicMenuOID_B
int			_checkBarterMenuOID_B
int			_checkContainerMenuOID_B
int			_checkGiftMenuOID_B

int			_searchKeyOID_K
int			_switchTabKeyOID_K
int			_equipModeKeyOID_K

; State
int			_itemlistFontSizeIdx		= 1
int			_itemlistQuantityMinCount	= 6

int			_itemcardAlignIdx			= 2
float		_itemcardXOffset			= 0.0
float		_itemcardYOffset			= 0.0

float		_3DItemXOffset				= 0.0
float		_3DItemYOffset				= 0.0
float		_3DItemScale				= 1.5

int			_searchKey					= 57
int			_switchTabKey				= 56
int			_equipModeKey				= 42

; Internal
float		_itemXBase
float		_itemXBaseW

; -- Version 2 --

; Lists
string[]	_categoryIconThemeShortNames
string[]	_categoryIconThemeLongNames
string[]	_categoryIconThemeValues

; OIDs
int			_itemlistCategoryIconThemeOID_M
int			_itemlistNoIconColorsOID_B

int			_switchTabButtonOID_K
int			_prevColumnButtonOID_K
int			_nextColumnButtonOID_K
int			_sortOrderButtonOID_K

; State
int			_categoryIconThemeIdx		= 0
bool		_itemlistNoIconColors		= false

int			_switchTabButton			= 271 ; BACK
int			_prevColumnButton			= 274 ; LEFT_SHOULDER
int			_nextColumnButton			= 275 ; RIGHT_SHOULDER
int			_sortOrderButton			= 272 ; LEFT_THUMB


; PROPERTIES --------------------------------------------------------------------------------------

SKI_SettingsManager property		SKI_SettingsManagerInstance auto
SKI_Main property					SKI_MainInstance auto


; INITIALIZATION ----------------------------------------------------------------------------------

; @overrides SKI_ConfigBase
event OnConfigInit()
	; Translate strings to display in UI
	_alignments = new string[3]
	_alignments[0] = "$Left"
	_alignments[1] = "$Right"
	_alignments[2] = "$Center"

	_sizes = new string[3]
	_sizes[0] = "$Small"
	_sizes[1] = "$Medium"
	_sizes[2] = "$Large"

	; Strings used as variable values
	_alignmentValues = new string[3]
	_alignmentValues[0] = "left"
	_alignmentValues[1] = "right"
	_alignmentValues[2] = "center"

	ApplySettings()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	parent.OnGameReload()
	
	ApplySettings()
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)

	; Version 2
	if (a_version >= 2 && CurrentVersion < 2)
		Debug.Trace(self + ": Updating to script version 2")

		_categoryIconThemeShortNames = new string[4]
		_categoryIconThemeShortNames[0] = "SKYUI V3"
		_categoryIconThemeShortNames[1] = "CELTIC"
		_categoryIconThemeShortNames[2] = "CURVED"
		_categoryIconThemeShortNames[3] = "STRAIGHT"

		_categoryIconThemeLongNames = new string[4]
		_categoryIconThemeLongNames[0] = "SkyUI V3, by PsychoSteve"
		_categoryIconThemeLongNames[1] = "Celtic, by GreatClone"
		_categoryIconThemeLongNames[2] = "Curved, by T3T"
		_categoryIconThemeLongNames[3] = "Straight, by T3T"

		_categoryIconThemeValues = new string[4]
		_categoryIconThemeValues[0] = "skyui\\icons_category_psychosteve.swf"
		_categoryIconThemeValues[1] = "skyui\\icons_category_celtic.swf"
		_categoryIconThemeValues[2] = "skyui\\icons_category_curved.swf"
		_categoryIconThemeValues[3] = "skyui\\icons_category_straight.swf"

		; Have been renamed, so clear old overrides and set new ones
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$search")
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$switchTab")
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$equipMode")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)
	endIf
endEvent


; EVENTS ------------------------------------------------------------------------------------------

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
	if (a_page == "$General")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$Item List")
		_itemlistFontSizeOID_T				= AddTextOption("$Font Size", _sizes[_itemlistFontSizeIdx])
		_itemlistQuantityMinCountOID_S		= AddSliderOption("$Quantity Menu Min. Count", _itemlistQuantityMinCount)
		_itemlistCategoryIconThemeOID_M		= AddMenuOption("$Category Icon Theme", _categoryIconThemeShortNames[_categoryIconThemeIdx])
		_itemlistNoIconColorsOID_B			= AddToggleOption("$Disable Icon Colors", _itemlistNoIconColors)

		SetCursorPosition(1)

		AddHeaderOption("$Controls")
		if (! Game.UsingGamepad())
			_searchKeyOID_K					= AddKeyMapOption("$Search", _searchKey)
			_switchTabKeyOID_K				= AddKeyMapOption("$Switch Tab", _switchTabKey)
			_equipModeKeyOID_K				= AddKeyMapOption("$Equip Mode", _equipModeKey)
			_switchTabButtonOID_K			= -1
			_prevColumnButtonOID_K			= -1
			_nextColumnButtonOID_K			= -1
			_sortOrderButtonOID_K			= -1
		else
			_searchKeyOID_K					= AddKeyMapOption("$Search", _searchKey, OPTION_FLAG_DISABLED)
			_switchTabButtonOID_K			= AddKeyMapOption("$Switch Tab", _switchTabButton)
			_prevColumnButtonOID_K			= AddKeyMapOption("$Previous Column", _prevColumnButton)
			_nextColumnButtonOID_K			= AddKeyMapOption("$Next Column", _nextColumnButton)
			_sortOrderButtonOID_K			= AddKeyMapOption("$Order", _sortOrderButton)
			_switchTabKeyOID_K				= -1
			_equipModeKeyOID_K				= -1
		endIf

	; -------------------------------------------------------
	elseIf (a_page == "$Advanced")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$Item Card")
		_itemcardAlignOID_T					= AddTextOption("$Align", _alignments[_itemcardAlignIdx])
		_itemcardXOffsetOID_S				= AddSliderOption("$Horizontal Offset", _itemcardXOffset)
		_itemcardYOffsetOID_S				= AddSliderOption("$Vertical Offset", _itemcardYOffset)

		AddEmptyOption()

		AddHeaderOption("$3D Item")
		_3DItemXOffsetOID_S					= AddSliderOption("$Horizontal Offset", _3DItemXOffset)
		_3DItemYOffsetOID_S					= AddSliderOption("$Vertical Offset", _3DItemYOffset)
		_3DItemScaleOID_S					= AddSliderOption("$Scale", _3DItemScale, "{1}")

		SetCursorPosition(1)

		AddHeaderOption("$SWF Version Checking")
		_checkInventoryMenuOID_B			= AddToggleOption("Inventory Menu", SKI_MainInstance.InventoryMenuCheckEnabled)
		_checkMagicMenuOID_B				= AddToggleOption("Magic Menu", SKI_MainInstance.MagicMenuCheckEnabled)
		_checkBarterMenuOID_B				= AddToggleOption("Barter Menu", SKI_MainInstance.BarterMenuCheckEnabled)
		_checkContainerMenuOID_B			= AddToggleOption("Container Menu", SKI_MainInstance.ContainerMenuCheckEnabled)
		_checkGiftMenuOID_B					= AddToggleOption("Gift Menu", SKI_MainInstance.GiftMenuCheckEnabled)
		
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

	elseif (a_option == _itemlistQuantityMinCountOID_S)
		_itemlistQuantityMinCount = 6
		SetSliderOptionValue(a_option, _itemlistQuantityMinCount)
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount)

	elseIf (a_option == _itemlistCategoryIconThemeOID_M)
		_categoryIconThemeIdx = 0
		SetTextOptionValue(a_option, _categoryIconThemeShortNames[_categoryIconThemeIdx])
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])

	elseif (a_option == _itemlistNoIconColorsOID_B)
		_itemlistNoIconColors = false
		SetToggleOptionValue(a_option, _itemlistNoIconColors)
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors)

	; -------------------------------------------------------
	elseIf (a_option == _searchKeyOID_K)
		_searchKey = 57
		SetKeyMapOptionValue(a_option, _searchKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
	elseIf (a_option == _switchTabKeyOID_K)
		_switchTabKey = 56
		SetKeyMapOptionValue(a_option, _switchTabKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
	elseIf (a_option == _equipModeKeyOID_K)
		_equipModeKey = 42
		SetKeyMapOptionValue(a_option, _equipModeKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)
	elseIf (a_option == _switchTabButtonOID_K)
		_switchTabButton = 271
		SetKeyMapOptionValue(a_option, _switchTabButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)
	elseIf (a_option == _prevColumnButtonOID_K)
		_prevColumnButton = 274
		SetKeyMapOptionValue(a_option, _prevColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)
	elseIf (a_option == _nextColumnButtonOID_K)
		_nextColumnButton = 275
		SetKeyMapOptionValue(a_option, _nextColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)
	elseIf (a_option == _sortOrderButtonOID_K)
		_sortOrderButton = 272
		SetKeyMapOptionValue(a_option, _sortOrderButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)

	; -------------------------------------------------------
	elseIf (a_option == _itemcardAlignOID_T)
		_itemcardAlignIdx = 2
		SetTextOptionValue(a_option, _alignments[_itemcardAlignIdx])
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])

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

	; -------------------------------------------------------
	if (a_option == _itemlistFontSizeOID_T)
		if (_itemlistFontSizeIdx < _sizes.length - 1)
			_itemlistFontSizeIdx += 1
		else
			_itemlistFontSizeIdx = 0
		endif
		SetTextOptionValue(a_option, _sizes[_itemlistFontSizeIdx])
		ApplyItemListFontSize()

	elseIf (a_option == _itemlistNoIconColorsOID_B)
		_itemListNoIconColors = !_itemlistNoIconColors
		SetToggleOptionValue(a_option, _itemlistNoIconColors)
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors)

	; -------------------------------------------------------
	elseIf (a_option == _itemcardAlignOID_T)
		if (_itemcardAlignIdx < _alignments.length - 1)
			_itemcardAlignIdx += 1
		else
			_itemcardAlignIdx = 0
		endif
		SetTextOptionValue(a_option, _alignments[_itemcardAlignIdx])
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])

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

	; -------------------------------------------------------
	if (a_option == _itemlistQuantityMinCountOID_S)
		SetSliderDialogStartValue(_itemlistQuantityMinCount)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)

	; -------------------------------------------------------
	elseIf (a_option == _itemcardXOffsetOID_S)
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

	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)

	; -------------------------------------------------------
	if (a_option == _itemlistQuantityMinCountOID_S)
		_itemlistQuantityMinCount = a_value as int
		SetSliderOptionValue(a_option, _itemlistQuantityMinCount)
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount)

	; -------------------------------------------------------
	elseIf (a_option == _itemcardXOffsetOID_S)
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

	endIf
endEvent

; -------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	if (a_option == _itemlistCategoryIconThemeOID_M)
		SetMenuDialogStartIndex(_categoryIconThemeIdx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_categoryIconThemeLongNames)
	endIf
endEvent

; -------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	if (a_option == _itemlistCategoryIconThemeOID_M)
		_categoryIconThemeIdx = a_index
		SetMenuOptionValue(a_option, _categoryIconThemeShortNames[_categoryIconThemeIdx])
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)

	; Do nothing for ESC
	if (a_keyCode == 1)
		return
	endIf

	; -------------------------------------------------------
	if (! Game.UsingGamepad())

		; Can't detect for mouse, don't need for gamepad
		if (a_keyCode > 255)
			ShowMessage("$SKI_MSG1", false, "$OK")
			return
		endIf

		if (a_option == _searchKeyOID_K)
			SwapKeys(a_keyCode, _searchKey)

			_searchKey = a_keyCode
			SetKeyMapOptionValue(a_option, _searchKey)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)

		elseIf (a_option == _switchTabKeyOID_K)
			SwapKeys(a_keyCode, _switchTabKey)

			_switchTabKey = a_keyCode
			SetKeyMapOptionValue(a_option, _switchTabKey)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)

		elseIf (a_option == _equipModeKeyOID_K)
			SwapKeys(a_keyCode, _equipModeKey)

			_equipModeKey = a_keyCode
			SetKeyMapOptionValue(a_option, _equipModeKey)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)

		endIf

	; -------------------------------------------------------
	else
		; If you removed the gamepad while in this menu, ignore other keys
		if (a_keyCode < 266)
			return
		endIf

		if (a_option == _switchTabButtonOID_K)
			SwapKeys(a_keyCode, _switchTabButton)

			_switchTabButton = a_keyCode
			SetKeyMapOptionValue(a_option, _switchTabButton)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)

		elseIf (a_option == _prevColumnButtonOID_K)
			SwapKeys(a_keyCode, _prevColumnButton)

			_prevColumnButton = a_keyCode
			SetKeyMapOptionValue(a_option, _prevColumnButton)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)

		elseIf (a_option == _nextColumnButtonOID_K)
			SwapKeys(a_keyCode, _nextColumnButton)

			_nextColumnButton = a_keyCode
			SetKeyMapOptionValue(a_option, _nextColumnButton)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)

		elseIf (a_option == _sortOrderButtonOID_K)
			SwapKeys(a_keyCode, _sortOrderButton)

			_sortOrderButton = a_keyCode
			SetKeyMapOptionValue(a_option, _sortOrderButton)
			SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)

		endIf
	endIf
endEvent

; -------------------------------------------------------------------------------------------------
; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)

	if (a_option == _itemlistFontSizeOID_T)
		SetInfoText("$SKI_INFO1")
	elseIf(a_option == _itemlistQuantityMinCountOID_S)
		SetInfoText("$SKI_INFO2")
	elseIf(a_option == _itemlistCategoryIconThemeOID_M)
		SetInfoText("$SKI_INFO11")
	elseIf(a_option == _itemlistNoIconColorsOID_B)
		SetInfoText("$SKI_INFO10")
	
	elseIf (a_option == _searchKeyOID_K)
		SetInfoText("$SKI_INFO7") ; Default: Space
	elseIf (a_option == _switchTabKeyOID_K)
		SetInfoText("$SKI_INFO8") ; Default: Left Alt
	elseIf (a_option == _equipModeKeyOID_K)
		SetInfoText("$SKI_INFO9") ; Default: Shift
	elseIf (a_option == _switchTabButtonOID_K)
		SetInfoText("$SKI_INFO12") ; Default: Back
	elseIf (a_option == _prevColumnButtonOID_K)
		SetInfoText("$SKI_INFO13") ; Default: LB (L1, LEFT_SHOULDER)
	elseIf (a_option == _nextColumnButtonOID_K)
		SetInfoText("$SKI_INFO14") ; Default: RB (R1, RIGHT_SHOULDER)
	elseIf (a_option == _sortOrderButtonOID_K)
		SetInfoText("$SKI_INFO15") ; Default: LS (L3, LEFT_THUMB)

	elseIf (a_option == _itemcardAlignOID_T)
		SetInfoText("$SKI_INFO3")
	elseIf (a_option == _itemcardXOffsetOID_S)
		SetInfoText("$SKI_INFO4")
	elseIf (a_option == _itemcardYOffsetOID_S)
		SetInfoText("$SKI_INFO4")

	elseIf (a_option == _3DItemXOffsetOID_S)
		SetInfoText("$SKI_INFO4")
	elseIf (a_option == _3DItemYOffsetOID_S)

		SetInfoText("$SKI_INFO4")
	elseIf (a_option == _3DItemScaleOID_S)
		SetInfoText("$SKI_INFO5")

	elseIf (a_option == _checkInventoryMenuOID_B)
		SetInfoText("$SKI_INFO6")
	elseIf (a_option == _checkMagicMenuOID_B)
		SetInfoText("$SKI_INFO6")
	elseIf (a_option == _checkBarterMenuOID_B)
		SetInfoText("$SKI_INFO6")
	elseIf (a_option == _checkContainerMenuOID_B)
		SetInfoText("$SKI_INFO6")
	elseIf (a_option == _checkGiftMenuOID_B)
		SetInfoText("$SKI_INFO6")
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function ApplySettings()
	; Apply settings that aren't handled by SKI_SettingsManagerInstance
	float h = Utility.GetINIInt("iSize H:Display")
	float w = Utility.GetINIInt("iSize W:Display")
	float ar = w / h

	; Widescreen
	if (ar == 1.6) ; 16:10, 1920×1200
		_itemXBaseW = -32.458335876465
	else
		_itemXBaseW = -29.122497558594
	endIf

	; Non-widescreen
	if (ar == 1.25) ; 5:4, 1280x1024
		_itemXBase = -41.622497558594
	else
		_itemXBase = -39.122497558594
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
	; Negative values shift the 3D item to the right
	Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBaseW + _3DItemXOffset))
	Utility.SetINIFloat("fInventory3DItemPosX:Interface", (_itemXBase + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBaseW + _3DItemXOffset))
	Utility.SetINIFloat("fMagic3DItemPosX:Interface", (_itemXBase + _3DItemXOffset))
endFunction

function Apply3DItemYOffset()
	; Negative values shift the 3D item to the bottom
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

function SwapKeys(int a_newKey, int a_curKey)
	if (a_newKey == _searchKey)
		_searchKey = a_curKey
		SetKeyMapOptionValue(_searchKeyOID_K, _searchKey, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
	elseIf (a_newKey == _switchTabKey)
		_switchTabKey = a_curKey
		SetKeyMapOptionValue(_switchTabKeyOID_K, _switchTabKey, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
	elseIf (a_newKey == _equipModeKey)
		_equipModeKey = a_curKey
		SetKeyMapOptionValue(_equipModeKeyOID_K, _equipModeKey, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)

	elseIf (a_newKey == _switchTabButton)
		_switchTabButton = a_curKey
		SetKeyMapOptionValue(_switchTabButtonOID_K, _switchTabButton, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)
	elseIf (a_newKey == _prevColumnButton)
		_prevColumnButton = a_curKey
		SetKeyMapOptionValue(_prevColumnButtonOID_K, _prevColumnButton, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)
	elseIf (a_newKey == _nextColumnButton)
		_nextColumnButton = a_curKey
		SetKeyMapOptionValue(_nextColumnButtonOID_K, _nextColumnButton, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)
	elseIf (a_newKey == _sortOrderButton)
		_sortOrderButton = a_curKey
		SetKeyMapOptionValue(_sortOrderButtonOID_K, _sortOrderButton, true)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)
	endIf
endFunction