extends SceneBase

var pickedZone:int = BodyWritingsZone.ArmLeft

func _init():
	sceneID = "PermanentMarkerScene"

func _run():
	if(state == ""):
		playAnimation(StageScene.Solo, "stand", {bodystate={naked=true}})
		
		saynn("You are holding a black [b]permanent[/b] marker in your hand.")

		saynn("What do you wanna do?")

		if(!ServiceLocator.safe_get_service(&"Player").hasBlockedHands() && !ServiceLocator.safe_get_service(&"Player").hasBoundArms()):
			addButton("Draw on self", "You changed your mind", "pickzonemenu")
		else:
			addDisabledButton("Draw on self", "Your arms or hands are bound!")
		addButton("Leave it", "You changed your mind", "endthescene")
	
	if(state == "pickzonemenu"):
		saynn("Where do you wanna leave a bodywriting?")
		
		addButton("Cancel", "You changed your mind", "")
		for zone in BodyWritingsZone.ALL:
			var zoneName:String = BodyWritingsZone.getZoneVisibleName(zone)
			addButton(zoneName, "Pick this zone", "pickzone", [zone])
	
	if(state == "pickwritingmenu"):
		saynn("What do you want to write on your "+str(BodyWritingsZone.getZoneVisibleName(pickedZone))+"?")
		
		var theEffect
		if(ServiceLocator.safe_get_service(&"Player").hasEffect(StatusEffect.HasBodyWritings)):
			theEffect = ServiceLocator.safe_get_service(&"Player").getEffect(StatusEffect.HasBodyWritings)
		
		addButton("Back", "You changed your mind", "pickzonemenu")
		for writingID in BodyWritings.getWritingIDsForZone(pickedZone):
			var writingInfo:Dictionary = BodyWritings.getWritingInfo(writingID)
			
			var writingName:String = writingInfo[BodyWritingsDB.DBText]
			if(theEffect && theEffect.hasPermanentWritingIDAtZone(pickedZone, writingID)):
				addDisabledButton(writingName, "You already have this permanent writing in this zone!")
			else:
				addButton(writingName, "Write this with a permanent marker!", "doWrite", [writingID])
	
	if(state == "afterwrite"):
		playAnimation(StageScene.Solo, "stand", {bodystate={naked=true}})
		
		saynn("You finish scribbling a writing on your skin with a permanent marker!")
		
		saynn("The marker is now out of ink so you throw it out.")
		
		addButton("Continue", "See what happens next", "endthescene")
	
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
		
	if(_action == "pickzone"):
		pickedZone = _args[0]
		setState("pickwritingmenu")
		return
	if(_action == "doWrite"):
		var writingID:String = _args[0]
		ServiceLocator.safe_get_service(&"Player").addBodywriting(pickedZone, writingID, true)
		ServiceLocator.safe_get_service(&"Player").getInventory().removeXOfOrDestroy("PermanentMarker", 1)
		setState("afterwrite")
		return
	
	setState(_action)

func saveData():
	var data = super.saveData()

	data["pickedZone"] = pickedZone

	return data

func loadData(data):
	super.loadData(data)

	pickedZone = SAVE.loadVar(data, "pickedZone", BodyWritingsZone.ArmLeft)
