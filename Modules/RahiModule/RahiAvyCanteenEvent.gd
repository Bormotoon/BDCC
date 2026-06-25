extends EventBase

func _init():
	id = "RahiAvyCanteenEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EatingInCanteen)

func react(_triggerID, _args):
	if(RNG.chance(50) || !ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("RahiModule", "Rahi_Introduced") || ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("RahiModule", "Rahi_CanteenSceneHappened")):
		return false
	
	if(doEventCheck("RahiBusy") != null):
		return false
	
	runScene("RahiAvyCanteenScene")
	return true

func getPriority():
	return 5
