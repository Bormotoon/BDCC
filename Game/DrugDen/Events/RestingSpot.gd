extends DrugDenEventBase

func _init():
	id = "RestingSpot"

func getMaxPerFloor() -> int:
	return 1

func getCooldown() -> int:
	return randi_range(1, 2)

func getStartCooldown() -> int:
	return randi_range(1, 2)

func getInteractInfo() -> Dictionary:
	return {
		text = "You found someone's resting spot! You can rest and fully restore your stamina or masturbate and get rid of your lust!",
		actions = [
			{
				id = "rest",
				name = "Rest",
				desc = "Fully restore your stamina.",
				args = [],
				disabled = false,
			},
			{
				id = "masturbate",
				name = "Masturbate",
				desc = "Get rid of your lust. Your hands and arms have to be free.",
				args = [],
				disabled = (ServiceLocator.safe_get_service(&"Player").hasBoundArms() || ServiceLocator.safe_get_service(&"Player").hasBlockedHands()),
			},
		],
	}

func doInteract(_actionID:String, _args:Array = []) -> Dictionary:
	if(_actionID == "rest"):
		ServiceLocator.safe_get_service(&"Player").addStamina(ServiceLocator.safe_get_service(&"Player").getMaxStamina())
		ServiceLocator.safe_get_service(&"Player").addIntoxication(-0.5)
		return {text="You rest for a bit and now feel energized.", ended=true, anim=[StageScene.Sleeping, "sleep"]}
	
	ServiceLocator.safe_get_service(&"Player").orgasmFrom("pc")
	return {text="You get as comfy as you can and masturbate until you cum, which helps to clear your mind!", ended=true, anim=[StageScene.Grope, "watchstroke" if ServiceLocator.safe_get_service(&"Player").hasReachablePenis() else "watchrub", {onlyPC=true, pcCum=true, bodyState={naked=true,hard=true}}]}

func getMapIcon():
	return RoomStuff.RoomSprite.BED
