# Components/SexReactionComponent.gd
class_name SexReactionComponent extends Component

## Listens to EventBus and applies pleasure/pain based on fetishes and stats.

@export var base_sensitivity: float = 1.0

var health_component: HealthComponent
var current_arousal: float = 0.0

func _ready() -> void:
	super._ready()
	EventBus.sex_event_triggered.connect(_on_sex_event_triggered)

	if entity.has_method("get_component"):
		health_component = entity.get_component(&"HealthComponent")

func _on_sex_event_triggered(event_type: StringName, event_participants: Array, _location: StringName) -> void:
	if not event_participants.has(entity):
		return

	var is_target = (event_participants.size() > 1 and event_participants[1] == entity)

	if is_target:
		_handle_received_action(event_type)

func _handle_received_action(action_id: StringName) -> void:
	var pleasure_gain = 0.0
	var pain_gain = 0.0

	match action_id:
		&"spank":
			pain_gain = 5.0
			pleasure_gain = 2.0 * base_sensitivity
		&"kiss":
			pleasure_gain = 10.0 * base_sensitivity

	current_arousal = clampf(current_arousal + pleasure_gain, 0.0, 100.0)

	if pain_gain > 0 and health_component:
		health_component.add_pain(pain_gain)
