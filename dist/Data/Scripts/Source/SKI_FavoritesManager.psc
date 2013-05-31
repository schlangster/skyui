scriptname SKI_FavoritesManager extends SKI_QuestBase

import Math


; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		MENU_ROOT		= "_root.MenuHolder.Menu_mc" autoReadonly

int property		GROUP_FLAG_UNEQUIP_ARMOR	= 1	autoReadonly
int property		GROUP_FLAG_UNEQUIP_HANDS	= 2	autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

Actor Property		PlayerREF auto

bool property		ButtonHelpEnabled	= true auto

int property GroupAddKey
	int function get()
		return _groupAddKey
	endFunction

	function set(int a_val)
		SwapControlKey(a_val, _groupAddKey)
		_groupAddKey = a_val
	endFunction
endProperty

int property GroupUseKey
	int function get()
		return _groupUseKey
	endFunction

	function set(int a_val)
		SwapControlKey(a_val, _groupUseKey)
		_groupUseKey = a_val
	endFunction
endProperty

int property SetIconKey
	int function get()
		return _setIconKey
	endFunction

	function set(int a_val)
		SwapControlKey(a_val, _setIconKey)
		_setIconKey = a_val
	endFunction
endProperty

int property SaveEquipStateKey
	int function get()
		return _saveEquipStateKey
	endFunction

	function set(int a_val)
		SwapControlKey(a_val, _saveEquipStateKey)
		_saveEquipStateKey = a_val
	endFunction
endProperty

int property ToggleFocusKey
	int function get()
		return _toggleFocusKey
	endFunction

	function set(int a_val)
		SwapControlKey(a_val, _toggleFocusKey)
		_toggleFocusKey = a_val
	endFunction
endProperty

; PRIVATE VARIABLES -------------------------------------------------------------------------------

Form[]				_items1
Form[]				_items2
int[]				_itemFormIds1
int[]				_itemFormIds2

int[]				_groupFlags

Form[]				_groupMainHandItems
int[]				_groupMainHandFormIds

Form[]				_groupOffHandItems
int[]				_groupOffHandFormIds

Form[]				_groupIconItems
int[]				_groupIconFormIds

bool				_silenceEquipSounds = false

SoundCategory		_audioCategoryUI

; Forms to support EquipSlot comparisons
EquipSlot 			_rightHandSlot
EquipSlot 			_eitherHandSlot
EquipSlot 			_leftHandSlot
EquipSlot 			_bothHandsSlot
EquipSlot 			_voiceSlot

; State variables for Group Use
bool				_usedRightHand		= false
bool				_usedLeftHand		= false
bool				_usedVoice			= false
int					_usedOutfitMask		= 0

; Keys
int					_groupAddKey		= 33 ; F
int					_groupUseKey		= 19 ; R
int					_setIconKey			= 56 ; LAlt
int					_saveEquipStateKey	= 20 ; T
int					_toggleFocusKey		= 57 ; Space

int[]				_groupHotkeys




; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_items1			= new Form[128]
	_items2			= new Form[128]
	_itemFormIds1	= new int[128]
	_itemFormIds2	= new int[128]

	_groupFlags		= new int[8]

	_groupMainHandItems		= new Form[8]
	_groupMainHandFormIds	= new int[8]

	_groupOffHandItems		= new Form[8]
	_groupOffHandFormIds	= new int[8]
	
	_groupIconItems		= new Form[8]
	_groupIconFormIds	= new int[8]

	_groupHotkeys = new int[8]
	_groupHotkeys[0] = 59	; F1
	_groupHotkeys[1] = 60	; F2
	_groupHotkeys[2] = 61	; F3
	_groupHotkeys[3] = 62	; F4
	_groupHotkeys[4] = -1
	_groupHotkeys[5] = -1
	_groupHotkeys[6] = -1
	_groupHotkeys[7] = -1

	_audioCategoryUI	= Game.GetFormFromFile(0x00064451, "Skyrim.esm") as SoundCategory

	_rightHandSlot 		= Game.GetFormFromFile(0x00013f42, "Skyrim.esm") as EquipSlot
	_leftHandSlot 		= Game.GetFormFromFile(0x00013f43, "Skyrim.esm") as EquipSlot
	_eitherHandSlot		= Game.GetFormFromFile(0x00013f44, "Skyrim.esm") as EquipSlot
	_bothHandsSlot 		= Game.GetFormFromFile(0x00013f45, "Skyrim.esm") as EquipSlot
	_voiceSlot	 		= Game.GetFormFromFile(0x00025bee, "Skyrim.esm") as EquipSlot
	
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKIFM_groupAdd", "OnGroupAdd")
	RegisterForModEvent("SKIFM_groupRemove", "OnGroupRemove")
	RegisterForModEvent("SKIFM_groupUse", "OnGroupUse")
	RegisterForModEvent("SKIFM_saveEquipState", "OnSaveEquipState")
	RegisterForModEvent("SKIFM_setGroupIcon", "OnSetGroupIcon")
	RegisterForModEvent("SKIFM_foundInvalidItem", "OnFoundInvalidItem")
	
	RegisterForMenu(FAVORITES_MENU)
	
	RegisterHotkeys()

	CleanUp()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	InitControls()
	InitMenuGroupData()
endEvent

event OnFoundInvalidItem(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	RemoveInvalidItem(a_sender,true)
endEvent

event OnGroupAdd(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	if (GroupAdd(groupIndex, item))
		UpdateMenuGroupData(groupIndex)
	else
		UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".unlock", true)
		Debug.Notification("Group full!")
	endIf
endEvent

event OnGroupRemove(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	if (GroupRemove(groupIndex, item))
		UpdateMenuGroupData(groupIndex)
	else
		UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".unlock", true)
	endIf
endEvent

; Read the player's current equipment and save it to the target group
event OnSaveEquipState(string a_eventName, string a_strArg, float a_numArg, Form a_sender)	
	int groupIndex = a_numArg as int
	Form[] handItems = new Form[2]

	int handIndex = 0
	
	; Right
	Form rightHand = PlayerREF.GetEquippedObject(1)
	if (rightHand && IsFormInGroup(groupIndex, rightHand))
		_groupMainHandItems[groupIndex] = rightHand
		_groupMainHandFormIDs[groupIndex] = rightHand.GetFormID()
	else
		_groupMainHandItems[groupIndex] = none
		_groupMainHandFormIDs[groupIndex] = 0
	endIf

	; Left
	Form leftHand = PlayerREF.GetEquippedObject(0)
	if (leftHand && IsFormInGroup(groupIndex, leftHand))
		_groupOffHandItems[groupIndex] = leftHand
		_groupOffHandFormIDs[groupIndex] = leftHand.GetFormID()
	else
		_groupOffHandItems[groupIndex] = none
		_groupOffHandFormIDs[groupIndex] = 0
	endIf
	
	UpdateMenuGroupData(groupIndex)
endEvent

; This will set a form as the icon form for a group
event OnSetGroupIcon(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	_groupIconItems[groupIndex] = item
	_groupIconFormIds[groupIndex] = item.GetFormID()

	UpdateMenuGroupData(groupIndex)
endEvent

event OnGroupUse(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	gotoState("PROCESSING")

	GroupUse(a_numArg as int)

	gotoState("")
endEvent

event OnKeyDown(int a_keyCode)
	gotoState("PROCESSING")

	int groupIndex = _groupHotkeys.Find(a_keyCode)
	if (groupIndex != -1 && !Utility.IsInMenuMode())
		GroupUse(groupIndex)
	endIf

	gotoState("")
endEvent

state PROCESSING
	
	event OnGroupUse(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	endEvent

	event OnKeyDown(int a_keyCode)
	endEvent

endState


; FUNCTIONS ---------------------------------------------------------------------------------------

;get whether a flag is set for the specified group
bool function GetGroupFlag(int a_groupIndex, int a_flag)
    return LogicalAnd(_groupFlags[a_groupIndex], a_flag) as bool
endFunction
 
;set a flag for the specified group
function SetGroupFlag(int a_groupIndex, int a_flag, bool a_value)
	if (a_value)
		_groupFlags[a_groupIndex] = LogicalOr(_groupFlags[a_groupIndex], a_flag)
	else
		_groupFlags[a_groupIndex] = LogicalAnd(_groupFlags[a_groupIndex], LogicalNot(a_flag))
	endIf
endFunction

int[] function GetGroupHotkeys()
	; Return a copy
	int[] result = new int[8]
	int i = 0
	while (i<8)
		result[i] = _groupHotkeys[i]
		i += 1
	endWhile
	return result
endFunction

bool function SetGroupHotkey(int a_groupIndex, int a_keycode)

	; Special case for unmap
	if (a_keycode == -1)
		_groupHotkeys[a_groupIndex] = -1
		UnregisterForKey(oldKeycode)
		return true
	endIf

	; Old group index this keycode was bound to
	int oldIndex = _groupHotkeys.Find(a_keycode)
	; Old keycode at the target position
	int oldKeycode = _groupHotkeys[a_groupIndex]

	; Already assigned, no need to do anything
	if (oldIndex == a_groupIndex)
		return false
	endIf

	; Swap
	if (oldIndex != -1 && oldKeycode != -1)
		_groupHotkeys[oldIndex] = oldKeycode
	else
		; Unset previous group this key was assigned to
		if (oldIndex != -1)
			_groupHotkeys[oldIndex] = -1
		endIf

		; If we replaced a key, unregister it
		if (oldKeycode != -1)
			UnregisterForKey(oldKeycode)
		endIf

		RegisterForKey(a_keycode)
	endIf

	_groupHotkeys[a_groupIndex] = a_keycode

	return true
endFunction

; Send the group data to the UI, so that when the user selects a group, it can filter its entries.
function InitControls()
	int[] args = new int[6]
	args[0] = ButtonHelpEnabled as int
	args[1] = _groupAddKey
	args[2] = _groupUseKey
	args[3] = _setIconKey
	args[4] = _saveEquipStateKey
	args[5] = _toggleFocusKey

	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".initControls", args)
endFunction

; Send the group data to the UI, so that when the user selects a group, it can filter its entries.
function InitMenuGroupData()
	; groupCount, mainHandFormId[8], offHandFormId[8], iconFormId[8]
	int[] args = new int[25]
	args[0] = 8

	int c = 1

	int i = 0
	while (i<8)
		args[c] = _groupMainHandFormIds[i]
		i += 1
		c += 1
	endWhile

	i = 0
	while (i<8)
		args[c] = _groupOffHandFormIds[i]
		i += 1
		c += 1
	endWhile
	
	i = 0
	while (i<8)
		args[c] = _groupIconFormIds[i]
		i += 1
		c += 1
	endWhile
	
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds1)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds2)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".finishGroupData", args)
endFunction

function UpdateMenuGroupData(int a_groupIndex)
	int offset = 32 * a_groupIndex

	int[] itemFormIds

	if (offset >= 128)
		offset -= 128
		itemFormIds = _itemFormIds2
	else
		itemFormIds = _itemFormIds1
	endIf

	; groupIndex, mainHandFormId, offHandFormID, iconFormId, itemFormIds[32]
	int[] args = new int[36]

	args[0] = a_groupIndex
	args[1] = _groupMainHandFormIds[a_groupIndex]
	args[2] = _groupOffHandFormIds[a_groupIndex]
	args[3] = _groupIconFormIds[a_groupIndex]

	int i = 4
	int j = offset

	while (i<36)
		args[i] = itemFormIds[j]

		i += 1
		j += 1
	endWhile
	
	; This also unlocks the menu, so no need to call unlock
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".updateGroupData", args)
endFunction

; Ensure that our data is still valid. Might not be the case if a mod was uninstalled
function CleanUp()
	
	; Note on thread safety:
	; Since we don't manage an explicit group count, items can just be set or unset from multiple threads

	int i = 0
	while (i < _items1.length)

		if (_items1[i] == none || _items1[i].GetFormID() == 0)
			_items1[i] = none
			_itemFormIds1[i] = 0
		endIf

		i += 1
	endWhile

	i = 0
	while (i < _items2.length)

		if (_items2[i] == none || _items2[i].GetFormID() == 0)
			_items2[i] = none
			_itemFormIds2[i] = 0
		endIf

		i += 1
	endWhile
endFunction

bool function GroupAdd(int a_groupIndex, Form a_item)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	; Prevent the same form being added to a group twice
	if (IsFormInGroup(a_groupIndex,a_item))
		return true
	endIf
	
	; Pick next free slot
	int index = FindFreeIndex(items, offset)
	
	; No more space in group?
	if (index == -1)
		return false
	endIf

	; Store received data
	int formId = a_item.GetFormID()
	items[index] = a_item
	formIds[index] = formId

	; If there's no icon item set yet, use this one
	if (_groupIconItems[a_groupIndex] == none)
		_groupIconItems[a_groupIndex] = a_item
		_groupIconFormIds[a_groupIndex] = formId
	endIf

	return true
endFunction

bool function GroupRemove(int a_groupIndex, Form a_item)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	int i = offset
	int n = offset+32
	while (i < n)
		if (items[i] == a_item)
			items[i] = none
			formIds[i] = 0
			i = n
		else
			i += 1
		endIf
	endWhile

	if (a_item == _groupMainHandItems[a_groupIndex])
		_groupMainHandItems[a_groupIndex] = none
		_groupMainHandFormIds[a_groupIndex] = 0
	endIf

	if (a_item == _groupOffHandItems[a_groupIndex])
		_groupOffHandItems[a_groupIndex] = none
		_groupOffHandFormIds[a_groupIndex] = 0
	endIf

	if (a_item == _groupIconItems[a_groupIndex])
		ReplaceGroupIcon(a_groupIndex)
	endIf

	return true
endFunction

function GroupUse(int a_groupIndex)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	; Reset state
	_usedRightHand		= false
	_usedLeftHand		= false
	_usedVoice			= false
	_usedOutfitMask		= 0

	; These items are equipped later
	Form[] deferredItems = new Form[32]
	int deferredIdx = 0

	; Encountered invalid items are removed at the end when speed is no longer an issue
	Form[] invalidItems = new Form[32]
	int invalidIdx = 0

	; Turn off UI sounds to avoid annoying clicking noise while swapping spells
	_audioCategoryUI.Mute()
	
	; Unequip hands first?
	if (GetGroupFlag(a_groupIndex,GROUP_FLAG_UNEQUIP_HANDS))
		Form rightHand = PlayerREF.GetEquippedObject(1)
		if (rightHand)
			int itemType = rightHand.GetType()
			if (itemType == 22)
				PlayerREF.UnequipSpell(rightHand as Spell, 0)
			else
				PlayerREF.UnequipItemEx(rightHand, 1)
			endif
		endIf

		Form leftHand = PlayerREF.GetEquippedObject(0)
		if (leftHand)
			int itemType = leftHand.GetType()
			if (itemType == 22)
				PlayerREF.UnequipSpell(leftHand as Spell, 1)
			else
				PlayerREF.UnequipItemEx(leftHand, 2)
			endif
		endIf
	endIf
	
	; Process main and offhand items

	; Left first, to avoid problems when equipping the same weapon twice
	Form offHandItem = _groupOffHandItems[a_groupIndex]
	if (offHandItem)
		ProcessItem(offHandItem, offHandItem.GetType(), false, true)
	endIf

	Form mainHandItem = _groupMainHandItems[a_groupIndex]
	if (mainHandItem)
		ProcessItem(mainHandItem, mainHandItem.GetType(), false, false)
	endIf

	; Validate & process items
	int i = offset
	int n = offset + 32
	while (i < n)
		Form item = items[i]

		if (item && item != mainHandItem && item != offHandItem)
			int itemType = item.GetType()

			if (! ValidateItem(item, itemType))
				invalidItems[invalidIdx] = item
				invalidIdx += 1
			elseIf (! ProcessItem(item, itemType))
				deferredItems[deferredIdx] = item
				deferredIdx += 1
			endIf
		endIf

		i += 1
	endWhile

	; Process deferred items
	i = 0
	while (i < deferredIdx)
		Form item = deferredItems[i]
		int itemType = item.GetType()

		ProcessItem(item, itemType, false)

		i += 1
	endWhile

	; Unequip any armor not belonging to current outfit mask
	if (GetGroupFlag(a_groupIndex,GROUP_FLAG_UNEQUIP_ARMOR))
		int h = 0x00000001
		while (h < 0x80000000)
			Form wornForm = PlayerREF.GetWornForm(h)
			if (wornForm)
				if (!LogicalAND(h, _usedOutfitMask))
					PlayerREF.UnEquipItemEX(wornForm)
				endIf
			endIf
			h = LeftShift(h,1)
		endWhile
	endIf
	
	_audioCategoryUI.UnMute() ; Turn UI sounds back on

	i = 0
	while (i<invalidIdx)
		RemoveInvalidItem(invalidItems[i])
		i += 1
	endWhile
endFunction

bool function ValidateItem(Form a_item, int a_itemType)
	; Player has removed this item from Favorites, so don't use it and queue it for removal
	if (! Game.IsObjectFavorited(a_item))
		return false
	endIf

	; This is a Spell or Shout and can't be counted like an item
	if (a_itemType == 22 || a_itemType == 119)
		return PlayerREF.HasSpell(a_item)
	; This is an inventory item
	else 
		return PlayerREF.GetItemCount(a_item) > 0
	endIf
endFunction

bool function ProcessItem(Form a_item, int a_itemType, bool a_allowDeferring = true, bool a_offHandOnly = false)

	; WEAPON ------------
	if (a_itemType == 41)

		; Any weapon needs at least one free hand
		if (_usedRightHand && _usedLeftHand)
			return true
		endIf

		Weapon itemWeapon = a_item as Weapon
		int weaponType = itemWeapon.GetweaponType()

		; It's one-handed and the player has a free hand
		if (weaponType <= 4 || weaponType == 8) ; Fists(0), Swords(1), Daggers(2), War Axes(3), Maces(4), Staffs(8)
			if (!_usedRightHand && !a_offHandOnly)
				PlayerREF.EquipItemEX(itemWeapon, 1, equipSound = _silenceEquipSounds)
				_usedRightHand = true
			elseIf (!_usedLeftHand)
				PlayerREF.EquipItemEX(itemWeapon, 2, equipSound = _silenceEquipSounds)
				_usedLeftHand = true
			endIf

		; It's two-handed and both hands are free
		elseIf (weaponType > 4 && !_usedRightHand && !_usedLeftHand) ; 
			PlayerREF.EquipItemEX(itemWeapon, equipSlot = 0, equipSound = _silenceEquipSounds)
			_usedRightHand = true
			_usedLeftHand = true
		endIf

		return true

	; ARMOR ------------
	elseIf (a_itemType == 26)
		int slotMask = (a_item as Armor).GetslotMask()

		; It's a shield... 
		if (slotMask == 512)
			if (!_usedLeftHand)
				PlayerREF.EquipItemEX(a_item, equipSlot = 0, equipSound = _silenceEquipSounds)
				_usedLeftHand = true
				_usedOutfitMask += slotMask
			endIf
		; It's not a shield, just equip it
		else 
			PlayerREF.EquipItemEX(a_item, equipSlot = 0, equipSound = _silenceEquipSounds)
			_usedOutfitMask += slotMask
		endIf

		return true

	; AMMO ------------
	elseIf (a_itemType == 42) ;kAmmo
		PlayerREF.EquipItemEX(a_item, equipSlot = 0, equipSound = _silenceEquipSounds)
		return true

	; SPELL ------------
	elseIf (a_itemType == 22) 

		Spell itemSpell = a_item as Spell
		EquipSlot spellEquipSlot = itemSpell.GetEquipType()

		if (spellEquipSlot != _voiceSlot)

			; Any non power spell needs at least one free hand
			if (_usedRightHand && _usedLeftHand)
				return true
			endIf

			; spell is eitherhanded
			if (spellEquipSlot == _eitherHandSlot)
				if (!_usedRightHand && !a_offHandOnly)
					PlayerREF.EquipSpell(itemSpell, 1)
					_usedRightHand = true
				elseIf (!_usedLeftHand)
					PlayerREF.EquipSpell(itemSpell, 0)
					_usedLeftHand = true
				endIf

			; Spell requires two hands ...
			elseIf (spellEquipSlot == _bothHandsSlot)
				if (!_usedRightHand && !_usedLeftHand)
					PlayerREF.EquipSpell(itemSpell, 1)
					_usedRightHand = true
					_usedLeftHand = true
				endIf

			; a lot of NPC spells are left-hand only, so if the player is using PSB they'll need this
			elseIf (spellEquipSlot == _leftHandSlot)
				if (!_usedLeftHand)
					PlayerREF.EquipSpell(itemSpell, 0)
					_usedLeftHand = true
				endIf
			endIf

		else
			if (!_usedVoice)
				PlayerREF.EquipSpell(itemSpell, 2)
				_usedVoice = true
			endIf
		endIf

		return true

	; SCROLL ------------
	elseIf (a_itemType == 23)
		Scroll itemScroll = a_item as Scroll
		
		; Any scroll needs at least one free hand
		if (_usedRightHand && _usedLeftHand)
			return true
		endIf
		;FIXME - GetEquipType seems to be broken for scrolls
		;If (itemScroll.GetEquipType() == _bothHandsSlot && !_usedLeftHand && !_usedRightHand)
		;	PlayerREF.EquipItemEX(itemScroll, equipSlot = 0, equipSound = _silenceEquipSounds)
		;	_usedLeftHand = true
		;	_usedRightHand = true
		if (!_usedRightHand && !a_offHandOnly)
			PlayerREF.EquipItemEX(itemScroll, equipSlot = 1, equipSound = _silenceEquipSounds)
			_usedRightHand = true			
		elseIf (!_usedLeftHand)
			PlayerREF.EquipItemEX(itemScroll, equipSlot = 2, equipSound = _silenceEquipSounds)
			_usedLeftHand = true
		endIf
		
		return true
		
	; SHOUT ------------
	elseIf (a_itemType == 119)
		if (!_usedVoice)
			PlayerREF.EquipShout(a_item as Shout)
			_usedVoice = true
		endIf

	; POTION ------------
	elseIf (a_itemType == 46)
		if ((a_item as Potion).IsHostile()) ; This is a poison and should only be applied after new weapons have been equipped.
			if (a_allowDeferring)
				return false
			endIf

			; This will fail if a poisonable weapon is only equipped in the offhand. That's a Skyrim bug, not my bug.
			PlayerREF.EquipItem(a_item, abSilent = True)

			return true
		endiF

		; This is a non-hostile potion, food, or... something? and can be used immediately
		PlayerREF.EquipItem(a_item as Potion, abSilent = True)
		return true

	; INGREDIENT ------------
	elseIf (a_itemType == 30) ;kIngredient
		PlayerREF.EquipItem(a_item as Ingredient, abSilent = True)
		return true

	; LIGHT (TORCH) ------------
	elseIf (a_itemType == 31)
		;Should be equipped last, as it depends on having the left hand free
		if (a_allowDeferring)
			return false
		endIf

		if (!_usedLeftHand)
			PlayerREF.EquipItemEX(a_item, equipSlot = 0, equipSound = _silenceEquipSounds)
			_usedLeftHand = true
		endIf

		return true
	endIf

	return true
endFunction

function RemoveInvalidItem(Form a_item, bool redrawIcon = false)
	int index

	; GroupData
	index = _items1.Find(a_item)
	if (index != -1)
		_items1[index] = none
		_itemFormIds1[index] = 0
	endIf

	index = _items2.Find(a_item)
	if (index != -1)
		_items2[index] = none
		_itemFormIds2[index] = 0
	endIf

	; Main hand
	index = _groupMainHandItems.Find(a_item)
	if (index != -1)
		_groupMainHandItems[index] = none
		_groupMainHandFormIds[index] = 0
	endIf

	; Off hand
	index = _groupOffHandItems.Find(a_item)
	if (index != -1)
		_groupOffHandItems[index] = none
		_groupOffHandFormIds[index] = 0
	endIf

	; Icon
	index = _groupIconItems.Find(a_item)
	if (index != -1)
		ReplaceGroupIcon(index)
		if (redrawIcon)
			UpdateMenuGroupData(index)
		endIf
	endIf
endFunction

int function FindFreeIndex(Form[] a_items, int offset)
	int i = a_items.Find(none,offset)
	
	if (i >= offset && i < offset + 32)
		return i
	endIf
	
	return -1
endFunction

function ReplaceGroupIcon(int a_groupIndex)

	; If player has MH or OH set for the group, use it first
	if (_groupMainHandItems[a_groupIndex])
		_groupIconItems[a_groupIndex] = _groupMainHandItems[a_groupIndex]
		_groupIconFormIds[a_groupIndex] = _groupMainHandItems[a_groupIndex].GetFormID()
		return
	elseIf (_groupOffHandItems[a_groupIndex])
		_groupIconItems[a_groupIndex] = _groupOffHandItems[a_groupIndex]
		_groupIconFormIds[a_groupIndex] = _groupOffHandItems[a_groupIndex].GetFormID()
		return
	endIf

	int offset = a_groupIndex * 32

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	int i = offset
	int n = offset+32

	while (i < n)
		if (items[i] != none)
			_groupIconItems[a_groupIndex] = items[i]
			_groupIconFormIds[a_groupIndex] = items[i].GetFormID()
			return
		else
			i += 1
		endIf
	endWhile

	_groupIconItems[a_groupIndex] = none
	_groupIconFormIds[a_groupIndex] = 0
endFunction

; utility function to see if form is in the specified group. 
bool function IsFormInGroup(int a_groupIndex, form a_item)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items

	if (offset >= 128)
		offset -= 128
		items = _items2
	else
		items = _items1
	endIf
	
	int i = items.Find(a_item,offset)
	if (i >= offset && i < offset+32)
		return true
	endIf
	
	return false
endFunction

function RegisterHotkeys()
	int i = 0
	
	while (i < _groupHotkeys.Length)
		
		if (_groupHotkeys[i] != -1)
			RegisterForKey(_groupHotkeys[i])
		endIf

		i += 1
	endWhile
endFunction

function SwapControlKey(int a_newKey, int a_curKey)
	if (a_newKey == _groupAddKey)
		_groupAddKey = a_curKey
	elseIf (a_newKey == _groupUseKey)
		_groupUseKey = a_curKey
	elseIf (a_newKey == _setIconKey)
		_setIconKey = a_curKey
	elseIf (a_newKey == _saveEquipStateKey)
		_saveEquipStateKey = a_curKey
	elseIf (a_newKey == _toggleFocusKey)
		_toggleFocusKey = a_curKey
	endIf
endFunction