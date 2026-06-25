extends LootList

func _init():
	handlesIds = ["guard", "inmate", "engineer", "medical", "junkie"]

func getLoot(_id, _characterID, _battleName):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return []
	
	if(!ServiceLocator.safe_get_service(&"Player").hasPermanentBodywritings()):
		return []

	return [
		[5.0, [["Soap", 1, 1]]],
	]
