extends SceneBase

func _init():
	sceneID = "RestingInCellScene"

func _run():
	if(state == ""):
		playAnimation(StageScene.Sleeping, "sleep")
		
		saynn("You lay down on your stiff prisoner bed and let out a tired sigh.")
		
		saynn("What do you wanna do?")

		addButton("Stand up", "No time for resting", "endthescene")

		addButton("Sleep", "Sleep until the next day and recover your stamina", "gosleep")

		var currentTime = ServiceLocator.safe_get_service(&"MainScene").getTime()
		for t in [8, 10, 12, 14, 16, 18, 20, 22]:
			if(currentTime < t*60*60):
				addButton("Rest %02d:00" % [t], "Wake up when the time becomes %02d:00" % [t], "restuntil", [t])
			else:
				addDisabledButton("Rest %02d:00" % [t], "Too late for that today")
			
	if(state == "rested"):
		saynn("You spend some time in your cell. You feel less tired.")
		
		addButton("Continue", "Time to wake up", "endthescene")
		
	if(state == "slept"):
		playAnimation(StageScene.Sleeping, "sleep", {bodyState={naked=true}})
		
		saynn("You slept in your cell. It's not the most pleasant experience but you managed to recover your energy.")
		
		saynn("You wake up when all the prison lights begin to turn on.")
		
		saynn("Welcome to day "+str(ServiceLocator.safe_get_service(&"MainScene").getDays())+" of your sentence.")
		
		addButton("Continue", "Time to wake up", "endthesceneandtriggerevents")
		
		ServiceLocator.safe_get_service(&"EventSystem").triggerRun(Trigger.WakeUpInCell)

func _react(_action: String, _args):
	if(_action == "restuntil"):
		var newt = _args[0]
		
		var timePassed = ServiceLocator.safe_get_service(&"MainScene").processTimeUntil(newt * 60 * 60)
		ServiceLocator.safe_get_service(&"Player").afterRestingInBed(timePassed)
		
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.Waiting, [timePassed])):
			endScene()
			return
		
		setState("rested")
		return
		
	if(_action == "gosleep"):
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.AboutToSleepInCell)):
			endScene()
			return
		
		ServiceLocator.safe_get_service(&"MainScene").startNewDay()
		ServiceLocator.safe_get_service(&"Player").afterSleepingInBed()
		
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.SleepInCell)):
			pass
		
		setState("slept")
		return

	if(_action == "endthescene"):
		endScene()
		return

	if(_action == "endthesceneandtriggerevents"):
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.WakeUpInCell)):
			ServiceLocator.safe_get_service(&"MainScene").showLog()
			endScene()
			return
		ServiceLocator.safe_get_service(&"MainScene").showLog()
		
		endScene()
		return
	
	setState(_action)
