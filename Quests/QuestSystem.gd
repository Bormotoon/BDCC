extends Node
class_name QuestSystem

## MIGRATED to Godot 4 (GDScript 2.0).
## Quest management with datapack support.

var quests: Dictionary = {}

func _ready() -> void:
	ServiceLocator.safe_get_service(&"QuestSystem") = self
	name = "QuestSystem"
	registerQuests()

func registerQuests() -> void:
	var loaded_quests = GlobalRegistry.getQuests()
	for quest_id in loaded_quests:
		quests[quest_id] = loaded_quests[quest_id]

func isCompleted(quest_id) -> bool:
	assert(quests.has(quest_id))
	return quests[quest_id].isCompleted()

func isActive(quest_id) -> bool:
	assert(quests.has(quest_id))
	return quests[quest_id].isVisible() and not quests[quest_id].isCompleted()

func getQuests() -> Dictionary:
	return quests

func getAllQuests() -> Dictionary:
	var result := quests.duplicate()
	for datapack_id in ServiceLocator.safe_get_service(&"MainScene").loadedDatapacks:
		var datapack = GlobalRegistry.getDatapack(datapack_id)
		if datapack == null:
			continue
		for quest_id in datapack.quests:
			var datapack_quest = datapack.quests[quest_id]
			var new_quest: DatapackQuestBase = DatapackQuestBase.new()
			new_quest.id = datapack_id + ":" + quest_id
			new_quest.setDatapackAndQuest(datapack, datapack_quest)
			result[datapack_id + ":" + quest_id] = new_quest
	return result
