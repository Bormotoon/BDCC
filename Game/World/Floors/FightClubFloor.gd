extends SubGameWorld



func _on_FightClubRoom_onEnter(room):
	room.addButton("Leave", "Return to the prison", "leave")


func _on_FightClubRoom_onReact(_room, key):
	if(key == "leave"):
		ServiceLocator.safe_get_service(&"Player").setLocation("gym_secret")
		ServiceLocator.safe_get_service(&"MainScene").reRun()
