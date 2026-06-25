extends EventBase

func _init():
	id = "CaughtOffLimitsInMentalEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)
	es.addTrigger(self, Trigger.PCLookingForTrouble)

func react(_triggerID, _args):
	if(true): # Disabled because of interactions
		return
	var isLookingForTrouble = (_triggerID == Trigger.PCLookingForTrouble)
	var baseChance = 30 + 10.0*ServiceLocator.safe_get_service(&"Player").getExposure()
	baseChance *= ServiceLocator.safe_get_service(&"Player").getEncounterChanceModifierStaff()
	
	if(ServiceLocator.safe_get_service(&"MainScene").getFlag("Trigger_CaughtOffLimitsCD", 0) > 0 && !isLookingForTrouble):
		return
	
	#if(!RNG.chance(30 + 10.0*ServiceLocator.safe_get_service(&"Player").getExposure()) || !ServiceLocator.safe_get_service(&"World").getRoomByID(ServiceLocator.safe_get_service(&"Player").getLocation()).loctag_MentalWard):
	#	return false
	
	if(ServiceLocator.safe_get_service(&"World").getRoomByID(ServiceLocator.safe_get_service(&"Player").getLocation()).loctag_MentalWard):
		if(RNG.chance(baseChance) || isLookingForTrouble):
			ServiceLocator.safe_get_service(&"MainScene").setFlag("Trigger_CaughtOffLimitsCD", 3)
			
			var encounterLevel = randi_range(0, Util.maxi(0, ServiceLocator.safe_get_service(&"Player").getLevel() + randi_range(-4, 1)))
			encounterLevel = Util.maxi(encounterLevel, 0)
			encounterLevel = Util.mini(encounterLevel, 10+randi_range(-1, 1))
			
			return ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.CaughtOffLimitsByNurse, [encounterLevel])
	
	#ServiceLocator.safe_get_service(&"MainScene").setFlag("Trigger_CaughtOffLimitsCD", 3)
	#runScene(RNG.pick([
	#	"NurseFelineOffLimits",
	#	]))
	#return true
	return false

func getPriority():
	return 5

