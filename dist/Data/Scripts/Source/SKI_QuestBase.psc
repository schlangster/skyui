scriptname SKI_QuestBase extends Quest hidden

; -------------------------------------------------------------------------------------------------
; Version Tracking
;
; Quest implements
;	GetVersion, to return the static version number
;	OnVersionUpdate to handle the updating
; Update can be triggered externally by calling CheckVersion()

int property CurrentVersion auto hidden

function CheckVersion()
	int version = GetVersion()
	if (CurrentVersion < version)
		OnVersionUpdate(version)
		CurrentVersion = version
	endIf
endFunction

int function GetVersion()
	return 1
endFunction

event OnVersionUpdate(int a_version)
endEvent


; -------------------------------------------------------------------------------------------------
; Reload Events

event OnGameReload()
endEvent