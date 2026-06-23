# Systems/SexEngine/States/IdleState.gd
class_name IdleState extends SexState

## Initial state when sex scene starts. Generates goals and transitions to first activity.

func _init() -> void:
	id = &"idle"

func enter(engine: Node) -> void:
	pass

func exit(engine: Node) -> void:
	pass

func process_turn(engine: Node) -> void:
	if engine is SexEngineManager:
		# If no goals exist, generate them
		var has_goals := false
		for dom_id in engine.get_doms():
			var dom_info = engine.get_dom_info(dom_id)
			var goals = dom_info.get("goals", [])
			if not goals.is_empty():
				has_goals = true
				break

		if not has_goals:
			engine.generate_goals()

func get_available_actions(_participant: Node) -> Array[Resource]:
	return []
