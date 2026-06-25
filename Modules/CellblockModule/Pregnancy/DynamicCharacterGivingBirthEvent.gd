extends EventBase

func _init():
	id = "DynamicCharacterGivingBirthEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.TalkingToDynamicNPC)

func react(_triggerID, _args):
	var npcID = _args[0]
	var character = getCharacter(npcID)
	if(character == null || !character.isReadyToGiveBirth() || !character.supportsDefaultGiveBirthScene()):
		return false
	
	ServiceLocator.safe_get_service(&"MainScene").IS.deletePawn(npcID)
	runScene("DynamicCharacterGivingBirthScene", [npcID])
	return true

func getPriority():
	return 10
