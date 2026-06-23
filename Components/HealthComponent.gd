# Components/HealthComponent.gd
class_name HealthComponent extends Component

## Migrated from BaseCharacter.gd lines 89-462.
## Handles pain, lust, stamina, combat damage, and fighting state.

enum FightingState { NONE, DODGE, BLOCK, DEFOCUS }

@export var base_pain_threshold: float = 100.0
@export var base_lust_threshold: float = 100.0
@export var base_max_stamina: float = 100.0
@export var initial_dodge_chance: float = 0.2

var current_pain: float = 0.0
var current_lust: float = 0.0
var current_stamina: float = 100.0
var fighting_state: FightingState = FightingState.NONE

# Buff/skill modifier references (set by parent entity)
var _buffs_holder: Node = null
var _skills_holder: Node = null

func _ready() -> void:
	super._ready()
	if entity.has_method("get_component"):
		_buffs_holder = entity.get_component(&"BuffsHolder")
		_skills_holder = entity.get_component(&"SkillsHolder")

# --- Thresholds (migrated from BaseCharacter lines 158-168) ---

func get_pain_threshold() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_pain_threshold"):
		extra += _skills_holder.get_extra_pain_threshold()
	if _buffs_holder and _buffs_holder.has_method("get_extra_pain_threshold"):
		extra += _buffs_holder.get_extra_pain_threshold()
	return maxf(10.0, base_pain_threshold + extra)

func get_lust_threshold() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_lust_threshold"):
		extra += _skills_holder.get_extra_lust_threshold()
	if _buffs_holder and _buffs_holder.has_method("get_extra_lust_threshold"):
		extra += _buffs_holder.get_extra_lust_threshold()
	return maxf(10.0, base_lust_threshold + extra)

func get_max_stamina() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_stamina"):
		extra += _skills_holder.get_extra_stamina()
	if _buffs_holder and _buffs_holder.has_method("get_extra_stamina"):
		extra += _buffs_holder.get_extra_stamina()
	return maxf(0.0, base_max_stamina + extra)

# --- Stat accessors (migrated from BaseCharacter lines 89-136) ---

func get_pain() -> float:
	return current_pain

func get_lust() -> float:
	return current_lust

func get_stamina() -> float:
	return current_stamina

func get_pain_level() -> float:
	var threshold := get_pain_threshold()
	if threshold <= 0.0:
		return 0.0
	return current_pain / threshold

func get_lust_level() -> float:
	var threshold := get_lust_threshold()
	if threshold <= 0.0:
		return 0.0
	return current_lust / threshold

func get_stamina_level() -> float:
	var max_stam := get_max_stamina()
	if max_stam <= 0.0:
		return 0.0
	return current_stamina / max_stam

# --- Stat modifiers (migrated from BaseCharacter lines 93-127) ---

func add_pain(amount: float) -> void:
	var old_pain := current_pain
	current_pain = clampf(current_pain + amount, 0.0, get_pain_threshold())

	if old_pain != current_pain:
		EventBus.stat_changed.emit(entity, &"pain", old_pain, current_pain)

	if current_pain >= get_pain_threshold():
		_pass_out()

func add_lust(amount: float) -> void:
	var old_lust := current_lust
	current_lust = clampf(current_lust + amount, 0.0, get_lust_threshold())

	if old_lust != current_lust:
		EventBus.stat_changed.emit(entity, &"lust", old_lust, current_lust)

func add_stamina(amount: float) -> void:
	var old_stamina := current_stamina
	current_stamina = clampf(current_stamina + amount, 0.0, get_max_stamina())

	if old_stamina != current_stamina:
		EventBus.stat_changed.emit(entity, &"stamina", old_stamina, current_stamina)

# --- Fighting state (migrated from BaseCharacter lines 443-462, now enum) ---

func is_dodging() -> bool:
	return fighting_state == FightingState.DODGE

func is_blocking() -> bool:
	return fighting_state == FightingState.BLOCK

func is_defocusing() -> bool:
	return fighting_state == FightingState.DEFOCUS

func set_fighting_state_normal() -> void:
	fighting_state = FightingState.NONE

func set_fighting_state_dodging() -> void:
	fighting_state = FightingState.DODGE

func set_fighting_state_blocking() -> void:
	fighting_state = FightingState.BLOCK

func set_fighting_state_defocusing() -> void:
	fighting_state = FightingState.DEFOCUS

# --- Damage multipliers (migrated from BaseCharacter lines 342-367) ---

func get_deal_damage_multiplier(damage_type: StringName) -> float:
	var mult := 0.0
	if _buffs_holder and _buffs_holder.has_method("get_deal_damage_mult"):
		mult += _buffs_holder.get_deal_damage_mult(damage_type)
	if _skills_holder and _skills_holder.has_method("get_damage_multiplier"):
		mult += _skills_holder.get_damage_multiplier(damage_type)
	return clampf(mult, -0.8, 10.0)

func get_receive_damage_multiplier(damage_type: StringName) -> float:
	var mult := 0.0
	if _buffs_holder and _buffs_holder.has_method("get_receive_damage_mult"):
		mult += _buffs_holder.get_receive_damage_mult(damage_type)
	return clampf(mult, -0.8, 10.0)

# --- Dodge and accuracy (migrated from BaseCharacter lines 369-396) ---

func get_dodge_chance() -> float:
	if is_dodging():
		return 1.0
	var mult := initial_dodge_chance
	if _buffs_holder and _buffs_holder.has_method("get_dodge_chance"):
		mult += _buffs_holder.get_dodge_chance()
	return clampf(mult, 0.0, 0.8)

func get_attack_accuracy() -> float:
	var mult := 0.0
	if _buffs_holder and _buffs_holder.has_method("get_accuracy"):
		mult += _buffs_holder.get_accuracy()
	return clampf(mult, -0.9, 10.0)

# --- Receive damage (migrated from BaseCharacter lines 398-441) ---

func receive_damage(damage_type: StringName, amount: int, armor_scale: float = 1.0) -> int:
	var mult := get_receive_damage_multiplier(damage_type)
	var new_damage := roundi(amount * (1.0 + mult))

	if amount > 0:
		new_damage = maxi(new_damage, 1)

	match damage_type:
		&"physical":
			var old_pain := current_pain
			add_pain(float(new_damage))
			return roundi(current_pain - old_pain)
		&"lust":
			var old_lust := current_lust
			add_lust(float(new_damage))
			if is_defocusing() and old_lust < (get_lust_threshold() - 1.0) and current_lust >= get_lust_threshold():
				add_lust(-1.0)
			return roundi(current_lust - old_lust)
		&"stamina":
			var old_stamina := current_stamina
			add_stamina(-float(new_damage))
			return -roundi(current_stamina - old_stamina)

	return 0

# --- Pass out (migrated from BaseCharacter) ---

func _pass_out() -> void:
	EventBus.sex_event_triggered.emit(&"passed_out", [entity], &"any")

func is_conscious() -> bool:
	return current_pain < get_pain_threshold()
