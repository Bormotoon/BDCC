extends EventBase

func _init():
	id = "TaviQuest2ElevatorEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.InsideElevator)

func run(_triggerID, _args):
	if(!ServiceLocator.safe_get_service(&"QuestSystem").isActive("TaviQuest2") || !getModuleFlag("TaviModule", "Tavi_Quest2MetHer", false)):
		return
	
	if(ServiceLocator.safe_get_service(&"Player").getLocation() == "cd_elevator"):
		return
	addButton("Command deck", "Where all the higher-ups live", "commanddeck")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "commanddeck"):
		ServiceLocator.safe_get_service(&"Player").setLocation("cd_elevator")
		ServiceLocator.safe_get_service(&"MainScene").endCurrentScene()
		ServiceLocator.safe_get_service(&"MainScene").reRun()
