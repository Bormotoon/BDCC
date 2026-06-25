extends QuestBase

func _init():
	id = "PortalPantiesQuest"

func getVisibleName():
	return "Bluespace panties"

func getProgress():
	var result = []
	
	result.append("Find some generic female panties and bring them to Alex Rynard. He said you can buy some in the laundry.")
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_GavePantiesToAlex")):
		result.append("You are now wearing the portal panties. Alex said you will be awarded a single credit after each test they do with you.")
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_PcDenied")):
		result.append("You denied his offer.")
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_FleshlightsGotStolen")):
		result.append("Someone fucked you through the portal panties! You gotta return to Alex and ask why that happened.")
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_FleshlightsAskedAlex")):
		result.append("Somehow the fleshlights with your private bits were stolen! Alex said you can look for them in the cellblock, near the cells.")
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_FleshlightsFoundFleshlights")):
		result.append("You got the fleshlights! Return them to Alex so he can unlock your portal panties.")
	
	return result

func isVisible():
	return ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_AskedAlex")

func isCompleted():
	return ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_PcDenied") || ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_FleshlightsReturnedToAlex")

func isMainQuest():
	return false
