extends EventBase

func _init():
	id = "TaviFirstEncounterEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "mining_nearentrance")

func react(_triggerID, _args):
	if(!ServiceLocator.safe_get_service(&"MainScene").getFlag("Mining_IntroducedToMinning") || ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_IntroducedTo")):
		return false
		
	ServiceLocator.safe_get_service(&"MainScene").setModuleFlag("TaviModule", "Tavi_IntroducedTo", true)
	ServiceLocator.safe_get_service(&"MainScene").applyWorldEdit("TaviWorldEdit")
	runScene("TaviFirstEncounterScene")
	return true

func getPriority():
	return 10
