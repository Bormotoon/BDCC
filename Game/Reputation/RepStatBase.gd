extends RefCounted
class_name RepStatBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base reputation stat with level scoring.

var id: String = "error"

func getVisibleName() -> String:
	return "Error?"

func getTextForLevel(_level: int, _rep) -> String:
	return "ERROR, FILL ME PLS"

func getEffectsInfoForLevel(_level: int, _rep) -> Array:
	return []

func getMaxLevel() -> int:
	return 4

func getMinLevel() -> int:
	return -1

func getNeededScoreForLevel(level: int, cur_level: int) -> float:
	if cur_level > 0 and level < cur_level:
		return 1.0
	if cur_level < 0 and level > cur_level:
		return 1.0
	var abs_level := absi(level)
	if abs_level <= 1:
		return 1.0
	return 1.0 + float(abs_level * abs_level) * 0.1

func getSpecialRequirementToReachLevel(_level: int, _rep):
	return null
