extends EventBase

func _init():
	id = "NemesisAmbushEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.AboutToSleepInCell)
	es.addTrigger(self, Trigger.EatingInCanteen)
	es.addTrigger(self, Trigger.TakingAShower)
	#es.addTrigger(self, Trigger.EnteringRoom) # The interaction itself is now doing it

func getPriority():
	return 5.0

func react(_triggerID, _args):
	if(_triggerID == Trigger.EnteringRoom):
		if(tryStartAmbush("normal", true)):
			return true
	elif(_triggerID == Trigger.AboutToSleepInCell):
		if(tryStartAmbush("cell")):
			return true
	elif(_triggerID == Trigger.TakingAShower):
		if(tryStartAmbush("shower")):
			return true
	elif(_triggerID == Trigger.EatingInCanteen):
		if(tryStartAmbush("canteen")):
			return true
	
	return false

func getNearbyAmbushInteraction(onlySameLoc:bool = false) -> PawnInteractionBase:
	for charID in ServiceLocator.safe_get_service(&"MainScene").RS.special:
		var theSpecial:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.special[charID]
		if(theSpecial.id != "Nemesis"):
			continue
		var thePawn := ServiceLocator.safe_get_service(&"MainScene").IS.getPawn(charID)
		if(!thePawn):
			continue
		var theInteraction:PawnInteractionBase = thePawn.getInteraction()
		if(!theInteraction || theInteraction.id != "NemesisAmbush"):
			continue
		if(!theInteraction.canAmbush()):
			continue
		if(onlySameLoc && theInteraction.getLocation() != ServiceLocator.safe_get_service(&"Player").getLocation()):
			continue
		return theInteraction
	return null

func startAmbushScene(_interaction:PawnInteractionBase, _type:String):
	runScene("NemesisAmbushScene", [_type, _interaction.getRoleID("main"), _interaction.getRoleID("extra1"), _interaction.getRoleID("extra2")])

func tryStartAmbush(_type:String, onlySameLoc:bool = false) -> bool:
	var theInteraction := getNearbyAmbushInteraction(onlySameLoc)
	if(!theInteraction):
		return false
	startAmbushScene(theInteraction, _type)
	return true
