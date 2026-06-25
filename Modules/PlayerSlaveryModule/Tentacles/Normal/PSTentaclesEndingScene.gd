extends SceneBase

func _init():
	sceneID = "PSTentaclesEndingScene"

func _reactInit():
	addCharacter(ServiceLocator.safe_get_service(&"MainScene").PS.getTentaclesCharID())

func resolveCustomCharacterName(_charID):
	if(_charID == "ten"):
		return ServiceLocator.safe_get_service(&"MainScene").PS.getTentaclesCharID()
	if(_charID == "sci1"):
		return ServiceLocator.safe_get_service(&"MainScene").PS.getScientist1CharID()
	if(_charID == "sci2"):
		return ServiceLocator.safe_get_service(&"MainScene").PS.getScientist2CharID()

func _run():
	var _tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS

	if(state == ""):
		saynn("ENDING ENDING ENDING!!!")

		addButton("Okay", "ENOUGH FUN", "doEndSlavery")
	if(state == "doSleep"):
		saynn("YOU SLEPT. EVENT HERE MAYBE?")

		addButton("Continue", "See what happens next", "endthescene")

func _react(_action: String, _args):
	var _tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS

	if(_action == "endthescene"):
		endScene()
		return

	if(_action == "doEndSlavery"):
		endScene()
		ServiceLocator.safe_get_service(&"MainScene").endCurrentScene()
		ServiceLocator.safe_get_service(&"MainScene").stopPlayerSlavery()
		ServiceLocator.safe_get_service(&"Player").setLocation(ServiceLocator.safe_get_service(&"Player").getCellLocation())
		return

	setState(_action)
