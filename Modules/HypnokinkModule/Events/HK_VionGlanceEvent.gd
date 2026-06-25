extends EventBase

func _init():
	id = "VionGlanceEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)

func react(_triggerID, _args):
	if(getFlag("HypnokinkModule.DidVionGlance", false) or getFlag("HypnokinkModule.DidVionIntroduction", false)):
		return
	if(ServiceLocator.safe_get_service(&"MainScene").getDays() < 4):
		return
	
	if(WorldPopulation.Inmates in ServiceLocator.safe_get_service(&"Player").getLocationPopulation()):
		var baseChance = 5
		
		if(RNG.chance(baseChance)):
			runScene("VionGlance")

		return false

func getPriority():
	return -5
