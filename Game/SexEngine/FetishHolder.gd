extends RefCounted
class_name FetishHolder

## MIGRATED to Godot 4 (GDScript 2.0).
## Fetish management with scoring and forced obedience blending.

var character: WeakRef
var fetish_map: Dictionary = {}

func _init() -> void:
	for fetish_id in GlobalRegistry.getFetishes():
		set_fetish(fetish_id, FetishInterest.Likes)

func clear() -> void:
	fetish_map.clear()

func clear_to_interest(interest_value: float) -> void:
	for fetish_id in GlobalRegistry.getFetishes():
		set_fetish(fetish_id, interest_value)

func get_character():
	if character == null:
		return null
	return character.get_ref()

func set_character(new_char) -> void:
	character = weakref(new_char)

func set_fetish(fetish_id: String, interest: float) -> void:
	fetish_map[fetish_id] = clampf(interest, -1.0, 1.0)

func get_fetish(fetish_id: String) -> float:
	return fetish_map.get(fetish_id, 0.0)

func get_fetish_value(fetish_id: String) -> float:
	return fetish_map.get(fetish_id, 0.0)

func add_fetish(fetish_id: String, val: float) -> void:
	fetish_map[fetish_id] = clampf(get_fetish(fetish_id) + val, -1.0, 1.0)

func get_fetishes() -> Dictionary:
	return fetish_map

## Goal generation from fetishes
func get_goals(_sex_engine, _sub, min_value: float = 0.0) -> Array:
	var result: Array = []
	for fetish_id in GlobalRegistry.getFetishes():
		var interest_value: float = fetish_map.get(fetish_id, 0.0)
		if interest_value >= min_value:
			var fetish: FetishBase = GlobalRegistry.getFetish(fetish_id)
			var goals = fetish.getGoals(_sex_engine, self, get_character(), _sub)
			for goal in goals:
				result.append([goal, maxf(0.1, interest_value)])
	return result

func remove_impossible_fetishes() -> void:
	var the_character = get_character()
	if the_character == null:
		return
	for fetish_id in fetish_map.keys():
		var fetish: FetishBase = GlobalRegistry.getFetish(fetish_id)
		if not fetish.isPossibleFor(the_character):
			fetish_map.erase(fetish_id)

## Fetish scoring with forced obedience blending (lines 84-98)
func score_fetish(fetishes: Dictionary, only_positive: bool = false) -> float:
	var max_possible := 0.0
	var result := 0.0
	for fetish_id in fetishes:
		var fetish_value: float = get_fetish_value(fetish_id)
		var add_value := fetish_value * fetishes[fetish_id]
		if not only_positive or add_value > 0.0:
			result += add_value
		max_possible += 1.0
	var forced_obedience := clampf(get_character().get_forced_obedience_level(), 0.0, 1.0)
	if forced_obedience > 0.0:
		result = result * (1.0 - forced_obedience) + max_possible * forced_obedience
	return result

func score_fetish_max(fetishes: Dictionary, min_value: float = -999.9) -> float:
	var result := min_value
	for fetish_id in fetishes:
		var new_value: float = get_fetish_value(fetish_id) * fetishes[fetish_id]
		if new_value > result:
			result = new_value
	var forced_obedience := clampf(get_character().get_forced_obedience_level(), 0.0, 1.0)
	if forced_obedience > 0.0:
		result = result * (1.0 - forced_obedience) + forced_obedience
	return result

func save_data() -> Dictionary:
	return {"fetishMap": fetish_map}

func load_data(data: Dictionary) -> void:
	var new_map = SAVE.loadVar(data, "fetishMap", null)
	if new_map != null and new_map is Dictionary:
		var filtered: Dictionary = {}
		for fetish_id in new_map:
			var fetish_obj = GlobalRegistry.getFetish(fetish_id)
			if fetish_obj == null:
				continue
			var val = new_map[fetish_id]
			if val is String:
				val = FetishInterest.textToNumber(val)
			filtered[fetish_id] = val
		fetish_map = filtered
	# Add missing fetishes
	var the_char = get_character()
	if the_char != null:
		for fetish_id in GlobalRegistry.getFetishes():
			if not fetish_map.has(fetish_id):
				var fetish_obj = GlobalRegistry.getFetish(fetish_id)
				if fetish_obj.isPossibleFor(the_char):
					fetish_map[fetish_id] = RNG.randf_range(-1.0, 1.0)
