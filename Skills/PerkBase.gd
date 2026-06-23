extends RefCounted
class_name PerkBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base perk with unlock/toggle/combat logic.

var npc = null
var id: String = "error"
var skill_group: StringName = Skill.Combat
var dungeon_weight: float = 1.0

func getVisibleName() -> String:
	return "Error"

func getVisibleDescription() -> String:
	return "Error bad"

func getMoreDescription() -> String:
	return ""

func runOnceWhenLearned() -> void:
	pass

func getSkillGroup() -> StringName:
	return skill_group

func getSkillTier() -> int:
	return 0

func hiddenWhenLocked() -> bool:
	return false

func hiddenWhenUnlocked() -> bool:
	return false

func toggleable() -> bool:
	return true

func unlockable() -> bool:
	return true

func getPicture() -> String:
	return "res://Images/Perks/upgrade.png"

func getCost() -> int:
	return maxi(getSkillTier() + 1, 0)

func getRequiredPerks() -> Array:
	return []

func setCharacter(new_npc) -> void:
	npc = new_npc

func addsAttacks() -> Array:
	return []

func processBattleTurn() -> void:
	pass

func onFightStart(_contex: Dictionary = {}) -> void:
	pass

func processBattleTurnContex(_contex: Dictionary = {}) -> void:
	pass

func processSexTurnContex(_contex: Dictionary = {}) -> void:
	pass

func onFightEnd(_contex: Dictionary = {}) -> void:
	pass

func getDungeonPerkCost() -> int:
	return 1

func getDungeonPerkDescription() -> String:
	return getVisibleDescription()
