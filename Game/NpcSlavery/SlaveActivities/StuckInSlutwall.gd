extends StuckInStocks

func _init():
	id = "StuckInSlutwall"
	
func getVisibleName():
	return "Stuck in a slutwall"

func getActivityText():
	return "{npc.name} is currently stuck in a slutwall so {npc.he} {npc.isAre} not here."

func getInteractActions():
	return [
	]

func onStart(_args = []):
	var pawn = ServiceLocator.safe_get_service(&"MainScene").IS.spawnPawnIfNeeded(getCharID())
	pawn.setLocation("fight_slutwall")
	ServiceLocator.safe_get_service(&"MainScene").IS.startInteraction("InSlutwall", {inmate=getCharID()})

func onInteractionChanged(_newInteraction):
	if(_newInteraction == null || _newInteraction.id != "InSlutwall"):
		stopActivity()

func getSexEventID():
	return "slutwallUsed"
