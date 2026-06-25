extends Module

func getFlags():
	return {
		"slavesSpace": flag(FlagType.Number),
		
		"hasSybian": flag(FlagType.Bool),
		"hasWoodenHorse": flag(FlagType.Bool),
		
		
		"debugSlaveInfo": flag(FlagType.Bool),
		
		"slutEventCooldown": flag(FlagType.Number),
		"slutBigEventCooldown": flag(FlagType.Number),
		"pupEventCooldown": flag(FlagType.Number),
	}

func _init():
	id = "NpcSlaveryModule"
	author = "Rahi"
	
	scenes = [
			"res://Modules/NpcSlaveryModule/SocketBuyCellUpgradesScene.gd",
		
			"res://Modules/NpcSlaveryModule/Enslaving/EnslaveDynamicNpcScene.gd",
			"res://Modules/NpcSlaveryModule/Enslaving/KidnapDynamicNpcScene.gd",
			
			"res://Modules/NpcSlaveryModule/Slavery/SlaveTalkScene.gd",
			"res://Modules/NpcSlaveryModule/Slavery/SlavesCheckScene.gd",
			"res://Modules/NpcSlaveryModule/Slavery/SlaveStartActionScene.gd",
			"res://Modules/NpcSlaveryModule/Slavery/SlaveActionWrapperScene.gd",
			"res://Modules/NpcSlaveryModule/Slavery/SlaveEventWrapperScene.gd",
			"res://Modules/NpcSlaveryModule/Slavery/SlaveTPToLocScene.gd",
			
			"res://Modules/NpcSlaveryModule/Devices/SybianRidingScene.gd",
		]
	characters = [
	]
	items = []
	events = [
		"res://Modules/NpcSlaveryModule/Enslaving/EnslaveDynamicNpcEvent.gd",
		"res://Modules/NpcSlaveryModule/Slavery/SlaveTalkEvent.gd",
		"res://Modules/NpcSlaveryModule/Slavery/SlaveEventEvent.gd",
		
		"res://Modules/NpcSlaveryModule/Devices/PlayerCellDevicesEvent.gd",
	]

func resetFlagsOnNewDay():
	pass

func getSlavesSpace() -> int:
	return int(getFlag("NpcSlaveryModule.slavesSpace", 0))

func canEnslave():
	return getSlavesSpace()

func canKidnapCharacterReason(character) -> Array:
	var theSpecialRelationship:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.getSpecialRelationship(character.getID())
	if(theSpecialRelationship):
		var theSpecialCanInfo:Array = theSpecialRelationship.canEnslaveReason(true)
		if(!theSpecialCanInfo[0]):
			return [theSpecialCanInfo[0], theSpecialCanInfo[1]]
	
	var enslaveQuest:NpcEnslavementQuest = character.getEnslaveQuest()
	if(!enslaveQuest):
		return [false, "They are not prepared for this!"] # Shouldn't see this
	if(!enslaveQuest.isEverythingCompleted()):
		return [false, "They are not ready to be kidnapped"]
		
	return [true]

func canStartEnslavingCharacterReason(character) -> Array:
	var theSpecialRelationship:SpecialRelationshipBase = ServiceLocator.safe_get_service(&"MainScene").RS.getSpecialRelationship(character.getID())
	if(theSpecialRelationship):
		var theSpecialCanInfo:Array = theSpecialRelationship.canEnslaveReason(false)
		if(!theSpecialCanInfo[0]):
			return [theSpecialCanInfo[0], theSpecialCanInfo[1]]
	
	var pcRestraintsPreventChoking:bool = ServiceLocator.safe_get_service(&"Player").hasBlockedHands() || ServiceLocator.safe_get_service(&"Player").hasBoundArms()
	if(pcRestraintsPreventChoking):
		return [false, "You can't do that with restraints on your arms.."]
	if(!character.getInventory().hasEquippedItemWithTag(ItemTag.AllowsEnslaving)):
		return [false, "They need to be wearing a collar for you to be able to enslave them"]
	
	return [true]

func getSlaves():
	return ServiceLocator.safe_get_service(&"MainScene").getDynamicCharacterIDsFromPool(CharacterPool.Slaves)

func hasSlaves():
	return int(ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPoolSize(CharacterPool.Slaves)) > 0

func hasFreeSpaceToEnslave():
	var currentSlaveAmount = int(ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPoolSize(CharacterPool.Slaves))

	var freeSpace = getSlavesSpace() - currentSlaveAmount
	return freeSpace > 0

func makeSurePCHasSlaveSpace():
	var currentSlaveAmount = int(ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPoolSize(CharacterPool.Slaves))

	var freeSpace = getSlavesSpace() - currentSlaveAmount
	if(freeSpace <= 0):
		setFlag("NpcSlaveryModule.slavesSpace", currentSlaveAmount + 1)

func slavesHaveAnyEvents():
	var slaves = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharacterIDsFromPool(CharacterPool.Slaves)
	
	for charID in slaves:
		var character:DynamicCharacter = GlobalRegistry.getCharacter(charID)
		var npcSlavery:NpcSlave = character.getNpcSlavery()
		if(npcSlavery == null):
			continue
		if(npcSlavery.hasRandomEventToTrigger()):
			return true
	return false

func getSlavesSpaceUpgradeCost():
	var currentSpace = getSlavesSpace()
	
	if(currentSpace == 0):
		return 30
	return currentSpace * 10
	
func doEnslaveCharacter(npcID, defaultSlaveType = SlaveType.Slut):
	var theChar:DynamicCharacter = GlobalRegistry.getCharacter(npcID)
	
	if(theChar == null || !theChar.isDynamicCharacter()):
		return false
	if(theChar.isSlaveToPlayer()):
		return false
	
	var theEnslaveQuest:NpcEnslavementQuest = theChar.getEnslaveQuest()
	theChar.setEnslaveQuest(null)
	
	var slaveType = defaultSlaveType
	if(theEnslaveQuest != null):
		slaveType = theEnslaveQuest.slaveType
	
	var newNpcSlavery = NpcSlave.new()
	newNpcSlavery.setChar(theChar)
	newNpcSlavery.setMainSlaveType(slaveType)
	newNpcSlavery.slaveSpecializations = {
		slaveType: 0,
	}
	#newNpcSlavery.generateTasks()
	theChar.setNpcSlavery(newNpcSlavery)
	newNpcSlavery.onEnslave()
	
	ServiceLocator.safe_get_service(&"MainScene").IS.deletePawn(npcID)
	ServiceLocator.safe_get_service(&"MainScene").removeDynamicCharacterFromAllPools(npcID)
	ServiceLocator.safe_get_service(&"MainScene").addDynamicCharacterToPool(npcID, CharacterPool.Slaves)
	
	ServiceLocator.safe_get_service(&"MainScene").RS.onGettingEnslavedByPlayer(npcID)
	
	return true

func doFreeEnslavedCharacter(npcID):
	var theChar:DynamicCharacter = GlobalRegistry.getCharacter(npcID)
	
	if(theChar == null || !theChar.isDynamicCharacter()):
		return false
	if(!theChar.isSlaveToPlayer()):
		return false
	
	#var npcSlavery:NpcSlave = theChar.getNpcSlavery()
	theChar.setEnslaveQuest(null)
	theChar.setNpcSlavery(null)
	
	ServiceLocator.safe_get_service(&"MainScene").removeDynamicCharacterFromAllPools(npcID)
	var newPool = theChar.getCharacterPool()
	if(newPool != null):
		ServiceLocator.safe_get_service(&"MainScene").addDynamicCharacterToPool(npcID, newPool)
	
