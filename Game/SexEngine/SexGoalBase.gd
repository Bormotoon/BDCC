extends RefCounted
class_name SexGoalBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for sex goals. extends Reference → RefCounted.

var id: String = "error"

func get_visible_name() -> String:
	return "Error"

func is_possible(_sex_engine, _dom_info, _sub_info, _data) -> bool:
	return true

func is_completed(_sex_engine, _dom_info, _sub_info, _data) -> bool:
	return false

func generate_data(_sex_engine, _dom_info, _sub_info) -> Array:
	return []

func progress_goal(_sex_engine, _dom_info, _sub_info, _data, _args: Array = []) -> void:
	pass

func get_sub_goals(_sex_engine, _dom_info, _sub_info, _data) -> Dictionary:
	return {}

func can_lead_to_subs_pregnancy(_sex_engine, _dom_info, _sub_info, _data) -> bool:
	return false

func dom_wants_to_cum() -> bool:
	return false

func get_goal_default_weight() -> float:
	return 1.0

func do_fast_sex(_sex_engine, _dom_info, _sub_info, _data) -> void:
	pass

func send_sex_event(_sex_engine, type, _source_info, _target_info, data: Dictionary = {}) -> void:
	var new_event: SexEvent = SexEvent.new()
	new_event.type = type
	new_event.sourceCharID = _source_info.charID
	new_event.targetCharID = _target_info.charID
	new_event.data = data
	new_event.isSexEngine = true
	new_event.sexEngine = _sex_engine
	_source_info.getChar().sendSexEvent(new_event)
	if _source_info.getChar() != _target_info.getChar():
		_target_info.getChar().sendSexEvent(new_event)

func can_beg_for() -> bool:
	return false

func get_beg_name() -> String:
	return get_visible_name()

const BegCategoryDefault: Array = ["Beg"]
const BegCategoryChoking: Array = ["Beg", "Choking"]
const BegCategoryExotic: Array = ["Beg", "Exotic"]
const BegCategorySex: Array = ["Beg", "Sex"]

func get_beg_category() -> Array:
	return BegCategoryDefault

func get_beg_desc() -> String:
	return "Ask the dom to do this to you!"

func get_beg_agree_dialogue() -> String:
	return RNG.pick(["Sure.", "Sounds good.", "Alright, let's do it.", "Okay, I hear you."])

func get_beg_deny_dialogue() -> String:
	return RNG.pick(["Nope. I don't want to.", "I don't want to do that.", "No. Just no."])

func get_beg_dom_fetishes() -> Dictionary:
	return {}
