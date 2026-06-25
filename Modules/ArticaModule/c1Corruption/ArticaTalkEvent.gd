extends EventBase

func _init():
	id = "ArticaTalkEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "main_bench3")

func run(_triggerID, _args):
	if(!getFlag("ArticaModule.corruptionBegan", false)):
		return
	if(getFlag("ArticaModule.lastQuestStarted") && !getFlag("ArticaModule.LQArticaGotDreamCatcher") && !getFlag("ArticaModule.LQArticaGotBrainwashed")):
		addDisabledButton("Artica", "Artica is in her cell")
		return
	
	if(checkCharacterBusy("ArticaBusy", "Seems like the fluff is not here", "Artica")):
		return
	
	if(ServiceLocator.safe_get_service(&"MainScene").getDays() < getFlag("ArticaModule.busyUntilDay", -1)):
		saynn("Seems like the fluff is not here")
		
		addDisabledButton("Artica", "She is not here today")
		return
	
	addButtonUnlessLate("Artica", "Talk with the herm fluff", "talk")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "talk"):
		ServiceLocator.safe_get_service(&"MainScene").applyWorldEdit("ArticaWorldEdit")
		if(getCharacter("artica").hasEffect(StatusEffect.ArticaFullWithPlantEggs)):
			var fullWithEggs = getCharacter("artica").getEffect(StatusEffect.ArticaFullWithPlantEggs)
			if(fullWithEggs.turns <= 0):
				runScene("articaEventTentacles4Scene")
				return
		
		if(!getFlag("ArticaModule.lastQuestStarted") && getModule("ArticaModule").getCorruption() >= 1.0):
			setFlag("ArticaModule.lastQuestStarted", true)
			runScene("articaLastQuest1Scene")
			return
		
		if(!ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.TalkingToNPC, ["artica"])):
			getCharacter("artica").removeStrapon()
			runScene("articaTalkScene")
