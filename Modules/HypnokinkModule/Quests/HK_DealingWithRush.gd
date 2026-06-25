extends QuestBase

func _init():
	id = "DealingWithRush"

func getVisibleName():
	return "Stallion for time"

func getProgress():
	var result = []
	
	result.append("Vion needs help dealing with Rush, an equine-dragon hybrid making increasingly insistent demands.")
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.RushDealStruckAtLeastOnce", false)):
		result.append("You've struck a deal with Rush that should get him off Vion's back for a while.")
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.RushCausingMoreTrouble", false)):
		result.append("Your solution for the Rush problem is proving to be only temporary. Perhaps a more permanent one is possible?")
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.RushSubdued", false)):
		result.append("Rush has been dealt with permanently.")
	
	return result

func isVisible():
	return ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.KnowAboutRush", false)

func isCompleted():
	return ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.RushSubdued", false)

func isMainQuest():
	return false
