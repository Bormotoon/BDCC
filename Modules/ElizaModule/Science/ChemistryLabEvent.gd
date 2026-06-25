extends EventBase

func _init():
	id = "ChemistryLabEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "med_researchlab")
	es.addTrigger(self, Trigger.TalkingToNPC, "eliza")

func run(_triggerID, _args):
	if(_triggerID == Trigger.TalkingToNPC):
		if(ServiceLocator.safe_get_service(&"Player").getTFHolder().hasActiveTransformations()):
			addButton("I'm transformed!", "Ask the feline to help you with your changing body", "ask_help_tf")
	
	var hasLabAccess:bool = getModule("ElizaModule").hasLabAccess()
	if(!hasLabAccess):
		return

	if(_triggerID == Trigger.TalkingToNPC):
		if(getFlag("ElizaModule.s2hap") && ServiceLocator.safe_get_service(&"MainScene").SCI.doesPCHaveUnknownStrangePills()):
			addButton("Strange pill!", "Make Eliza scan the strange pill that you have", "scan_strange_pill")
		if(ServiceLocator.safe_get_service(&"MainScene").SCI.hasTFsCanScan(ServiceLocator.safe_get_service(&"Player"))):
			addButton("Get scanned!", "Make Eliza scan the effects of your current transformations", "scan_tfs")
		return
	#if(getFlag("ElizaModule.firstDrugTestHappened")):
	addButton("Lab", "Look at the lab", "lab")
	
func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "lab"):
		runScene("ChemistryLabScene")
	if(_method == "scan_strange_pill"):
		ServiceLocator.safe_get_service(&"MainScene").endCurrentScene()
		runScene("ElizaGenericUnlockDrugScene")
	if(_method == "scan_tfs"):
		ServiceLocator.safe_get_service(&"MainScene").endCurrentScene()
		runScene("ElizaGenericTestDrugScene")
	if(_method == "ask_help_tf"):
		runScene("ElizaHelpGotTransformedScene")
