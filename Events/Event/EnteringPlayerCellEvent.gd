extends EventBase

func _init():
	id = "EnteringPlayerCellEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "cellblock_orange_playercell")
	es.addTrigger(self, Trigger.EnteringRoom, "cellblock_red_playercell")
	es.addTrigger(self, Trigger.EnteringRoom, "cellblock_pink_playercell")

func react(_triggerID, _args):
	if(_args.size() > 0 && _args[0] == ServiceLocator.safe_get_service(&"Player").getCellLocation()):
		return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.EnteringPlayerCell)
		
	return false

func run(_triggerID, _args):
	if(_args.size() > 0 &&_args[0] == ServiceLocator.safe_get_service(&"Player").getCellLocation()):
		ServiceLocator.safe_get_service(&"EventSystem").triggerRun(Trigger.EnteringPlayerCell)

func getPriority():
	return 4
