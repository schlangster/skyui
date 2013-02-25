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
;
; 3:	- Added disable 3D item positioning option
;
; 4:	- Converted script to use state options
;		- Added map menu version check
;		- Added active effects widget configuration

int function GetVersion()
	return 4
endFunction


; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

; Lists
string[]	_alignments
string[]	_alignmentValues
string[]	_sizes

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

; State
int			_categoryIconThemeIdx		= 0
bool		_itemlistNoIconColors		= false

int			_switchTabButton			= 271 ; BACK
int			_prevColumnButton			= 274 ; LEFT_SHOULDER
int			_nextColumnButton			= 275 ; RIGHT_SHOULDER
int			_sortOrderButton			= 272 ; LEFT_THUMB

; -- Version 3 --

; State
bool		_3DItemDisablePositioning		= false

; Internal
float		_fInventory3DItemPosXWide
float		_fInventory3DItemPosX
float		_fMagic3DItemPosXWide
float		_fMagic3DItemPosX

; Flags
int			_3DItemFlags

; -- Version 4 --

; Lists
string[]	_orientations
string[]	_orientationValues

string[]	_vertAlignments
string[]	_vertAlignmentValues

float[]		_effectWidgetIconSizeValues

float[]		_alignmentBaseOffsets
float[]		_vertAlignmentBaseOffsets

; State
int			_effectWidgetIconSizeIdx		= 1		; medium
int			_effectWidgetVAnchorIdx			= 0		; top
int			_effectWidgetHAnchorIdx			= 1		; right
int			_effectWidgetGroupCount			= 8
int			_effectWidgetOrientationIdx		= 1		; vertical
float		_effectWidgetXOffset			= 0.0
float		_effectWidgetYOffset			= 0.0

; Flags
int			_effectWidgetFlags


; PROPERTIES --------------------------------------------------------------------------------------

; -- Version 1 --

SKI_SettingsManager property		SKI_SettingsManagerInstance auto
SKI_Main property					SKI_MainInstance auto

; -- Version 4 --

SKI_ActiveEffectsWidget property		SKI_ActiveEffectsWidgetInstance auto


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

	if (a_version >= 3 && CurrentVersion < 3)
		Debug.Trace(self + ": Updating to script version 3")

		_3DItemFlags = OPTION_FLAG_NONE

		;The below all reset to true with version 3.2
		;SKI_MainInstance.InventoryMenuCheckEnabled
		;SKI_MainInstance.MagicMenuCheckEnabled
		;SKI_MainInstance.BarterMenuCheckEnabled
		;SKI_MainInstance.ContainerMenuCheckEnabled
		;SKI_MainInstance.GiftMenuCheckEnabled
	endIf

	if (a_version >= 4 && CurrentVersion < 4)
		Debug.Trace(self + ": Updating to script version 4")

		_orientations = new string[2]
		_orientations[0] = "$Horizontal"
		_orientations[1] = "$Vertical"

		_orientationValues = new string[2]
		_orientationValues[0] = "horizontal"
		_orientationValues[1] = "vertical"

		_vertAlignments = new string[3]
		_vertAlignments[0] = "$Top"
		_vertAlignments[1] = "$Bottom"
		_vertAlignments[2] = "$Center"

		_vertAlignmentValues = new string[3]
		_vertAlignmentValues[0] = "top"
		_vertAlignmentValues[1] = "bottom"
		_vertAlignmentValues[2] = "center"

		_effectWidgetIconSizeValues = new float[3]
		_effectWidgetIconSizeValues[0] = 32.0
		_effectWidgetIconSizeValues[1] = 48.0
		_effectWidgetIconSizeValues[2] = 64.0

		_alignmentBaseOffsets = new float[3]
		_alignmentBaseOffsets[0] = 0.0
		_alignmentBaseOffsets[1] = 1280.0
		_alignmentBaseOffsets[2] = 640.0

		_vertAlignmentBaseOffsets = new float[3]
		_vertAlignmentBaseOffsets[0] = 0.0
		_vertAlignmentBaseOffsets[1] = 720.0
		_vertAlignmentBaseOffsets[2] = 360.0

		_effectWidgetFlags = OPTION_FLAG_NONE

		; Sync widget default values
		SKI_ActiveEffectsWidgetInstance.Enabled				= true
		SKI_ActiveEffectsWidgetInstance.EffectSize			= _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		SKI_ActiveEffectsWidgetInstance.HAnchor				= _alignmentValues[_effectWidgetHAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.VAnchor				= _vertAlignmentValues[_effectWidgetVAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount	= _effectWidgetGroupCount
		SKI_ActiveEffectsWidgetInstance.Orientation			= _orientationValues[_effectWidgetOrientationIdx]
		SKI_ActiveEffectsWidgetInstance.X					= _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SKI_ActiveEffectsWidgetInstance.Y					= _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
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
		AddTextOptionST("ITEMLIST_FONT_SIZE", "$Font Size", _sizes[_itemlistFontSizeIdx])
		AddSliderOptionST("ITEMLIST_QUANTITY_MIN_COUNT", "$Quantity Menu Min. Count", _itemlistQuantityMinCount)
		AddMenuOptionST("ITEMLIST_CATEGORY_ICON_THEME", "$Category Icon Theme", _categoryIconThemeShortNames[_categoryIconThemeIdx])
		AddToggleOptionST("ITEMLIST_NO_ICON_COLORS", "$Disable Icon Colors", _itemlistNoIconColors)

		AddEmptyOption()

		AddHeaderOption("$Active Effects HUD")
		AddToggleOptionST("EFFECT_WIDGET_ENABLED", "$Enabled", SKI_ActiveEffectsWidgetInstance.Enabled)
		AddTextOptionST("EFFECT_WIDGET_ICON_SIZE","$Icon Size", _sizes[_effectWidgetIconSizeIdx])
		AddTextOptionST("EFFECT_WIDGET_ORIENTATION", "$Orientation", _orientations[_effectWidgetOrientationIdx])
		AddTextOptionST("EFFECT_WIDGET_HORIZONTAL_ANCHOR", "$Horizontal Anchor", _alignments[_effectWidgetHAnchorIdx])
		AddTextOptionST("EFFECT_WIDGET_VERTICAL_ANCHOR", "$Vertical Anchor", _vertAlignments[_effectWidgetVAnchorIdx])
		AddSliderOptionST("EFFECT_WIDGET_GROUP_COUNT", "$Icon Group Count", SKI_ActiveEffectsWidgetInstance.GroupEffectCount, "{0}")
		AddSliderOptionST("EFFECT_WIDGET_XOFFSET", "$Horizontal Offset", _effectWidgetXOffset)
		AddSliderOptionST("EFFECT_WIDGET_YOFFSET", "$Vertical Offset", _effectWidgetYOffset)

		SetCursorPosition(1)

		AddHeaderOption("$Controls")
		if (! Game.UsingGamepad())
			AddKeyMapOptionST("SEARCH_KEY", "$Search", _searchKey)
			AddKeyMapOptionST("SWITCH_TAB_KEY", "$Switch Tab", _switchTabKey)
			AddKeyMapOptionST("EQUIP_MODE_KEY", "$Equip Mode", _equipModeKey)
		else
			AddKeyMapOptionST("SEARCH_KEY", "$Search", _searchKey, OPTION_FLAG_DISABLED)
			AddKeyMapOptionST("SWITCH_TAB_BUTTON", "$Switch Tab", _switchTabButton)
			AddKeyMapOptionST("PREV_COLUMN_BUTTON", "$Previous Column", _prevColumnButton)
			AddKeyMapOptionST("NEXT_COLUMN_BUTTON", "$Next Column", _nextColumnButton)
			AddKeyMapOptionST("SORT_ORDER_BUTTON", "$Order", _sortOrderButton)
		endIf

	; -------------------------------------------------------
	elseIf (a_page == "$Advanced")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$Item Card")
		AddTextOptionST("ITEMCARD_ALIGN", "$Align", _alignments[_itemcardAlignIdx])
		AddSliderOptionST("ITEMCARD_XOFFSET", "$Horizontal Offset", _itemcardXOffset)
		AddSliderOptionST("ITEMCARD_YOFFSET", "$Vertical Offset", _itemcardYOffset)

		AddEmptyOption()

		AddHeaderOption("$3D Item")
		AddSliderOptionST("XD_ITEM_XOFFSET", "$Horizontal Offset", _3DItemXOffset, "{0}", _3DItemFlags)
		AddSliderOptionST("XD_ITEM_YOFFSET", "$Vertical Offset", _3DItemYOffset, "{0}", _3DItemFlags)
		AddSliderOptionST("XD_ITEM_SCALE", "$Scale", _3DItemScale, "{1}", _3DItemFlags)
		AddToggleOptionST("XD_ITEM_POSITIONING", "$Disable Positioning", _3DItemDisablePositioning)

		SetCursorPosition(1)

		AddHeaderOption("$SWF Version Checking")
		AddToggleOptionST("CHECK_INVENTORY_MENU", "Inventory Menu", SKI_MainInstance.InventoryMenuCheckEnabled)
		AddToggleOptionST("CHECK_MAGIC_MENU", "Magic Menu", SKI_MainInstance.MagicMenuCheckEnabled)
		AddToggleOptionST("CHECK_BARTER_MENU", "Barter Menu", SKI_MainInstance.BarterMenuCheckEnabled)
		AddToggleOptionST("CHECK_CONTAINER_MENU", "Container Menu", SKI_MainInstance.ContainerMenuCheckEnabled)
		AddToggleOptionST("CHECK_GIFT_MENU", "Gift Menu", SKI_MainInstance.GiftMenuCheckEnabled)
		AddToggleOptionST("CHECK_MAP_MENU", "Map Menu", SKI_MainInstance.MapMenuCheckEnabled)
	endIf
endEvent


; STATE OPTIONS -----------------------------------------------------------------------------------

state ITEMLIST_FONT_SIZE ; TEXT

	event OnSelectST()
		if (_itemlistFontSizeIdx < _sizes.length - 1)
			_itemlistFontSizeIdx += 1
		else
			_itemlistFontSizeIdx = 0
		endif
		SetTextOptionValueST(_sizes[_itemlistFontSizeIdx])
		ApplyItemListFontSize()
	endEvent

	event OnDefaultST()
		_itemlistFontSizeIdx = 1
		SetTextOptionValueST(_sizes[_itemlistFontSizeIdx])
		ApplyItemListFontSize()
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _sizes[1] + "}")
	endEvent
	
endState

state ITEMLIST_QUANTITY_MIN_COUNT ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_itemlistQuantityMinCount)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_itemlistQuantityMinCount = a_value as int
		SetSliderOptionValueST(_itemlistQuantityMinCount)
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount)
	endEvent

	event OnDefaultST()
		_itemlistQuantityMinCount = 6
		SetSliderOptionValueST(_itemlistQuantityMinCount)
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO2{6}")
	endEvent
	
endState

state ITEMLIST_CATEGORY_ICON_THEME ; MENU

	event OnMenuOpenST()
		SetMenuDialogStartIndex(_categoryIconThemeIdx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_categoryIconThemeLongNames)
	endEvent

	event OnMenuAcceptST(int a_index)
		_categoryIconThemeIdx = a_index
		SetMenuOptionValueST(_categoryIconThemeShortNames[_categoryIconThemeIdx])
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endEvent

	event OnDefaultST()
		_categoryIconThemeIdx = 0
		SetTextOptionValueST(_categoryIconThemeShortNames[_categoryIconThemeIdx])
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _categoryIconThemeShortNames[0] + "}")
	endEvent
	
endState

state ITEMLIST_NO_ICON_COLORS ; TOGGLE

	event OnSelectST()
		_itemListNoIconColors = !_itemlistNoIconColors
		SetToggleOptionValueST(_itemlistNoIconColors)
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors)
	endEvent

	event OnDefaultST()
		_itemlistNoIconColors = false
		SetToggleOptionValueST(_itemlistNoIconColors)
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{$Off}")
	endEvent
	
endState

; -------------------------------------------------------

state EFFECT_WIDGET_ENABLED ; TOGGLE

	event OnSelectST()
		bool newVal = !SKI_ActiveEffectsWidgetInstance.Enabled
		SKI_ActiveEffectsWidgetInstance.Enabled = newVal

		if (newVal)
			_effectWidgetFlags = OPTION_FLAG_NONE
		else
			_effectWidgetFlags = OPTION_FLAG_DISABLED
		endIf

		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ICON_SIZE")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ORIENTATION")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_HORIZONTAL_ANCHOR")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_VERTICAL_ANCHOR")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_GROUP_COUNT")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_XOFFSET")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_YOFFSET")
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_ActiveEffectsWidgetInstance.Enabled = true

		_effectWidgetFlags = OPTION_FLAG_NONE
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ICON_SIZE")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ORIENTATION")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_HORIZONTAL_ANCHOR")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_VERTICAL_ANCHOR")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_GROUP_COUNT")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_XOFFSET")
		SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_YOFFSET")
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{$On}")
	endEvent
	
endState

state EFFECT_WIDGET_ICON_SIZE ; TEXT

	event OnSelectST()
		if (_effectWidgetIconSizeIdx < _sizes.length - 1)
			_effectWidgetIconSizeIdx += 1
		else
			_effectWidgetIconSizeIdx = 0
		endIf

		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		SetTextOptionValueST(_sizes[_effectWidgetIconSizeIdx])
	endEvent

	event OnDefaultST()
		_effectWidgetIconSizeIdx = 1
		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		SetTextOptionValueST(_sizes[_effectWidgetIconSizeIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _sizes[1] + "}")
	endEvent
	
endState

state EFFECT_WIDGET_ORIENTATION ; TEXT

	event OnSelectST()
		if (_effectWidgetOrientationIdx < _orientations.length - 1)
		  _effectWidgetOrientationIdx += 1
		else
		  _effectWidgetOrientationIdx = 0
		endIf
		
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[_effectWidgetOrientationIdx]
		SetTextOptionValueST(_orientations[_effectWidgetOrientationIdx])
	endEvent

	event OnDefaultST()
		_effectWidgetOrientationIdx = 1
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[_effectWidgetOrientationIdx]
		SetTextOptionValueST(_orientations[_effectWidgetOrientationIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _orientations[1] + "}")
	endEvent

endState

state EFFECT_WIDGET_HORIZONTAL_ANCHOR ; TEXT

	event OnSelectST()
		if (_effectWidgetHAnchorIdx < _alignments.length - 1)
		  _effectWidgetHAnchorIdx += 1
		else
		  _effectWidgetHAnchorIdx = 0
		endIf

		SKI_ActiveEffectsWidgetInstance.HAnchor = _alignmentValues[_effectWidgetHAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SetTextOptionValueST(_alignments[_effectWidgetHAnchorIdx])
	endEvent

	event OnDefaultST()
		_effectWidgetVAnchorIdx = 1
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SetTextOptionValueST(_alignments[_effectWidgetHAnchorIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _alignments[1] + "}")
	endEvent

endState

state EFFECT_WIDGET_VERTICAL_ANCHOR ; TEXT

	event OnSelectST()
		if (_effectWidgetVAnchorIdx < _vertAlignments.length - 1)
		  _effectWidgetVAnchorIdx += 1
		else
		  _effectWidgetVAnchorIdx = 0
		endIf

		SKI_ActiveEffectsWidgetInstance.VAnchor = _vertAlignmentValues[_effectWidgetVAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		SetTextOptionValueST(_vertAlignments[_effectWidgetVAnchorIdx])
	endEvent

	event OnDefaultST()
		_effectWidgetVAnchorIdx = 0
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		SetTextOptionValueST(_vertAlignments[_effectWidgetVAnchorIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _vertAlignments[0] + "}")
	endEvent

endState

state EFFECT_WIDGET_GROUP_COUNT ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(SKI_ActiveEffectsWidgetInstance.GroupEffectCount)
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(1, 16)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = a_value as int
		SetSliderOptionValueST(a_value as int)
	endEvent

	event OnDefaultST()
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = 8
		SetSliderOptionValueST(8)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{8}")
	endEvent

endState

state EFFECT_WIDGET_XOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_effectWidgetXOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1280, 1280)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_effectWidgetXOffset = a_value
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SetSliderOptionValueST(_effectWidgetXOffset)
	endEvent

	event OnDefaultST()
		_effectWidgetXOffset = 0.0
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SetSliderOptionValueST(_effectWidgetXOffset)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

state EFFECT_WIDGET_YOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_effectWidgetYOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-720, 720)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_effectWidgetYOffset = a_value
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		SetSliderOptionValueST(_effectWidgetYOffset)
	endEvent

	event OnDefaultST()
		_effectWidgetYOffset = 0.0
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		SetSliderOptionValueST(_effectWidgetYOffset)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

; -------------------------------------------------------

state SEARCH_KEY ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, false))
			return
		endIf

		SwapKeys(a_keyCode, _searchKey)

		_searchKey = a_keyCode
		SetKeyMapOptionValueST(_searchKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
	endEvent

	event OnDefaultST()
		_searchKey = 57
		SetKeyMapOptionValueST(_searchKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{Space}")
	endEvent

endState

state SWITCH_TAB_KEY ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, false))
			return
		endIf

		SwapKeys(a_keyCode, _switchTabKey)

		_switchTabKey = a_keyCode
		SetKeyMapOptionValueST(_switchTabKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
	endEvent

	event OnDefaultST()
		_switchTabKey = 56
		SetKeyMapOptionValueST(_switchTabKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{LAlt}")
	endEvent

endState

state EQUIP_MODE_KEY ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, false))
			return
		endIf

		SwapKeys(a_keyCode, _equipModeKey)

		_equipModeKey = a_keyCode
		SetKeyMapOptionValueST(_equipModeKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)
	endEvent

	event OnDefaultST()
		_equipModeKey = 42
		SetKeyMapOptionValueST(_equipModeKey)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{Shift}")
	endEvent

endState

state SWITCH_TAB_BUTTON ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, true))
			return
		endIf

		SwapKeys(a_keyCode, _switchTabButton)

		_switchTabButton = a_keyCode
		SetKeyMapOptionValueST(_switchTabButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)
	endEvent

	event OnDefaultST()
		_switchTabButton = 271
		SetKeyMapOptionValueST(_switchTabButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{Back}")
	endEvent

endState

state PREV_COLUMN_BUTTON ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, true))
			return
		endIf

		SwapKeys(a_keyCode, _prevColumnButton)

		_prevColumnButton = a_keyCode
		SetKeyMapOptionValueST(_prevColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)
	endEvent

	event OnDefaultST()
		_prevColumnButton = 274
		SetKeyMapOptionValueST(_prevColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{LB}")
	endEvent

endState

state NEXT_COLUMN_BUTTON ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, true))
			return
		endIf

		SwapKeys(a_keyCode, _nextColumnButton)

		_nextColumnButton = a_keyCode
		SetKeyMapOptionValueST(_nextColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)
	endEvent

	event OnDefaultST()
		_nextColumnButton = 275
		SetKeyMapOptionValueST(_nextColumnButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{RB}")
	endEvent

endState

state SORT_ORDER_BUTTON ; KEYMAP

	event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if (! ValidateKey(a_keyCode, true))
			return
		endIf

		SwapKeys(a_keyCode, _sortOrderButton)

		_sortOrderButton = a_keyCode
		SetKeyMapOptionValueST(_sortOrderButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)
	endEvent

	event OnDefaultST()
		_sortOrderButton = 272
		SetKeyMapOptionValueST(_sortOrderButton)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{LS}")
	endEvent

endState

; -------------------------------------------------------

state ITEMCARD_ALIGN ; KEYMAP

	event OnSelectST()
		if (_itemcardAlignIdx < _alignments.length - 1)
			_itemcardAlignIdx += 1
		else
			_itemcardAlignIdx = 0
		endif
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])
		SetTextOptionValueST(_alignments[_itemcardAlignIdx])
	endEvent

	event OnDefaultST()
		_itemcardAlignIdx = 2
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])
		SetTextOptionValueST(_alignments[_itemcardAlignIdx])
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{" + _alignments[2] + "}")
	endEvent

endState

state ITEMCARD_XOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_itemcardXOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_itemcardXOffset = a_value
		SetSliderOptionValueST(_itemcardXOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset)
	endEvent

	event OnDefaultST()
		_itemcardXOffset = 0.0
		SetSliderOptionValueST(_itemcardXOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

state ITEMCARD_YOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_itemcardYOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_itemcardYOffset = a_value
		SetSliderOptionValueST(_itemcardYOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset)
	endEvent

	event OnDefaultST()
		_itemcardYOffset = 0.0
		SetSliderOptionValueST(_itemcardYOffset)
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

; -------------------------------------------------------

state XD_ITEM_XOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_3DItemXOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-128, 128)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_3DItemXOffset = a_value
		SetSliderOptionValueST(_3DItemXOffset)
		Apply3DItemXOffset()
	endEvent

	event OnDefaultST()
		_3DItemXOffset = 0.0
		SetSliderOptionValueST(_3DItemXOffset)
		Apply3DItemXOffset()
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

state XD_ITEM_YOFFSET ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_3DItemYOffset)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-128, 128)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_3DItemYOffset = a_value
		SetSliderOptionValueST(_3DItemYOffset)
		Apply3DItemYOffset()
	endEvent

	event OnDefaultST()
		_3DItemYOffset = 0.0
		SetSliderOptionValueST(_3DItemYOffset)
		Apply3DItemYOffset()
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{0}")
	endEvent

endState

state XD_ITEM_SCALE ; SLIDER

	event OnSliderOpenST()
		SetSliderDialogStartValue(_3DItemScale)
		SetSliderDialogDefaultValue(1.5)
		SetSliderDialogRange(0.5, 5)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		_3DItemScale = a_value
		SetSliderOptionValueST(_3DItemScale, "{1}")
		Apply3DItemScale()
	endEvent

	event OnDefaultST()
		_3DItemScale = 1.5
		SetSliderOptionValueST(_3DItemScale, "{1}")
		Apply3DItemScale()
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO1{1.5}")
	endEvent

endState

state XD_ITEM_POSITIONING ; SLIDER

	event OnSelectST()
		bool newVal = !_3DItemDisablePositioning
		_3DItemDisablePositioning = newVal

		if (newVal)
			_3DItemFlags = OPTION_FLAG_DISABLED
		else
			_3DItemFlags = OPTION_FLAG_NONE
		endIf

		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_XOFFSET")
		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_YOFFSET")
		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_SCALE")
		SetToggleOptionValueST(newVal)
		Apply3DItemXOffset()
		Apply3DItemYOffset()
	endEvent

	event OnDefaultST()
		_3DItemDisablePositioning = false
		_3DItemFlags = OPTION_FLAG_NONE
		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_XOFFSET")
		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_YOFFSET")
		SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_SCALE")
		SetToggleOptionValueST(false)
		Apply3DItemXOffset()
		Apply3DItemYOffset()
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO4{$Off}")
	endEvent

endState

; -------------------------------------------------------

state CHECK_INVENTORY_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.InventoryMenuCheckEnabled
		SKI_MainInstance.InventoryMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.InventoryMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState

state CHECK_MAGIC_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.MagicMenuCheckEnabled
		SKI_MainInstance.MagicMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.MagicMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState

state CHECK_BARTER_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.BarterMenuCheckEnabled
		SKI_MainInstance.BarterMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.BarterMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState

state CHECK_CONTAINER_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.ContainerMenuCheckEnabled
		SKI_MainInstance.ContainerMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.ContainerMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState

state CHECK_GIFT_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.GiftMenuCheckEnabled
		SKI_MainInstance.GiftMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.GiftMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState

state CHECK_MAP_MENU ; SLIDER

	event OnSelectST()
		bool newVal = !SKI_MainInstance.MapMenuCheckEnabled
		SKI_MainInstance.MapMenuCheckEnabled = newVal
		SetToggleOptionValueST(newVal)
	endEvent

	event OnDefaultST()
		SKI_MainInstance.MapMenuCheckEnabled = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("$SKI_INFO3{$On}")
	endEvent
	
endState


; FUNCTIONS ---------------------------------------------------------------------------------------

function ApplySettings()
	; Apply settings that aren't handled by SKI_SettingsManagerInstance

	_fInventory3DItemPosXWide	= Utility.GetINIFloat("fInventory3DItemPosXWide:Interface")
	_fInventory3DItemPosX 		= Utility.GetINIFloat("fInventory3DItemPosX:Interface")
	_fMagic3DItemPosXWide 		= Utility.GetINIFloat("fMagic3DItemPosXWide:Interface")
	_fMagic3DItemPosX 			= Utility.GetINIFloat("fMagic3DItemPosX:Interface")

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
	if (_3DItemDisablePositioning)
		Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", _fInventory3DItemPosXWide)
		Utility.SetINIFloat("fInventory3DItemPosX:Interface", _fInventory3DItemPosX)
		Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", _fMagic3DItemPosXWide)
		Utility.SetINIFloat("fMagic3DItemPosX:Interface", _fMagic3DItemPosX)
	else
		Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", (_itemXBaseW + _3DItemXOffset))
		Utility.SetINIFloat("fInventory3DItemPosX:Interface", (_itemXBase + _3DItemXOffset))
		Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", (_itemXBaseW + _3DItemXOffset))
		Utility.SetINIFloat("fMagic3DItemPosX:Interface", (_itemXBase + _3DItemXOffset))
	endIf
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

bool function ValidateKey(int a_keyCode, bool a_gamepad)
	; Do nothing for ESC
	if (a_keyCode == 1)
		return false
	endIf

	bool isGamepad = Game.UsingGamepad()

	if (isGamepad != a_gamepad)
		return false
	endIf

	if (!isGamepad)
		; Can't detect for mouse, don't need for gamepad
		if (a_keyCode > 255)
			ShowMessage("$SKI_MSG1", false, "$OK")
			return false
		endIf
	else
		; If you removed the gamepad while in this menu, ignore other keys
		if (a_keyCode < 266)
			return false
		endIf
	endIf

	return true
endFunction

function SwapKeys(int a_newKey, int a_curKey)
	if (a_newKey == _searchKey)
		_searchKey = a_curKey
		SetKeyMapOptionValueST(_searchKey, true, "SEARCH_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey)
	elseIf (a_newKey == _switchTabKey)
		_switchTabKey = a_curKey
		SetKeyMapOptionValueST(_switchTabKey, true, "SWITCH_TAB_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey)
	elseIf (a_newKey == _equipModeKey)
		_equipModeKey = a_curKey
		SetKeyMapOptionValueST(_equipModeKey, true, "EQUIP_MODE_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey)

	elseIf (a_newKey == _switchTabButton)
		_switchTabButton = a_curKey
		SetKeyMapOptionValueST(_switchTabButton, true, "SWITCH_TAB_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton)
	elseIf (a_newKey == _prevColumnButton)
		_prevColumnButton = a_curKey
		SetKeyMapOptionValueST(_prevColumnButton, true, "PREV_COLUMN_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton)
	elseIf (a_newKey == _nextColumnButton)
		_nextColumnButton = a_curKey
		SetKeyMapOptionValueST(_nextColumnButton, true, "NEXT_COLUMN_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton)
	elseIf (a_newKey == _sortOrderButton)
		_sortOrderButton = a_curKey
		SetKeyMapOptionValueST(_sortOrderButton, true, "SORT_ORDER_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton)
	endIf
endFunction


; REMOVED DATA  -----------------------------------------------------------------------------------
											
; -- Version 1 --							; (remove version)

; int		_itemlistFontSizeOID_T			; (4)
; int		_itemlistQuantityMinCountOID_S	; (4)
; int		_itemcardAlignOID_T				; (4)
; int		_itemcardXOffsetOID_S			; (4)
; int		_itemcardYOffsetOID_S			; (4)
; int		_3DItemXOffsetOID_S				; (4)
; int		_3DItemYOffsetOID_S				; (4)
; int		_3DItemScaleOID_S				; (4)
; int		_checkInventoryMenuOID_B		; (4)
; int		_checkMagicMenuOID_B			; (4)
; int		_checkBarterMenuOID_B			; (4)
; int		_checkContainerMenuOID_B		; (4)
; int		_checkGiftMenuOID_B				; (4)
; int		_searchKeyOID_K					; (4)
; int		_switchTabKeyOID_K				; (4)
; int		_equipModeKeyOID_K				; (4)

; -- Version 2 --

; int		_itemlistCategoryIconThemeOID_M	; (4)
; int		_itemlistNoIconColorsOID_B 		; (4)
; int		_switchTabButtonOID_K 			; (4)
; int		_prevColumnButtonOID_K 			; (4)
; int		_nextColumnButtonOID_K 			; (4)
; int		_sortOrderButtonOID_K 			; (4)

; -- Version 3 --

; int		_3DItemDisablePositioningOID_B	; (4)