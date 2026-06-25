extends EventBase
#ACEPREGEXPAC - Add this Event
func _init():
	id = "AlexIsTheFatherEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.TalkingToNPC, ["alexrynard"])

func react(_triggerID, _args):
	if(!getModuleFlag("AcePregExpac", "Alex_ToldIsFather", 1)) || !ServiceLocator.safe_get_service(&"Player").isHeavilyPregnant():
		return false
	if(!getFlag("AcePregExpac.Alex_CameInside", false)):
		return false
	
	setModuleFlag("AcePregExpac", "Alex_ToldIsFather", 0)
	runScene("TellAlexHeIsFatherScene")
	
	return true

func getPriority():
	return 10
