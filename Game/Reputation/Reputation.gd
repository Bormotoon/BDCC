extends ReputationPlaceholder
class_name Reputation

## MIGRATED to Godot 4 (GDScript 2.0).
## Full reputation system with levels, scores, and level-up messages.

var char_id: String = ""
var levels: Dictionary = {}
var scores: Dictionary = {}

func isPlaceholder() -> bool:
	return false

func getChar():
	return GlobalRegistry.getCharacter(char_id)

func setCharacter(the_char) -> void:
	char_id = the_char.getID()

func isPlayer() -> bool:
	return char_id == "pc"

func getRepLevel(stat: String) -> int:
	return levels.get(stat, 0)

func getRepScore(stat: String) -> float:
	return scores.get(stat, 0.0)

func setLevel(stat: String, new_level: int, show_message: bool = true) -> void:
	var rep_stat: RepStatBase = GlobalRegistry.getRepStat(stat)
	if rep_stat == null:
		return
	new_level = clampi(new_level, rep_stat.getMinLevel(), rep_stat.getMaxLevel())
	if not levels.has(stat):
		levels[stat] = 0
	var old_level: int = levels[stat]
	if old_level == new_level:
		return
	levels[stat] = new_level
	scores[stat] = 0.0
	onRepLevelChanged(stat, new_level, old_level < new_level, show_message)

func addRep(stat: String, amount: float) -> void:
	if not scores.has(stat):
		scores[stat] = 0.0
	scores[stat] += amount
	checkLevelUp(stat)

func checkLevelUp(stat: String) -> void:
	var rep_stat: RepStatBase = GlobalRegistry.getRepStat(stat)
	if rep_stat == null:
		return
	var cur_level: int = getRepLevel(stat)
	var max_level: int = rep_stat.getMaxLevel()
	if cur_level >= max_level:
		return
	var cur_score: float = getRepScore(stat)
	var next_level: int = cur_level + 1
	var needed: float = rep_stat.getNeededScoreForLevel(next_level, cur_level)
	if cur_score >= needed:
		var special_req = rep_stat.getSpecialRequirementToReachLevel(next_level, self)
		if special_req == null:
			setLevel(stat, next_level)

func onRepLevelChanged(stat: String, new_level: int, is_up: bool, show_message: bool) -> void:
	if show_message:
		var rep_stat: RepStatBase = GlobalRegistry.getRepStat(stat)
		if rep_stat != null:
			var text := rep_stat.getTextForLevel(new_level, self)
			if text != "":
				GM.main.addMessage(text)

func getGenericRepMult(stat: String, default_mult: float) -> float:
	var level: int = getRepLevel(stat)
	if level <= 1:
		return default_mult
	return default_mult + sqrt(float(level * 2))

func saveData() -> Dictionary:
	return {"levels": levels, "scores": scores}

func loadData(data: Dictionary) -> void:
	levels = SAVE.loadVar(data, "levels", {})
	scores = SAVE.loadVar(data, "scores", {})
