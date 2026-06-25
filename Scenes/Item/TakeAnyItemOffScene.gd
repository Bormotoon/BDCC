extends SceneBase

var uniqueItemID = ""

func _init():
	sceneID = "TakeAnyItemOffScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]
	
func _reactInit():
	if(uniqueItemID == null || uniqueItemID == ""):
		return
		
	var item: ItemBase = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
	if(item == null):
		return
	
	if(item.isRestraint()):
		var restraintData = item.getRestraintData()
		if(restraintData != null && restraintData.hasSmartLock()):
			setState("smartlocked")
			return
	
	if(!ServiceLocator.safe_get_service(&"Player").hasBlockedHands()):
		if(ServiceLocator.safe_get_service(&"Player").hasBoundArms()):
			setState("awkwardtakeoff")
		
		item.resetLustState()
		ServiceLocator.safe_get_service(&"Player").getInventory().removeEquippedItem(item)
		ServiceLocator.safe_get_service(&"Player").getInventory().addItem(item)
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"MainScene").updateSubAnims()
	else:
		setState("blockedhands")

func _run():
	if(state == ""):
		if(uniqueItemID == null || uniqueItemID == ""):
			addButton("Continue", "Oops", "endthescene")
			return
		
		var item: ItemBase = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
		if(item == null):
			saynn("Error: no item found")
		else:
			saynn("You "+item.getTakingOffStringLong(false))
		
		addButton("Continue", "You took off an item", "endthescene")

	if(state == "smartlocked"):
		saynn("This item is smartlocked.. so you can't remove it.")
		
		addButton("Continue", "Aww", "endthescene")

	if(state == "awkwardtakeoff"):
		if(uniqueItemID == null || uniqueItemID == ""):
			addButton("Continue", "Oops", "endthescene")
			return
		
		var item: ItemBase = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
		if(item == null):
			saynn("Error: no item found")
		else:
			saynn("It's very awkward to do with bound arms but you just about managed. You "+item.getTakingOffStringLong(false))
		
		addButton("Continue", "You took off an item", "endthescene")

	if(state == "blockedhands"):
		saynn("You really try to take anything off but your blocked hands prevent you from doing so")
		
		addButton("Continue", "Aww", "endthescene")


func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)

func saveData():
	var data = super.saveData()
	
	data["uniqueItemID"] = uniqueItemID
	
	return data
	
func loadData(data):
	super.loadData(data)
	
	uniqueItemID = SAVE.loadVar(data, "uniqueItemID", "")
