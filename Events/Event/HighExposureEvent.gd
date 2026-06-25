extends EventBase

func _init():
	id = "HighExposureEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.PCLookingForTrouble)

func react(_triggerID, _args):
	if(true): #Disabled because interactions
		return
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("ExposureEventCD", 0) > 0 && !isLookingForTrouble):
		ServiceLocator.safe_get_service(&"MainScene").increaseFlag("ExposureEventCD", -1)
		return
	
	if(ServiceLocator.safe_get_service(&"Player").hasEffect(StatusEffect.Exposed) || isLookingForTrouble):
		if(WorldPopulation.Inmates in ServiceLocator.safe_get_service(&"Player").getLocationPopulation()):
			var baseChance = 2.0 + min(5.0, 2.0*ServiceLocator.safe_get_service(&"Player").getExposure())
			baseChance *= ServiceLocator.safe_get_service(&"Player").getEncounterChanceModifierInmates()
			
			if(RNG.chance(baseChance) || isLookingForTrouble):
				ServiceLocator.safe_get_service(&"MainScene").setFlag("ExposureEventCD", randi_range(5, 10))
				
				var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-1, 1)))
				encounterLevel = Util.maxi(encounterLevel, 0)
				encounterLevel = Util.mini(encounterLevel, 15+randi_range(-1, 1))
				
				return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.HighExposureInmateEvent, [encounterLevel])

		return false

func getPriority():
	return 1
