scriptname SKI_QuestBase extends Quest hidden

;##################################################################################################
; API Version:		1
;##################################################################################################
;
; Base script for SkyUI quest scripts.
;
; This file contains the public interface of SKI_QuestBase so you're able to extend it.
;
; DO NOT MODIFY THIS SCRIPT!
; DO NOT RECOMPILE THIS SCRIPT!
;
;##################################################################################################

event OnInit()
endEvent

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

event OnGameReload()
endEvent

function Guard()
	Debug.MessageBox("SKI_QuestBase: Don't recompile this script!")
endFunction