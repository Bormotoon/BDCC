extends EventBase

func _init():
	id = "CaughtFirstTimeEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.MasturbationSpottedInmate)
	es.addTrigger(self, Trigger.MasturbationSpottedGuard)

func react(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("PunishmentsModule.FirstTimeCaughtMasturbating")):
		return
	
	if(_triggerID == Trigger.MasturbationSpottedInmate):
		runScene("CaughtFirstTimeInmate")
	if(_triggerID == Trigger.MasturbationSpottedGuard):
		runScene("CaughtFirstTimeStaff")
	
	ServiceLocator.safe_get_service(&"MainScene").setFlag("PunishmentsModule.FirstTimeCaughtMasturbating", true)
	return true

func getPriority():
	return 100000
