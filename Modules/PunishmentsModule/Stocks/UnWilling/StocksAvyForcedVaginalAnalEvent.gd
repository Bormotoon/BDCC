extends EventBase

func _init():
	id = "StocksAvyForcedVaginalAnalEvent"

func registerTriggers(es):
	es.addTrigger(self, "StocksUnWillingSex")

func react(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"Player").hasVagina()):
		runScene("StocksAvyForcedVaginalAnal")
		return true

func getPriority():
	return 10

