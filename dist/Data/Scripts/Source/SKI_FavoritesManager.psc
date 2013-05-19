scriptname SKI_FavoritesManager extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		MENU_ROOT		= "_root.Menu_mc" autoReadonly

int property		FAV_FLAG_LISTONLY	= 	0 	AutoReadOnly
int property		FAV_FLAG_ALLOWUSE	= 	1 	AutoReadOnly
int property		FAV_FLAG_EQUIPSET	= 	2 	AutoReadOnly
int property		FAV_FLAG_NOWEAPON	= 	4 	AutoReadOnly
int property		FAV_FLAG_NOARMOR	= 	8 	AutoReadOnly
int property		FAV_FLAG_NOAMMO		= 	16 	AutoReadOnly

; PROPERTIES --------------------------------------------------------------------------------------

Actor Property PlayerREF Auto ; Needed for GetItemCount and EquipItem
SoundCategory Property AudioCategoryUI Auto

; PRIVATE VARIABLES -------------------------------------------------------------------------------

; IMPORTANT NOTE:
; The example implementation here uses arrays. It might also be possible to do the same with
; FormLists much easier, but I have never used them.
;
; SKSE has
;
;	;Sends Form data to Scaleform as a Flash object, FormLists included.
;	Function InvokeForm(string menuName, string target, Form arg) global native
;
; for this.

; Each group gets a fixed portion of the array.
; Assuming 8 groups and a group size of 32 => 2x128 length arrays, because 8x32=256.
; Less arrays means less function calls we need to pass the group data to the UI for synchronization.
; This improves responsiveness. Assuming a group size of 16, everything would fit into a single array.
; On the other hand, 16 entries might be too restrictive for the user.
; So we have to balance this out.

Form[]		_items1
Form[]		_items2

; These are to know which type each generic Form has. I'm sure there's some way to get the formtype directly from the item, so we can probably get rid of those.
string[]	_typeDescriptors1
string[]	_typeDescriptors2

; There is the problem that we have to send the group data to the UI, and we cannot send Form[] arrays,
; only primitive array types like int[].
; Because of that we keep the formIds around separately (so it is always formIdsX[i] == itemsX[i].GetFormID())
; With FormLists, we would not have this problem. So again, it is worth investigating as an alternative approach.
int[]		_formIds1
int[]		_formIds2

int[]		_groupCounts

; index is 0-7 for groups
; Flags: 
;   0 = Standard list, Disallow group use
;   1 = Allow group use
;   2 = Act like equipment set (unequip any gear not in the group)
;   4 = Don't remove equipped Weapons or Spells
;   8 = Don't remove equipped Armor
;  16 = Don't remove equipped Ammo
int[]		_groupFlags

bool 		_useDebug = True
bool		_silenceEquipSounds = False

; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	DebugT("OnInit!")
	_items1				= new Form[128]
	_items2				= new Form[128]
	_typeDescriptors1	= new string[128]
	_typeDescriptors2	= new string[128]
	_formIds1			= new int[128]
	_formIds2			= new int[128]

	_groupCounts		= new int[8]

	OnGameReload()

	; DEBUG
	RegisterForSingleUpdate(5)
	DebugT("OnInit End!")
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	DebugT("OnGameReload!")
	; We re-register after each reload instead of only once in OnInit()
	; in case SKSE is removed and the registerations have to be refreshed.
	RegisterForModEvent("SKIFM_groupAdded", "OnGroupAdd")
	RegisterForModEvent("SKIFM_groupRemoved", "OnGroupRemove")
	RegisterForModEvent("SKIFM_groupUsed", "OnGroupUse")

	CleanUp()
	DebugT("OnGameReload End!")
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnGroupAdd(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	DebugT("OnGroupAdd!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)
	
	Form	item = a_sender
	string	typeDescriptor = a_strArg
	int		groupIndex = a_numArg as int

	; Group already full - play some error sound?
	if (_groupCounts[groupIndex] >= 32)
		return
	endIf

	int offset = 32 * groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	string[] typeDescriptors
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		typeDescriptors = _typeDescriptors2
		formIds = _formIds2
	else
		items = _items1
		typeDescriptors = _typeDescriptors1
		formIds = _formIds1
	endIf

	; Pick next free slot
	int index = FindFreeIndex(items, offset)

	; Store received data
	if (index != -1)
		items[index] = item
		typeDescriptors[index] = typeDescriptor
		formIds[index] = item.GetFormID()

		_groupCounts[groupIndex] = _groupCounts[groupIndex] + 1
	endIf
	DebugT("OnGroupAdd end!")
endEvent

event OnGroupRemove(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	DebugT("OnGroupRemove!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)

	; This index treats the arrays as one big 256 length array
	int itemIndex = a_numArg as Int
	int groupIndex = (itemIndex / 32) as int

	; Select the target set of arrays, adjust index
	Form[] items
	string[] typeDescriptors
	int[] formIds

	if (itemIndex >= 128)
		itemIndex -= 128
		items = _items2
		typeDescriptors = _typeDescriptors2
		formIds = _formIds2
	else
		items = _items1
		typeDescriptors = _typeDescriptors1
		formIds = _formIds1
	endIf

	items[itemIndex] = none
	typeDescriptors[itemIndex] = ""
	formIds[itemIndex] = 0
	_groupCounts[groupIndex] = _groupCounts[groupIndex] - 1
	DebugT("OnGroupRemove end!")
endEvent

event OnGroupUse(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	DebugT("OnGroupUse!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)

	int groupIndex = a_numArg as int

	int offset = 32 * groupIndex

	; Select the target set of arrays, adjust offset
	Form[] items
	string[] typeDescriptors
	int[] formIds

	if (offset >= 128)
		offset -= 128
		items = _items2
		typeDescriptors = _typeDescriptors2
		formIds = _formIds2
	else
		items = _items1
		typeDescriptors = _typeDescriptors1
	endIf

	
	Form item
	Int itemType
	Int itemCount
	Int handSlot = 1
	Int ringSlot
	int i = offset
	AudioCategoryUI.Mute() ; Turn off UI sounds to avoid annoying clicking noise while swapping spells
	while (i < offset+32)
		item = items[i]
		itemCount = 0

		If item ;prevent logspam if item is none
			DebugT("items[" + i + "] is " + item)
			itemType = item.GetType()
			DebugT(item.GetName() + " is Type " + itemType)
			
			If itemType == 22 || itemType == 119 ; This is a Spell or Shout and can't be counted like an item
				If PlayerREF.HasSpell(item)
					itemCount = 1
				EndIf
			Else ; This is an inventory item
				itemCount = PlayerREF.GetItemCount(item) 
			EndIf
		EndIf
		If item != None && itemCount ;Item exists and player has at least one of it
			If itemType == 41 ;kWeapon
				Int WeaponType = (item as Weapon).GetWeaponType()
				DebugT(item + " is WeaponType " + WeaponType)
				If WeaponType > 4 && handSlot == 1; It's two-handed and both hands are free
					; use SKSE EquipItemEX which hopefully avoids the enchantment bug and lets us pick the hand
					PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
					handSlot += 2
					DebugT("Equipped " + item.GetName() + " in both hands!")
				ElseIf WeaponType <= 4 && handSlot < 3 ; It's one-handed and the player has a free hand
					PlayerREF.EquipItemEX(item, equipSlot = handSlot, equipSound = _silenceEquipSounds)
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				Else
					DebugT("Player tried to equip " + item.GetName() + " but doesn't have a free hand!")
				EndIf
			ElseIf itemType == 26 ;kArmor
				Int SlotMask = (item as Armor).GetSlotMask()
				DebugT(item + " has armor SlotMask " + SlotMask)
				If SlotMask == 512 && handSlot > 2; It's a shield but player's left hand is already full
					DebugT("Player tried to equip shield " + item.GetName() + " but doesn't have a free left hand!")
				Else
					PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
					DebugT("Equipped " + item.GetName() + "!")
				EndIf
			ElseIf itemType == 42 ;kAmmo
				PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
				DebugT("Equipped " + item.GetName() + "!")
			ElseIf itemType == 22 ;kSpell
				DebugT("Equipping " + item.GetName() + "...")
				If item == item as Spell
					DebugT("Item is the same as its spell version!")
				Else ; test to see if maybe powers act differently because their default type is Form, rather than Spell
					DebugT("Item is NOT THE SAME as its spell version!")
				EndIf
				;This is annoying. Since there's apparently no way to get a spell's EquipType (i.e. right/left/both/power), we have to use trial and error
				Spell powerSpell = PlayerREF.GetEquippedSpell(2) ; Save currently equipped Power
				PlayerREF.EquipSpell(item as Spell,2) ; Try to equip the spell as a Power
				Bool SpellFound = False
				If PlayerREF.GetEquippedSpell(2) == item as Spell ; Spell equipped as Power/Shout
					DebugT("Equipped " + item.GetName() + " as Power/Shout!")
					SpellFound = True
				ElseIf PlayerREF.GetEquippedSpell(3) == item as Spell ; Spell went.. somewhere else?
					DebugT("Equipped " + item.GetName() + " as Instant(?)!")
					SpellFound = True
				EndIf
				If !SpellFound ; Spell failed to equip as a Power, so it must be a handed Spell
					If powerSpell ; Restore equipped Power, as it will have been removed by the failed attempt
						PlayerREF.EquipSpell(powerSpell,2) 
					EndIf
					If handSlot == 1 ; Both hands are free
						PlayerREF.EquipSpell(item as Spell,1) ; Try to equip the spell in right hand
					ElseIf handSlot == 2 ; Left hand is free
						PlayerREF.EquipSpell(item as Spell,0) ; Try to equip the spell in left hand
					EndIf
				EndIf
				; The following are separate If statements so if the spell took up both hands, we know both hands are full
				If PlayerREF.GetEquippedSpell(1) == item as Spell ; Spell took up the right hand
					SpellFound = True
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				EndIf
				If PlayerREF.GetEquippedSpell(0) == item as Spell ; Spell took up the left hand
					SpellFound = True
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				EndIf
				If !SpellFound
					DebugT("Spell " + item.GetName() + " was not equipped, probably had no free hands!")
				EndIf
			ElseIf itemType == 119 ;kShout
				PlayerREF.EquipShout(item as Shout)
				DebugT("Equipped " + item.GetName() + " as a Shout!")
			EndIf
		ElseIf !item
			DebugT("items[" + i + "] is none!")
		ElseIf !itemCount
			DebugT("Player tried to equip " + item.GetName() + " but doesn't have one!")
		Else
			DebugT("Something totally weird happened on items[" + i + "]!")
		EndIf

		i += 1
	endWhile
	AudioCategoryUI.Mute() ; Turn UI sounds back on
	DebugT("OnGroupUse end!")
endEvent

event OnMenuOpen(string a_menuName)
	DebugT("OnMenuOpen!")
	SynchronizeGroupData()
endEvent

event OnGroupFlag(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	; Just remembered that the mod event only supports a single numberic argument as per Schlangster
	; Fortunately strings be coerced into ints. 
	DebugT("OnGroupFlag!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)
	
	Form	item = a_sender
	int		flags = a_strArg as Int
	int		groupIndex = a_numArg as int

	_groupFlags[groupIndex] = flags
	
	DebugT("OnGroupFlag end!")
EndEvent

; FUNCTIONS ---------------------------------------------------------------------------------------

; Send the group data to the UI, so that when the user selects a group, it can filter its entries.
function SynchronizeGroupData()
	DebugT("SynchronizeGroupData called!")
	UI.InvokeInt(FAVORITES_MENU, MENU_ROOT + ".initGroupData", 32)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupData", _formIds1)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupData", _formIds2)
	UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".commitGroupData", true)

	; The UI has a full list of all favorite entries at this point, including their formIds.
	; For each formId it receives here, it can lookup the respective entry and mark it.
	DebugT("SynchronizeGroupData end!")
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
			_typeDescriptors1[i] = ""
			_formIds1[i] = 0
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
			_typeDescriptors2[i] = ""
			_formIds2[i] = 0
		else
			_groupCounts[groupIndex] = _groupCounts[groupIndex] + 1
		endIf

		if (i % 32 == 31)
			groupIndex += 1
		endIf

		i += 1
	endWhile

	; TODO - what to do with items that are no longer in the player inventory?
	; We have to find an efficient method to detect and remove them.
	DebugT("Cleanup end!")
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


; DEBUG ---------------------------------------------------------------------------------------

Function DebugT(string DebugString)
	If _useDebug
		Debug.Trace("SKI_Favs: " + DebugString)
	EndIf
EndFunction

event OnUpdate()
	DebugT("onUpdate!")
	
	; For testing
	Form myForm ; = ...
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Weapon1)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Weapon2)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Weapon1)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Armor2)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Armor1)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Ring1)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Ring2)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Ring3)
	;OnGroupAdd("SKIFM_groupAdded", "weapon", 0, Ring4)

	;OnGroupUse("SKIFM_groupAdded", "", 0, none)
	DebugT("onUpdate end!")
endEvent

Bool Function CheckFlag(Int group, Int flag)
	Return Math.LogicalAnd(_groupFlags[group],flag) as Bool
EndFunction

Function ParseFlags(Int Flags)
	DebugT("Flags: " + Flags)
	If Math.LogicalAnd(Flags,FAV_FLAG_ALLOWUSE)
		DebugT(" FAV_FLAG_ALLOWUSE")
	EndIf
	If Math.LogicalAnd(Flags,FAV_FLAG_EQUIPSET)
		DebugT(" FAV_FLAG_EQUIPSET")
	EndIf
	If Math.LogicalAnd(Flags,FAV_FLAG_NOWEAPON)
		DebugT(" FAV_FLAG_NOWEAPON")
	EndIf
	If Math.LogicalAnd(Flags,FAV_FLAG_NOARMOR)
		DebugT(" FAV_FLAG_NOARMOR")
	EndIf
	If Math.LogicalAnd(Flags,FAV_FLAG_NOAMMO)
		DebugT(" FAV_FLAG_NOAMMO")
	EndIf
EndFunction

