extends EventBase

func _init():
	id = "LootableRoomEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom)

func run(_triggerID, _args):
	if(_args.size() == 0):
		return
	var roomID = _args[0]
	
	if(ServiceLocator.safe_get_service(&"MainScene").canLootRoom(roomID)):
		if(ServiceLocator.safe_get_service(&"Player").isBlindfolded() && !ServiceLocator.safe_get_service(&"Player").canHandleBlindness()):
			saynn("You have a strong feeling there is something to loot here but you can't do it while blindfolded..")
		else:
			var room = ServiceLocator.safe_get_service(&"World").getRoomByID(roomID)
			if(room == null):
				return
			
			var roomMessage = room.lootAroundMessage
			if(roomMessage == null || roomMessage == ""):
				roomMessage = "You notice something that you can loot here."
			
			saynn(roomMessage)
			addButton("Loot", "See what's here", "loot", [roomID])

func getPriority():
	return 1

func onButton(_method, _args):
	if(_method == "loot"):
		var roomID = _args[0]
		ServiceLocator.safe_get_service(&"MainScene").markRoomAsLooted(roomID)
		var room = ServiceLocator.safe_get_service(&"World").getRoomByID(roomID)
		
		var lootTableID = "base"
		if(room.lootTableId != null && room.lootTableId != ""):
			lootTableID = room.lootTableId
		
		var lootTable = GlobalRegistry.getLootTable(lootTableID)
		if(lootTable == null):
			lootTable = LootTableBase.new()
		
		var loot = lootTable.generateAndCreateItems()
		if(!loot.has("credits")):
			loot["credits"] = 0
		loot["credits"] += room.lootCredits
		if(!loot.has("items")):
			loot["items"] = []
		if(room.lootItemIds != null):
			for itemID in room.lootItemIds:
				var item = GlobalRegistry.createItem(itemID)
				if(item != null):
					loot["items"].append(item)
		
		if((loot.has("items") && loot["items"].size() > 0) || (loot.has("credits") && loot["credits"] > 0)):
			runScene("LootingScene", [loot])
		else:
			ServiceLocator.safe_get_service(&"MainScene").addMessage("You didn't find anything")
			ServiceLocator.safe_get_service(&"MainScene").reRun()
