extends EventBase

func _init():
	id = "StealDrugsFromMedicalEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "medical_storage")
	
func run(_triggerID, _args):
	if(getFlag("MedicalModule.Medical_StoleDrugsToday")):
		addDisabledButton("Search", "You already stole drugs here today")
	else:
		saynn("There are some drugs you can steal here.")
		
		addButtonUnlessLate("Search", "Look around for things to steal", "stealdrugs")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "stealdrugs"):
		setFlag("MedicalModule.Medical_StoleDrugsToday", true)
		
		var medicalStorageLoot = load("res://Inventory/LootTable/MedicalStorageLoot.gd")
		var lootTable = medicalStorageLoot.new()
		
		var loot = lootTable.generateAndCreateItems()
		
		if(loot.has("items") && loot["items"].size() > 0):
			runScene("LootingScene", [loot])
			ServiceLocator.safe_get_service(&"MainScene").addMessage("You found some drugs to steal")
		else:
			ServiceLocator.safe_get_service(&"MainScene").addMessage("You didn't find anything")
			ServiceLocator.safe_get_service(&"MainScene").reRun()
