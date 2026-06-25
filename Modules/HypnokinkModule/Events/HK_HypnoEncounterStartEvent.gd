extends EventBase

func _init():
	id = "HypnoEncounterStartEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.PCLookingForTrouble)

func react(_triggerID, _args):
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	
	if(not ServiceLocator.safe_get_service(&"Player").hasPerk(Perk.HypnosisFamousDrawback)):
		return
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.HypnoEncounterCooldown", 0) > 0 && !isLookingForTrouble):
		ServiceLocator.safe_get_service(&"MainScene").increaseFlag("HypnokinkModule.HypnoEncounterCooldown", -1)
		return
	
	if(WorldPopulation.Inmates in ServiceLocator.safe_get_service(&"Player").getLocationPopulation()):
		var baseChance:float = 0.5 + min(100.0, HypnokinkUtil.getSuggestibleStacks(ServiceLocator.safe_get_service(&"Player"))) * 0.01
		baseChance *= ServiceLocator.safe_get_service(&"Player").getEncounterChanceModifierInmates()
		
		if(RNG.chance(baseChance) || isLookingForTrouble):
			ServiceLocator.safe_get_service(&"MainScene").setFlag("HypnokinkModule.HypnoEncounterCooldown", randi_range(10, 60))
			
			var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-1, 1)))
			encounterLevel = Util.maxi(encounterLevel, 0)
			encounterLevel = Util.mini(encounterLevel, 15+randi_range(-1, 1))
			
			return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.HypnoEncounter, [encounterLevel, WorldPopulation.Inmates])

		return false

func getPriority():
	return 1
