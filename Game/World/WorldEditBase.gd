extends RefCounted
class_name WorldEditBase

var id = "error"
var isRegular = false # true = apply() is called after every tick

func apply(_world: GameWorld):
	pass

func getFlag(flagID, defaultValue = null):
	return ServiceLocator.safe_get_service(&"MainScene").getFlag(flagID, defaultValue)
