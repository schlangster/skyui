scriptname SKI_Main extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU		= "HUD Menu" autoReadOnly
string property		INVENTORY_MENU	= "InventoryMenu" autoReadonly
string property		MAGIC_MENU		= "MagicMenu" autoReadonly
string property		CONTAINER_MENU	= "ContainerMenu" autoReadonly
string property		BARTER_MENU		= "BarterMenu" autoReadonly
string property		GIFT_MENU		= "GiftMenu" autoReadonly
string property		JOURNAL_MENU	= "Journal Menu" autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

int property		MinSKSERelease
	int function get()
		return 34
	endFunction
endProperty

string property		MinSKSEVersion
	string function get()
		return "1.6.6"
	endFunction
endProperty

int property		ReqSWFRelease
	int function get()
		return 8
	endFunction
endProperty

string property		ReqSWFVersion
	string function get()
		return "3.1"
	endFunction
endProperty

bool property		InventoryMenuCheckEnabled	= true auto
bool property		MagicMenuCheckEnabled		= true auto
bool property		BarterMenuCheckEnabled		= true auto 
bool property		ContainerMenuCheckEnabled	= true auto
bool property		GiftMenuCheckEnabled		= true auto

bool property		ErrorDetected				= false auto


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	ErrorDetected = false

	if (SKSE.GetVersionRelease() == 0)
		Error("The Skyrim Script Extender (SKSE) is not running.\nSkyUI will not work correctly!\n\n" \
			+ "This message may also appear if a new Skyrim Patch has been released. In this case, wait until SKSE has been updated, then install the new version.")
		return

	elseIf (SKSE.GetVersionRelease() < MinSKSERelease)
		Error("Your Skyrim Script Extender (SKSE) is outdated.\nSkyUI will not work correctly!\n" \
			+ "Required version: " + MinSKSEVersion + " or newer\n" \
			+ "Detected version: " + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta())
		return

	; Could also check for != SKSE.GetVersionRelease(), but this should be strict enough
	elseIf (SKSE.GetScriptVersionRelease() < MinSKSERelease)
		Error("Your Skyrim Script Extender (SKSE) scripts are outdated.\nYou probably forgot to install/update them with the rest of SKSE.\nSkyUI will not work correctly!")
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

	RegisterForMenu(JOURNAL_MENU)
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	if (a_menuName == INVENTORY_MENU)
		if (CheckMenuVersion("inventorymenu.swf", a_menuName, "_global.InventoryMenu") && \
			CheckItemMenuComponents(a_menuName))
			; Only unregister if all checks have been performed (regardless of check result)
			UnregisterForMenu(a_menuName)
		EndIf

	elseIf (a_menuName == MAGIC_MENU)
		if (CheckMenuVersion("magicmenu.swf", a_menuName, "_global.MagicMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		EndIf

	elseIf (a_menuName == CONTAINER_MENU)
		if (CheckMenuVersion("containermenu.swf", a_menuName, "_global.ContainerMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		EndIf

	elseIf (a_menuName == BARTER_MENU)
		if (CheckMenuVersion("bartermenu.swf", a_menuName, "_global.BarterMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		EndIf

	elseIf (a_menuName == GIFT_MENU)
		if (CheckMenuVersion("giftmenu.swf", a_menuName, "_global.GiftMenu") && \
			CheckItemMenuComponents(a_menuName))
			UnregisterForMenu(a_menuName)
		EndIf

	elseIf (a_menuName == JOURNAL_MENU)
		if (CheckMenuVersion("quest_journal.swf", a_menuName, "_global.Quest_Journal") && \
			CheckMenuVersion("skyui/configpanel.swf", a_menuName, "_global.ConfigPanel"))
			UnregisterForMenu(a_menuName)
		EndIf
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Error(string a_msg)
	Debug.MessageBox("SKYUI ERROR\n\n" + a_msg + "\n\nFor more help, see the SkyUI mod description.")
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
		Error("Incompatible menu file (" + a_swfName + ").\nPlease make sure you installed everything correctly and no other mod has overwritten this file.\n" \
			+ "If you were using an older SkyUI version, un-install it and re-install the latest version.")

	elseIf (releaseIdx != ReqSWFRelease)
		Error("Menu file version mismatch for " + a_swfName + ".\n" \
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
