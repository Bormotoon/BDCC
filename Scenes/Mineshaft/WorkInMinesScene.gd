extends SceneBase

func _init():
	sceneID = "WorkInMinesScene"

func _run():
	if(state == ""):
		saynn("You grab a pickaxe and go deep into the mines.")

		addButton("Work", "Do the work", "work")
	
	if(state == "work"):
		saynn("You spend a few hours, pushing minecarts around and mining rocks. You feel tired as heck but you earned something at least.")
		
		addButton("Continue", "Finally rest", "endthescene")

		ServiceLocator.safe_get_service(&"EventSystem").triggerRun(Trigger.WorkingInMines)

func _react(_action: String, _args):
	if(_action == "work"):
		
		ServiceLocator.safe_get_service(&"Player").addCredits(1)
		ServiceLocator.safe_get_service(&"Player").addStamina(-40)
		
		processTime(2*60*60)
		
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.WorkingInMines)):
			endScene()
			return
		
		addMessage("You earned 1 work credit")

	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)
