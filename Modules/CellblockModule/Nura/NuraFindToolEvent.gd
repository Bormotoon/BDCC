extends EventBase

func _init():
	id = "NuraFindToolEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "eng_assemblylab")

func run(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("CellblockModule.FoundNura")):
		if(!ServiceLocator.safe_get_service(&"MainScene").getFlag("CellblockModule.NuraFoundTool")):
			saynn("You notice some kind of tool one of the worktables. An industrial-sized syringe with some circuitry attached.")
		
			addButton("Syringe tool", "Grab it", "nura")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "nura"):
		ServiceLocator.safe_get_service(&"MainScene").addMessage("You grab the syringe tool and store it. Maybe someone here can use it. But not you.")
		
		ServiceLocator.safe_get_service(&"MainScene").setFlag("CellblockModule.NuraFoundTool", true)
		ServiceLocator.safe_get_service(&"MainScene").reRun()
