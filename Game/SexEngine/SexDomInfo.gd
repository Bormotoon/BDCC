extends SexInfoBase
class_name SexDomInfo

## MIGRATED to Godot 4 (GDScript 2.0).
## Dom info with goals, anger, and personality changes.

var goals: Array = []
var anger: float = 0.0
var is_down: bool = false
var anger_full: float = 0.0
var has_any_cum_goals: bool = false
var dynamic_joiner: bool = false

func has_goal_to_cum() -> bool:
	return has_any_cum_goals

func after_goals_assigned() -> void:
	_check_has_cum_goals()

func _check_has_cum_goals() -> void:
	has_any_cum_goals = false
	for goal_info in goals:
		var sex_goal = GlobalRegistry.getSexGoal(goal_info[0])
		if sex_goal != null and sex_goal.domWantsToCum():
			has_any_cum_goals = true

func check_is_down() -> bool:
	if not is_down and getChar().getPainLevel() >= 1.0:
		is_down = true
		return true
	return false

func get_is_down() -> bool:
	return is_down

func can_do_actions() -> bool:
	return not is_down

## Line 41-58: anger with personality modifier
func add_anger(how_much: float = 0.2) -> void:
	var meanness := personalityScore({PersonalityStat.Mean: 0.5, PersonalityStat.Impatient: 0.2, PersonalityStat.Subby: -0.2})
	if meanness >= 0.0:
		if how_much > 0.0:
			how_much *= (1.0 + meanness)
		else:
			how_much *= maxf(1.0 - meanness, 0.1)
	else:
		if how_much > 0.0:
			how_much *= maxf(1.0 + meanness, 0.1)
		else:
			how_much *= (1.0 - meanness)
	if meanness < 0.5:
		add_frustration(maxf(how_much * (0.5 - meanness), 0.0))
	anger += how_much
	anger = clampf(anger, 0.0, 1.0)

func get_anger_score() -> float:
	return anger

func is_slightly_angry() -> bool:
	return anger > 0.2

func is_angry() -> bool:
	return anger > (0.6 - personalityScore({PersonalityStat.Mean: 0.2}))

func get_trusts_sub_score() -> float:
	return clampf(1.0 - anger * 3.0, 0.0, 1.0)

func get_sadistic_action_store() -> float:
	return fetishScore({Fetish.Sadism: 1.0}) / 8.0 + getAngerScore() / 10.0 + personalityScore({PersonalityStat.Mean: 1.0}) / 10.0

func init_from_personality() -> void:
	var character = getChar()
	var personality: Personality = character.getPersonality()
	var mean := personality.getStat(PersonalityStat.Mean)
	if mean > 0.0:
		anger = RNG.randf_range(0.0, mean) / 5.0

func process_turn() -> void:
	arousal_natural_fade()
	var forced_anger: float = getChar().getCustomAttribute(BuffAttribute.AngerInSex)
	if forced_anger > 0.0 and anger < forced_anger:
		anger = Util.moveNumberTowards(anger, forced_anger, 0.1)
	super.process_turn()
	anger_full += anger

func has_goals() -> bool:
	return goals.size() > 0

func goals_score(the_goals: Dictionary, the_sub_id: String) -> float:
	var result := 0.0
	for goal_info in goals:
		if the_goals.has(goal_info[0]) and goal_info[1] == the_sub_id:
			result += the_goals[goal_info[0]]
	return result

func get_average_anger() -> float:
	return anger_full / float(maxi(1, tick))

func is_dom() -> bool:
	return true

func on_goal_satisfied(_dom_info, _goal_id, _sub_info, mult: float = 1.0) -> void:
	add_satisfaction(0.5 * mult)

func on_goal_failed(_dom_info, _goal_id, _sub_info, mult: float = 1.0) -> void:
	add_frustration(1.0 * mult)

func set_dynamic_joiner(is_dyn: bool) -> void:
	dynamic_joiner = is_dyn

func is_dynamic_joiner() -> bool:
	return dynamic_joiner

## Personality changes after sex (lines 156-203) — ALL logic preserved
func affect_personality(_personality: Personality, _fetish_holder: FetishHolder) -> String:
	var changes: Array = []
	if not can_do_actions():
		if RNG.chance(50):
			if _personality.addStat(PersonalityStat.Subby, RNG.randf_range(0.05, 0.1)):
				changes.append("{npc.name} became less dominant because {npc.he} got beaten up by a sub.")
		if RNG.chance(50):
			if _personality.addStat(PersonalityStat.Coward, RNG.randf_range(0.01, 0.1)):
				changes.append("{npc.name} became more cowardly because {npc.he} got beaten up by a sub.")
	else:
		if RNG.chance(30):
			if _personality.addStat(PersonalityStat.Subby, RNG.randf_range(-0.05, -0.01)):
				changes.append("{npc.name} became slightly more dominant.")
		if RNG.chance(30):
			if _personality.addStat(PersonalityStat.Impatient, RNG.randf_range(-0.05, -0.01)):
				changes.append("{npc.name} became less impatient.")
		if RNG.chance(30):
			if _personality.addStat(PersonalityStat.Coward, RNG.randf_range(-0.05, -0.01)):
				changes.append("{npc.name} became more brave.")
		if getTimesCame() >= 1 and getAverageAnger() < 0.3:
			if RNG.chance(50):
				if _personality.addStat(PersonalityStat.Subby, RNG.randf_range(-0.1, -0.01)):
					changes.append("{npc.name} became more dominant after a good sex.")
	return GM.ui.processString(Util.join(changes, "\n"), {"npc": charID})

func save_data() -> Dictionary:
	var data := super.save_data()
	data["goals"] = goals
	data["anger"] = anger
	data["isDown"] = is_down
	data["angerFull"] = anger_full
	data["hasAnyCumGoals"] = has_any_cum_goals
	data["dynamicJoiner"] = dynamic_joiner
	return data

func load_data(data: Dictionary) -> void:
	super.load_data(data)
	goals = SAVE.loadVar(data, "goals", [])
	anger = SAVE.loadVar(data, "anger", 0.0)
	is_down = SAVE.loadVar(data, "isDown", false)
	anger_full = SAVE.loadVar(data, "angerFull", 0.0)
	has_any_cum_goals = SAVE.loadVar(data, "hasAnyCumGoals", false)
	dynamic_joiner = SAVE.loadVar(data, "dynamicJoiner", false)
