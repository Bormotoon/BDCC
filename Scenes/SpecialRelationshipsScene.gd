extends SceneBase

var selectedCharID:String = ""

func _init():
	sceneID = "SpecialRelationshipsScene"

func _run():
	if(state == ""):
		addButton("CLOSE", "Close this menu", "endthescene")
		playAnimation(StageScene.Solo, "stand")
		setCharactersEasyList([])
		aimCameraAndSetLocName(ServiceLocator.safe_get_service(&"Player").getLocation())
		
		for charID in ServiceLocator.safe_get_service(&"MainScene").RS.special:
			var theSpecial:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.special[charID]
			var theChar:BaseCharacter = getCharacter(charID)
			if(!theChar || !theSpecial):
				continue
			var theColor:Color = theSpecial.getCategoryColor()
			var theCharTypeName:String = CharacterType.getName(theChar.getCharType())
			sayn(theChar.getName()+" - "+theCharTypeName+" - [color=#"+theColor.to_html(false)+"]"+theSpecial.getCategoryName()+"[/color]")
			
			addButton(theChar.getName(), "Look at this relationship", "lookAt", [charID])
	
	if(state == "relationshipInfo"):
		addButton("BACK", "Go back to the previous menu", "")
		if(!ServiceLocator.safe_get_service(&"MainScene").RS.special.has(selectedCharID)):
			return
		var theSpecial:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.special[selectedCharID]
		var theChar:BaseCharacter = getCharacter(selectedCharID)
		if(!theChar || !theSpecial):
			return
		playAnimation(StageScene.Duo, "stand", {npc=selectedCharID})
		setCharactersEasyList([selectedCharID])
		sayn("Name: "+theChar.getName()+" ("+CharacterType.getName(theChar.getCharType())+")")
		var theColor:Color = theSpecial.getCategoryColor()
		sayn("Relationship: [color=#"+theColor.to_html(false)+"]"+theSpecial.getCategoryName()+"[/color]")
		sayn("Location: "+getLocName(selectedCharID))
		saynn(theSpecial.getBigDescription())
		var thePawn:CharacterPawn = ServiceLocator.safe_get_service(&"MainScene").IS.getPawn(selectedCharID)
		if(thePawn):
			aimCameraAndSetLocName(thePawn.getLocation())
		
		var canMeet:bool = theSpecial.canMeetThroughRelationshipMenu()
		if(canMeet):
			if(thePawn):
				var thePCLoc:String = ServiceLocator.safe_get_service(&"Player").getLocation()
				var theLoc:String = thePawn.getLocation()
				if(!isOnSameFloor(thePCLoc, theLoc)):
					addDisabledButton("Meet", "You need to be on the same floor!")
				elif(!thePawn.canBeInterrupted()):
					addDisabledButton("Meet", "They are busy with something!")
				elif(!isLocSafe(theLoc)):
					addDisabledButton("Meet", "Their location isn't safe!")
				elif(!isLocSafe(thePCLoc)):
					addDisabledButton("Meet", "Your current location isn't safe! Escape the danger first!")
				else:
					addButton("Meet", "Go meet them!", "doMeet")
			else:
				var theLoc:String = ServiceLocator.safe_get_service(&"Player").getLocation()
				if(!isFloorSafeToMeetAt(theLoc)):
					addDisabledButton("Meet", "You can't meet them on this floor!")
				elif(!isLocSafe(theLoc)):
					addDisabledButton("Meet", "Your current location isn't safe!")
				else:
					addButton("Meet", "Go meet them!", "doMeet")

func isLocSafe(_loc:String) -> bool:
	return ServiceLocator.safe_get_service(&"World").isLocSafe(_loc)

func isFloorSafeToMeetAt(_loc:String) -> bool:
	return ServiceLocator.safe_get_service(&"World").canMeetInLoc(_loc)

func isOnSameFloor(_loc1:String, _loc2:String) -> bool:
	var theRoom1:GameRoom = ServiceLocator.safe_get_service(&"World").getRoomByID(_loc1)
	var theRoom2:GameRoom = ServiceLocator.safe_get_service(&"World").getRoomByID(_loc2)
	if(!theRoom1 || !theRoom2):
		return false
	return theRoom1.getFloorID() == theRoom2.getFloorID()

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "lookAt"):
		selectedCharID = _args[0]
		setState("relationshipInfo")
		return
	if(_action == "doMeet"):
		if(ServiceLocator.safe_get_service(&"MainScene").IS.hasPawn(selectedCharID)):
			var thePawn:CharacterPawn = ServiceLocator.safe_get_service(&"MainScene").IS.spawnPawnIfNeeded(selectedCharID)
			ServiceLocator.safe_get_service(&"Player").setLocation(thePawn.getLocation())
			ServiceLocator.safe_get_service(&"MainScene").IS.startInteraction("Talking", {starter="pc", reacter=selectedCharID})
		else:
			var thePawn:CharacterPawn = ServiceLocator.safe_get_service(&"MainScene").IS.spawnPawnIfNeeded(selectedCharID)
			if(thePawn):
				thePawn.setLocation(ServiceLocator.safe_get_service(&"Player").getLocation())
				ServiceLocator.safe_get_service(&"MainScene").IS.startInteraction("Talking", {starter="pc", reacter=selectedCharID})
		
		processTime(5*60)
		endScene()
		return
	
	setState(_action)

func getLocName(theCharID:String) -> String:
	if(ServiceLocator.safe_get_service(&"MainScene").IS.hasPawn(theCharID)):
		var pawn:CharacterPawn = ServiceLocator.safe_get_service(&"MainScene").IS.getPawn(theCharID)
		var room = ServiceLocator.safe_get_service(&"World").getRoomByID(pawn.getLocation())
		if(room == null):
			return "Error.."
		else:
			var floorID:String = room.getFloorID()
			return getFloorName(floorID)+" - "+room.getName()
	return "Resting (Can be met through the Encounters menu)"

static func getFloorName(floorID:String) -> String:
	#var room = ServiceLocator.safe_get_service(&"World").getRoomByID(loc)
	#var floorID:String = room.getFloorID()
	if(floorID == "Cellblock"):
		return "Cellblock"
	if(floorID == "MainHall"):
		return "Main prison floor"
	if(floorID == "Medical"):
		return "Medical wing"
	if(floorID == "MiningFloor"):
		return "Mining floor"
	
	return "Unknown floor"

func supportsShowingPawns() -> bool:
	return true

func saveData():
	var data = super.saveData()
	
	data["selectedCharID"] = selectedCharID
	
	return data
	
func loadData(data):
	super.loadData(data)
	
	selectedCharID = SAVE.loadVar(data, "selectedCharID", "")
