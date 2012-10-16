scriptname SKI_PlayerLoadGameAlias extends ReferenceAlias
 
; PROPERTIES --------------------------------------------------------------------------------------

SKI_QuestBase property InitQuest auto
 

 ; EVENTS -----------------------------------------------------------------------------------------

event OnPlayerLoadGame()
	InitQuest.OnGameReload()
endEvent
