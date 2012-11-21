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
		return 33
	endFunction
endProperty

string property		MinSKSEVersion
	string function get()
		return "1.6.5"
	endFunction
endProperty

int property		ReqSWFRelease
	int function get()
		return 2
	endFunction
endProperty

string property		ReqSWFVersion
	string function get()
		return "3.0-alpha5"
	endFunction
endProperty

bool property		HUDMenuCheckEnabled			= true auto
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

	elseIf (SKSE.GetVersionRelease() < MinSKSERelease)
		Error("Your Skyrim Script Extender (SKSE) is outdated.\nSkyUI will not work correctly!\n" \
			+ "Required version: " + MinSKSEVersion + " or newer\n" \
			+ "Detected version: " + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta())
	endIf

	; Check hudmenu.swf version
	if (HUDMenuCheckEnabled)
		CheckMenuVersion("hudmenu.swf", HUD_MENU, "_global.HUDMenu")
	endIf

	; Check other menus, when they're opened
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
		UnregisterForMenu(INVENTORY_MENU)
		CheckMenuVersion("inventorymenu.swf", INVENTORY_MENU, "_global.InventoryMenu")
		CheckItemMenuComponents(INVENTORY_MENU)

	elseIf (a_menuName == MAGIC_MENU)
		UnregisterForMenu(MAGIC_MENU)
		CheckMenuVersion("magicmenu.swf", MAGIC_MENU, "_global.MagicMenu")
		CheckItemMenuComponents(MAGIC_MENU)

	elseIf (a_menuName == CONTAINER_MENU)
		UnregisterForMenu(CONTAINER_MENU)
		CheckMenuVersion("containermenu.swf", CONTAINER_MENU, "_global.ContainerMenu")
		CheckItemMenuComponents(CONTAINER_MENU)

	elseIf (a_menuName == BARTER_MENU)
		UnregisterForMenu(BARTER_MENU)
		CheckMenuVersion("bartermenu.swf", BARTER_MENU, "_global.BarterMenu")
		CheckItemMenuComponents(BARTER_MENU)

	elseIf (a_menuName == GIFT_MENU)
		UnregisterForMenu(GIFT_MENU)
		CheckMenuVersion("giftmenu.swf", GIFT_MENU, "_global.GiftMenu")
		CheckItemMenuComponents(GIFT_MENU)

	elseIf (a_menuName == JOURNAL_MENU)
		UnregisterForMenu(JOURNAL_MENU)
		CheckMenuVersion("quest_journal.swf", JOURNAL_MENU, "_global.Quest_Journal")
		CheckMenuVersion("skyui/configpanel.swf", JOURNAL_MENU, "_global.ConfigPanel")
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Error(string a_msg)
	Debug.MessageBox("SKYUI ERROR\n\n" + a_msg + "\n\nFor more help, see the SkyUI mod description.")
	ErrorDetected = true
endFunction

function CheckMenuVersion(string a_swfName, string a_menu, string a_class)
	int releaseIdx = UI.GetInt(a_menu, a_class + ".SKYUI_RELEASE_IDX")
	string version = UI.GetString(a_menu, a_class + ".SKYUI_VERSION_STRING")

	if (releaseIdx == 0)
		Error("Missing or incompatible menu file (" + a_swfName + ").\nPlease make sure you installed everything correctly and no other mod has overwritten this file.")

	elseIf (releaseIdx != ReqSWFRelease)
		Error("Menu file version mismatch for " + a_swfName + ".\n" \
			+ "Required version: " + ReqSWFVersion + "\n" \
			+ "Detected version: " + version)
	endIf
endFunction

function CheckItemMenuComponents(string a_menu)
	CheckMenuVersion("skyui/itemcard.swf", a_menu, "_global.ItemCard")
	CheckMenuVersion("skyui/bottombar.swf", a_menu, "_global.BottomBar")
	CheckMenuVersion("skyui/inventorylists.swf", a_menu, "_global.InventoryLists")
endFunction
