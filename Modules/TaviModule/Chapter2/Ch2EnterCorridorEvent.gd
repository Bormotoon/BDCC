extends EventBase

func _init():
	id = "Ch2EnterCorridorEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "eng_bay_corridor")
	es.addTrigger(self, Trigger.EnteringRoom, "eng_bay_nearbreakroom")
	
func run(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"Player").getLocation() != "eng_bay_corridor"):
		addButton("Corridor", "Leave the secure corridor", "exitsecure")
	
	if(ServiceLocator.safe_get_service(&"QuestSystem").isCompleted("Ch2AlexQuest") || getFlag("AlexRynardModule.ch2CanEnterEngineering")):
		if(ServiceLocator.safe_get_service(&"Player").getLocation() == "eng_bay_corridor"):
			addButton("Corridor", "Enter the secure corridor", "entersecure")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "entersecure"):
		ServiceLocator.safe_get_service(&"Player").setLocation("eng_bay_nearbreakroom")
		ServiceLocator.safe_get_service(&"MainScene").reRun()
	if(_method == "exitsecure"):
		ServiceLocator.safe_get_service(&"Player").setLocation("eng_bay_corridor")
		ServiceLocator.safe_get_service(&"MainScene").reRun()

