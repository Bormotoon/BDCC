# Resources/QuestData.gd
class_name QuestData extends Resource

## Migrated from QuestBase.gd (25 lines) and Quest.gd (2 lines).
## Resource-based quest definition replacing scattered Dictionary quests.

@export var quest_id: StringName = &"unknown_quest"
@export var title: String = "Unknown Quest"
@export_multiline var description: String = ""
@export var is_main_quest: bool = false
@export var stages: Array[String] = []
@export var default_vars: Dictionary = {}

# Runtime state (not serialized)
var _current_stage: int = 0
var _is_visible: bool = false
var _is_completed: bool = false

## Returns visible name for UI (migrated from QuestBase.getVisibleName)
func get_visible_name() -> String:
	return title

## Returns current progress description (migrated from QuestBase.getProgress)
func get_progress() -> Array[String]:
	if _current_stage < stages.size():
		return [stages[_current_stage]]
	return ["Quest completed"]

## Whether quest is visible in journal (migrated from QuestBase.isVisible)
func is_visible() -> bool:
	return _is_visible

## Whether quest is completed (migrated from QuestBase.isCompleted)
func is_completed() -> bool:
	return _is_completed

## Whether this is a main quest (migrated from QuestBase.isMainQuest)
func is_main() -> bool:
	return is_main_quest

## Quest priority for ordering (migrated from QuestBase.getPriority)
func get_priority() -> int:
	if is_main_quest:
		return 100
	return 0

## Advances to next stage
func advance_stage() -> void:
	if _current_stage < stages.size() - 1:
		_current_stage += 1
	else:
		_is_completed = true

## Marks quest as visible
func set_visible(visible: bool) -> void:
	_is_visible = visible

## Marks quest as completed
func set_completed(completed: bool) -> void:
	_is_completed = completed

## Gets a quest variable
func get_var(var_id: String, default_value: Variant = null) -> Variant:
	return default_vars.get(var_id, default_value)

## Sets a quest variable
func set_var(var_id: String, value: Variant) -> void:
	default_vars[var_id] = value
