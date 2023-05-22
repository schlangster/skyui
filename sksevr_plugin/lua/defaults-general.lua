Settings = {
	-- On a per-menu basis, change the keybind used to activate the search function.
	-- We're just using a bunch of strings try narrowing down when the search function
	-- should be triggerred.
	--
	-- For example:
	--  {"thumbstick", "clicked"} => triggers when either thumbstick click starts
	--  {"leftHand", "thumbstick", "clicked"} => triggers when the left hand thumbstick click starts
	--  {"rightHand", "touchpad", "center", "touched"} => triggers when the right hand touchpad has its center touched
	--
	-- Strings to indicate handedness:
	--   "leftHand", "rightHand"
	--
	-- Strings to indicate widget type:
	--   "touchpad", "thumbstick", "application menu", "grip", "trigger", "b button", "a button", "x button", "y button"
	--
	-- Strings to indicate touchpad region:
	--   "top", "right", "left", "bottom", "center"
	--
	-- Strings to indicate widget "phase": (touched => pressed => clicked => pressed => touched)
	--   "touched", "pressed", "clicked"
	--
	-- Strings to trigger either when a phase starts or ends:
	--   "start", "end"
	
	BarterMenu = {
		search = {}
	},
	ContainerMenu = {
		search = {}
	},
	CraftingMenu = {
		search = {}
	},
	GiftMenu = {
		search = {}
	},
	InventoryMenu = {
		search = {}
	},
	MagicMenu = {
		search = {}
	},
}