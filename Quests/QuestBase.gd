extends RefCounted
class_name QuestBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for quests.

var id: String = "error"

func getVisibleName() -> String:
	return "Bad quest"

func getProgress() -> Array:
	return ["Bad quest, let the developer know"]

func isVisible() -> bool:
	return false

func isCompleted() -> bool:
	return false

func isMainQuest() -> bool:
	return false

func getPriority() -> int:
	return 0

func getFlag(flag_id, default_value = null):
	return GM.main.getFlag(flag_id, default_value)
