extends EventBase

func _init():
	id = "Ch2e1ElizaTalkEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.TalkingToNPC, "eliza")
	
func run(_triggerID, _args):
	if(ServiceLocator.safe_get_service(&"QuestSystem").isActive("Ch2ElizaQuest") && !getFlag("TaviModule.ch2ElizaBeganCheckup")):
		addButtonUnlessLate("Mission", "You need to steal the drugs from Eliza", "startcheckup")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "startcheckup"):
		ServiceLocator.safe_get_service(&"MainScene").endCurrentScene()
		runScene("Ch2e1MedicalCheckup")
		setFlag("TaviModule.ch2ElizaBeganCheckup", true)

