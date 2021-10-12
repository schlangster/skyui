scriptname SKI_PlayerInventoryHook extends ReferenceAlias

;; Interface for FormDB
Function SetInt(Form form, string fieldName, int val) global native
int Function GetInt(Form form, string fieldName, int default_val) global native
Function SetBool(Form form, string fieldName, bool val) global native
bool Function GetBool(Form form, string fieldName, bool default_val) global native
Function RemoveField(Form form, string fieldName) global native
Function RemoveAllfields(Form form) global native

Event OnInit()
  Debug.Trace("[PIH] PlayerInventoryHook started")
endEvent

String function form2str(Form f)
  return f + " " + f.GetName()
endFunction

String function obj2str(ObjectReference o)
  return o + " base: " + form2str(o.GetBaseObject())
endFunction

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
  Debug.Trace("[PIH] OnItemAdded")
  Debug.Trace("[PIH] baseItem: " + form2str(akBaseItem))
  if akSourceContainer != None
    Debug.Trace("[PIH] SourceContainer: " + obj2str(akSourceContainer))
  endIf
  ;; We want to associate some data with the base Form to indicate that this item is "new".
  ;; {
  ;;   <akBaseItem FormID> = {skyui = {new_item: true}}
  ;; }
  ;;
  ;; This "new" status is only useful/meaningful when we're viewing the player's inventory.
  ;; Care should be taken to ignore this flag when not viewing player inventory.

  if akSourceContainer != Game.GetPlayer()
    ;; Add a "new" tag to the item indicating that it is new
    SetBool(akBaseItem, "skyui/new_item", true)

    bool val = GetBool(akBaseItem, "skyui/new_item", false)
    Debug.Trace("[PIH] Setting 'new' flag for " + akBaseItem + " to " + val)

  endIf
endEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
  Debug.Trace("[PIH] OnItemRemoved")
  Debug.Trace("[PIH] baseItem: " + form2str(akBaseItem))
  if akDestContainer != None
    Debug.Trace("[PIH] DestContainer: " + obj2str(akDestContainer))
  endIf

  ;; Make sure to clean any data associated with the base Form if the item is removed.
  ;; Another script might move the item before the player has the opportunity to open the inventory and cause
  ;; all the "new" tags to be cleared.
  if akDestContainer != Game.GetPlayer()
    bool val = GetBool(akBaseItem, "skyui/new_item", false)
    if val != false
      Debug.Trace("[PIH] " + akBaseItem + " still has the 'new' flag on it!")
    endIf
    RemoveField(akBaseItem, "skyui")
    Debug.Trace("[PIH] Destroying data associated with " + akBaseItem)
  endIf
endEvent
