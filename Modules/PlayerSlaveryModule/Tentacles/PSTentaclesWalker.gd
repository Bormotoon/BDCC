extends SceneBase

func _init():
	sceneID = "PSTentaclesWalker"

func _run():
	var tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS
	
	if(state == ""):
		saynn("You're free to wander around your cell.")
		var roomID:String = ServiceLocator.safe_get_service(&"Player").location
		var _roomInfo = ServiceLocator.safe_get_service(&"World").getRoomByID(roomID)
		aimCameraAndSetLocName(roomID)
		
		if(tentacles.getMonsterLoc() == roomID && !tentacles.hasEvent()):
			var theAnimInfo:Array = tentacles.getTentaclesMeetAnim()
			if(theAnimInfo.size() >= 3):
				playAnimation(theAnimInfo[0], theAnimInfo[1], theAnimInfo[2])
		
		var theText:String = tentacles.getText(roomID)
		if(!theText.is_empty()):
			saynn(theText)

		if(ServiceLocator.safe_get_service(&"World").canGoID(roomID, GameWorld.Direction.NORTH)):
			addButtonAt(6, "North", "Go north", "go", [GameWorld.Direction.NORTH, Direction.North])
		else:
			addDisabledButtonAt(6, "North", "Can't go north")
			
		if(ServiceLocator.safe_get_service(&"World").canGoID(roomID, GameWorld.Direction.WEST)):
			addButtonAt(10, "West", "Go west", "go", [GameWorld.Direction.WEST, Direction.West])
		else:
			addDisabledButtonAt(10, "West", "Can't go west")
			
		if(ServiceLocator.safe_get_service(&"World").canGoID(roomID, GameWorld.Direction.SOUTH)):
			addButtonAt(11, "South", "Go south", "go", [GameWorld.Direction.SOUTH, Direction.South])
		else:
			addDisabledButtonAt(11, "South", "Can't go south")
		
		if(ServiceLocator.safe_get_service(&"World").canGoID(roomID, GameWorld.Direction.EAST)):
			addButtonAt(12, "East", "Go east",  "go", [GameWorld.Direction.EAST, Direction.East])
		else:
			addDisabledButtonAt(12, "East", "Can't go east")
		
		var theActions:Array = tentacles.getActions(roomID)
		for actionEntry in theActions:
			addButton(actionEntry[0], actionEntry[1], "doAction", actionEntry)
		

func _react(_action: String, _args):
	var tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS
	
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "go"):
		playAnimation(StageScene.Solo, "walk")
		ServiceLocator.safe_get_service(&"Player").setLocation(ServiceLocator.safe_get_service(&"World").applyDirectionID(ServiceLocator.safe_get_service(&"Player").location, _args[0]))
		processTime((30 if !ServiceLocator.safe_get_service(&"Player").hasBoundLegs() else 60))
		aimCameraAndSetLocName(ServiceLocator.safe_get_service(&"Player").location)
		#ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.EnteringRoom, [ServiceLocator.safe_get_service(&"Player").location, _args[1]])
		
		tentacles.processTurn()
		
		var eventInfo:Array = tentacles.checkEvent(self, ServiceLocator.safe_get_service(&"Player").getLocation())
		if(!eventInfo.is_empty()):
			runScene(eventInfo[0], eventInfo[1] if eventInfo.size() > 1 else [])
			return
		elif(!ServiceLocator.safe_get_service(&"MainScene").checkExtraScenes(true, true)):
			if(ServiceLocator.safe_get_service(&"MainScene").showLog()):
				return
		
			tentacles.afterWalkCheck()
			
		return
	if(_action == "doAction"):
		tentacles.doAction(self, _args)
		return

	setState(_action)

func supportsShowingPawns() -> bool:
	return true

func getDebugActions():
	return ServiceLocator.safe_get_service(&"MainScene").PS.getDebugActions()

func doDebugAction(id, args = {}):
	ServiceLocator.safe_get_service(&"MainScene").PS.doDebugAction(id, args)
