extends RefCounted
class_name EventTrigger

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for event triggers.

var id: String = "error"

func addEvent(_event, _args) -> void:
	pass

func onAllEventsAdded() -> void:
	pass

func triggerReact(_args) -> bool:
	return false

func triggerRun(_args) -> void:
	pass
