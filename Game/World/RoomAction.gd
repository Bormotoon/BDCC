extends Node
class_name RoomAction

@export var ActionName: String
@export var ActionTooltip: String
@export var ActionScene: String

func _canRun() -> bool:
	return true

func _shouldShow() -> bool:
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	if(!ActionName):
		ActionName = name
