# Systems/SexEngine/Actions/KissAction.gd
class_name KissAction extends SexAction

## Migrated from SexActivityBase stimulation methods.
## Gentle pleasure action.

func _init() -> void:
	action_id = &"kiss"
	name = "Kiss"
	base_pleasure = 10.0
	base_pain = 0.0
	is_dom_action = false

func execute(source: Node, target: Node, location: StringName) -> void:
	super.execute(source, target, location)
	EventBus.sex_event_triggered.emit(&"kiss", [source, target], location)
