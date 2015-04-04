scriptname SKI_Main extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU		= "HUD Menu" autoReadOnly
string property		INVENTORY_MENU	= "InventoryMenu" autoReadonly
string property		MAGIC_MENU		= "MagicMenu" autoReadonly
string property		CONTAINER_MENU	= "ContainerMenu" autoReadonly
string property		BARTER_MENU		= "BarterMenu" autoReadonly
string property		GIFT_MENU		= "GiftMenu" autoReadonly
string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MAP_MENU		= "MapMenu" autoReadonly
string property		FAVORITES_MENU	= "FavoritesMenu" autoReadonly
string property		CRAFTING_MENU	= "Crafting Menu" autoReadonly

int property		ERR_SKSE_MISSING		= 1 autoReadonly
int property		ERR_SKSE_VERSION_RT		= 2 autoReadonly
int property		ERR_SKSE_VERSION_SCPT	= 3 autoReadonly
int property		ERR_INI_PAPYRUS			= 4 autoReadonly
int property		ERR_SWF_INVALID			= 5 autoReadonly
int property		ERR_SWF_VERSION			= 6 autoReadonly
int property		ERR_SKSE_BROKEN			= 7 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool _inventoryMenuCheckEnabled		= true
bool _magicMenuCheckEnabled			= true
bool _barterMenuCheckEnabled		= true
bool _containerMenuCheckEnabled		= true
bool _giftMenuCheckEnabled			= true
bool _mapMenuCheckEnabled			= true
bool _favoritesMenuCheckEnabled		= true
bool _craftingMenuCheckEnabled		= true


; PROPERTIES --------------------------------------------------------------------------------------

int property		MinSKSERelease	= 44		autoReadonly
string property		MinSKSEVersion	= "1.6.16"	autoReadonly

int property		ReqSWFRelease	= 17		autoReadonly
string property		ReqSWFVersion	= "5.0"		autoReadonly

bool property		ErrorDetected	= false auto


bool property InventoryMenuCheckEnabled
	bool function get()
		return _inventoryMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_inventoryMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(INVENTORY_MENU)
		else
			UnregisterForMenu(INVENTORY_MENU)
		endIf
	endFunction
endProperty

bool property MagicMenuCheckEnabled
	bool function get()
		return _magicMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_magicMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(MAGIC_MENU)
		else
			UnregisterForMenu(MAGIC_MENU)
		endIf
	endFunction
endProperty

bool property BarterMenuCheckEnabled
	bool function get()
		return _barterMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_barterMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(BARTER_MENU)
		else
			UnregisterForMenu(BARTER_MENU)
		endIf
	endFunction
endProperty

bool property ContainerMenuCheckEnabled
	bool function get()
		return _containerMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_containerMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(CONTAINER_MENU)
		else
			UnregisterForMenu(CONTAINER_MENU)
		endIf
	endFunction
endProperty

bool property GiftMenuCheckEnabled
	bool function get()
		return _giftMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_giftMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(GIFT_MENU)
		else
			UnregisterForMenu(GIFT_MENU)
		endIf
	endFunction
endProperty

bool property MapMenuCheckEnabled
	bool function get()
		return _mapMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_mapMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(MAP_MENU)
		else
			UnregisterForMenu(MAP_MENU)
		endIf
	endFunction
endProperty

bool property FavoritesMenuCheckEnabled
	bool function get()
		return _favoritesMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_favoritesMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(FAVORITES_MENU)
		else
			UnregisterForMenu(FAVORITES_MENU)
		endIf
	endFunction
endProperty

bool property CraftingMenuCheckEnabled
	bool function get()
		return _craftingMenuCheckEnabled
	endFunction

	function set(bool a_val)
		_craftingMenuCheckEnabled = a_val
		if (a_val)
			RegisterForMenu(CRAFTING_MENU)
		else
			UnregisterForMenu(CRAFTING_MENU)
		endIf
	endFunction
endProperty


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	ErrorDetected = false

	if (SKSE.GetVersionRelease() == 0)
		Error(ERR_SKSE_MISSING, "The Skyrim Script Extender (SKSE) is not running.\nSkyUI will not work correctly!\n\n" \
			+ "This message may also appear if a new Skyrim Patch has been released. In this case, wait until SKSE has been updated, then install the new version.")
		return

	elseIf (GetType() == 0)
		Error(ERR_SKSE_BROKEN, "The SKSE scripts have been overwritten or are not properly loaded.\nReinstalling SKSE might fix this.")
		return

	elseIf (SKSE.GetVersionRelease() < MinSKSERelease)
		Error(ERR_SKSE_VERSION_RT, "SKSE is outdated.\nSkyUI will not work correctly!\n" \
			+ "Required version: " + MinSKSEVersion + " or newer\n" \
			+ "Detected version: " + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta())
		return

	elseIf (SKSE.GetScriptVersionRelease() < MinSKSERelease)
		Error(ERR_SKSE_VERSION_SCPT, "SKSE scripts are outdated.\nYou probably forgot to install/update them with the rest of SKSE.\nSkyUI will not work correctly!")
		return
	endIf

	if (Utility.GetINIInt("iMinMemoryPageSize:Papyrus") <= 0 || Utility.GetINIInt("iMaxMemoryPageSize:Papyrus") <= 0 || Utility.GetINIInt("iMaxAllocatedMemoryBytes:Papyrus") <= 0)
		Error(ERR_INI_PAPYRUS, "Your Papyrus INI settings are invalid. Please fix this, otherwise SkyUI will stop working at some point.")
		return
	endIf

	; Check menus, when they're opened
	if (InventoryMenuCheckEnabled)
		RegisterForMenu(INVENTORY_MENU)
	endIf

	if (MagicMenuCheckEnabled)
		RegisterForMenu(MAGIC_MENU)
	endIf

	if (ContainerMenuCheckEnabled)
		RegisterForMenu(CONTAINER_MENU)
	endIf

	if (BarterMenuCheckEnabled)
		RegisterForMenu(BARTER_MENU)
	endIf

	if (GiftMenuCheckEnabled)
		RegisterForMenu(GIFT_MENU)
	endIf

	if (MapMenuCheckEnabled)
		RegisterForMenu(MAP_MENU)
	endIf

	if (FavoritesMenuCheckEnabled)
		RegisterForMenu(FAVORITES_MENU)
	endIf

	if (CraftingMenuCheckEnabled)
		RegisterForMenu(CRAFTING_MENU)
	endIf

	RegisterForMenu(JOURNAL_MENU)
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	if (a_menuName == INVENTORY_MENU)
		if (CheckMenuVersion("inventorymenu.swf", a_menuName, "_global.InventoryMenu") && \
			CheckItemMenuComponents(a_menuName))
			; Only unregister if all checks have been performed (regardless of check result)
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == MAGIC_MENU)
		if (CheckMenuVersion("magicmenu.swf", a_menuName, "_global.MagicMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == CONTAINER_MENU)
		if (CheckMenuVersion("containermenu.swf", a_menuName, "_global.ContainerMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == BARTER_MENU)
		if (CheckMenuVersion("bartermenu.swf", a_menuName, "_global.BarterMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == GIFT_MENU)
		if (CheckMenuVersion("giftmenu.swf", a_menuName, "_global.GiftMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == JOURNAL_MENU)
		if (CheckMenuVersion("quest_journal.swf", a_menuName, "_global.Quest_Journal") && \
			CheckMenuVersion("skyui/configpanel.swf", a_menuName, "_global.ConfigPanel"))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == MAP_MENU)
		if (CheckMenuVersion("map.swf", a_menuName, "_global.Map.MapMenu"))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == FAVORITES_MENU)
		if (CheckMenuVersion("favoritesmenu.swf", a_menuName, "_global.FavoritesMenu"))
			UnregisterForMenu(a_menuName)
		endIf

	elseIf (a_menuName == CRAFTING_MENU)
		if (CheckMenuVersion("craftingmenu.swf", a_menuName, "_global.CraftingMenu"))
			UnregisterForMenu(a_menuName)
		endIf
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Error(int a_errId, string a_msg)
	Debug.MessageBox("SKYUI ERROR CODE " + a_errId + "\n\n" + a_msg + "\n\nFor more help, visit the SkyUI download site.")
	ErrorDetected = true
endFunction

bool function CheckMenuVersion(string a_swfName, string a_menu, string a_class)
	; Returns false if the menu is closed before UI.Get* receive their value

	int releaseIdx = UI.GetInt(a_menu, a_class + ".SKYUI_RELEASE_IDX")
	string version = UI.GetString(a_menu, a_class + ".SKYUI_VERSION_STRING")

	if (!UI.IsMenuOpen(a_menu))
		return false
	endIf

	if (releaseIdx == 0)
		Error(ERR_SWF_INVALID, "Incompatible menu file (" + a_swfName + ").\nPlease make sure you installed everything correctly and no other mod has overwritten this file.\n" \
			+ "If you were using an older SkyUI version, un-install it and re-install the latest version.")

	elseIf (releaseIdx != ReqSWFRelease)
		Error(ERR_SWF_VERSION, "Menu file version mismatch for " + a_swfName + ".\n" \
			+ "Required version: " + ReqSWFVersion + "\n" \
			+ "Detected version: " + version)

	endIf

	return true
endFunction

bool function CheckItemMenuComponents(string a_menu)
	; Returns false if the menu is closed before all checks have finished

	return CheckMenuVersion("skyui/itemcard.swf", a_menu, "_global.ItemCard") && \
			CheckMenuVersion("skyui/bottombar.swf", a_menu, "_global.BottomBar") && \
			CheckMenuVersion("skyui/inventorylists.swf", a_menu, "_global.InventoryLists")
endFunction
