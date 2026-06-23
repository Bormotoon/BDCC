# Systems/SexEngine/SexEngineManager.gd
class_name SexEngineManager extends Node

## Migrated from SexEngine.gd (1854 lines).
## Main coordinator for sex scenes. Manages participants, goals, activities, and state transitions.

# Participants (migrated from SexEngine.gd lines 7-11)
var doms: Dictionary = {} # StringName -> SexDomInfo
var subs: Dictionary = {} # StringName -> SexSubInfo
var activities: Array = []
var participated_doms: Dictionary = {}

# Current state
var current_state: SexState
var location_id: StringName = &"unknown_room"
var sex_ended: bool = false

# Configuration (migrated from SexEngine.gd lines 19-34)
var disabled_goals: Dictionary = {}
var bondage_disabled: bool = false
var sub_must_go_unconscious: bool = false
var no_dynamic_joiners: bool = false
var dom_no_pulling_out: bool = false
var must_use_condoms: bool = false
var no_violence: bool = false
var doms_no_talking: bool = false
var pc_controls_doms: bool = false

# PC control
var pc_allows_dom_autonomy: bool = false
var pc_allows_dyn_joiners: bool = false
var pc_target: StringName = &""

# Output (migrated from SexEngine.gd lines 38-41)
var output_raw: Array = []
const OUTPUT_TEXT: int = 0
const OUTPUT_SAY: int = 1
const OUTPUT_SEPARATOR: int = 2

func _ready() -> void:
	ServiceLocator.register_service(&"SexEngine", self)

# --- Scene lifecycle ---

func start_scene(scene_participants: Array[Node], room_id: StringName, initial_state: SexState) -> void:
	location_id = room_id
	sex_ended = false

	# Register participants
	for participant in scene_participants:
		var char_id: StringName = participant.entity_id if participant is Entity else &"unknown"
		# Determine dom/sub role (simplified - real logic checks fetish/personality)
		if participant.has_component(&"SexReactionComponent"):
			var reaction: SexReactionComponent = participant.get_component(&"SexReactionComponent")
			if reaction.is_dom_action:
				doms[char_id] = {"entity": participant, "goals": [], "is_dynamic_joiner": false}
			else:
				subs[char_id] = {"entity": participant, "arousal": 0.0}

	change_state(initial_state)
	generate_goals()

	EventBus.sex_scene_started.emit(scene_participants, room_id)

func end_scene() -> void:
	if current_state:
		current_state.exit(self)

	var all_participants: Array[Node] = []
	for dom_id in doms:
		all_participants.append(doms[dom_id]["entity"])
	for sub_id in subs:
		all_participants.append(subs[sub_id]["entity"])

	current_state = null
	doms.clear()
	subs.clear()
	activities.clear()
	sex_ended = true

	EventBus.sex_scene_ended.emit(all_participants, location_id)

# --- State management ---

func change_state(new_state: SexState) -> void:
	if current_state:
		current_state.exit(self)

	current_state = new_state

	if current_state:
		current_state.enter(self)

# --- Goal generation (migrated from SexEngine.gd lines 330-395) ---

func generate_goals() -> void:
	var amount_to_generate: int = 2 + (subs.size() - 1)
	var generated_any: bool = false

	for dom_id in doms:
		if generate_goals_for(dom_id, amount_to_generate):
			generated_any = true

	if not is_dom(&"pc") and not generated_any and not doms.is_empty() and not pc_controls_doms:
		add_text_raw("Dom couldn't decide what to do with the sub, none of their fetishes apply.")

func generate_goals_for(dom_id: StringName, amount: int, fallback: bool = true) -> bool:
	if _internal_generate_goals(dom_id, amount):
		return true
	if not fallback:
		return false
	# Fallback with lower fetish threshold
	return _internal_generate_goals(dom_id, amount, -0.26)

func _internal_generate_goals(dom_id: StringName, amount: int, min_fetish_value: float = 0.0) -> bool:
	if dom_id == &"pc":
		return false

	if not doms.has(dom_id):
		return false

	var dom_info: Dictionary = doms[dom_id]
	var possible_goals: Array = []

	# Get all registered sex goals
	var all_goals: Dictionary = ServiceLocator.get_service(&"RegistryManager").get_all(&"sex_goals") if ServiceLocator else {}

	for goal_id in all_goals:
		if disabled_goals.has(goal_id):
			continue

		# Check if any activities support this goal
		if not _check_activities_support_goal(goal_id):
			continue

		for sub_id in subs:
			var goal_data: Dictionary = {}  # Would come from SexGoalBase.generateData
			var goal_weight: float = 1.0

			possible_goals.append({
				"goal_id": goal_id,
				"sub_id": sub_id,
				"data": goal_data,
				"weight": goal_weight,
			})

	if possible_goals.size() > 0:
		for _i in range(amount):
			var picked = RNG.pick(possible_goals)
			if picked:
				if not dom_info.has("goals"):
					dom_info["goals"] = []
				dom_info["goals"].append(picked.duplicate())
				return true

	return false

func _check_activities_support_goal(goal_id: StringName) -> bool:
	# Check if any registered sex activities support this goal
	for activity in activities:
		if activity.has_method("supports_goal"):
			if activity.supports_goal(goal_id):
				return true
	return false

func check_if_doms_need_more_goals() -> void:
	if not should_doms_keep_generating_tasks():
		return
	if sex_ended:
		return
	for dom_id in doms:
		var dom_info: Dictionary = doms[dom_id]
		var goals = dom_info.get("goals", [])
		if goals.is_empty() and not dom_info.get("is_dynamic_joiner", false):
			generate_goals_for(dom_id, 2)

func should_doms_keep_generating_tasks() -> bool:
	return can_choose_dom_autonomy()

func can_choose_dom_autonomy() -> bool:
	return is_dom(&"pc") and doms.size() > 1

# --- Turn processing (migrated from SexEngine.gd lines 630-663) ---

func process_scene_turn() -> void:
	if sex_ended:
		return

	_remove_ended_activities()

	# Process doms
	for dom_id in doms:
		var dom_info: Dictionary = doms[dom_id]
		var entity = dom_info.get("entity")
		if entity and entity.has_method("process_sex_turn"):
			entity.process_sex_turn(true)

	# Process subs
	for sub_id in subs:
		var sub_info: Dictionary = subs[sub_id]
		var entity = sub_info.get("entity")
		if entity and entity.has_method("process_sex_turn"):
			entity.process_sex_turn(false)

	# Process activities
	for activity in activities:
		if activity.get("has_ended", false):
			continue
		if activity.has_method("process_turn_final"):
			activity.process_turn_final()

	check_if_doms_need_more_goals()
	_remove_ended_activities()

# --- Activity management ---

func add_activity(activity: Dictionary) -> void:
	activities.append(activity)

func remove_activity(activity: Dictionary) -> void:
	activities.erase(activity)

func _remove_ended_activities() -> void:
	for i in range(activities.size() - 1, -1, -1):
		if activities[i].get("has_ended", false):
			activities.remove_at(i)

func get_activity_with_id(unique_id: int) -> Dictionary:
	for activity in activities:
		if activity.get("unique_id", -1) == unique_id:
			return activity
	return {}

# --- Output system (migrated from SexEngine.gd lines 65-108) ---

func add_text_raw(text: String) -> void:
	if text.is_empty():
		return
	output_raw.append([OUTPUT_TEXT, text])

func talk_text(char_id: StringName, text: String) -> void:
	if text.is_empty():
		return
	if doms_no_talking and doms.has(char_id):
		return
	output_raw.append([OUTPUT_SAY, char_id, text])

func add_output_separator() -> void:
	output_raw.append([OUTPUT_SEPARATOR])

func get_final_output() -> String:
	var result: String = ""
	var saved_tag: int = OUTPUT_TEXT

	for entry in output_raw:
		var is_empty: bool = result.is_empty()
		var tag: int = entry[0]

		match tag:
			OUTPUT_TEXT:
				if saved_tag == OUTPUT_TEXT:
					result += (" " if not is_empty else "") + entry[1]
				else:
					result += ("\n\n" if not is_empty else "") + entry[1]
			OUTPUT_SAY:
				result += ("\n\n" if not is_empty else "") + "[say=" + entry[1] + "]" + entry[2] + "[/say]"

		saved_tag = tag

	if result.is_empty():
		return "Nothing new happened."
	return result

# --- Helper methods ---

func is_dom(char_id: StringName) -> bool:
	return doms.has(char_id)

func is_sub(char_id: StringName) -> bool:
	return subs.has(char_id)

func get_dom_info(char_id: StringName) -> Dictionary:
	return doms.get(char_id, {})

func get_sub_info(char_id: StringName) -> Dictionary:
	return subs.get(char_id, {})

func get_doms() -> Dictionary:
	return doms

func get_subs() -> Dictionary:
	return subs

func should_pause_dom_actions() -> bool:
	if not is_dom(&"pc"):
		return false
	return not pc_allows_dom_autonomy

func sex_should_end() -> bool:
	return sex_ended
