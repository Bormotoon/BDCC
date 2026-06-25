extends QuestBase

func _init():
	id = "TaviAppleQuest"

func getVisibleName():
	return "Forbidden fruit"

func getProgress():
	var result = []
	
	result.append("Tavi told you she wants an apple. You can get one in the greenhouses which are near the prison's yard.")
	if(ServiceLocator.safe_get_service(&"Player").getInventory().hasItemID("appleitem")):
		result.append("I have an apple. I should go give it to Tavi. She is always hanging around on the mining level.")
	
	return result

func isVisible():
	return ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_NeedsApple")

func isCompleted():
	return ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_GotApple")

func isMainQuest():
	return false
