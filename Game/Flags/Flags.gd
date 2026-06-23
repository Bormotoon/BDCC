extends Object
class_name Flag

## MIGRATED to Godot 4 (GDScript 2.0).
## Global flag definitions and reset logic.

static func getFlags() -> Dictionary:
	return {
		"Canteen_PlayerAteToday": flag(FlagType.Bool),
		"Mining_IntroducedToMinning": flag(FlagType.Bool),
		"Game_CompletedPrologue": flag(FlagType.Bool),
		"Game_PickedStartingPerks": flag(FlagType.Bool),
		"Player_Crime_Type": flag(FlagType.Number),
		"Trigger_CaughtOffLimitsCD": flag(FlagType.Number),
		"ExposureEventCD": flag(FlagType.Number),
		"LastTimePeed": flag(FlagType.Number),
		"PickedSkinAtLeastOnce": flag(FlagType.Bool),
	}

enum Crime_Type {Innocent, Theft, Murder, Prostitution}

static func resetFlagsOnNewDay() -> void:
	if GM.main.getFlag("Canteen_PlayerAteToday"):
		GM.main.setFlag("Canteen_PlayerAteToday", false)
	var modules = GlobalRegistry.getModules()
	for module_id in modules:
		modules[module_id].reset_flags_on_new_day()

static func flag(type) -> Dictionary:
	return {"type": type}
