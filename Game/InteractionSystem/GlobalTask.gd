extends RefCounted
class_name GlobalTask

## MIGRATED to Godot 4 (GDScript 2.0).
## Global task for NPC behavior management.

var id: String = "error"
var unique_id: String = ""
var goal_id: String = InteractionGoal.Patrol
var max_assigned_unscaled: float = 1.0
var assigned: Array = []
var assigned_cached: int = 0
var max_assigned_cached: int = 0

func on_pawn_stopped_doing_task(pawn: CharacterPawn) -> void:
	if assigned.has(pawn.charID):
		assigned.erase(pawn.charID)
		assigned_cached -= 1

func on_pawn_started_doing_task(pawn: CharacterPawn) -> void:
	assigned.append(pawn.charID)
	assigned_cached += 1

func get_max_assigned(max_pawn_count: int) -> int:
	return maxi(1, roundi(max_assigned_unscaled * (max_pawn_count / 30.0)))

func can_do_task(_pawn: CharacterPawn) -> bool:
	return true

func should_ignore_char_type(_pawn: CharacterPawn) -> bool:
	return _pawn.canDoTaskOverride(id, self)

func can_do_task_final(pawn: CharacterPawn) -> bool:
	if assigned_cached >= max_assigned_cached:
		return false
	if not pawn.canBeInterrupted():
		return false
	return can_do_task(pawn)

func is_assigned(pawn: CharacterPawn) -> bool:
	return assigned.has(pawn.charID)

func get_all_assigned_pawns() -> Array:
	var result: Array = []
	for pawn_id in assigned:
		var pawn: CharacterPawn = GM.main.IS.getPawn(pawn_id)
		if pawn:
			result.append(pawn)
	return result

func get_goal_id(_pawn: CharacterPawn) -> String:
	return goal_id

func configure_goal_final(pawn: CharacterPawn, goal) -> void:
	goal.globalTask = id
	configure_goal(pawn, goal)

func configure_goal(_pawn: CharacterPawn, _goal) -> void:
	pass

func process_time(_how_much: int) -> void:
	pass

func reset_task() -> void:
	pass
