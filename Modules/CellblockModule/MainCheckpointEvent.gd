extends EventBase

func _init():
	id = "MainCheckpointEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "hall_checkpoint")

func react(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("CellblockModule", "Cellblock_FreeToPassCheckpoint")):
		return false
	
	if(_args != null && _args.size() > 1 && _args[1] == Direction.North):
		if(ServiceLocator.safe_get_service(&"Player").getInventory().getItemsWithTag(ItemTag.Illegal).size() > 0 || ServiceLocator.safe_get_service(&"Player").getInventory().getEquippedItemsWithTag(ItemTag.Illegal).size() > 0):
			runScene("MainCheckpointScene")
			return true
	return false

func getPriority():
	return 100
