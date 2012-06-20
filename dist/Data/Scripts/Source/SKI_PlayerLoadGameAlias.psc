scriptname SKI_PlayerLoadGameAlias extends ReferenceAlias  
 
SKI_QuestBase property InitQuest auto
 
event OnPlayerLoadGame()
	InitQuest.OnGameReload()
endEvent
