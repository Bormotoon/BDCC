# Systems/SexEngine/Actions/SpankAction.gd
class_name SpankAction extends SexAction

## Migrated from SexActivityBase stimulation methods.
## Pain/pleasure action.

func _init() -> void:
	action_id = &"spank"
	name = "Spank"
	base_pleasure = 2.0
	base_pain = 5.0
	is_dom_action = true

func execute(source: Node, target: Node, location: StringName) -> void:
	super.execute(source, target, location)
	EventBus.sex_event_triggered.emit(&"spank", [source, target], location)
