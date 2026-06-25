extends EventBase

func _init():
	id = "SlaverySlutProstitutionEvents"

func registerTriggers(_es):
	#es.addTrigger(self, Trigger.EnteringRoom)
	#es.addTrigger(self, Trigger.EnteringRoomWithSlave)
	#es.addTrigger(self, Trigger.PCLookingForTrouble)
	pass


func run(_triggerID, _args):
	if(!(WorldPopulation.Inmates in ServiceLocator.safe_get_service(&"Player").getLocationPopulation())):
		return
	
	if(getFlag("NpcSlaveryModule.slutBigEventCooldown", 0) > 0):
		increaseFlag("NpcSlaveryModule.slutBigEventCooldown", -1)
	
	var cooldown = getFlag("NpcSlaveryModule.slutEventCooldown", 0)
	if(cooldown > 0):
		increaseFlag("NpcSlaveryModule.slutEventCooldown", -1)
	if(getFlag("NpcSlaveryModule.slutEventCooldown", 0) <= 0):
		setFlag("NpcSlaveryModule.slutEventCooldown", randi_range(8, 15))
	else:
		return

	if(RNG.chance(30)):
		return
	
	var slaves = ServiceLocator.safe_get_service(&"MainScene").getPCSlavesIDs()
	var allWorkingSluts = []
	for slaveID in slaves:
		var theChar:DynamicCharacter = getCharacter(slaveID)
		if(theChar == null || !theChar.isSlaveToPlayer()):
			continue
		var npcSlavery:NpcSlave = theChar.getNpcSlavery()
		if(npcSlavery.isDoingActivity() && npcSlavery.getActivityID() == "Prostitution"):
			allWorkingSluts.append(theChar)
	
	if(allWorkingSluts.size() <= 0):
		return
	
	var randomSlave = RNG.pick(allWorkingSluts)
	
	saynn("You notice one of your working sluts, "+randomSlave.getName()+".")
	addButton(randomSlave.getName()+" (slut)", "See what your slut is doing", "lookslut", [randomSlave.getID()])
	
func onButton(_method, _args):
	if(_method == "lookslut"):
		setFlag("NpcSlaveryModule.slutEventCooldown", 10)
		if(!ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.SlaverySlutLookAtEvent, _args)):
			addMessage("The slut didn't react to you")
			ServiceLocator.safe_get_service(&"MainScene").reRun()
		#runScene("SlutProstitutionWatch", [_args[0]])
	
	
func react(_triggerID, _args):
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	
	if(getFlag("NpcSlaveryModule.slutEventCooldown", 0) != 1 && !isLookingForTrouble):
		return false
	if(!(WorldPopulation.Inmates in ServiceLocator.safe_get_service(&"Player").getLocationPopulation())):
		return false

	var slaves = ServiceLocator.safe_get_service(&"MainScene").getPCSlavesIDs()
	var allWorkingSluts = []
	var canGetCreds = []
	for slaveID in slaves:
		var theChar:DynamicCharacter = getCharacter(slaveID)
		if(theChar == null || !theChar.isSlaveToPlayer()):
			continue
		var npcSlavery:NpcSlave = theChar.getNpcSlavery()
		if(npcSlavery.isDoingActivity() && npcSlavery.getActivityID() == "Prostitution"):
			var prostitution = npcSlavery.getActivity()
			if(prostitution.canReceiveCredits()):
				canGetCreds.append(theChar)
			allWorkingSluts.append(theChar)

	if(canGetCreds.size() > 0):
		var randomChar = RNG.pick(canGetCreds)
		
		runScene("SlutProstitutionReceiveCredits", [randomChar.getID()])
		return true
	
	if((RNG.chance(20) || isLookingForTrouble) && allWorkingSluts.size() > 0 && (getFlag("NpcSlaveryModule.slutBigEventCooldown", 0)<=0 || isLookingForTrouble)):
		var randomChar = RNG.pick(allWorkingSluts)
		
		setFlag("NpcSlaveryModule.slutBigEventCooldown", randi_range(20, 100))
		#runScene("SlutProstitutionWatch", [randomChar.getID(), true])
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.SlaverySlutImportantEvent, [randomChar.getID()])):
			return true
	return false
	
func getPriority():
	return 1
