extends Object
class_name InteractionGoal

## MIGRATED to Godot 4 (GDScript 2.0).
## Goal ID constants and factory.

const Wander: String = "Wander"
const Eat: String = "Eat"
const Hangout: String = "Hangout"
const WorkMine: String = "WorkMine"
const Patrol: String = "Patrol"
const POI: String = "POI"
const Save: String = "Save"
const Prostitute: String = "Prostitute"
const Shower: String = "Shower"
const RepairClothes: String = "RepairClothes"
const Leave: String = "Leave"
const Struggle: String = "Struggle"
const GiveBirth: String = "GiveBirth"
const LayEggs: String = "LayEggs"
const HangoutAt: String = "HangoutAt"
const SlaveLeave: String = "SlaveLeave"
const SlaveGiveCredits: String = "SlaveGiveCredits"
const NemesisAmbush: String = "NemesisAmbush"
const GetHealed: String = "GetHealed"
const NpcOwnerApproach: String = "NpcOwnerApproach"

static func getAll() -> Array:
	return [Wander, Eat, Hangout, WorkMine, Patrol, POI, Save, Prostitute, Shower, RepairClothes, Leave, Struggle, GiveBirth, LayEggs, HangoutAt, SlaveLeave, SlaveGiveCredits]

static func getAllAlone() -> Array:
	return [Wander, Eat, Hangout, WorkMine, POI, Shower, RepairClothes, Leave, Struggle, GiveBirth, LayEggs, SlaveLeave, SlaveGiveCredits, Prostitute, NemesisAmbush, GetHealed, NpcOwnerApproach]

static func create(the_id: String):
	var resource_path = "res://Game/InteractionSystem/AloneGoals/Goal" + the_id + ".gd"
	var loaded = load(resource_path)
	if loaded == null:
		return null
	var new_block = loaded.new()
	if new_block != null:
		new_block.id = the_id
	return new_block

static func getRef(the_id: String):
	if GlobalRegistry.interactionGoalRefCache.has(the_id):
		return GlobalRegistry.interactionGoalRefCache[the_id]
	GlobalRegistry.interactionGoalRefCache[the_id] = create(the_id)
	return GlobalRegistry.interactionGoalRefCache[the_id]
