# Resources/DialogueData.gd
class_name DialogueData extends Resource

## Migrated from DialogueParser.gd (250 lines) and ModularDialogue system.
## Resource-based dialogue definition replacing runtime-parsed strings.

@export var dialogue_id: StringName = &"unknown_dialogue"
@export var participants: Array[StringName] = []
@export var nodes: Array[Dictionary] = [] # { "speaker": StringName, "text": String, "next_node": String }
@export var start_node: String = ""

# Runtime state
var _current_node_index: int = 0
var _is_active: bool = false

## Starts the dialogue
func start() -> void:
	_is_active = true
	_current_node_index = 0
	# Find start node
	if not start_node.is_empty():
		for i in range(nodes.size()):
			if nodes[i].get("id", "") == start_node:
				_current_node_index = i
				break

## Gets current dialogue node
func get_current_node() -> Dictionary:
	if _current_node_index < nodes.size():
		return nodes[_current_node_index]
	return {}

## Advances to next node
func advance() -> void:
	if _current_node_index < nodes.size():
		var next_id: String = nodes[_current_node_index].get("next_node", "")
		if not next_id.is_empty():
			for i in range(nodes.size()):
				if nodes[i].get("id", "") == next_id:
					_current_node_index = i
					return
	_current_node_index += 1

## Whether dialogue is still active
func is_active() -> bool:
	return _is_active and _current_node_index < nodes.size()

## Ends the dialogue
func end() -> void:
	_is_active = false

## Gets all speakers in this dialogue
func get_speakers() -> Array[StringName]:
	var speakers: Array[StringName] = []
	for node in nodes:
		var speaker: StringName = node.get("speaker", &"")
		if speaker != &"" and not speakers.has(speaker):
			speakers.append(speaker)
	return speakers

## Checks if a character participates
func has_participant(char_id: StringName) -> bool:
	return participants.has(char_id)
