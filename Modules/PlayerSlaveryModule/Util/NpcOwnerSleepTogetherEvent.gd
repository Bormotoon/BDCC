extends EventBase

func _init():
	id = "NpcOwnerSleepTogetherEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.SleepInCell)

func react(_triggerID, _args):
	var possible:Array = []
	for charID in ServiceLocator.safe_get_service(&"MainScene").RS.special:
		var theSpecial:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.special[charID]
		if(theSpecial.id != "SoftSlavery"):
			continue
		var theNpcOwner:NpcOwnerBase = theSpecial.npcOwner
		if(!theNpcOwner):
			continue
		if(theNpcOwner.checkShouldSleepTogether()):
			possible.append(charID)
	
	if(possible.is_empty()):
		return false
	runScene("NpcOwnerSleepTogetherScene", [RNG.pick(possible)])
	return true

func getPriority():
	return 10

