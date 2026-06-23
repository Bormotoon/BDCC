# Systems/SexEngine/SexState.gd
class_name SexState extends RefCounted

## Base class for all states/activities in the sex engine.
## Each position (e.g. Missionary, Blowjob) inherits this class.

var id: StringName = &"base_state"

func enter(engine: Node) -> void:
	pass

func exit(engine: Node) -> void:
	pass

func process_turn(engine: Node) -> void:
	pass

## Returns available SexActions for a specific participant in this state
func get_available_actions(participant: Node) -> Array[Resource]:
	return []
