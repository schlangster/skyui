scriptname SKI_FavoritesManager extends SKI_QuestBase

import Math


; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		MENU_ROOT		= "_root.MenuHolder.Menu_mc" autoReadonly

int property		GROUP_FLAG_UNEQUIP_ARMOR	= 	1	autoReadonly
int property		GROUP_FLAG_UNEQUIP_HANDS	= 	2	autoReadonly
int property		GROUP_FLAG_UNEQUIP_AMMO		= 	4	autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

bool property		ButtonHelpEnabled	= 	true	auto

Actor Property		PlayerREF auto
Message property	SKI_GroupFullMsg auto


; PRIVATE VARIABLES -------------------------------------------------------------------------------

Form[]				_items1
Form[]				_items2
int[]				_itemFormIds1
int[]				_itemFormIds2

int[]				_groupCounts

; index is 0-7 for groups
; Flags: 
;   0 = Standard list, Disallow group use
;   1 = Allow group use
;   2 = Act like equipment set (unequip any gear not in the group)
;   4 = Don't remove equipped Weapons or Spells
;   8 = Don't remove equipped Armor
;  16 = Don't remove equipped Ammo
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

SoundCategory		_audioCategoryUI

; Forms to support EquipSlot comparisons
EquipSlot 			_rightHandSlot
EquipSlot 			_eitherHandSlot
EquipSlot 			_leftHandSlot
EquipSlot 			_bothHandsSlot
EquipSlot 			_voiceSlot


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
	
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKIFM_groupAdd", "OnGroupAdd")
	RegisterForModEvent("SKIFM_groupRemove", "OnGroupRemove")
	RegisterForModEvent("SKIFM_groupUse", "OnGroupUse")
	RegisterForModEvent("SKIFM_saveEquipState", "OnSaveEquipState")
	RegisterForModEvent("SKIFM_setGroupIcon", "OnSetGroupIcon")
	
	RegisterForMenu(FAVORITES_MENU)

	RegisterHotkeys()

	CleanUp()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	InitMenuGroupData()

	;Switch on button helpers:
	UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".enableNavigationHelp", true) 
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
	int		groupIndex = a_numArg as int

	SaveEquipState(groupIndex)

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

function GroupAdd(int a_groupIndex, Form a_item)
	; Group already full - play some error sound?
	if (_groupCounts[a_groupIndex] >= 32)
		SKI_GroupFullMsg.Show()
		UpdateMenuGroupData(a_groupIndex)
		return
	endIf

	; Don't have to add twice
	if (IsFormInGroup(a_groupIndex, a_item))
		UpdateMenuGroupData(a_groupIndex)
		return
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
		_groupIconFormIds[a_groupIndex] = iconReplacement.GetFormID()
	endIf

	if (a_item == _groupMainHandItems[a_groupIndex])
		_groupMainHandItems[a_groupIndex] = none
		_groupMainHandFormIds[a_groupIndex] = 0
	endIf
endFunction

function GroupUse(int a_groupIndex)
	DebugT("GroupUse!")

	int offset = 32 * a_groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	string[] typeDescriptors
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	Form[] deferredItems = new Form[32]
	int deferredIdx
	
	Form item
	Form itemMH
	Form itemOH
	
	Form rHandItem
	Form lHandItem
	Form voiceItem

	int outFitSlot
	int itemType
	int itemCount
	;int handSlot = 1
	int ringSlot
	int i = offset
	int j
	
	bool mhProcessed = false
	itemMH = _groupMainHandItems[a_groupIndex]
	itemOH = _groupOffHandItems[a_groupIndex]
	
	Form[] sortedItems = new Form[32]
	sortedItems[0] = itemMH
	sortedItems[1] = itemOH
	j = 2
	while (i < offset+32)
		if (items[i] != itemMH) && (items[i] != itemOH)
			sortedItems[j] = items[i]
			j += 1
		endIf
		i += 1
	endWhile
	
	_audioCategoryUI.Mute() ; Turn off UI sounds to avoid annoying clicking noise while swapping spells
	i = 0
	while (i < sortedItems.Length)
		item = sortedItems[i]
		itemCount = 0
		if (item) ;prevent logspam if item is none
			DebugT("sortedItems[" + i + "] is " + item)
			itemType = item.GetType()
			DebugT(item.GetName() + " is Type " + itemType)
			
			if (itemType == 22 || itemType == 119) ; This is a Spell or Shout and can't be counted like an item
				if (PlayerREF.HasSpell(item))
					itemCount = 1
				endIf
			else ; This is an inventory item
				itemCount = PlayerREF.GetItemCount(item) 
			endIf
		endIf

		if (item != None && itemCount) ;Item exists and player has at least one of it
			if (itemType == 41) ;kWeapon
				Weapon itemW = item as Weapon
				int WeaponType = itemW.GetWeaponType()
				DebugT(item + " is WeaponType " + WeaponType)
				; DebugT("EquipType of " + itemW.GetName() + " is " + itemW.GetEquipType()) ; Note, this function does not exist
				if (WeaponType > 4) && !rHandItem && !lHandItem ; It's two-handed and both hands are free
					; use SKSE EquipItemEX which hopefully avoids the enchantment bug and lets us pick the hand
					PlayerREF.EquipItemEX(itemW, equipSlot = 0, equipSound = _silenceEquipSounds)
					DebugT("Equipped " + itemW.GetName() + " in both hands!")
					rHandItem = itemW
					lHandItem = rHandItem
				elseIf (WeaponType <= 4) && (!rHandItem || !lHandItem) ; It's one-handed and the player has a free hand
					If PlayerREF.GetItemCount(itemW) > 1 && !rHandItem && !lHandItem ; Player has at least two of these and two free hands, so dual-wield them
						; For some reason if we don't call EquipItemEX sequentially, the second one fails sometimes
						; Equipping the left hand first seems to prevent this
						PlayerREF.EquipItemEX(itemW, equipSlot = 2, equipSound = _silenceEquipSounds)
						PlayerREF.EquipItemEX(itemW, equipSlot = 1, equipSound = _silenceEquipSounds)
						;double-check it
						if PlayerREF.GetEquippedWeapon(abLeftHand = true) != item || PlayerREF.GetEquippedWeapon(abLeftHand = false) != item
							DebugT("Equip to dual hand failed, retrying...")
							PlayerREF.UnEquipItemEX(itemW, equipSlot = 1)
							PlayerREF.UnEquipItemEX(itemW, equipSlot = 2)
							PlayerREF.EquipItemEX(itemW as Weapon, equipSlot = 2, equipSound = _silenceEquipSounds)
							PlayerREF.EquipItemEX(itemW as Weapon, equipSlot = 1, equipSound = _silenceEquipSounds)
						endIf
						DebugT("Equipped " + itemW.GetName() + " in each hand (dual wielding)!")
						rHandItem = itemW
						lHandItem = rHandItem
					Else ; Player only has one, or only has one free hand
						If !rHandItem
							PlayerREF.EquipItemEX(itemW, 1, equipSound = _silenceEquipSounds)
							rHandItem = itemW
							DebugT("Equipped " + itemW.GetName() + " in Rhand!")
						ElseIf !lHandItem
							PlayerREF.EquipItemEX(itemW, 2, equipSound = _silenceEquipSounds)
							lHandItem = itemW
							DebugT("Equipped " + itemW.GetName() + " in Lhand!")
						EndIf
					EndIf
				else
					DebugT("Player tried to equip " + itemW.GetName() + " but doesn't have a free hand!")
				endIf
			elseIf (itemType == 26) ;kArmor
				int SlotMask = (item as Armor).GetSlotMask()
				DebugT(item + " has armor SlotMask " + SlotMask)
				if (SlotMask == 512) ; It's a shield... 
					If (!lHandItem) ; ... and player's left hand is empty. What luck!
						PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
						lHandItem = item
						DebugT("Equipped " + item.GetName() + " in Lhand!")
						outfitSlot += SlotMask
					Else ; ... player's left hand is already full, too bad :(
						DebugT("Player tried to equip shield " + item.GetName() + " but doesn't have a free left hand!")
					EndIf
				else ; It's not a shield, just equip it
					PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
					outfitSlot += SlotMask
					DebugT("Equipped " + item.GetName() + "!")
				endIf
			elseIf (itemType == 42) ;kAmmo
				PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
				DebugT("Equipped " + item.GetName() + "!")
			elseIf (itemType == 22 || itemType == 23) ;kSpell or kScroll, should work the same way.
				DebugT("Equipping " + item.GetName() + "...")
				Spell itemSpell = item as Spell
				DebugT("EquipType of " + itemSpell.GetName() + " is " + itemSpell.GetEquipType())
				EquipSlot spellEquipSlot = itemSpell.GetEquipType()
				If spellEquipSlot == _eitherHandSlot ; spell is eitherhanded
					If !rHandItem
						PlayerREF.EquipSpell(itemSpell, 1)
						rHandItem = item
						DebugT("Equipped " + itemSpell.GetName() + " in Rhand!")
					ElseIf !lHandItem
						PlayerREF.EquipSpell(itemSpell, 0)
						lHandItem = item
						DebugT("Equipped " + itemSpell.GetName() + " in Lhand!")
					Else
						DebugT("Player tried to equip " + itemSpell.GetName() + " but doesn't have a free hand!")
					EndIf
				ElseIf spellEquipSlot == _bothHandsSlot ; Spell requires two hands ...
					If !rHandItem && !lHandItem ; .. and Player has both hands free
						PlayerREF.EquipSpell(itemSpell, 1)
						rHandItem = item
						lHandItem = rHandItem
					Else
						DebugT("Player tried to equip " + itemSpell.GetName() + " but doesn't two free hands!")
					EndIf
				ElseIf spellEquipSlot == _leftHandSlot ; a lot of NPC spells are left-hand only, so if the player is using PSB they'll need this
					If !lHandItem
						PlayerREF.EquipSpell(itemSpell, 0)
						lHandItem = item
						DebugT("Equipped " + itemSpell.GetName() + " in Lhand!")
					Else
						DebugT("Player tried to equip Lhand-only spell " + itemSpell.GetName() + " but doesn't have a free Lhand!")
					EndIf
				ElseIf spellEquipSlot == _voiceSlot
					If !voiceItem
						PlayerREF.EquipSpell(itemSpell, 2)
						DebugT("Equipped " + itemSpell.GetName() + " as a Power!")
						voiceItem = item
					Else
						DebugT("Player tried to equip Power " + itemSpell.GetName() + " but the shout/power slot is already full!")
					EndIf
				EndIf
			elseIf (itemType == 119) ;kShout
				If !voiceItem
					PlayerREF.EquipShout(item as Shout)
					DebugT("Equipped " + item.GetName() + " as a Shout!")
					voiceItem = item
				Else
					DebugT("Player tried to equip Shout " + item.GetName() + " but the shout/power slot is already full!")
				EndIf
			elseIf (itemType == 46) ;kPotion
				if ((item as Potion).IsHostile()) ; This is a poison and should only be applied after new weapons have been equipped.
					deferredItems[deferredIdx] = item
					deferredIdx += 1
					DebugT("Deferred " + item.GetName() + " as a Poison!")
				else ; This is a non-hostile potion, food, or... something? and can be used immediately
					PlayerREF.EquipItem(item as Potion, abSilent = True)
					DebugT("Consumed " + item.GetName() + " as a Potion/Food!")
				endIf
			elseIf (itemType == 30) ;kIngredient
				PlayerREF.EquipItem(item as Ingredient, abSilent = True)
				DebugT("Consumed " + item.GetName() + " as a Ingredient!")
			elseIf (itemType == 31) ;kLight, hopefully a torch.
				;Should be equipped last, as it depends on having the left hand free
				deferredItems[deferredIdx] = item
				deferredIdx += 1
				DebugT("Deferred " + item.GetName() + " as a Light!")
			endIf
		elseIf (!item)
			;DebugT("items[" + i + "] is none!")
		elseIf (!itemCount)
			DebugT("Player tried to equip " + item.GetName() + " but doesn't have one!")
		else
			DebugT("WARNING! Something totally weird happened on items[" + i + "]!")
		endIf
		i += 1
	endWhile
	
	i = 0

	DebugT("Checking for deferred items...")

	while (i < deferredIdx)
		item = deferredItems[i]
		itemType = item.GetType()

		if (itemType == 46) ; kPotion which, since it was deferred, should be hostile, aka poison.
			; This will fail if a poisonable weapon is only equipped in the offhand. That's a Skyrim bug, not my bug.
			DebugT("Consuming deferred item " + i + ", " + item.GetName())
			PlayerREF.EquipItem(deferredItems[i], abSilent = True)
		elseIf (itemType == 31) ; kLight, probably a torch, which needs the left hand free
			if (!lHandItem) ; Left hand is free
				PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
				DebugT("Equipped deferred item " + item.GetName())
				lHandItem = item
			else
				DebugT("Player tried to equip light " + item.GetName() + " but doesn't have a free left hand!")
			endIf
		else ; Some other deferred item. 
			DebugT("Equipping deferred item " + i + ", " + item.GetName())
			PlayerREF.EquipItem(deferredItems[i], abSilent = True)
		endIf

		i += 1
	endWhile

	DebugT("Checking for one handed spell that should be dual-wielded...")
	If rHandItem ; check for none first to avoid logspam
		If rHandItem.GetType() == 22 && !lHandItem && !PlayerREF.GetEquippedSpell(0); Player has a spell equipped in the right hand, left is empty
			PlayerREF.EquipSpell(rHandItem as Spell,0) ; Equip empty left hand with a copy of right hand spell
			DebugT("Equipped " + rHandItem.GetName() + " in left hand for dual-wielding!")
		EndIf
	EndIf

	If GetGroupFlag(a_groupIndex,GROUP_FLAG_UNEQUIP_ARMOR)
		int h = 0x00000001
		Form aRemove
		While h < 0x80000000
			DebugT("Checking slot " + h)
			aRemove = PlayerRef.GetWornForm(h) ;as Armor
			if aRemove
				DebugT(" Found " + aRemove.GetName() + "!")
				If !LogicalAND(h,outfitSlot)
					DebugT("  Doesn't fit outfitSlot, removing it!")
					PlayerREF.UnEquipItemEX(aRemove)
				EndIf
			EndIf
			h = LeftShift(h,1)
		EndWhile
	EndIf
	
	_audioCategoryUI.UnMute() ; Turn UI sounds back on
	DebugT("rHandItem: " + rHandItem + ", lHandItem: " + lHandItem + ", voiceItem: " + voiceItem)
	DebugT("outfitSlot: " + outfitSlot)
	DebugT("OnGroupUse end!")
endFunction

function SaveEquipState(int a_groupIndex)
	form[] handItems = new Form[2]
	
	;Apparently there's no GetEquippedForm(aiHand), so we have to get the type first then use the right function
	; Lame!
	Int aiHand = 0
	
	while aiHand < 2
		int itemType = PlayerREF.GetEquippedItemType(aiHand)
		if (aiHand == 0) ; Shields are left-handed only
			handItems[aiHand] = PlayerREF.GetEquippedShield()
		endIf
		if (!handItems[aiHand]) ;No shield found, check for a weapon
			handItems[aiHand] = PlayerREF.GetEquippedWeapon(!(aiHand as bool)) ; abLeftHand is a bool. Dumb.
		endIf
		if (!handItems[aiHand]) ;No weapon found, check for a spell
			handItems[aiHand] = PlayerREF.GetEquippedSpell(aiHand)
		endIf
		debugt("Found " + handItems[aiHand] + " in hand " + aiHand)

		;Sadly, there doesn't seem to be able to be a method to detect what light/torch form is equipped, only whether there IS one equipped
		
		if (handItems[aiHand]) ; check for none to avoid logspam
			if !IsFormInGroup(a_groupIndex, handItems[aiHand]) ; see if equipped item is in the group
				DebugT(handItems[aiHand].GetName() + " is equipped but is not in the current group!")
				handItems[aiHand] = None
			endIf
		endIf
		aiHand += 1
	endWhile

	_groupMainHandItems[a_groupIndex] = handItems[1]
	if handItems[1] 
		_groupMainHandFormIDs[a_groupIndex] = handItems[1].GetFormID()
	else ; set formid to 0 if none
		_groupMainHandFormIDs[a_groupIndex] = 0
	endIf
	
	_groupOffHandItems[a_groupIndex] = handItems[0]
	if handItems[0] 
		_groupOffHandFormIDs[a_groupIndex] = handItems[0].GetFormID()
	else ; set formid to 0 if none
		_groupOffHandFormIDs[a_groupIndex] = 0
	endIf
endFunction

; Ensure that our data is still valid. Might not be the case if a mod was uninstalled
function CleanUp()
	DebugT("Cleanup called!")
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

int function FindFreeIndex(Form[] a_items, int offset)
	DebugT("FindFreeIndex called!")
	DebugT("  a_items: " + a_items)
	DebugT("  offset: " + offset)
	int i = offset
	
	while (i < offset + 32)
		if (a_items[i] == none)
			return i
		endIf
		i += 1
	endWhile
	
	return -1

	DebugT("FindFreeIndex end!")
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