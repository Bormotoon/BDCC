# Systems/SexEngine/SexAction.gd
class_name SexAction extends Resource

## Resource describing a single action (Thrust, Spank, Lick).

@export var action_id: StringName = &"unknown_action"
@export var name: String = "Unknown Action"
@export var base_pleasure: float = 10.0
@export var base_pain: float = 0.0
@export var is_dom_action: bool = true

## Executes the action and emits an event on the bus
func execute(source: Node, target: Node, location: StringName) -> void:
	EventBus.sex_event_triggered.emit(action_id, [source, target], location)
