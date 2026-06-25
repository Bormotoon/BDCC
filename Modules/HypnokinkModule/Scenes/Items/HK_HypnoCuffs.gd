extends SceneBase

var uniqueItemID

func _init():
	sceneID = "HypnoCuffsScene"
	
func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]

func _run():
	if(state == ""):
		if(HypnokinkUtil.isHypnotized(ServiceLocator.safe_get_service(&"Player"))):
			saynn("You can't possibly hope to remove these very real cuffs.")
			addButton("Continue", "Nothing you can do", "endthescene")
		else:
			saynn("After a moment of consideration, you realise you're not actually wearing cuffs!")
			addButton("Continue", "Well that was easy", "remove")
			addButton("Play along", "It can be fun to pretend", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
		
	if(_action == "remove"):
		var inventory = ServiceLocator.safe_get_service(&"Player").getInventory()
		var item: ItemBase = inventory.getItemByUniqueID(uniqueItemID)
		inventory.removeEquippedItem(item)
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
