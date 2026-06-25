extends SceneBase

var uniqueItemID = ""
var item: ItemBase = null

func _init():
	sceneID = "CatchBodyFluidsScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]
	
func _reactInit():
	if(ServiceLocator.safe_get_service(&"Player").hasBlockedHands() || ServiceLocator.safe_get_service(&"Player").hasBoundArms()):
		setState("cantdoit")
		return
	
	if(uniqueItemID == null || uniqueItemID == ""):
		return
		
	item = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
	if(item == null):
		return
	
	if(ServiceLocator.safe_get_service(&"Player").getFluids().isEmpty()):
		setState("nofluidsonbody")
		return
	
	processTime(10*60)
	var amount = ServiceLocator.safe_get_service(&"Player").getFluids().transferTo(item, randf_range(0.1, 0.2))
	
	addMessage("You managed to collect "+str(Util.roundF(amount))+" ml")

func _run():
	if(state == ""):
		saynn("You spend some time, using "+item.getVisibleName()+" to collect some of the lewd fluids that you are covered with.")
		
		addButton("Continue", "Okay", "endthescene")

	if(state == "nofluidsonbody"):
		saynn("You aren't covered with any fluids that you can collect")
		
		addButton("Continue", "aww", "endthescene")

	if(state == "cantdoit"):
		saynn("Some restraint prevents you from doing this")
		
		addButton("Continue", "aww", "endthescene")

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
	item = ServiceLocator.safe_get_service(&"Player").getInventory().getItemByUniqueID(uniqueItemID)
