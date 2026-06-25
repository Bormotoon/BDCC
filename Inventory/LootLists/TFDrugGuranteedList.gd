extends LootList

func _init():
	handlesAll = true

func getLoot(_id, _characterID, _battleName):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene")) || !ServiceLocator.safe_get_service(&"MainScene").SCI):
		return []
	
	if(_characterID == ServiceLocator.safe_get_service(&"MainScene").SCI.peekRandomNpcIDForStrangeDrug()):
		ServiceLocator.safe_get_service(&"MainScene").SCI.clearRandomNpcIDForStrangeDrug() # Maybe will lead to problems. Oh well
		return [
			[100.0, [["TFPill", 1, 1]]],
		]
	
	return [
	]
