extends EventBase

func _init():
	id = "DrugDenStartEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "yard_deadend2")

func run(_triggerID, _args):
	if(getModule("ElizaModule") != null && getModule("ElizaModule").canStartDrugDenRun()):
		addButton("Drug Den", "Begin your adventure", "start")
	
func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "start"):
		#ServiceLocator.safe_get_service(&"MainScene").DrugDenRun = DrugDen.new()
		#ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.start()
		runScene("DrugDenStartScene")
