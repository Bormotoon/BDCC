# Systems/SexEngine/Actions/ThrustAction.gd
class_name ThrustAction extends SexAction

## Migrated from SexActivityBase stimulation methods.
## Basic penetration action.

func _init() -> void:
	action_id = &"thrust"
	name = "Thrust"
	base_pleasure = 8.0
	base_pain = 1.0
	is_dom_action = true

func execute(source: Node, target: Node, location: StringName) -> void:
	super.execute(source, target, location)
	# Apply arousal to target via EventBus
	EventBus.sex_event_triggered.emit(&"penetration", [source, target], location)
