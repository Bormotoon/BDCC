extends SceneBase

func _init():
	sceneID = "PSTentaclesTemplate"

func _run():
	var _tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS
	
	if(state == ""):
		playAnimation(StageScene.Solo, "stand")
		saynn("MEOW MEOW!")
		
		addButton("Continue", "See what happens next", "endthescene")
		

func _react(_action: String, _args):
	var _tentacles:PlayerSlaveryTentacles = ServiceLocator.safe_get_service(&"MainScene").PS
	
	if(_action == "endthescene"):
		endScene()
		return

	setState(_action)

func supportsShowingPawns() -> bool:
	return true

func saveData():
	var data = super.saveData()
	
	#data["ambushType"] = ambushType
	
	return data
	
func loadData(data):
	super.loadData(data)
	
	#ambushType = SAVE.loadVar(data, "ambushType", "")
