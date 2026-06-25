extends SubGameWorld


func _on_CBStairs1_onEnter(room):
	room.addButton("Go up", "Go up to the main hall", "goup")

func _on_CBStairs1_onReact(_room, key):
	if(key == "goup"):
		ServiceLocator.safe_get_service(&"Player").setLocation("main_stairs1")
		ServiceLocator.safe_get_service(&"MainScene").reRun()


func _on_CBStairs2_onEnter(room):
	room.addButton("Go up", "Go up to the main hall", "goup")


func _on_CBStairs2_onReact(_room, key):
	if(key == "goup"):
		ServiceLocator.safe_get_service(&"Player").setLocation("main_stairs2")
		ServiceLocator.safe_get_service(&"MainScene").reRun()


func _on_CellblockRoom11_onEnter(_room):
	pass


func _on_CellblockRoom11_onReact(_room, key):
	if(key == "stash"):
		_room.runScene("PlayerStashScene")
		
	if(key == "rest"):
		_room.runScene("RestingInCellScene")
		#ServiceLocator.safe_get_service(&"Player").addStamina(100)
		#ServiceLocator.safe_get_service(&"MainScene").addMessage("You had a good rest")
		#ServiceLocator.safe_get_service(&"MainScene").reRun()
		
	if(key == "over"):
		ServiceLocator.safe_get_service(&"MainScene").overridePC()
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"Player").updateNonBattleEffects()
		ServiceLocator.safe_get_service(&"MainScene").reRun()
		
	if(key == "clearover"):
		ServiceLocator.safe_get_service(&"MainScene").clearOverridePC()
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"Player").updateNonBattleEffects()
		ServiceLocator.safe_get_service(&"MainScene").reRun()
		
	if(key == "flashback"):
		_room.runScene("PCOverrideExample")

func _on_CellblockRoom11_onPreEnter(room):
	if(ServiceLocator.safe_get_service(&"Player").getLocation() == ServiceLocator.safe_get_service(&"Player").getCellLocation()):
		room.roomDescription = "Your cell is nothing special. An automatic door that can be opened and closed remotely and an armored window that anyone can see through. Walls are made out of some metal, using a spoon on them would only leave a visible scratch. Everything is well lit at least."
		room.roomDescription += "\n\n"
		room.roomDescription += "One stiff-looking bed in the corner and a stool is all you get. You can rest here or hide something so you don't lose it during the personal searches."
		
		room.roomName = "My cell"
		
		room.addButton("Stash", "You can hide something in your cell", "stash")
		
		if(!ServiceLocator.safe_get_service(&"MainScene").playerHasCompanions()):
			room.addButton("Rest", "Lay down on the bed", "rest")
		# Debug testing, free to remove
		#room.addButton("Override", "Override pc", "over")
		#room.addButton("Clear", "Clear pc", "clearover")
		#room.addButton("Flashback test", "Test", "flashback")
	else:
		room.roomDescription = "This is not your cell"
		room.roomName = "Cell"
