extends QuestBase

func _init():
	id = "Ch3TaviQuest"

func getVisibleName():
	return "Tavi's Revenge"

func getProgress():
	var result = []
	
	result.append("You got everything you need. Time to go talk with Tavi.")
	
	if(ServiceLocator.safe_get_service(&"QuestSystem").isCompleted("Ch2ElizaQuest") && !ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.ch2DrugsGaveToTavi")):
		result.append("You have the drugs. Go give them to Tavi.")

	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.ch3StartedInfiltration")):
		result.append("You need to find the control room and initiate a maintenance protocol in order to open the door to the bluespace transmitter.")

	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.ch3CompletedDoorHack")):
		result.append("You enabled the maintenance protocol. Return back to Tavi.")

	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.Ch4ServedPunishment")):
		result.append("You're free! But you gotta get your revenge on the cat who told about your plans to the captain. Find Kait in the lilac block during mornings.")

	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.Ch4KaitSceneHappened")):
		result.append("Kait got dealt with for now. Go have some rest in your cell, Tavi needs some time to come up with a new plan.")

	return result

func isVisible():
	return ServiceLocator.safe_get_service(&"QuestSystem").isCompleted("Ch2ElizaQuest") && ServiceLocator.safe_get_service(&"QuestSystem").isCompleted("Ch2AlexQuest")

func isCompleted():
	return ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.Ch5NewPlanSceneHappend")

func isMainQuest():
	return true
