extends SceneBase

var inventoryScreenScene = preload("res://UI/Inventory/InventoryScreen.tscn")

func _init():
	sceneID = "PlayerStashScene"

func _run():
	if(state == ""):
		if(ServiceLocator.safe_get_service(&"Player").getLocation() != ServiceLocator.safe_get_service(&"Player").getCellLocation()):
			saynn("What do you want to do with your stash.")
		else:
			saynn("You find a place you can stash some items in, it's under your pillow. What do you wanna do")
		
		var items = GlobalRegistry.getCharacter("playerstash").getInventory().getAllItems()
		var itemNames = []
		for item in items:
			itemNames.append(item.getVisibleName())
		say("Items in the stash:\n")
		say(Util.join(itemNames, ", "))
		say("\n\n")
		
		items = ServiceLocator.safe_get_service(&"Player").getInventory().getAllItems()
		itemNames = []
		for item in items:
			itemNames.append(item.getVisibleName())
		say("Your items:\n")
		say(Util.join(itemNames, ", "))
		
		addButton("Stash item", "Hide an item", "hideitemmenu")
		addButton("Take item", "Take an item", "takeitemmenu")
		addButton("Step away", "You're done", "endthescene")
	if(state == "hideitemmenu"):
		var theItems = []
		theItems.append_array(ServiceLocator.safe_get_service(&"Player").getInventory().getItems())
		if(ServiceLocator.safe_get_service(&"Player").getCredits() > 0):
			var credsItem = GlobalRegistry.createItem("WorkCredit")
			credsItem.setAmount(ServiceLocator.safe_get_service(&"Player").getCredits())
			theItems.append(credsItem)
		
		var inventory = inventoryScreenScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("inventory", inventory)
		inventory.setItems(theItems, "stash")
		var _ok = inventory.onItemSelected.connect(onInventoryItemSelected)
		var _ok2 = inventory.onInteractWith.connect(onInventoryItemInteracted)
		var _ok3 = inventory.onInteractWithGroup.connect(onInventoryItemGroupInteracted)
		addButton("Back", "Go back", "")
	
	if(state == "takeitemmenu"):
		var inventory = inventoryScreenScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("inventory", inventory)
		inventory.setItems(GlobalRegistry.getCharacter("playerstash").getInventory().getAllItems(), "take")
		var _ok = inventory.onItemSelected.connect(onInventoryItemSelected)
		var _ok2 = inventory.onInteractWith.connect(onInventoryItemInteracted)
		var _ok3 = inventory.onInteractWithGroup.connect(onInventoryItemGroupInteracted)
		addButton("Back", "Go back", "")

func _react(_action: String, _args):
	if(_action == "hideitem"):
		var item: ItemBase = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(_args[0])
		ServiceLocator.safe_get_service(&"Player").getInventory().removeItem(item)
		GlobalRegistry.getCharacter("playerstash").getInventory().addItem(item)
		
		#setState("")
		return
	if(_action == "takeitem"):
		var item: ItemBase = GlobalRegistry.getCharacter("playerstash").getInventory().getItemByUniqueID(_args[0])
		GlobalRegistry.getCharacter("playerstash").getInventory().removeItem(item)
		ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
		
		#setState("")
		return
	if(_action == "stashx"):
		var item: ItemBase = _args[0]
		
		var newItem = item.splitAmount(_args[1])
		
		if(newItem != null):
			if(newItem.id == "WorkCredit"):
				ServiceLocator.safe_get_service(&"Player").addCredits(-newItem.getAmount())
			GlobalRegistry.getCharacter("playerstash").getInventory().addItem(newItem)
		
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
				GlobalRegistry.getCharacter("playerstash").getInventory().addItem(item)
		return
		
	if(_action == "takeallitems"):
		var itemsToCheck = GlobalRegistry.getCharacter("playerstash").getInventory().getItems().duplicate()
		for item in itemsToCheck:
			if(item.id == _args[0]):
				GlobalRegistry.getCharacter("playerstash").getInventory().removeItem(item)
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
				
				addButton("Stash "+str(amount), "Stash this amount", "stashx", [item, amount])
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
		GlobalRegistry.getCharacter("playerstash").getInventory().addItem(item)
		var inv = ServiceLocator.safe_get_service(&"UI").getCustomControl("inventory")
		if(inv.selectedItem == item):
			inv.selectedItem = null
			inv.updateSelectedInfo()
			ServiceLocator.safe_get_service(&"UI").clearButtons()
			addButton("Back", "Don't do anything", "")
		var theItems = []
		theItems.append_array(ServiceLocator.safe_get_service(&"Player").getInventory().getItems())
		if(ServiceLocator.safe_get_service(&"Player").getCredits() > 0):
			var credsItem = GlobalRegistry.createItem("WorkCredit")
			credsItem.setAmount(ServiceLocator.safe_get_service(&"Player").getCredits())
			theItems.append(credsItem)
		inv.setItems(theItems, "stash")
	if(state == "takeitemmenu"):
		#ServiceLocator.safe_get_service(&"MainScene").pickOption("takeitem", [item.getUniqueID()])
		GlobalRegistry.getCharacter("playerstash").getInventory().removeItem(item)
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
		inv.setItems(GlobalRegistry.getCharacter("playerstash").getInventory().getAllItems(), "take")
