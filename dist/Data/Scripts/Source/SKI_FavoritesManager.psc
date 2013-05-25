scriptname SKI_FavoritesManager extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		MENU_ROOT		= "_root.MenuHolder.Menu_mc" autoReadonly

int property		FAV_FLAG_LISTONLY	= 	0	autoReadonly
int property		FAV_FLAG_ALLOWUSE	= 	1	autoReadonly
int property		FAV_FLAG_EQUIPSET	= 	2	autoReadonly
int property		FAV_FLAG_NOWEAPON	= 	4	autoReadonly
int property		FAV_FLAG_NOARMOR	= 	8	autoReadonly
int property		FAV_FLAG_NOAMMO		= 	16 	autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

Actor Property		PlayerREF Auto ; Needed for GetItemCount and EquipItem


; PRIVATE VARIABLES -------------------------------------------------------------------------------

Form[]				_items1
Form[]				_items2
int[]				_itemFormIds1
int[]				_itemFormIds2
int[]				_itemFlags1
int[]				_itemFlags2

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

bool 				_useDebug = True
bool				_silenceEquipSounds = False

SoundCategory		_audioCategoryUI


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_items1			= new Form[128]
	_items2			= new Form[128]
	_itemFormIds1	= new int[128]
	_itemFormIds2	= new int[128]
	_itemFlags1		= new int[128]
	_itemFlags2		= new int[128]

	_groupCounts	= new int[8]
	_groupFlags		= new int[8]

	_audioCategoryUI = Game.GetFormFromFile(0x00064451, "Skyrim.esm") as SoundCategory

	OnGameReload()

	; DEBUG
	;RegisterForSingleUpdate(5)
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKIFM_groupAdded", "OnGroupAdd")
	RegisterForModEvent("SKIFM_groupRemoved", "OnGroupRemove")
	RegisterForModEvent("SKIFM_groupUsed", "OnGroupUse")

	RegisterForMenu(FAVORITES_MENU)

	CleanUp()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnGroupAdd(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	DebugT("OnGroupAdd!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)
	
	Form	item = a_sender
	int		groupIndex = a_numArg as int

	; Group already full - play some error sound?
	if (_groupCounts[groupIndex] >= 32)
		return
	endIf

	int offset = 32 * groupIndex

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
		items[index] = item
		formIds[index] = item.GetFormID()

		_groupCounts[groupIndex] = _groupCounts[groupIndex] + 1
	endIf

	UpdateMenuGroupData(groupIndex)

	DebugT("OnGroupAdd end!")
endEvent

event OnGroupRemove(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	DebugT("OnGroupRemove!")
	DebugT("  a_eventName: " + a_eventName)
	DebugT("  a_strArg: " + a_strArg)
	DebugT("  a_numArg: " + a_numArg)
	DebugT("  a_sender: " + a_sender)

	; This index treats the arrays as one big 256 length array
	int itemIndex = a_numArg as int
	int groupIndex = (itemIndex / 32) as int

	; Select the target set of arrays, adjust index
	Form[] items
	string[] typeDescriptors
	int[] formIds

	if (itemIndex >= 128)
		itemIndex -= 128
		items = _items2
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	items[itemIndex] = none
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
		formIds = _itemFormIds2
	else
		items = _items1
		formIds = _itemFormIds1
	endIf

	Form[] deferredItems = new Form[32]
	int deferredIdx
	
	Form item
	int itemType
	int itemCount
	int handSlot = 1
	int ringSlot
	int i = offset

	_audioCategoryUI.Mute() ; Turn off UI sounds to avoid annoying clicking noise while swapping spells

	while (i < offset+32)
		item = items[i]
		itemCount = 0

		if (item) ;prevent logspam if item is none
			DebugT("items[" + i + "] is " + item)
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
				int WeaponType = (item as Weapon).GetWeaponType()
				DebugT(item + " is WeaponType " + WeaponType)
				if (WeaponType > 4 && handSlot == 1) ; It's two-handed and both hands are free
					; use SKSE EquipItemEX which hopefully avoids the enchantment bug and lets us pick the hand
					PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
					handSlot += 2
					DebugT("Equipped " + item.GetName() + " in both hands!")
				elseIf (WeaponType <= 4 && handSlot < 3) ; It's one-handed and the player has a free hand
					PlayerREF.EquipItemEX(item, equipSlot = handSlot, equipSound = _silenceEquipSounds)
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				else
					DebugT("Player tried to equip " + item.GetName() + " but doesn't have a free hand!")
				endIf
			elseIf (itemType == 26) ;kArmor
				int SlotMask = (item as Armor).GetSlotMask()
				DebugT(item + " has armor SlotMask " + SlotMask)
				if (SlotMask == 512 && handSlot > 2) ; It's a shield but player's left hand is already full
					DebugT("Player tried to equip shield " + item.GetName() + " but doesn't have a free left hand!")
				else
					PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
					DebugT("Equipped " + item.GetName() + "!")
				endIf
			elseIf (itemType == 42) ;kAmmo
				PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
				DebugT("Equipped " + item.GetName() + "!")
			elseIf (itemType == 22 || itemType == 23) ;kSpell or kScroll, should work the same way.
				DebugT("Equipping " + item.GetName() + "...")
				if (item == item as Spell)
					DebugT("Item is the same as its spell version!")
				else ; test to see if maybe powers act differently because their default type is Form, rather than Spell
					DebugT("Item is NOT THE SAME as its spell version!")
				endIf
				;This is annoying. Since there's apparently no way to get a spell's EquipType (i.e. right/left/both/power), we have to use trial and error
				;FIXME: A future revision of SKSE will be adding a way to get the EquipType from a spell, so this can be fixed whenever it comes out.
				Spell powerSpell = PlayerREF.GetEquippedSpell(2) ; Save currently equipped Power
				PlayerREF.EquipSpell(item as Spell,2) ; Try to equip the spell as a Power
				Bool SpellFound = False
				if (PlayerREF.GetEquippedSpell(2) == item as Spell) ; Spell equipped as Power/Shout
					DebugT("Equipped " + item.GetName() + " as Power/Shout!")
					SpellFound = True
				elseIf (PlayerREF.GetEquippedSpell(3) == item as Spell) ; Spell went.. somewhere else?
					DebugT("Equipped " + item.GetName() + " as Instant(?)!")
					SpellFound = True
				endIf
				if (!SpellFound) ; Spell failed to equip as a Power, so it must be a handed Spell
					if (powerSpell) ; Restore equipped Power, as it will have been removed by the failed attempt
						PlayerREF.EquipSpell(powerSpell,2) 
					endIf
					if (handSlot == 1) ; Both hands are free
						PlayerREF.EquipSpell(item as Spell,1) ; Try to equip the spell in right hand
					elseIf (handSlot == 2) ; Left hand is free
						PlayerREF.EquipSpell(item as Spell,0) ; Try to equip the spell in left hand
					endIf
				endIf
				; The following are separate if (statements so if the spell took up both hands, we know both hands are full)
				if (PlayerREF.GetEquippedSpell(1) == item as Spell) ; Spell took up the right hand
					SpellFound = True
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				endIf
				if (PlayerREF.GetEquippedSpell(0) == item as Spell) ; Spell took up the left hand
					SpellFound = True
					DebugT("Equipped " + item.GetName() + " in hand " + handSlot + "!")
					handSlot += 1
				endIf
				if (!SpellFound)
					DebugT("Spell " + item.GetName() + " was not equipped, probably had no free hands!")
				endIf
			elseIf (itemType == 119) ;kShout
				PlayerREF.EquipShout(item as Shout)
				DebugT("Equipped " + item.GetName() + " as a Shout!")
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

	;if (!PlayerREF.IsOnMount() ; Do not use this when mounted, as per instructions)
	;	PlayerREF.QueueNiNodeUpdate()
	;endIf

	DebugT("Checking for deferred items...")

	while (i < deferredIdx)
		item = deferredItems[i]
		itemType = item.GetType()

		if (itemType == 46) ; kPotion which, since it was deferred, should be hostile, aka poison.
			DebugT("Consuming deferred item " + i + ", " + item.GetName())
			PlayerREF.EquipItem(deferredItems[i], abSilent = True)
		elseIf (itemType == 31) ; kLight, probably a torch, which needs the left hand free
			if (handSlot < 3) ; Left hand is free
				PlayerREF.EquipItemEX(item, equipSlot = 0, equipSound = _silenceEquipSounds)
				DebugT("Equipped deferred item " + item.GetName())
			else
				DebugT("Player tried to equip light " + item.GetName() + " but doesn't have a free left hand!")
			endIf
		else ; Some other deferred item. 
			DebugT("Equipping deferred item " + i + ", " + item.GetName())
			PlayerREF.EquipItem(deferredItems[i], abSilent = True)
		endIf

		i += 1
	endWhile

	_audioCategoryUI.Mute() ; Turn UI sounds back on

	DebugT("OnGroupUse end!")
endEvent

event OnMenuOpen(string a_menuName)
	DebugT("OnMenuOpen!")
	InitMenuGroupData()
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
	int		flags = a_strArg as int
	int		groupIndex = a_numArg as int

	_groupFlags[groupIndex] = flags
	
	DebugT("OnGroupFlag end!")
EndEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; Send the group data to the UI, so that when the user selects a group, it can filter its entries.
function InitMenuGroupData()
	DebugT("InitMenuGroupData called!")
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds1)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupFlags", _itemFlags1)

	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupForms", _itemFormIds2)
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".pushGroupFlags", _itemFlags2)

	UI.InvokeBool(FAVORITES_MENU, MENU_ROOT + ".finishGroupData", true)

	DebugT("InitMenuGroupData end!")
endFunction

function UpdateMenuGroupData(int a_groupIndex)
	DebugT("UpdateMenuGroupData called!")

	int offset = 32 * a_groupIndex

	int[] itemFormIds
	int[] itemFlags

	if (offset >= 128)
		offset -= 128
		itemFormIds = _itemFormIds2
		itemFlags = _itemFlags2
	else
		itemFormIds = _itemFormIds1
		itemFlags = _itemFlags1
	endIf

	; startIndex + 32 * (form, flag)
	int[] args = new int[65]

	args[0] = a_groupIndex

	int i=1
	int j=offset

	while (i<65)
		args[i] = itemFormIds[j]
		args[i+1] = itemFlags[j]

		i += 2
		j += 1
	endWhile
	
	UI.InvokeIntA(FAVORITES_MENU, MENU_ROOT + ".updateGroupData", args)

	DebugT("UpdateMenuGroupData end!")
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

function DebugT(string DebugString)
	if (_useDebug)
		Debug.Trace("SKI_Favs: " + DebugString)
	endIf
endFunction

bool function CheckFlag(int a_group, int a_flag)
	Return Math.LogicalAnd(_groupFlags[a_group], a_flag) as bool
endFunction

function ParseFlags(int a_flags)
	DebugT("Flags: " + a_flags)
	if (Math.LogicalAnd(a_flags, FAV_FLAG_ALLOWUSE))
		DebugT(" FAV_FLAG_ALLOWUSE")
	endIf
	if (Math.LogicalAnd(a_flags, FAV_FLAG_EQUIPSET))
		DebugT(" FAV_FLAG_EQUIPSET")
	endIf
	if (Math.LogicalAnd(a_flags, FAV_FLAG_NOWEAPON))
		DebugT(" FAV_FLAG_NOWEAPON")
	endIf
	if (Math.LogicalAnd(a_flags, FAV_FLAG_NOARMOR))
		DebugT(" FAV_FLAG_NOARMOR")
	endIf
	if (Math.LogicalAnd(a_flags, FAV_FLAG_NOAMMO))
		DebugT(" FAV_FLAG_NOAMMO")
	endIf
endFunction