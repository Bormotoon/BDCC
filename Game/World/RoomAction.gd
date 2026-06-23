extends Node
class_name RoomAction

@export var var ActionName
@export var var ActionTooltip
@export var var ActionScene

func _canRun() -> bool:
	return true

func _shouldShow() -> bool:
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	if(!ActionName):
		ActionName = name
