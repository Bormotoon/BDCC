extends EventBase

func _init():
	id = "EnterMedicalEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "med_lobbynw")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "med_lobbynw")
	es.addTrigger(self, Trigger.EnteringRoom, "med_lobbyne")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "med_lobbyne")

func run(_triggerID, _args):
	var hasLabAccess:bool = getModule("ElizaModule").hasLabAccess()
	if(!hasLabAccess):
		return
	
	addButton("Enter", "Enter the medical block", "enter")
	
func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "enter"):
		if(ServiceLocator.safe_get_service(&"Player").getLocation() == "med_lobbynw"):
			ServiceLocator.safe_get_service(&"Player").setLocation("med_staffonly_door1")
		else:
			ServiceLocator.safe_get_service(&"Player").setLocation("med_staffonly_door2")
		ServiceLocator.safe_get_service(&"MainScene").reRun()
