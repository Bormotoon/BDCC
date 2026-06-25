extends EventBase

func _init():
	id = "AdvancedPenisPumpEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.Waiting)
	es.addTrigger(self, Trigger.WakeUpInCell)
	es.addTrigger(self, Trigger.TakingAShower)
	
func react(_triggerID, _args):
	var currentTime = ServiceLocator.safe_get_service(&"MainScene").getTimeInGlobalSeconds()
	var lastTimeMilked = getFlag("MedicalModule.AdvPenisPumpLastMilked", 0)
	
	# Means this event runs every 30 minutes basically
	if(currentTime >= (lastTimeMilked + 60*30) || _triggerID == Trigger.WakeUpInCell):
		setFlag("MedicalModule.AdvPenisPumpLastMilked", currentTime)
	else:
		return false
	
	if(!ServiceLocator.safe_get_service(&"Player").getInventory().hasItemIDEquipped("PenisPumpAdvanced") || !ServiceLocator.safe_get_service(&"Player").hasPenis()):
		return false
	
	var cumProducion = ServiceLocator.safe_get_service(&"Player").getBodypart(BodypartSlot.Penis).getFluidProduction()
	if(cumProducion == null):
		return false
	
	if(ServiceLocator.safe_get_service(&"Player").canBeSeedMilked() && cumProducion.getFluidLevel()>=1.0):
		var penisPump = ServiceLocator.safe_get_service(&"Player").getInventory().getEquippedItemByID("PenisPumpAdvanced")
		if(penisPump == null):
			return false
		
		ServiceLocator.safe_get_service(&"Player").addSkillExperience(Skill.Breeder, 10)
		var howMuchTransferred = ServiceLocator.safe_get_service(&"Player").getBodypart(BodypartSlot.Penis).getFluids().transferTo(penisPump, 1.0)
		ServiceLocator.safe_get_service(&"Player").orgasmFrom("pc")
		if(howMuchTransferred > 0.0):
			ServiceLocator.safe_get_service(&"MainScene").addMessage("Your penis pump engages, milking your cock until you orgasm hard! It collects "+str(Util.roundF(howMuchTransferred))+" ml of {pc.cum} during your orgasm.")
			
			if(penisPump.getFluids().isFull()):
				ServiceLocator.safe_get_service(&"MainScene").addMessage("Your penis pump is now full!")
		

	return false
	
func getPriority():
	return 20
