extends LootList

func _init():
	handlesIds = ["guard", "inmate", "engineer", "medical", "junkie"]

func getLoot(_id, _characterID, _battleName):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return []
	
	var mod:float = 1.0
	if(_id == "medical"):
		mod = 5.0
	if(ServiceLocator.safe_get_service(&"MainScene") && !ServiceLocator.safe_get_service(&"MainScene").getFlag("ElizaModule.s1hap")):
		mod *= 0.2
	
	var hasTFs:bool = ServiceLocator.safe_get_service(&"Player").hasActiveTransformations()
	if(!hasTFs):
		return [
			[5.0*mod*(0.1 if _id != "inmate" else 1.0), [["TFPill", 1, 1]]],
		]

	
	var undoAmount:int = ServiceLocator.safe_get_service(&"Player").getInventory().getAmountOf("TFUndoPill")
	var applyAmount:int = ServiceLocator.safe_get_service(&"Player").getInventory().getAmountOf("TFApplyPill")
	
	return [
		[5.0*mod*(0.0 if undoAmount > 0 else 1.0), [["TFUndoPill", 1, 1]]],
		[5.0*mod, [["TFAcceleratePill", 1, 1]]],
		[5.0*mod*(0.0 if applyAmount > 0 else 1.0), [["TFApplyPill", 1, 1]]],
		[5.0*mod*(0.1 if _id != "inmate" else 1.0), [["TFPill", 1, 1]]],
	]
