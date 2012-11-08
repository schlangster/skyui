scriptname SKI_PlayerLoadGameAlias extends ReferenceAlias

 ; EVENTS -----------------------------------------------------------------------------------------

event OnPlayerLoadGame()
	(GetOwningQuest() as SKI_QuestBase).OnGameReload()
endEvent
