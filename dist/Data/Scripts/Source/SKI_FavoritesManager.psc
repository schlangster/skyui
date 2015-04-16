scriptname SKI_FavoritesManager extends SKI_QuestBase

import Math

; SCRIPT VERSION ----------------------------------------------------------------------------------
;
; History
;
; 1:	- Initial version
;
; 2:	- Added check for vampire lord
;
; 3:	- Less eagerly clearing of invalid entries

int function GetVersion()
	return 3
endFunction


; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		MENU_ROOT		= "_root.MenuHolder.Menu_mc" autoReadonly

int property		GROUP_FLAG_UNEQUIP_ARMOR	= 1	autoReadonly
int property		GROUP_FLAG_UNEQUIP_HANDS	= 2	autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

; -- Version 1 --

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

; -- Version 1 --

Form[]				_items1
Form[]				_items2
int[]				_itemIds1
int[]				_itemIds2

int[]				_groupFlags

Form[]				_groupMainHandItems
int[]				_groupMainHandItemIds

Form[]				_groupOffHandItems
int[]				_groupOffHandItemIds

Form[]				_groupIconItems
int[]				_groupIconItemIds

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

; -- Version 2 --

Race				_vampireLordRace

; -- Version 3 --

bool[]				_itemInvalidFlags1
bool[]				_itemInvalidFlags2


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_items1			= new Form[128]
	_items2			= new Form[128]
	_itemIds1		= new int[128]
	_itemIds2		= new int[128]

	_groupFlags		= new int[8]

	_groupMainHandItems		= new Form[8]
	_groupMainHandItemIds	= new int[8]

	_groupOffHandItems		= new Form[8]
	_groupOffHandItemIds	= new int[8]
	
	_groupIconItems		= new Form[8]
	_groupIconItemIds	= new int[8]

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
	CheckVersion()

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

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)

	; Version 2
	if (a_version >= 2 && CurrentVersion < 2)
		Debug.Trace(self + ": Updating to script version 2")

		_vampireLordRace	= Game.GetFormFromFile(0x0000283A, "Dawnguard.esm") as Race
	endIf

	; Version 3
	if (a_version >= 3 && CurrentVersion < 3)
		Debug.Trace(self + ": Updating to script version 3")

		_itemInvalidFlags1 = new bool[128]
		_itemInvalidFlags2 = new bool[128]
	endIf

endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)

	int i = 0
	while (i < 128)
		_itemInvalidFlags1[i] = false
		i += 1
	endWhile

	i = 0
	while (i < 128)
		_itemInvalidFlags2[i] = false
		i += 1
	endWhile

	InitControls()
	InitMenuGroupData()
endEvent

event OnFoundInvalidItem(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	InvalidateItem(a_strArg as int,true)
endEvent

event OnGroupAdd(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int		groupIndex = a_numArg as int
	int		itemId = a_strArg as int
	Form	item = a_sender

	if (GroupAdd(groupIndex, itemId, item))
		UpdateMenuGroupData(groupIndex)
	else
		UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".unlock", true)
		Debug.Notification("Group full!")
	endIf
endEvent

event OnGroupRemove(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int		groupIndex = a_numArg as int
	int		itemId = a_strArg as int

	if (GroupRemove(groupIndex, itemId))
		UpdateMenuGroupData(groupIndex)
	else
		UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".unlock", true)
	endIf
endEvent

; Read the player's current equipment and save it to the target group
event OnSaveEquipState(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int groupIndex = a_numArg as int
	
	int mainHandItemId = UI.GetInt(FAVORITES_MENU, MENU_ROOT + ".rightHandItemId")
	int offHandItemId = UI.GetInt(FAVORITES_MENU, MENU_ROOT + ".leftHandItemId")

	form mainHandForm = GetFormFromItemId(groupIndex,mainHandItemId) ; will return none if not in group
	if (mainHandForm)
		_groupMainHandItemIds[groupIndex] = mainHandItemId
		_groupMainHandItems[groupIndex] = mainHandForm
	else
		_groupMainHandItemIds[groupIndex] = 0
		_groupMainHandItems[groupIndex] = none
	endIf

	form offHandForm = GetFormFromItemId(groupIndex,offHandItemId)
	if (offHandForm)
		_groupOffHandItemIds[groupIndex] = offHandItemId
		_groupOffHandItems[groupIndex] = offHandForm
	else
		_groupOffHandItemIds[groupIndex] = 0
		_groupOffHandItems[groupIndex] = none
	endIf
	
	UpdateMenuGroupData(groupIndex)
endEvent

; This will set a form as the icon form for a group
event OnSetGroupIcon(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int		groupIndex = a_numArg as int
	int		itemId = a_strArg as int
	Form	item = a_sender

	_groupIconItems[groupIndex] = item
	_groupIconItemIds[groupIndex] = itemId

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
	; Don't send group data if vampire lord
	if (_vampireLordRace == PlayerRef.GetRace())
		return
	endIf

	; groupCount, mainHandFormId[8], offHandFormId[8], iconFormId[8]
	int[] args = new int[25]
	args[0] = 8

	int c = 1

	int i = 0
	while (i<8)
		args[c] = _groupMainHandItemIds[i]
		i += 1
		c += 1
	endWhile

	i = 0
	while (i<8)
		args[c] = _groupOffHandItemIds[i]
		i += 1
		c += 1
	endWhile
	
	i = 0
	while (i<8)
		args[c] = _groupIconItemIds[i]
		i += 1
		c += 1
	endWhile

	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupItems", _itemIds1)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupItems", _itemIds2)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".finishGroupData", args)
endFunction

function UpdateMenuGroupData(int a_groupIndex)
	int offset = 32 * a_groupIndex

	int[] itemIds

	if (offset >= 128)
		offset -= 128
		itemIds = _itemIds2
	else
		itemIds = _itemIds1
	endIf

	; groupIndex, mainHandItemId, offHandItemID, iconItemId, itemIds[32]
	int[] args = new int[36]

	args[0] = a_groupIndex
	args[1] = _groupMainHandItemIds[a_groupIndex]
	args[2] = _groupOffHandItemIds[a_groupIndex]
	args[3] = _groupIconItemIds[a_groupIndex]

	int i = 4
	int j = offset

	while (i<36)
		args[i] = itemIds[j]

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
			_itemIds1[i] = 0
		endIf

		i += 1
	endWhile

	i = 0
	while (i < _items2.length)

		if (_items2[i] == none || _items2[i].GetFormID() == 0)
			_items2[i] = none
			_itemIds2[i] = 0
		endIf

		i += 1
	endWhile
endFunction

bool function GroupAdd(int a_groupIndex, int a_itemId, Form a_item)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] itemIds
	bool[] itemInvalidFlags

	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf

	; Prevent the same itemId being added to a group twice
	if (IsItemIdInGroup(a_groupIndex,a_itemId))
		return true
	endIf
	
	; Pick next free slot
	int index = FindFreeIndex(itemIds, itemInvalidFlags, offset)
	
	; No more space in group?
	if (index == -1)
		return false
	endIf

	; Store received data
	items[index] = a_item
	itemIds[index] = a_itemId
	itemInvalidFlags[index] = false

	; If there's no icon item set yet, use this one
	if (_groupIconItems[a_groupIndex] == none)
		_groupIconItems[a_groupIndex] = a_item
		_groupIconItemIds[a_groupIndex] = a_itemId
	endIf

	return true
endFunction

bool function GroupRemove(int a_groupIndex, int a_itemId)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] itemIds
	bool[] itemInvalidFlags

	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf

	int i = offset
	int n = offset+32
	while (i < n)
		if (itemIds[i] == a_itemId)
			items[i] = none
			itemIds[i] = 0
			itemInvalidFlags[i] = false
			i = n
		else
			i += 1
		endIf
	endWhile

	if (a_itemId == _groupMainHandItemIds[a_groupIndex])
		_groupMainHandItems[a_groupIndex] = none
		_groupMainHandItemIds[a_groupIndex] = 0
	endIf

	if (a_itemId == _groupOffHandItemIds[a_groupIndex])
		_groupOffHandItems[a_groupIndex] = none
		_groupOffHandItemIds[a_groupIndex] = 0
	endIf

	if (a_itemId == _groupIconItemIds[a_groupIndex])
		ReplaceGroupIcon(a_groupIndex)
	endIf

	return true
endFunction

function GroupUse(int a_groupIndex)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] itemIds
	bool[] itemInvalidFlags

	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf

	; Reset state
	_usedRightHand		= false
	_usedLeftHand		= false
	_usedVoice			= false
	_usedOutfitMask		= 0

	; These items are equipped later
	form[] deferredItems = new Form[32]
	int deferredIdx = 0

	; Encountered invalid items are removed at the end when speed is no longer an issue
	int[] invalidItemIds = new int[32]
	int invalidIdx = 0

	; Turn off UI sounds to avoid annoying clicking noise while swapping spells
	_audioCategoryUI.Mute()
	
	; Unequip hands first?
	if (GetGroupFlag(a_groupIndex,GROUP_FLAG_UNEQUIP_HANDS))
		UnequipHand(0)
		UnequipHand(1)
	endIf
	
	; Process main and offhand items

	; Left first, to avoid problems when equipping the same weapon twice
	Form offHandItem = _groupOffHandItems[a_groupIndex]
	int offHandItemId = _groupOffHandItemIds[a_groupIndex]
	if (offHandItem)
		int itemType = offHandItem.GetType()
		if (IsItemValid(offHandItem, itemType))
			ProcessItem(offHandItem, itemType, false, true, offHandItemId)
		endIf
	endIf

	Form mainHandItem = _groupMainHandItems[a_groupIndex]
	int mainHandItemId = _groupMainHandItemIds[a_groupIndex]
	if (mainHandItem)
		int itemType = mainHandItem.GetType()
		if (IsItemValid(mainHandItem, itemType))
			ProcessItem(mainHandItem, itemType, false, false, mainHandItemId)
		endIf
	endIf

	; Validate & process items
	int i = offset
	int n = offset + 32
	while (i < n)
		Form item = items[i]
		int itemId = itemIds[i]
		
		if (item && item != mainHandItem && item != offHandItem && !itemInvalidFlags[i])
			int itemType = item.GetType()

			if (! IsItemValid(item, itemType))
				invalidItemIds[invalidIdx] = itemId
				invalidIdx += 1
			elseIf (! ProcessItem(item, itemType, a_itemId = itemId))
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
		InvalidateItem(invalidItemIds[i])
		i += 1
	endWhile
endFunction

function UnequipHand(int a_hand)
	int a_handEx = 1
	if (a_hand == 0)
		a_handEx = 2 ; unequipspell and *ItemEx need different hand args
	endIf

	Form handItem = PlayerREF.GetEquippedObject(a_hand)
	if (handItem)
		int itemType = handItem.GetType()
		if (itemType == 22)
			PlayerREF.UnequipSpell(handItem as Spell, a_hand)
		else
			PlayerREF.UnequipItemEx(handItem, a_handEx)
		endIf
	endIf
endFunction

bool function IsItemValid(Form a_item, int a_itemType)
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

bool function ProcessItem(Form a_item, int a_itemType, bool a_allowDeferring = true, bool a_offHandOnly = false, int a_itemId = 0)

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

				if (a_item == PlayerREF.GetEquippedObject(1) && a_itemId != PlayerREF.GetEquippedItemId(1))
					UnequipHand(1) ; avoid damage-related bug when swapping for enhanced item
				endIf
				PlayerREF.EquipItemById(itemWeapon, a_itemId, 1, equipSound = _silenceEquipSounds)
				_usedRightHand = true
			elseIf (!_usedLeftHand)
				if (a_item == PlayerREF.GetEquippedObject(0) && a_itemId != PlayerREF.GetEquippedItemId(0))
					UnequipHand(0)
				endIf
				PlayerREF.EquipItemById(itemWeapon, a_itemId, 2, equipSound = _silenceEquipSounds)
				_usedLeftHand = true
			endIf

		; It's two-handed and both hands are free
		elseIf (weaponType > 4 && !_usedRightHand && !_usedLeftHand)
			if (a_item == PlayerREF.GetEquippedObject(0) && a_itemId != PlayerREF.GetEquippedItemId(0))
				UnequipHand(0)
			endIf
			PlayerREF.EquipItemById(itemWeapon, a_itemId, equipSlot = 0, equipSound = _silenceEquipSounds)

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
				PlayerREF.EquipItemById(a_item, a_itemId, equipSlot = 0, equipSound = _silenceEquipSounds)
				_usedLeftHand = true
				_usedOutfitMask += slotMask
			endIf
		; It's not a shield, just equip it if slot is free
		elseIf (! LogicalAnd(_usedOutfitMask,slotMask))
			if (a_item == PlayerREF.GetWornForm(slotMask) && a_itemId != PlayerREF.GetWornItemId(slotMask))
				PlayerREF.UnequipItemEx(a_item)
			endIf
			
			PlayerREF.EquipItemById(a_item, a_itemId, equipSlot = 0, equipSound = _silenceEquipSounds)
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

		return true

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
		if (!_usedLeftHand)
			PlayerREF.EquipItemEX(a_item, equipSlot = 0, equipSound = _silenceEquipSounds)
			_usedLeftHand = true
		endIf

		return true
	endIf

	return true
endFunction

function InvalidateItem(int a_itemId, bool redrawIcon = false)
	int index

	; GroupData
	index = _itemIds1.Find(a_itemId)
	if (index != -1)
		_itemInvalidFlags1[index] = true
	endIf

	index = _itemIds2.Find(a_itemId)
	if (index != -1)
		_itemInvalidFlags2[index] = true
	endIf

	; Main hand
	index = _groupMainHandItemIds.Find(a_itemId)
	if (index != -1)
		_groupMainHandItems[index] = none
		_groupMainHandItemIds[index] = 0
	endIf

	; Off hand
	index = _groupOffHandItemIds.Find(a_itemId)
	if (index != -1)
		_groupOffHandItems[index] = none
		_groupOffHandItemIds[index] = 0
	endIf

	; Icon
	index = _groupIconItemIds.Find(a_itemId)
	if (index != -1)
		ReplaceGroupIcon(index)
		if (redrawIcon)
			UpdateMenuGroupData(index)
		endIf
	endIf
endFunction

int function FindFreeIndex(int[] a_itemIds, bool[] a_itemInvalidFlags, int offset)
	int i = a_itemIds.Find(0,offset)
	
	; First try to find an entry that is 0
	if (i >= offset && i < offset + 32)
		return i
	endIf

	; Failed. Now try to claim an entry flagged as invalid.
	i = offset
	int n = offset + 32
	while (i < n)
		if (a_itemInvalidFlags[i])
			return i
		endIf

		i += 1
	endWhile
	
	return -1
endFunction

function ReplaceGroupIcon(int a_groupIndex)

	; If player has MH or OH set for the group, use it first
	if (_groupMainHandItemIds[a_groupIndex])
		_groupIconItems[a_groupIndex] = _groupMainHandItems[a_groupIndex]
		_groupIconItemIds[a_groupIndex] = _groupMainHandItemIds[a_groupIndex]
		return
	elseIf (_groupOffHandItemIds[a_groupIndex])
		_groupIconItems[a_groupIndex] = _groupOffHandItems[a_groupIndex]
		_groupIconItemIds[a_groupIndex] = _groupOffHandItemIds[a_groupIndex]
		return
	endIf

	int offset = a_groupIndex * 32

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] itemIds
	bool[] itemInvalidFlags

	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf

	int i = offset
	int n = offset+32

	; Use icon of first found item
	while (i < n)
		if (items[i] != none && !itemInvalidFlags[i])
			_groupIconItems[a_groupIndex] = items[i]
			_groupIconItemIds[a_groupIndex] = itemIds[i]
			return
		else
			i += 1
		endIf
	endWhile

	_groupIconItems[a_groupIndex] = none
	_groupIconItemIds[a_groupIndex] = 0
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

; utility function to see how many of the form are in a group
int function GetNumFormsInGroup(int a_groupIndex,form a_item)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	form[] items

	if (offset >= 128)
		offset -= 128
		items = _items2
	else
		items = _items1
	endIf

	int i = offset
	int n = offset + 32
	int count
	while (i < n)
		if (items[i] == a_item)
			count += 1
		endIf
		i += 1
	endWhile
	
	return count
endFunction

form function GetFormFromItemId(int a_groupIndex,int itemId)
	int offset = 32 * a_groupIndex
	; Select the target set of arrays, adjust offset
	form[] items
	int[] itemIds
	
	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf

	int i = itemIds.Find(itemId,offset)
	if (i >= offset && i < offset + 32)
		return items[i]
	else
		return none
	endIf
endFunction

; return the Nth itemId
int function GetNthItemIdInGroup(int a_groupIndex,form a_item,int a_num = 1)
	int offset = 32 * a_groupIndex
	; Select the target set of arrays, adjust offset
	form[] items
	int[] itemIds
	
	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf

	int i = offset
	int n = offset + 32
	int count = 0
	
	int result = offset
	while (result >= offset && result < n && count < a_num)
		result = items.Find(a_item,i)
		i = result + 1
		count += 1
	endWhile
	if (result >= offset && result < n)
		return itemIds[result]
	endIf
	return 0
endFunction

; utility function to see if itemId is in the specified group. 
bool function IsItemIdInGroup(int a_groupIndex, int a_itemId)
	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	int[] itemIds

	if (offset >= 128)
		offset -= 128
		itemIds = _itemIds2
	else
		itemIds = _itemIds1
	endIf
	
	int i = itemIds.Find(a_itemId,offset)
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

; DEBUG ------------------------------------------------------------------------------------------

function PrintGroupItems(int a_groupIndex)
	;This is here so I can see what's in the group, because the UI is currently broken
	Debug.Trace("PrintGroupItems called on group " + a_groupIndex)

	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	int[] itemIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf

	int i = offset
	int n = offset + 32
	while (i < n)
		if (items[i])
			Debug.Trace(i + " is " + itemIds[i] + ", form is " + items[i] + ": " + items[i].GetName())
		endIf
		i += 1
	endWhile
	if (_groupIconItemIds[a_groupIndex])
		Debug.Trace("Group icon is " + _groupIconItemIds[a_groupIndex] + ", form is " + _groupIconItems[a_groupIndex] + ": " + _groupIconItems[a_groupIndex].GetName())
	endIf
	if (_groupMainHandItemIds[a_groupIndex])
		Debug.Trace("Group MH is " + _groupMainHandItemIds[a_groupIndex] + ", form is " + _groupMainHandItems[a_groupIndex] + ": " + _groupMainHandItems[a_groupIndex].GetName())
	endIf
	if (_groupOffHandItemIds[a_groupIndex])
		Debug.Trace("Group OH is " + _groupOffHandItemIds[a_groupIndex] + ", form is " + _groupOffHandItems[a_groupIndex] + ": " + _groupOffHandItems[a_groupIndex].GetName())
	endIf
endFunction
