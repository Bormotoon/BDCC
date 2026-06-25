extends SceneBase

var inventoryScreenScene = preload("res://UI/Inventory/InventoryScreen.tscn")

var npcID = ""
var npc:DynamicCharacter

var itemPutonMessage = ""

func _initScene(_args = []):
	npcID = _args[0]
	npc = GlobalRegistry.getCharacter(npcID)

func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID

func _init():
	sceneID = "ActionSlaveryManageInventory"

func _run():
	if(state == ""):
		addCharacter(npcID)
		
		saynn("What do you want to do?")
		
		#var items = getCharacter(npcID).getInventory().getAllItems()
		
		say("{npc.name}'s equipped items:\n")
		for slot in InventorySlot.getAll():
			if(!npc.getInventory().hasSlotEquipped(slot) && npc.invCanEquipSlot(slot)):
				#say(InventorySlot.getVisibleName(slot)+": "+"Nothing"+"\n")
				continue
			if(!npc.invCanEquipSlot(slot)):
				continue
			
			var item = npc.getInventory().getEquippedItem(slot)
			
			say(InventorySlot.getVisibleName(slot)+": "+item.getVisibleName()+"\n")
		
		say("\n")
		var items = npc.getInventory().getAllItems()
		var itemNames = []
		for item in items:
			itemNames.append(item.getStackName())
		say("{npc.name}'s stored items:\n")
		say(Util.join(itemNames, ", "))
		
		addButton("Give", "Give your slave something", "hideitemmenu")
		addButton("Take/Equip", "Take something from your slave or make them equip/unequip something", "takeitemmenu")
		addButton("Step away", "You're done", "endthescene")
	if(state == "hideitemmenu"):
		var theItems = []
		theItems.append_array(ServiceLocator.safe_get_service(&"Player").getInventory().getItems())
		#if(ServiceLocator.safe_get_service(&"Player").getCredits() > 0):
		#	var credsItem = GlobalRegistry.createItem("WorkCredit")
		#	credsItem.setAmount(ServiceLocator.safe_get_service(&"Player").getCredits())
		#	theItems.append(credsItem)
		
		var inventory = inventoryScreenScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("inventory", inventory)
		inventory.setItems(theItems, "give")
		var _ok = inventory.onItemSelected.connect(onInventoryItemSelected)
		var _ok2 = inventory.onInteractWith.connect(onInventoryItemInteracted)
		var _ok3 = inventory.onInteractWithGroup.connect(onInventoryItemGroupInteracted)
		addButton("Back", "Go back", "")
	
	if(state == "takeitemmenu"):
		var inventory = inventoryScreenScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("inventory", inventory)
		inventory.setItems(npc.getInventory().getItemsAndEquippedItemsTogetherGrouped(), "equiptake")
		#inventory.setItems(npc.getInventory().getAllItems(), "take")
		var _ok = inventory.onItemSelected.connect(onInventoryItemSelected)
		var _ok2 = inventory.onInteractWith.connect(onInventoryItemInteracted)
		var _ok3 = inventory.onInteractWithGroup.connect(onInventoryItemGroupInteracted)
		addButton("Back", "Go back", "")
	
	if(state == "item_toggle_message"):
		saynn(itemPutonMessage)
		
		addButton("Continue", "See what happens next", "takeitemmenu")

func _react(_action: String, _args):
	if(_action == "hideitem"):
		var item: ItemBase = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(_args[0])
		ServiceLocator.safe_get_service(&"Player").getInventory().removeItem(item)
		npc.getInventory().addItem(item)
		
		#setState("")
		return
	if(_action == "takeitem"):
		var item: ItemBase = npc.getInventory().getItemByUniqueID(_args[0])
		npc.getInventory().removeItem(item)
		ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
		
		#setState("")
		return
	if(_action == "stashx"):
		var item: ItemBase = _args[0]
		
		var newItem = item.splitAmount(_args[1])
		
		if(newItem != null):
			ServiceLocator.safe_get_service(&"Player").addCredits(-newItem.getAmount())
			npc.getInventory().addItem(newItem)
		
		return
		
	if(_action == "taketheitem"):
		var item: ItemBase = _args[0]
		npc.getInventory().removeItem(item)
		ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
		return
		
	if(_action == "takex"):
		var item: ItemBase = _args[0]
		
		var newItem = item.splitAmount(_args[1])
		
		if(newItem != null):
			if(item.id == "WorkCredit"):
				ServiceLocator.safe_get_service(&"Player").addCredits(newItem.getAmount())
			else:
				ServiceLocator.safe_get_service(&"Player").getInventory().addItem(newItem)
		
		return
		
	if(_action == "hideallitems"):
		var itemsToCheck = ServiceLocator.safe_get_service(&"Player").getInventory().getItems().duplicate()
		for item in itemsToCheck:
			if(item.id == _args[0]):
				ServiceLocator.safe_get_service(&"Player").getInventory().removeItem(item)
				npc.getInventory().addItem(item)
		return
		
	if(_action == "takeallitems"):
		var itemsToCheck = npc.getInventory().getItems().duplicate()
		for item in itemsToCheck:
			if(item.id == _args[0]):
				npc.getInventory().removeItem(item)
				ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
		return
		
	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)

func onInventoryItemSelected(item: ItemBase):
	if(state == "hideitemmenu"):
		ServiceLocator.safe_get_service(&"UI").clearButtons()
		addButton("Back", "Go back", "")
		
		if(item.canCombine() && item.getAmount() > 1):
			var amounts = [1, 2, 3, 4, 5, int(item.getAmount() * 0.5)]
			amounts.sort()
			var checkedAmounts = {}
			for amount in amounts:
				if(amount > item.getAmount()):
					break
				if(checkedAmounts.has(str(amount))):
					continue
				checkedAmounts[str(amount)] = true
				
				addButton("Give "+str(amount), "Give this amount", "stashx", [item, amount])
	if(state == "takeitemmenu"):
		ServiceLocator.safe_get_service(&"UI").clearButtons()
		addButton("Back", "Go back", "")
		
		if(item.canCombine() && item.getAmount() > 1):
			var amounts = [1, 2, 3, 4, 5, int(item.getAmount() * 0.5)]
			amounts.sort()
			var checkedAmounts = {}
			for amount in amounts:
				if(amount > item.getAmount()):
					break
				if(checkedAmounts.has(str(amount))):
					continue
				checkedAmounts[str(amount)] = true
				
				addButton("Take "+str(amount), "Take this amount", "takex", [item, amount])
		else:
			if(!item.isWornByWearer()):
				addButton("Take", "Take this item", "taketheitem", [item])

func tryToggleWornItem(item:ItemBase):
	if(item.getClothingSlot() == null):
		return [false, "This is not a clothing item"]
	
	if(item.isWornByWearer()):
		if(!item.isRestraint()):
			pass
		else:
			if(!item.canBeEasilyRemovedByDom()):
				return [false, "This restraint is impossible for you to remove!"]
		
		npc.getInventory().unequipItem(item)
		return [true, "You "+item.getTakingOffStringLong(false)+" from {npc.name}."]
	else:
		if(!npc.getInventory().canEquipSlot(item.getClothingSlot())):
			return [false, "{npc.name} can't wear this item!"]
		if(item.getPutOnScene() != "PutOnAnyItemScene" && !item.canForceOntoNpc()):
			return [false, "This item is too tricky for you to put onto {npc.name}."]
		#if(!item.isRestraint()):
		#	pass
		#else:
			#var restraintData:RestraintData = item.getRestraintData()
			#if(!restraintData.canBeEasilyRemovedByDom()):
			#	return [false, "This is a restraint you can't add!"]
		if(npc.getInventory().hasSlotEquipped(item.getClothingSlot())):
			return [false, "{npc.name} is already wearing something on the same slot!"]
		npc.getInventory().forceEquipStoreOther(item)
		return [true, "You "+item.getPuttingOnStringLong(false)+" onto {npc.name}."]

func onInventoryItemGroupInteracted(item: ItemBase):
	if(state == "hideitemmenu"):
		ServiceLocator.safe_get_service(&"MainScene").pickOption("hideallitems", [item.id])
	if(state == "takeitemmenu"):
		ServiceLocator.safe_get_service(&"MainScene").pickOption("takeallitems", [item.id])

func onInventoryItemInteracted(item: ItemBase):
	if(state == "hideitemmenu"):
		#ServiceLocator.safe_get_service(&"MainScene").pickOption("hideitem", [item.getUniqueID()])
		if(item.id == "WorkCredit"):
			ServiceLocator.safe_get_service(&"Player").addCredits(-ServiceLocator.safe_get_service(&"Player").getCredits())
		ServiceLocator.safe_get_service(&"Player").getInventory().removeItem(item)
		npc.getInventory().addItem(item)
		var inv = ServiceLocator.safe_get_service(&"UI").getCustomControl("inventory")
		if(inv.selectedItem == item):
			inv.selectedItem = null
			inv.updateSelectedInfo()
			ServiceLocator.safe_get_service(&"UI").clearButtons()
			addButton("Back", "Don't do anything", "")
		var theItems = []
		theItems.append_array(ServiceLocator.safe_get_service(&"Player").getInventory().getItems())
		#if(ServiceLocator.safe_get_service(&"Player").getCredits() > 0):
		#	var credsItem = GlobalRegistry.createItem("WorkCredit")
		#	credsItem.setAmount(ServiceLocator.safe_get_service(&"Player").getCredits())
		#	theItems.append(credsItem)
		inv.setItems(theItems, "give")
	if(state == "takeitemmenu"):
		if(item.getClothingSlot() != null):
			var theResult = tryToggleWornItem(item)
			itemPutonMessage = theResult[1]
			if(!theResult[0]):
				setState("item_toggle_message")
				ServiceLocator.safe_get_service(&"MainScene").reRun()
				return
			#npc.updateNonBattleEffects()
		else:
			#ServiceLocator.safe_get_service(&"MainScene").pickOption("takeitem", [item.getUniqueID()])
			npc.getInventory().removeItem(item)
			if(item.id == "WorkCredit"):
				ServiceLocator.safe_get_service(&"Player").addCredits(item.getAmount())
			else:
				ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
				
		var inv = ServiceLocator.safe_get_service(&"UI").getCustomControl("inventory")
		if(inv.selectedItem == item):
			inv.selectedItem = null
			inv.updateSelectedInfo()
			ServiceLocator.safe_get_service(&"UI").clearButtons()
			addButton("Back", "Don't do anything", "")
		#inv.setItems(npc.getInventory().getAllItems(), "take")
		inv.setItems(npc.getInventory().getItemsAndEquippedItemsTogetherGrouped(), "equiptake")

func saveData():
	var data = super.saveData()
	
	data["npcID"] = npcID
	data["itemPutonMessage"] = itemPutonMessage

	return data
	
func loadData(data):
	super.loadData(data)
	
	npcID = SAVE.loadVar(data, "npcID", "")
	itemPutonMessage = SAVE.loadVar(data, "itemPutonMessage", "")
	npc = GlobalRegistry.getCharacter(npcID)
