extends RefCounted
class_name SexReactionHandler

## MIGRATED to Godot 4 (GDScript 2.0).
## Reaction handler with chance-based dialogue selection.

const REACT_CHANCE: int = 0
const REACT_TOGETHER: int = 1
const REACT_CHANCES: int = 2

const DOM_0: int = 0
const DOM_1: int = 1
const DOM_2: int = 2
const SUB_0: int = -1
const SUB_1: int = -2
const SUB_2: int = -3

const ROLE_MAIN: int = 0
const ROLE_TARGET: int = 1
const ROLE_EXTRA: int = 2
const ROLE_EXTRA_2: int = 3

var chance_to_react: float = 100.0
var handles: Dictionary = {}
var handler_weight: float = 1.0

func should_say_together(reaction_id: int) -> bool:
	if handles.has(reaction_id) and handles[reaction_id].has(REACT_TOGETHER):
		return handles[reaction_id][REACT_TOGETHER]
	return false

func get_chance(reaction_id: int) -> float:
	if not should_say_together(reaction_id) and handles.has(reaction_id) and handles[reaction_id].has(REACT_CHANCES):
		var the_chances: Array = handles[reaction_id][REACT_CHANCES]
		if indxTemp >= 0 and indxTemp < the_chances.size():
			return the_chances[indxTemp]
	if handles.has(reaction_id) and handles[reaction_id].has(REACT_CHANCE):
		return handles[reaction_id][REACT_CHANCE]
	return chance_to_react

func check_chance(reaction_id: int, chances: Array = []) -> bool:
	if not chances.is_empty():
		if indxTemp >= 0 and indxTemp < chances.size():
			return RNG.chance(chances[indxTemp])
	return RNG.chance(get_chance(reaction_id))

func add_lines(lines: Array) -> void:
	linesTemp.append_array(lines)

func get_lines(reaction: int, role: int, args: Array):
	return []

func get_reaction_text(reaction_id: int, args: Dictionary = {}) -> String:
	return ""

func get_together_text(reaction_id: int, args: Dictionary = {}) -> String:
	return ""

func get_main_text(reaction_id: int, args: Dictionary = {}) -> String:
	return ""

func get_target_text(reaction_id: int, args: Dictionary = {}) -> String:
	return ""

func process(reaction_id: int, args: Dictionary = {}) -> Array:
	return []

func get_info_string() -> String:
	return ""
