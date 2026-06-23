# Systems/SexEngine/SexEngineManager.gd
class_name SexEngineManager extends Node

## Main coordinator for sex scenes. Manages participants and current state (SexState).

var current_state: SexState
var participants: Array[Node] = []
var location_id: StringName = &"unknown_room"

func _ready() -> void:
	ServiceLocator.register_service(&"SexEngine", self)

func start_scene(scene_participants: Array[Node], room_id: StringName, initial_state: SexState) -> void:
	participants = scene_participants
	location_id = room_id
	change_state(initial_state)

func change_state(new_state: SexState) -> void:
	if current_state:
		current_state.exit(self)

	current_state = new_state

	if current_state:
		current_state.enter(self)

func process_scene_turn() -> void:
	if current_state:
		current_state.process_turn(self)

func end_scene() -> void:
	if current_state:
		current_state.exit(self)
	current_state = null
	participants.clear()
