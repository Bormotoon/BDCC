extends EventBase

func _init():
	id = "NovaFirstTimePregnantEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.WakeUpInCell)

func react(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("NovaModule", "Nova_FirstTimePregnantHappened", false) || !GlobalRegistry.getCharacter("nova").isVisiblyPregnantFromPlayer()):
		return false
	
	ServiceLocator.safe_get_service(&"MainScene").setModuleFlag("NovaModule", "Nova_FirstTimePregnantHappened", true)
	runScene("NovaFirstTimePregnantScene")
	
	return true
	
func getPriority():
	return 11

