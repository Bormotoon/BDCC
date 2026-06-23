extends RefCounted
class_name ReputationPlaceholder

## MIGRATED to Godot 4 (GDScript 2.0).
## Placeholder for characters without real reputation.

func isPlaceholder() -> bool:
	return true

func getRepLevel(_stat: String) -> int:
	return 0

func getRepScore(_stat: String) -> float:
	return 0.0

func addRep(_stat: String, _how_much: float, _show_message: bool = true) -> void:
	pass

func setLevel(_stat: String, _new_level: int, _show_message: bool = true) -> void:
	pass

func addRepBelowLevel(_stat: String, _how_much: float, _level: int, _show_message: bool = true) -> void:
	pass

func isEventRequired(_event_id: String) -> bool:
	return false

func handleSpecialEvent(_event_id: String) -> void:
	pass

func getGenericRepMult(_rep_id: String, _mult: float = 2.0) -> float:
	return 1.0
