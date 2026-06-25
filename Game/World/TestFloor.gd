extends SubGameWorld

func _on_ScriptedRoom_onEnter(room: GameRoom):
	#room.clearScreen()
	
	room.say("Meow")
	room.addButton("Do mew", "Talk to mew", "wut")
	
	#room.runScene("TestScene")


func _on_ScriptedRoom_onReact(room: GameRoom, key):
	if(key == "wut"):
		room.say("yap")
		room.addButton("Do more mew", "Talk to mew", "wut")
		room.addButton("Return", "Talk to mew", "wut2")
		room.addButton("start a scene", "Talk to mew", "wut3")
		room.addButton("start a fight", "Fight", "wut4")
		if(ServiceLocator.safe_get_service(&"Player").getPain() > 0):
			room.addButton("sip some tea", "Heals", "wut5")
		else:
			room.addDisabledButton("sip some tea", "You're healthy already")
	if(key == "wut2"):
		#ServiceLocator.safe_get_service(&"Player").breasts.size = BodypartBreasts.BreastsSize.A
		#ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"MainScene").reRun()
	if(key == "wut3"):
		room.runScene("TestScene")
	if(key == "wut4"):
		room.runScene("FightScene", ["testchar"])
	if(key == "wut5"):
		room.say("You sipped some tea and feel better")
		ServiceLocator.safe_get_service(&"Player").addPain(-10)
		room.addButton("Continue", "Talk to mew", "wut")
