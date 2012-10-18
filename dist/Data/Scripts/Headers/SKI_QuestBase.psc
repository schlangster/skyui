scriptname SKI_QuestBase extends Quest hidden

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; DO NOT MODIFY OR RECOMPILE THIS SCRIPT
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

; -------------------------------------------------------------------------------------------------
; Version Tracking
;
; Quest implements
;	GetVersion, to return the static version number
;	OnVersionUpdate to handle the updating
; Update process is triggered by calling CheckVersion()

int property CurrentVersion auto hidden

function CheckVersion()
	Guard()
endFunction

int function GetVersion()
	Guard()
endFunction

event OnVersionUpdate(int a_version)
	Guard()
endEvent


; -------------------------------------------------------------------------------------------------
; Reload Events
;
; Helper to add reload event to quest script.
; 1. Create quest
; 2. Add player alias to quest
; 3. Attach SKI_PlayerLoadGameAlias to player alias
; 4. Set InitQuest property of alias script to quest

event OnGameReload()
endEvent

function Guard()
	Debug.MessageBox("SKI_QuestBase: Y U RECOMPILE ME?")
endFunction