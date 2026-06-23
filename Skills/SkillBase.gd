extends RefCounted
class_name SkillBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base skill with level/experience system.

var npc = null
var id: String = "error"
var level: int = 0
var experience: int = 0
var activities: Dictionary = {}
signal levelChanged(id, newlevel)
signal experienceChanged

func setCharacter(new_npc) -> void:
	npc = new_npc

func getVisibleName() -> String:
	return "Error"

func getShortName() -> String:
	return getVisibleName()

func getVisibleDescription() -> String:
	return "Error, bad description"

static func getRequiredExperience(lvl: int) -> int:
	return 100 + lvl * 10 + int(sqrt(maxf(0.0, float(lvl)))) * 10

static func alwaysVisible() -> bool:
	return false

func scripted() -> bool:
	return false

func setLevel(lvl: int) -> void:
	if lvl > getLevelCap():
		lvl = getLevelCap()
	level = lvl
	levelChanged.emit(id, level)

func getLevel() -> int:
	return level

func addExperience(add_exp: int, activity_id = null) -> void:
	if npc == null or not npc.isPlayer():
		return
	if activity_id != null and activity_id != "" and activities.has(activity_id):
		return
	var mult := 1.0
	mult += npc.getSkillExperienceMult(id)
	experience += roundi(float(add_exp) * mult)
	if activity_id != null and activity_id != "":
		activities[activity_id] = 1
	checkNewLevel()
	experienceChanged.emit()

func getExperience() -> int:
	return experience

func getExperienceToNextLevel() -> int:
	return getRequiredExperience(level)

func getLevelProgress() -> float:
	var required := getExperienceToNextLevel()
	if required <= 0:
		return 1.0
	return float(experience) / float(required)

func getLevelCap() -> int:
	return 100

func checkNewLevel() -> void:
	while experience >= getExperienceToNextLevel():
		experience -= getExperienceToNextLevel()
		setLevel(level + 1)
