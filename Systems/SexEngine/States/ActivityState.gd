# Systems/SexEngine/States/ActivityState.gd
class_name ActivityState extends SexState

## Active state when a sex activity is in progress.
## Handles AI decision-making for dom actions and sub reactions.

var current_activity: Dictionary = {}

func _init() -> void:
	id = &"activity"

func enter(engine: Node) -> void:
	if engine is SexEngineManager and not engine.activities.is_empty():
		current_activity = engine.activities[0]

func exit(_engine: Node) -> void:
	current_activity = {}

func process_turn(engine: Node) -> void:
	if engine is SexEngineManager:
		# Process AI actions for doms
		for dom_id in engine.get_doms():
			if dom_id == &"pc" and not engine.pc_allows_dom_autonomy:
				continue
			_process_dom_ai(engine, dom_id)

		# Process sub reactions
		for sub_id in engine.get_subs():
			_process_sub_reaction(engine, sub_id)

func _process_dom_ai(engine: SexEngineManager, dom_id: StringName) -> void:
	var dom_info = engine.get_dom_info(dom_id)
	var entity = dom_info.get("entity")
	if not entity:
		return

	# Get available actions from current activity
	var possible_actions: Array = []
	if current_activity.has_method("get_actions"):
		possible_actions = current_activity.get_actions(entity)

	if possible_actions.is_empty():
		return

	# Weighted random selection
	var scores: Array = []
	for action in possible_actions:
		scores.append(action.get("score", 1.0))

	var picked = RNG.pick(possible_actions)
	if picked and picked.has("execute"):
		picked["execute"].call(entity, engine.location_id)

func _process_sub_reaction(engine: SexEngineManager, sub_id: StringName) -> void:
	var sub_info = engine.get_sub_info(sub_id)
	var entity = sub_info.get("entity")
	if not entity:
		return

	# Sub reactions are handled by SexReactionComponent via EventBus
	# No direct processing needed here
