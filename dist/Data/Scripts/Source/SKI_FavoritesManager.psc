scriptname SKI_FavoritesManager extends SKI_QuestBase

import Math


; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		INVENTORY_MENU	= "InventoryMenu" autoReadonly
string property		MENU_ROOT		= "_root.MenuHolder.Menu_mc" autoReadonly

int property		GROUP_FLAG_UNEQUIP_ARMOR	= 	1	autoReadonly
int property		GROUP_FLAG_UNEQUIP_HANDS	= 	2	autoReadonly
int property		GROUP_FLAG_NEEDS_CLEANUP	= 	8	autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

Actor Property		PlayerREF auto
Message property 	SKI_GroupFullMsg auto

bool property		ButtonHelpEnabled	= 	true	auto


; PRIVATE VARIABLES -------------------------------------------------------------------------------

Form[]				_items1
Form[]				_items2
int[]				_itemFormIds1
int[]				_itemFormIds2

int[]				_groupCounts

int[]				_groupFlags

Form[]				_groupMainHandItems
int[]				_groupMainHandFormIds

Form[]				_groupOffHandItems
int[]				_groupOffHandFormIds

Form[]				_groupIconItems
int[]				_groupIconFormIds

int[]				_groupHotkeys

bool 				_useDebug = True
bool				_silenceEquipSounds = False
Bool				_inCleanup = False

SoundCategory		_audioCategoryUI

; Forms to support EquipSlot comparisons
EquipSlot 			_rightHandSlot
EquipSlot 			_eitherHandSlot
EquipSlot 			_leftHandSlot
EquipSlot 			_bothHandsSlot
EquipSlot 			_voiceSlot

Ammo				_dummyArrow

; State variables for Group Use
bool				_usedRightHand		= false
bool				_usedLeftHand		= false
bool				_usedVoice			= false
int					_usedOutfitMask		= 0


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_items1			= new Form[128]
	_items2			= new Form[128]
	_itemFormIds1	= new int[128]
	_itemFormIds2	= new int[128]

	_groupCounts	= new int[8]
	_groupFlags		= new int[8]

	_groupMainHandItems		= new Form[8]
	_groupMainHandFormIds	= new int[8]

	_groupOffHandItems		= new Form[8]
	_groupOffHandFormIds	= new int[8]
	
	_groupIconItems		= new Form[8]
	_groupIconFormIds	= new int[8]

	_groupHotkeys = new int[8]
	_groupHotkeys[0] = 59
	_groupHotkeys[1] = 60
	_groupHotkeys[2] = 61
	_groupHotkeys[3] = 62
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
	_dummyArrow			= Game.GetFormFromFile(0x00052E99, "Skyrim.esm") as Ammo
	
	OnGameReload()

	; DEBUG
	;RegisterForSingleUpdate(5)
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKIFM_groupAdd", "OnGroupAdd")
	RegisterForModEvent("SKIFM_groupRemove", "OnGroupRemove")
	RegisterForModEvent("SKIFM_groupUse", "OnGroupUse")
	RegisterForModEvent("SKIFM_saveEquipState", "OnSaveEquipState")
	RegisterForModEvent("SKIFM_setGroupIcon", "OnSetGroupIcon")
	
	RegisterForMenu(FAVORITES_MENU)
	RegisterForMenu(INVENTORY_MENU)
	
	RegisterHotkeys()

	CleanUp()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	DebugT("OnMenuOpen!")

	if (a_menuName != FAVORITES_MENU)
		return
	endIf

	while (_inCleanUp) ; FIXME: This is probably not the best place to put the spinlock, do I need it in every event?
		Utility.WaitMenuMode(0.1)
	endWhile

	InitMenuGroupData()
	;Switch on button helpers
	UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".enableNavigationHelp", true)
	
	int i = 0
	int cleanedCount = 0
	; The following takes between 0.3s and 0.5s per group
	; Worst case scenario, 8 groups with 32 items each, ~4 seconds
	;DEBUG	
	If _inCleanUp
		DebugT("Already performing a cleanup, skipping it this time!")
		Return
	endIf
	float StartTime = Utility.GetCurrentRealTime()
	_inCleanUp = True ; variable to use for spinlocking, if needed
	while (i < _groupFlags.Length)
		if GetGroupFlag(i,GROUP_FLAG_NEEDS_CLEANUP)
			CleanUpGroup(i)
			SetGroupFlag(i,GROUP_FLAG_NEEDS_CLEANUP,false)
			cleanedCount += 1
		endIf
		i += 1
	endWhile
	_inCleanUp = false
	;DEBUG
	float EndTime = Utility.GetCurrentRealTime()
	DebugT("Cleaned up " + cleanedCount + " groups in " + (EndTime - StartTime))
endEvent

event OnMenuClose(string a_menuName)
	if (a_menuName == INVENTORY_MENU)

	endIf
endEvent

event OnGroupAdd(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	GroupAdd(groupIndex, item)

	UpdateMenuGroupData(groupIndex)
endEvent



event OnGroupRemove(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	GroupRemove(groupIndex, item)

	UpdateMenuGroupData(groupIndex)
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

	event OnMenuClose(string a_menuName)
	endEvent
	
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
	int i=0
	while (i<8)
		result[i] = _groupHotkeys[i]
		i += 1
	endWhile
	return result
endFunction

bool function SetGroupHotkey(int a_groupIndex, int a_keycode)
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
	endIf

	_groupHotkeys[a_groupIndex] = a_keycode

	return true
endFunction

; Send the group data to the UI, so that when the user selects a group, it can filter its entries.
function InitMenuGroupData()
	DebugT("InitMenuGroupData called!")

	; groupCount, mainHandFormId[8], offHandFormId[8], iconFormId[8]
	int[] args = new int[25]
	args[0] = 8

	int c=1

	int i=0
	while (i<8)
		args[c] = _groupMainHandFormIds[i]
		i += 1
		c += 1
	endWhile

	i=0
	while (i<8)
		args[c] = _groupOffHandFormIds[i]
		i += 1
		c += 1
	endWhile
	
	i=0
	while (i<8)
		args[c] = _groupIconFormIds[i]
		i += 1
		c += 1
	endWhile
	
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds1)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds2)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".finishGroupData", args)

	DebugT("InitMenuGroupData end!")
endFunction

function UpdateMenuGroupData(int a_groupIndex)
	DebugT("UpdateMenuGroupData called!")

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

	int i=4
	int j=offset

	while (i<36)
		args[i] = itemFormIds[j]

		i += 1
		j += 1
	endWhile
	
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".updateGroupData", args)

	DebugT("UpdateMenuGroupData end!")
endFunction

; Check for unfavorited items in the group and clean them from the itemlists
function CleanUpGroup(int groupIndex, bool cleanMissing = false)
	DebugT("CleanUpGroup called on group " + groupIndex + ", cleanMissing = " + cleanMissing)
	float StartTime = Utility.GetCurrentRealTime()
	
	Form[] items
	int[] itemFormIDs
	int i
	int offset = 32 * groupIndex
		
	if (offset >= 128)
		offset -= 128
		items = _items2
		itemFormIDs = _itemFormIds2
	else
		items = _items1
		itemFormIDs = _itemFormIds1
	endIf
	
	Form[] invalidItems = new Form[32]
	int invalidIdx 
	int n=offset+32
	while (i < n)
		if (items[i]) ; prevent errors about none
			if (!Game.IsObjectFavorited(items[i])) ; find unfaved items
				invalidItems[invalidIdx] = items[i]
				invalidIdx += 1
			elseIf cleanMissing ;GetItemCount is slow, only do it if we're supposed to
				 if (PlayerRef.GetItemCount(items[i]) == 0)
					invalidItems[invalidIdx] = items[i]
					invalidIdx += 1
				 endif
			endIf
		endIf
		i += 1
	endWhile
	RemoveFormsInArray(invalidItems)
	float EndTime = Utility.GetCurrentRealTime()
	DebugT("Cleaned up " + InvalidIdx + " items in " + (EndTime - StartTime))
endFunction

; Ensure that our data is still valid. Might not be the case if a mod was uninstalled
function CleanUp()
	; Re-count items while checking in the next step
	int i = 0
	while (i < 8)
		_groupCounts[i] = 0
		i += 1
	endWhile

	int groupIndex = 0

	i = 0
	while (i < _items1.length)

		if (_items1[i] == none || _items1[i].GetFormID() == 0)
			_items1[i] = none
			_itemFormIds1[i] = 0
		else
			_groupCounts[groupIndex] = _groupCounts[groupIndex] + 1
		endIf

		if (i % 32 == 31)
			groupIndex += 1
		endIf

		i += 1
	endWhile

	i = 0
	while (i < _items2.length)

		if (_items2[i] == none || _items2[i].GetFormID() == 0)
			_items2[i] = none
			_itemFormIds2[i] = 0
		else
			_groupCounts[groupIndex] = _groupCounts[groupIndex] + 1
		endIf

		if (i % 32 == 31)
			groupIndex += 1
		endIf

		i += 1
	endWhile
endFunction

function GroupAdd(int a_groupIndex, Form a_item)
	; Group already full - play some error sound?
	if (_groupCounts[a_groupIndex] >= 32)
		CleanUpGroup(a_groupIndex, true)
		if (_groupCounts[a_groupIndex] >= 32) ; Nothing could be removed, group is full of valid, favorited items
			return
		endIf
	endIf

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

	; Pick next free slot
	int index = FindFreeIndex(items, offset)
	
	; Store received data
	if (index != -1)
		int formId = a_item.GetFormID()
		items[index] = a_item
		formIds[index] = formId

		_groupCounts[a_groupIndex] = _groupCounts[a_groupIndex] + 1

		; If there's no icon item set yet, use this one
		if (_groupIconItems[a_groupIndex] == none)
			_groupIconItems[a_groupIndex] = a_item
			_groupIconFormIds[a_groupIndex] = formId
		endIf
	endIf
endFunction

function GroupRemove(int a_groupIndex, Form a_item)
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

	Form iconReplacement = none

	int i=offset
	int n=offset+32
	while (i < n)
		if (items[i] == a_item)
			items[i] = none
			formIds[i] = 0
			_groupCounts[a_groupIndex] = _groupCounts[a_groupIndex] - 1			
			i = n
		else
			if (items[i] != none && iconReplacement == none)
				; Pick any != none form as potential icon replacement
				iconReplacement = items[i]
			endIf
			i += 1
		endIf
	endWhile

	if (a_item == _groupIconItems[a_groupIndex])
		_groupIconItems[a_groupIndex] = iconReplacement
		if (iconReplacement)
			_groupIconFormIds[a_groupIndex] = iconReplacement.GetFormID()
		else
			_groupIconFormIds[a_groupIndex] = 0
		endIf
	endIf

	if (a_item == _groupMainHandItems[a_groupIndex])
		_groupMainHandItems[a_groupIndex] = none
		_groupMainHandFormIds[a_groupIndex] = 0
	endIf

	if (a_item == _groupOffHandItems[a_groupIndex])
		_groupOffHandItems[a_groupIndex] = none
		_groupOffHandFormIds[a_groupIndex] = 0
	endIf
endFunction

function GroupUse(int a_groupIndex)
	DebugT("GroupUse!")

	float StartTime
	float EndTime

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
	
	; Unequip hands first?
	if (GetGroupFlag(a_groupIndex,GROUP_FLAG_UNEQUIP_HANDS))
		Form rightHand = PlayerREF.GetEquippedObject(1)
		if (rightHand)
			PlayerREF.UnequipItem(rightHand, abSilent = true)
		endIf

		Form leftHand = PlayerREF.GetEquippedObject(0)
		if (leftHand)
			PlayerREF.UnequipItem(leftHand, abSilent = true)
		endIf
	endIf
	
	; Process main and offhand items first
	Form mainHandItem = _groupMainHandItems[a_groupIndex]
	if (mainHandItem)
		ProcessItem(mainHandItem, mainHandItem.GetType())
	endIf

	Form offHandItem = _groupOffHandItems[a_groupIndex]
	if (offHandItem)
		ProcessItem(offHandItem, offHandItem.GetType())
	endIf
	
	; Turn off UI sounds to avoid annoying clicking noise while swapping spells
	_audioCategoryUI.Mute()

	;DEBUG
	StartTime = Utility.GetCurrentRealTime()

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
			Form wornForm = PlayerRef.GetWornForm(h)
			if (wornForm)
				if (!LogicalAND(h, _usedOutfitMask))
					PlayerREF.UnEquipItemEX(wornForm)
				endIf
			endIf
			h = LeftShift(h,1)
		endWhile
	endIf
	
	_audioCategoryUI.UnMute() ; Turn UI sounds back on

	;DEBUG
	EndTime = Utility.GetCurrentRealTime()
	Debug.Notification("Equip time: " + (EndTime - StartTime))
	
	StartTime = Utility.GetCurrentRealTime()
	DebugT("Checking for invalid items...")
	RemoveFormsInArray(invalidItems)
	EndTime = Utility.GetCurrentRealTime()
	Debug.Trace("Cleanup time: " + (EndTime - StartTime))
	
	DebugT("OnGroupUse end!")
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

bool function ProcessItem(Form a_item, int a_itemType, bool a_allowDeferring = true)

	; WEAPON ------------
	if (a_itemType == 41)

		; Any weapon needs at least one free hand
		if (_usedRightHand && _usedLeftHand)
			return true
		endIf

		Weapon itemWeapon = a_item as Weapon
		int weaponType = itemWeapon.GetweaponType()

		; It's two-handed and both hands are free
		if (weaponType > 4 && !_usedRightHand && !_usedLeftHand)
			PlayerREF.EquipItemEX(itemWeapon, equipSlot = 0, equipSound = _silenceEquipSounds)
			_usedRightHand = true
			_usedLeftHand = true

		; It's one-handed and the player has a free hand
		elseIf (weaponType <= 4)
			if (!_usedRightHand)
				PlayerREF.EquipItemEX(itemWeapon, 1, equipSound = _silenceEquipSounds)
				_usedRightHand = true
			elseIf (!_usedLeftHand)
				PlayerREF.EquipItemEX(itemWeapon, 2, equipSound = _silenceEquipSounds)
				_usedLeftHand = true
			endIf
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

	; SPELL OR SCROLL ------------
	elseIf (a_itemType == 22 || a_itemType == 23) 

		Spell itemSpell = a_item as Spell
		EquipSlot spellEquipSlot = itemSpell.GetEquipType()

		if (spellEquipSlot != _voiceSlot)

			; Any non power spell needs at least one free hand
			if (_usedRightHand && _usedLeftHand)
				return true
			endIf

			; spell is eitherhanded
			if (spellEquipSlot == _eitherHandSlot)
				if (!_usedRightHand)
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

function RemoveFormsInArray(form[] invalidItems)
	int i = 0
	int groupIndex = 0
	form item
	
	while (i < invalidItems.Length)
		item = invalidItems[i]
		If (item)
			DebugT("Cleaning item " + item)
			int itemIdx = _items1.find(item)
			while (itemIdx >= 0)
				DebugT(" Found " + item + " in _items1[" + itemIdx + "], removing it!")
				_items1[itemIdx] = none
				_itemFormIDs1[itemIdx] = 0
				groupIndex = itemIDX / 32
				_groupCounts[groupIndex] = _groupCounts[groupIndex] - 1
				DebugT(" _groupCounts[" + groupIndex + "] is now " + _groupCounts[groupIndex])
				itemIdx = _items1.find(item)
			endWhile
			itemIdx = _items2.find(item)
			while (itemIdx >= 0)
				DebugT(" Found " + item + " in _items2[" + itemIdx + "], removing it!")
				_items2[itemIdx] = none
				_itemFormIDs2[itemIdx] = 0
				groupIndex = (128 + itemIDX) / 32
				_groupCounts[groupIndex] = _groupCounts[groupIndex] - 1
				DebugT(" _groupCounts[" + groupIndex + "] is now " + _groupCounts[groupIndex])
				itemIdx = _items2.find(item)
			endWhile
		endIf
		i += 1
	endWhile
endFunction

int function FindFreeIndex(Form[] a_items, int offset)
	int i = offset
	
	while (i < offset + 32)
		
		if (a_items[i] == none)
			return i
		endIf

		i += 1
	endWhile
	
	return -1
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
	
	int i
	while (i < offset+32)
		if (items[i] == a_item)
			return true
		endIf
		i += 1
	endWhile

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

; DEBUG ---------------------------------------------------------------------------------------

function DebugT(string DebugString)
	if (_useDebug)
		Debug.Trace("SKI_Favs: " + DebugString)
	endIf
endFunction