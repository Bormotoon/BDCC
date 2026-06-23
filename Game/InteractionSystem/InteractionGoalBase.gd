extends RefCounted
class_name InteractionGoalBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for interaction goals. extends Reference → RefCounted.

var id: String = ""
var pawn_id: String = ""
var interaction
var global_task: String = ""

func save_data() -> Dictionary:
	return {"gt": global_task}

func load_data(data: Dictionary) -> void:
	global_task = SAVE.loadVar(data, "gt", "")

func get_score(_pawn: CharacterPawn) -> float:
	return 0.0

func get_text() -> String:
	return "They be doing something!"

func on_goal_start() -> void:
	pass

func get_actions() -> Array:
	return []

func do_action(_id: String, _args: Dictionary) -> void:
	pass

func get_keep_score() -> float:
	return get_score(get_pawn()) + 0.1

func get_pawn() -> CharacterPawn:
	return GM.main.IS.getPawn(pawn_id)

func get_interaction():
	return interaction

func can_reach_pc() -> bool:
	var room = GM.world.getRoomByID(GM.pc.getLocation())
	if room == null or room.is_offlimits_for_inmates():
		return false
	return true

func get_location() -> String:
	return getInteraction().getLocation()

func set_location(new_loc: String) -> void:
	getInteraction().setLocation(new_loc)

func go_towards(target: String):
	return getInteraction().goTowards(target)

func do_wander():
	return getInteraction().doWander()

func complete_goal() -> void:
	getInteraction().completeGoal()

func get_current_action() -> String:
	return getInteraction().getCurrentAction()

func do_look_around(keep_score_mult: float = 1.0):
	return getInteraction().doLookAround("main", keep_score_mult)

func get_anim_data() -> Array:
	return [StageScene.Solo, "stand", {"pc": "main"}]

func get_activity_icon():
	return RoomStuff.PawnActivity.None
