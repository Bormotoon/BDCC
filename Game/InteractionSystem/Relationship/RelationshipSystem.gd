extends RefCounted
class_name RelationshipSystem

## MIGRATED to Godot 4 (GDScript 2.0).
## Relationship management with affection/lust decay and special relationships.

var entries: Dictionary = {}
var special: Dictionary = {}
var cooldowns: Dictionary = {}

func clearRelationships() -> void:
	entries.clear()

func onNewDay() -> void:
	for char_id in special:
		special[char_id].onNewDay()
	for special_id in cooldowns:
		var the_cooldowns: Dictionary = cooldowns[special_id]
		var to_remove: Array = []
		for char_id in the_cooldowns:
			the_cooldowns[char_id] -= 1
			if the_cooldowns[char_id] <= 0:
				to_remove.append(char_id)
		for char_id in to_remove:
			the_cooldowns.erase(char_id)

func hoursPassed(how_many: int) -> void:
	decayRelationships(how_many)
	for char_id in special:
		special[char_id].hoursPassed(how_many)

## Line 30-56: Affection/lust decay over time
func decayRelationships(hours_passed: int) -> void:
	var rem: float = float(hours_passed) * 0.0005
	var to_remove: Array = []
	var checked: Dictionary = {}
	for char_id in entries:
		for char2_id in entries[char_id]:
			var entry: RelationshipEntry = entries[char_id][char2_id]
			if checked.has(entry):
				continue
			checked[entry] = true
			if absf(entry.affection) <= rem:
				entry.affection = 0.0
			else:
				entry.affection -= signf(entry.affection) * rem
			if absf(entry.lust) <= rem:
				entry.lust = 0.0
			else:
				entry.lust -= signf(entry.lust) * rem
			if entry.shouldBeRemoved():
				to_remove.append([char_id, char2_id])
	for pair in to_remove:
		removeEntry(pair[0], pair[1])

func getEntry(char1: String, char2: String) -> RelationshipEntry:
	assert(char1 != char2)
	if not entries.has(char1):
		entries[char1] = {}
	if not entries.has(char2):
		entries[char2] = {}
	if entries[char1].has(char2):
		return entries[char1][char2]
	if entries[char2].has(char1):
		return entries[char2][char1]
	var entry := RelationshipEntry.new()
	entries[char1][char2] = entry
	entries[char2][char1] = entry
	return entry

func hasEntry(char1: String, char2: String) -> bool:
	if not entries.has(char1):
		return false
	return entries[char1].has(char2)

func removeEntry(char1: String, char2: String) -> void:
	if entries.has(char1):
		entries[char1].erase(char2)
	if entries.has(char2):
		entries[char2].erase(char1)

func getAffection(char1: String, char2: String) -> float:
	if not hasEntry(char1, char2):
		return 0.0
	return getEntry(char1, char2).affection

func addAffection(char1: String, char2: String, amount: float) -> void:
	getEntry(char1, char2).affection += amount

func getLust(char1: String, char2: String) -> float:
	if not hasEntry(char1, char2):
		return 0.0
	return getEntry(char1, char2).lust

func addLust(char1: String, char2: String, amount: float) -> void:
	getEntry(char1, char2).lust += amount

# Special relationships
func startSpecialRelantionship(relationship_type: String, char_id: String) -> void:
	if special.has(char_id):
		return
	var base = GlobalRegistry.getSpecialRelationship(relationship_type)
	if base == null:
		return
	var new_rel = base.new()
	new_rel.init(char_id)
	special[char_id] = new_rel

func removeSpecialRelationship(char_id: String) -> void:
	special.erase(char_id)

func getSpecialRelationship(char_id: String):
	return special.get(char_id)

func saveData() -> Dictionary:
	return {"entries": {}, "special": {}, "cooldowns": {}}

func loadData(data: Dictionary) -> void:
	pass
