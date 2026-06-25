extends EventBase

func _init():
	id = "TaviQuest2TalkEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "hall_mainentrance")

func run(_triggerID, _args):
	if(!ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_Quest2Started", false) || ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_Quest2MetHer", false)):
		return
	
	if(ServiceLocator.safe_get_service(&"MainScene").getDays() > ServiceLocator.safe_get_service(&"MainScene").getModuleFlag("TaviModule", "Tavi_Quest2Day", 0)):
		addButtonUnlessLate("Tavi", "Wait for Tavi to show up", "talk")
	else:
		addDisabledButton("Tavi", "Wait until tomorrow before doing this")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "talk"):
		runScene("TaviQuest2Meet")
