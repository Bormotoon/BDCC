extends EventBase

func _init():
	id = "GreenhouseStealEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "main_greenhouses")

func run(_triggerID, _args):
	if(!ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("CellblockModule", "Cellblock_GreenhouseLooted", false)):
		addButtonUnlessLate("Steal", "Try and steal something", "steal_apple")
	else:
		addDisabledButton("Steal", "Too dangerous to do this again today")

func getPriority():
	return 6

func onButton(_method, _args):
	if(_method == "steal_apple"):
#		ServiceLocator.safe_get_service(&"Player").getInventory().addItem(GlobalRegistry.createItem("appleitem"))
#		ServiceLocator.safe_get_service(&"MainScene").addMessage("You stole an apple")
#		ServiceLocator.safe_get_service(&"MainScene").reRun()
		runScene("StealingFromGreenhouseScene")
		
