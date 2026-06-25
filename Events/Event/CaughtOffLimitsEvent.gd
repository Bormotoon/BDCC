extends EventBase

func _init():
	id = "CaughtOffLimitsEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.PCLookingForTrouble)

func react(_triggerID, _args):
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	var baseChance = 30 + 10.0*ServiceLocator.safe_get_service(&"Player").getExposure()
	baseChance *= ServiceLocator.safe_get_service(&"Player").getEncounterChanceModifierStaff()
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("Trigger_CaughtOffLimitsCD", 0) > 0 && !isLookingForTrouble):
		ServiceLocator.safe_get_service(&"MainScene").increaseFlag("Trigger_CaughtOffLimitsCD", -1)
		return
	
	# Replaced with interactions
#	if(ServiceLocator.safe_get_service(&"World").getRoomByID(ServiceLocator.safe_get_service(&"Player").getLocation()).loctag_Greenhouses):
#		if(RNG.chance(baseChance) || isLookingForTrouble):
#			ServiceLocator.safe_get_service(&"MainScene").setFlag("Trigger_CaughtOffLimitsCD", 3)
#
#			var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-1, 1)))
#			encounterLevel = Util.maxi(encounterLevel, 0)
#			encounterLevel = Util.mini(encounterLevel, 15+randi_range(-1, 1))
#
#			return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.CaughtOffLimits, [encounterLevel])
#
	if(ServiceLocator.safe_get_service(&"World").getRoomByID(ServiceLocator.safe_get_service(&"Player").getLocation()).loctag_OldGuardsEncounter):
		if(RNG.chance(baseChance) || isLookingForTrouble):
			ServiceLocator.safe_get_service(&"MainScene").setFlag("Trigger_CaughtOffLimitsCD", 3)
			
			var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-4, 1)))
			encounterLevel = Util.maxi(encounterLevel, 0)
			encounterLevel = Util.mini(encounterLevel, 10+randi_range(-1, 1))
			
			return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.CaughtOffLimits, [encounterLevel])
#
#	if(ServiceLocator.safe_get_service(&"World").getRoomByID(ServiceLocator.safe_get_service(&"Player").getLocation()).loctag_EngineersEncounter):
#		if(RNG.chance(baseChance) || isLookingForTrouble):
#			ServiceLocator.safe_get_service(&"MainScene").setFlag("Trigger_CaughtOffLimitsCD", 3)
#
#			var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-2, 3)))
#			encounterLevel = Util.maxi(encounterLevel, 10)
#			encounterLevel = Util.mini(encounterLevel, 20+randi_range(-1, 1))
#
#			return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.CaughtOffLimitsByEnginner, [encounterLevel])
#
	return false

func getPriority():
	return 5
