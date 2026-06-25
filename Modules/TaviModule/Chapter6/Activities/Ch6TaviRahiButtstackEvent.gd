extends EventBase

func _init():
	id = "Ch6TaviRahiButtstackEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.WakeUpInCell)

func react(_triggerID, _args):
	if(getFlag("TaviModule.Ch6TaviAndRahiStackSceneHappened")):
		return false
	if(getModule("TaviModule").getSkillScore("taviSkillPetplay") < 7 || getModule("RahiModule").getSkillScore("rahiSkillPetplay") < 15):
		return false
	#ACEPREGEXPAC = Tavi/Rahi Buttstack scene can happen if either characters are pregnant
#	if(getCharacter("tavi").isVisiblyPregnant() || getCharacter("rahi").isVisiblyPregnant()):
#		return false
	if(ServiceLocator.safe_get_service(&"Player").hasBoundArms() || ServiceLocator.safe_get_service(&"Player").hasBoundLegs() || ServiceLocator.safe_get_service(&"Player").hasBlockedHands() || ServiceLocator.safe_get_service(&"Player").isBlindfolded() || ServiceLocator.safe_get_service(&"Player").isGagged()):
		return false
	
	setFlag("TaviModule.Ch6TaviAndRahiStackSceneHappened", true)
	runScene("Ch6TaviRahiButtstackScene", [true])
	return true

func getPriority():
	return 10

