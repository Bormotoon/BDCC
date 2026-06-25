extends SceneBase

var uniqueItemID = ""
var item: ItemBase = null
var savedEffects = ""

func _init():
	sceneID = "DrinkFromScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]
	
func _reactInit():
	if(ServiceLocator.safe_get_service(&"Player").isOralBlocked() || ServiceLocator.safe_get_service(&"Player").hasBoundArms()):
		setState("cantdrink")
		return
	
	if(uniqueItemID == null || uniqueItemID == ""):
		return
		
	item = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
	if(item == null):
		return
	
	var fluids:Fluids = item.getFluids()
	if(fluids == null || fluids.isEmpty()):
		setState("nothingtodrink")

	var extraMessages = []
	var fluidByAmount = fluids.getFluidAmountByType()
	for fluidID in fluidByAmount:
		var swallowData:Dictionary = ServiceLocator.safe_get_service(&"Player").doSwallow(fluidID, fluidByAmount[fluidID])
		if(swallowData.has("text") && swallowData["text"] != ""):
			extraMessages.append(swallowData["text"])
	
	fluids.transferTo(ServiceLocator.safe_get_service(&"Player").getBodypart(BodypartSlot.Head), 1.0)
	savedEffects = Util.join(extraMessages, " ")

func _run():
	if(state == ""):
		saynn("You swallow the contents of "+item.getVisibleName())
		
		saynn(savedEffects)
		
		addButton("Continue", "Okay", "endthescene")

	if(state == "nothingtodrink"):
		saynn("There was nothing to drink")
		
		addButton("Continue", "aww", "endthescene")

	if(state == "cantdrink"):
		saynn("Some restraint prevents you from drinking that")
		
		addButton("Continue", "aww", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)

func saveData():
	var data = super.saveData()
	
	data["uniqueItemID"] = uniqueItemID
	data["savedEffects"] = savedEffects
	
	return data
	
func loadData(data):
	super.loadData(data)
	
	uniqueItemID = SAVE.loadVar(data, "uniqueItemID", "")
	savedEffects = SAVE.loadVar(data, "savedEffects", "")
	item = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
