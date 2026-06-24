extends SexInfoBase
class_name SexSubInfo

## MIGRATED to Godot 4 (GDScript 2.0).
## Sub info with resistance, fear, consciousness, and personality changes.

var resistance: float = 0.0
var fear: float = 0.0
var resistance_full: float = 0.0
var fear_full: float = 0.0
var obey_mode: bool = false

func init_from_personality() -> void:
	var character = getChar()
	var personality: Personality = character.getPersonality()
	var bratiness := personality.getStat(PersonalityStat.Brat)
	if bratiness > 0.0:
		resistance = randf_range(0.0, bratiness)
	if getChar().getBuffsHolder().hasBuff(Buff.ActiveResistanceInSexBuff):
		resistance = 1.0
	if getChar().isSlaveToPlayer():
		var npc_slave = getChar().getNpcSlavery()
		fear = npc_slave.getFear()

func can_do_actions() -> bool:
	if getChar().getBuffsHolder().hasBuff(Buff.SpacedOutInSexBuff):
		return false
	if getConsciousness() <= 0.0:
		return false
	return true

func is_unconscious() -> bool:
	return getConsciousness() <= 0.0

func is_resisting_slightly() -> bool:
	if should_fully_obey():
		return false
	return resistance >= (0.1 + personalityScore({PersonalityStat.Naive: 0.05}))

func is_resisting() -> bool:
	if should_fully_obey():
		return false
	return resistance >= (0.3 + personalityScore({PersonalityStat.Naive: 0.2}))

func is_scared() -> bool:
	if should_fully_obey():
		return false
	return fear >= (0.5 - 0.3 * personalityScore({PersonalityStat.Coward: 1.0}))

func is_very_scared() -> bool:
	if should_fully_obey():
		return false
	return fear >= 0.9

func get_about_to_pass_out_score() -> float:
	if getConsciousness() > 0.8:
		return 0.0
	return clampf(1.0 - getConsciousness() * 2.0, 0.0, 1.0)

func add_pain(new_pain: float) -> void:
	super.add_pain(new_pain)
	if new_pain >= 0.0 and getChar().getPainLevel() >= 1.0:
		addConsciousness(-new_pain / 100.0)

func getConsciousness() -> float:
	return getChar().getConsciousness()

## Line 93-110: Consciousness with fetish-based satisfaction/frustration
func add_consciousness(new_con: float) -> void:
	var was_conscious := getConsciousness() > 0.0
	getChar().addConsciousness(new_con)
	if new_con < 0.0:
		if getConsciousness() < 0.5:
			if fetishScore({Fetish.UnconsciousSex: 1.0}) < 0.3:
				add_frustration(absf(new_con) * 3.0)
			else:
				add_satisfaction(absf(new_con) * 3.0)
		if getConsciousness() >= 0.5:
			if fetishScore({Fetish.Choking: 1.0}) < 0.3:
				add_frustration(absf(new_con))
			else:
				add_satisfaction(absf(new_con))
	if was_conscious and charID == "pc" and getConsciousness() <= 0.0:
		SexToyManager.sendTrigger(SexToyTrigger.OnLoseConsciousness)

## Line 112-118: Fear with Coward personality and forced obedience
func add_fear(add_fear: float) -> void:
	if getConsciousness() <= 1.0 and add_fear > 0.0:
		add_fear /= maxf(getConsciousness(), 0.1)
	fear += add_fear * (1.0 + personalityScore({PersonalityStat.Coward: 0.5}))
	fear = clampf(fear, 0.0, 1.0)
	var forced_obedience := clampf(getChar().getForcedObedienceLevel(), 0.0, 1.0)
	fear = clampf(fear, 0.0, 1.0 - forced_obedience)

## Line 120-131: Resistance with Subby/Brat personality
func add_resistance(add_res: float) -> void:
	if is_scared():
		add_res /= 2.0
	if is_very_scared():
		add_res /= 2.0
	resistance += add_res * (1.0 + personalityScore({PersonalityStat.Subby: -0.2, PersonalityStat.Brat: 0.1}))
	resistance = clampf(resistance, 0.0, 1.0)
	var forced_obedience := clampf(getChar().getForcedObedienceLevel(), 0.0, 1.0)
	resistance = clampf(resistance, 0.0, 1.0 - forced_obedience)
	if add_res > 0.0:
		add_frustration(add_res * 0.2)

func get_resist_score() -> float:
	if is_scared() or should_fully_obey():
		return 0.0
	if is_resisting():
		return 1.0
	if RNG.chance(personalityScore({PersonalityStat.Brat: 1.0}) * 5.0):
		return 1.0
	return 0.0

func get_resist_score_smooth() -> float:
	if is_scared() or should_fully_obey():
		return 0.0
	if is_resisting():
		return 1.0
	return resistance

func get_comply_score() -> float:
	if should_fully_obey():
		return 1.0
	if is_scared() or is_resisting():
		return 0.0
	return 1.0

## Line 160-186: processTurn with resistance/fear decay and forced obedience
func process_turn() -> void:
	arousal_natural_fade()
	fear = Util.moveNumberTowards(fear, 0.0, 0.02 + personalityScore({PersonalityStat.Coward: -0.02}))
	if is_scared():
		resistance = Util.moveNumberTowards(resistance, 0.0, fear / 10.0)
	else:
		if getChar().getBuffsHolder().hasBuff(Buff.ActiveResistanceInSexBuff):
			resistance = Util.moveNumberTowards(resistance, 1.0, 0.1)
	obey_mode = false
	var forced_obedience := clampf(getChar().getForcedObedienceLevel(), 0.0, 1.0)
	if forced_obedience > 0.0:
		resistance = clampf(resistance, 0.0, 1.0 - forced_obedience)
		fear = clampf(fear, 0.0, 1.0 - forced_obedience)
		if getChar().isPlayer():
			obey_mode = RNG.chance(forced_obedience * 100.0)
	super.process_turn()
	resistance_full += resistance
	fear_full += fear

func get_average_resistance() -> float:
	return resistance_full / float(maxi(1, tick))

func get_average_fear() -> float:
	return fear_full / float(maxi(1, tick))

## Personality changes (lines 203-278) — ALL logic preserved
func affect_personality(_personality: Personality, _fetish_holder: FetishHolder) -> String:
	var changes: Array = []
	if isUnconscious():
		if RNG.chance(50):
			if _personality.addStat(PersonalityStat.Subby, randf_range(0.05, 0.1)):
				changes.append("{npc.name} became less dominant because {npc.he} finished unconscious.")
		if RNG.chance(30):
			if _personality.addStat(PersonalityStat.Coward, randf_range(0.05, 0.1)):
				changes.append("{npc.name} became more cowardly because {npc.he} finished unconscious.")
	else:
		if getTimesCame() <= 0:
			if RNG.chance(50):
				if _personality.addStat(PersonalityStat.Brat, randf_range(-0.1, -0.01)):
					changes.append("{npc.name} became less bratty because of the frustration.")
		if getTimesCame() >= 4:
			if RNG.chance(50):
				if _personality.addStat(PersonalityStat.Subby, randf_range(0.05, 0.15)):
					changes.append("{npc.name} became more subby after so many orgasms.")
		if getAverageResistance() > 0.5:
			if RNG.chance(50):
				if _personality.addStat(PersonalityStat.Subby, randf_range(-0.1, -0.01)):
					changes.append("{npc.name} became slightly more dominant after resisting so much.")
		if getTimesCame() >= 1 and getAverageLust() > 0.5 and getAverageResistance() < 0.3:
			if RNG.chance(50):
				if _personality.addStat(PersonalityStat.Subby, randf_range(0.01, 0.1)):
					changes.append("{npc.name} became more subby after a good sex.")
		if getAverageFear() > 0.6:
			if RNG.chance(70):
				if _personality.addStat(PersonalityStat.Coward, randf_range(0.01, 0.1)):
					changes.append("{npc.name} became more cowardly after so much intimidation.")
	return GM.ui.processString(Util.join(changes, "\n"), {"npc": charID})

func is_resisting_new_fetishes(_fetish_id: String) -> bool:
	if is_resisting():
		if getChar().getLustLevel() <= 0.8:
			return true
	return false

func should_fully_obey() -> bool:
	if obey_mode:
		return true
	var forced_obedience := clampf(getChar().getForcedObedienceLevel(), 0.0, 1.0)
	return forced_obedience >= 1.0

func save_data() -> Dictionary:
	var data := super.save_data()
	data["resistance"] = resistance
	data["fear"] = fear
	data["resistanceFull"] = resistance_full
	data["fearFull"] = fear_full
	data["obeyMode"] = obey_mode
	return data

func load_data(data: Dictionary) -> void:
	super.load_data(data)
	resistance = SAVE.loadVar(data, "resistance", 0.0)
	fear = SAVE.loadVar(data, "fear", 0.0)
	resistance_full = SAVE.loadVar(data, "resistanceFull", 0.0)
	fear_full = SAVE.loadVar(data, "fearFull", 0.0)
	obey_mode = SAVE.loadVar(data, "obeyMode", false)
