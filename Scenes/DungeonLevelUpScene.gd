extends SceneBase

var levelUpScreenScene = preload("res://UI/SkillsUI/DungeonLevelUpScreen.tscn")

var perksList:Array = []

func _init():
	sceneID = "DungeonLevelUpScene"
	
func _reactInit():
	perksList = ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.getPerksForReachingLevel(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.handledPCLevel+1)

func _run():
	if(state == ""):
		var levelUpScreen = levelUpScreenScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("levelUpScreen", levelUpScreen)
		levelUpScreen.setData(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.handledPCLevel+1, perksList, ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.lastSelectedStat if ServiceLocator.safe_get_service(&"MainScene").DrugDenRun != null else "")
		var _ok = levelUpScreen.onConfirm.connect(onConfirmPressed)
		
		addButton("Confirm", "You're content with this", "doConfirm")

func onConfirmPressed(selectedStat:String, selectedPerk:String):
	if(selectedStat != ""):
		ServiceLocator.safe_get_service(&"Player").getSkillsHolder().setStat(selectedStat, ServiceLocator.safe_get_service(&"Player").getStat(selectedStat) + 3)
	if(selectedPerk != ""):
		ServiceLocator.safe_get_service(&"Player").getSkillsHolder().addPerk(selectedPerk)
	if(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun != null):
		ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.lastSelectedStat = selectedStat
		ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.afterLevelUp()
		if(!ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.shouldShowLevelUpScreen()):
			ServiceLocator.safe_get_service(&"MainScene").pickOption("endthescene", [])
		else:
			perksList = ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.getPerksForReachingLevel(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.handledPCLevel+1)
			ServiceLocator.safe_get_service(&"MainScene").pickOption("", [])
	else:
		ServiceLocator.safe_get_service(&"MainScene").pickOption("endthescene", [])
	
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "doConfirm"):
		ServiceLocator.safe_get_service(&"UI").getCustomControl("levelUpScreen")._on_ContinueButton_pressed()
		return
	
	setState(_action)

func saveData():
	var data = super.saveData()
	
	data["perksList"] = perksList

	return data
	
func loadData(data):
	super.loadData(data)
	
	perksList = SAVE.loadVar(data, "perksList", [])
