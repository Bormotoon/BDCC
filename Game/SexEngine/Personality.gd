extends RefCounted
class_name Personality

## MIGRATED to Godot 4 (GDScript 2.0).
## Personality system with stat-based scoring.

var character: WeakRef
var stats: Dictionary = {}

func _init() -> void:
	for stat_id in PersonalityStat.getAll():
		stats[stat_id] = 0.0

func set_character(new_char) -> void:
	character = weakref(new_char)

func get_character():
	if character == null:
		return null
	return character.get_ref()

func clear() -> void:
	stats.clear()

func get_stat(stat_id) -> float:
	return stats.get(stat_id, 0.0)

func set_stat(stat_id, new_value: float) -> void:
	stats[stat_id] = clampf(new_value, -1.0, 1.0)

func add_stat(stat_id, add_value: float) -> bool:
	if not stats.has(stat_id):
		stats[stat_id] = 0.0
	var old_value: float = stats[stat_id]
	stats[stat_id] = clampf(stats[stat_id] + add_value, -1.0, 1.0)
	return old_value != stats[stat_id]

func personality_score(personality_stats: Dictionary = {}, only_positive: bool = false) -> float:
	var result := 0.0
	for stat_id in personality_stats:
		var personality_value := get_stat(stat_id)
		var add_value := personality_value * personality_stats[stat_id]
		if only_positive and add_value <= 0.0:
			continue
		result += add_value
	return result

func personality_score_max(personality_stats: Dictionary = {}, min_value: float = -999.9) -> float:
	var result := min_value
	for stat_id in personality_stats:
		var personality_value := get_stat(stat_id)
		var add_value := personality_value * personality_stats[stat_id]
		if add_value > result:
			result = add_value
	return result

func save_data() -> Dictionary:
	return {"stats": stats}

func load_data(data: Dictionary) -> void:
	var new_stats = SAVE.loadVar(data, "stats", null)
	if new_stats != null and new_stats is Dictionary:
		var filtered: Dictionary = {}
		for stat_id in new_stats:
			if not PersonalityStat.statExists(stat_id):
				continue
			filtered[stat_id] = new_stats[stat_id]
		stats = filtered
