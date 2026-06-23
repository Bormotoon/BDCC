# Components/HealthComponent.gd
class_name HealthComponent extends Component

@export var max_stamina: float = 100.0
@export var pain_threshold: float = 100.0

var current_stamina: float = 100.0
var current_pain: float = 0.0

func add_pain(amount: float) -> void:
	var old_pain = current_pain
	current_pain = clampf(current_pain + amount, 0.0, pain_threshold)

	EventBus.stat_changed.emit(entity, &"pain", old_pain, current_pain)

	if current_pain >= pain_threshold:
		_pass_out()

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		var old_stamina = current_stamina
		current_stamina -= amount
		EventBus.stat_changed.emit(entity, &"stamina", old_stamina, current_stamina)
		return true
	return false

func _pass_out() -> void:
	EventBus.sex_event_triggered.emit(&"passed_out", [entity], &"any")
