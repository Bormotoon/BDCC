# Components/HealthComponent.gd
class_name HealthComponent extends Component

## EXACT migration from BaseCharacter.gd lines 89-462.
## All formulas, edge cases, and constants preserved 1:1.

enum FightingState { NONE, DODGE, BLOCK, DEFOCUS }

@export var base_pain_threshold: float = 100.0
@export var base_lust_threshold: float = 100.0
@export var base_max_stamina: float = 100.0
@export var initial_dodge_chance: float = 0.2

var current_pain: float = 0.0
var current_lust: float = 0.0
var current_stamina: float = 100.0
var fighting_state: FightingState = FightingState.NONE

# Component references
var _buffs_holder: Node = null
var _skills_holder: Node = null
var _status_effects: Dictionary = {} # StringName -> StatusEffect

func _ready() -> void:
	super._ready()
	if entity.has_method("get_component"):
		_buffs_holder = entity.get_component(&"BuffsHolder")
		_skills_holder = entity.get_component(&"SkillsHolder")

# ==========================================
# THRESHOLDS (BaseCharacter lines 158-168)
# ==========================================

## Hard floor: minimum threshold is 10 (line 161)
func get_pain_threshold() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_pain_threshold"):
		extra += _skills_holder.get_extra_pain_threshold()
	if _buffs_holder and _buffs_holder.has_method("get_extra_pain_threshold"):
		extra += _buffs_holder.get_extra_pain_threshold()
	return maxf(10.0, base_pain_threshold + extra)

## Hard floor: minimum threshold is 10 (line 167)
func get_lust_threshold() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_lust_threshold"):
		extra += _skills_holder.get_extra_lust_threshold()
	if _buffs_holder and _buffs_holder.has_method("get_extra_lust_threshold"):
		extra += _buffs_holder.get_extra_lust_threshold()
	return maxf(10.0, base_lust_threshold + extra)

## Minimum is 0 (line 142: max(0, ...))
func get_max_stamina() -> float:
	var extra := 0.0
	if _skills_holder and _skills_holder.has_method("get_extra_stamina"):
		extra += _skills_holder.get_extra_stamina()
	if _buffs_holder and _buffs_holder.has_method("get_extra_stamina"):
		extra += _buffs_holder.get_extra_stamina()
	return maxf(0.0, base_max_stamina + extra)

# ==========================================
# STAT ACCESSORS (BaseCharacter lines 129-177)
# ==========================================

func get_pain() -> float:
	return current_pain

func get_lust() -> float:
	return current_lust

func get_stamina() -> float:
	return current_stamina

## Line 170-171: current / threshold (NO clamping, can exceed 1.0)
func get_pain_level() -> float:
	return current_pain / get_pain_threshold()

## Line 173-174
func get_lust_level() -> float:
	return current_lust / get_lust_threshold()

## Line 176-177
func get_stamina_level() -> float:
	return current_stamina / get_max_stamina()

## Line 179-180
func get_ambient_pain() -> float:
	if _buffs_holder and _buffs_holder.has_method("get_ambient_pain"):
		return _buffs_holder.get_ambient_pain()
	return 0.0

## Line 182-183
func get_ambient_lust() -> float:
	if _buffs_holder and _buffs_holder.has_method("get_ambient_lust"):
		return _buffs_holder.get_ambient_lust()
	return 0.0

# ==========================================
# STAT MODIFIERS (BaseCharacter lines 93-127)
# ==========================================

## Line 93-103: clamp to [0, threshold], emit signal if changed
func add_pain(amount: float) -> void:
	var initial_pain := current_pain
	current_pain = clampf(current_pain + amount, 0.0, get_pain_threshold())
	if initial_pain != current_pain:
		EventBus.pain_changed.emit(entity, current_pain, initial_pain)
	EventBus.stat_changed.emit(entity, &"pain", initial_pain, current_pain)

## Line 105-115
func add_lust(amount: float) -> void:
	var initial_lust := current_lust
	current_lust = clampf(current_lust + amount, 0.0, get_lust_threshold())
	if initial_lust != current_lust:
		EventBus.lust_changed.emit(entity, current_lust, initial_lust)
	EventBus.stat_changed.emit(entity, &"lust", initial_lust, current_lust)

## Line 117-127
func add_stamina(amount: float) -> void:
	var initial_stamina := current_stamina
	current_stamina = clampf(current_stamina + amount, 0.0, get_max_stamina())
	if initial_stamina != current_stamina:
		EventBus.stamina_changed.emit(entity, current_stamina, initial_stamina)
	EventBus.stat_changed.emit(entity, &"stamina", initial_stamina, current_stamina)

# ==========================================
# FIGHTING STATE (BaseCharacter lines 443-462)
# ==========================================

## Line 443-444: fightingState == "dodge"
func is_dodging() -> bool:
	return fighting_state == FightingState.DODGE

## Line 446-447
func is_blocking() -> bool:
	return fighting_state == FightingState.BLOCK

## Line 449-450
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

# ==========================================
# DAMAGE MULTIPLIERS (BaseCharacter lines 342-396)
# ==========================================

## Line 342-354: sum(statusEffects) + buffs + skills, floor -0.8
func get_deal_damage_multiplier(damage_type: StringName) -> float:
	var mult := 0.0
	for effect_id in _status_effects:
		var effect = _status_effects[effect_id]
		if effect.has_method("get_damage_multiplier_mod"):
			mult += effect.get_damage_multiplier_mod(damage_type)
	if _buffs_holder and _buffs_holder.has_method("get_deal_damage_mult"):
		mult += _buffs_holder.get_deal_damage_mult(damage_type)
	if _skills_holder and _skills_holder.has_method("get_damage_multiplier"):
		mult += _skills_holder.get_damage_multiplier(damage_type)
	if mult < -0.8:
		mult = -0.8
	return mult

## Line 356-367: sum(statusEffects) + buffs only (NO skills), floor -0.8
func get_receive_damage_multiplier(damage_type: StringName) -> float:
	var mult := 0.0
	for effect_id in _status_effects:
		var effect = _status_effects[effect_id]
		if effect.has_method("get_received_damage_mod"):
			mult += effect.get_received_damage_mod(damage_type)
	if _buffs_holder and _buffs_holder.has_method("get_receive_damage_mult"):
		mult += _buffs_holder.get_receive_damage_mult(damage_type)
	if mult < -0.8:
		mult = -0.8
	return mult

## Line 369-383: if dodging return 1.0, else cap at 0.8
func get_dodge_chance() -> float:
	if is_dodging():
		return 1.0
	var mult := initial_dodge_chance
	for effect_id in _status_effects:
		var effect = _status_effects[effect_id]
		if effect.has_method("get_dodge_mod"):
			mult += effect.get_dodge_mod()
	if _buffs_holder and _buffs_holder.has_method("get_dodge_chance"):
		mult += _buffs_holder.get_dodge_chance()
	if mult > 0.8:
		mult = 0.8
	return mult

## Line 385-396: sum(statusEffects) + buffs, floor -0.9
func get_attack_accuracy() -> float:
	var mult := 0.0
	for effect_id in _status_effects:
		var effect = _status_effects[effect_id]
		if effect.has_method("get_accuracy_mod"):
			mult += effect.get_accuracy_mod()
	if _buffs_holder and _buffs_holder.has_method("get_accuracy"):
		mult += _buffs_holder.get_accuracy()
	if mult < -0.9:
		mult = -0.9
	return mult

# ==========================================
# STATUS EFFECT MANAGEMENT
# ==========================================

func add_status_effect(effect_id: StringName, effect: Node) -> void:
	_status_effects[effect_id] = effect
	EventBus.status_effect_added.emit(entity, effect_id)

func remove_status_effect(effect_id: StringName) -> void:
	_status_effects.erase(effect_id)
	EventBus.status_effect_removed.emit(entity, effect_id)

func has_status_effect(effect_id: StringName) -> bool:
	return _status_effects.has(effect_id)

# ==========================================
# ARMOR (referenced in receiveDamage)
# ==========================================

## Placeholder — will be connected to inventory/buffs system
func get_armor(damage_type: StringName) -> float:
	if _buffs_holder and _buffs_holder.has_method("get_armor"):
		return _buffs_holder.get_armor(damage_type)
	return 0.0

# ==========================================
# RECEIVE DAMAGE (BaseCharacter lines 398-441) — EXACT FORMULAS
# ==========================================

## EXACT migration: round(amount * (1.0 + mult)), armor scaling, damage types
func receive_damage(damage_type: StringName, amount: int, armor_scale: float = 1.0) -> int:
	var mult := get_receive_damage_multiplier(damage_type)
	var new_damage := roundi(amount * (1.0 + mult))

	# Armor calculation (line 402-410): only when amount > 0
	if amount > 0:
		var the_armor := get_armor(damage_type)
		# Line 404: negative armor is NOT scaled by armorScale
		var final_armor: float
		if the_armor > 0.0:
			final_armor = floorf(the_armor * armor_scale)
		else:
			final_armor = floorf(the_armor)

		# Line 406-409: negative armor = vulnerability multiplier
		if final_armor < 0:
			new_damage = roundi(new_damage * (-final_armor / 50.0))
		else:
			# Positive armor: diminishing returns formula (50 armor = 50% reduction)
			new_damage = roundi(new_damage * (50.0 / (50.0 + final_armor)))

		# Line 410: minimum 1 damage
		new_damage = maxi(new_damage, 1)

	# Line 412-419: Physical damage
	if damage_type == &"physical":
		var old_pain := current_pain
		add_pain(float(new_damage))
		var actual_add_pain := current_pain - old_pain
		return roundi(actual_add_pain)

	# Line 421-430: Lust damage with defocus perk edge case
	if damage_type == &"lust":
		var old_lust := current_lust
		add_lust(float(new_damage))
		# Line 425: Defocus + SexDefocusNeverLose perk prevents hitting exact threshold
		if is_defocusing() and _has_perk(&"SexDefocusNeverLose") and old_lust < (get_lust_threshold() - 1.0) and current_lust >= get_lust_threshold():
			add_lust(-1.0)
		var actual_add_lust := current_lust - old_lust
		return roundi(actual_add_lust)

	# Line 432-439: Stamina damage (subtracted, returns negated delta)
	if damage_type == &"stamina":
		var old_stamina := current_stamina
		add_stamina(-float(new_damage))
		var actual_add_stamina := current_stamina - old_stamina
		return -roundi(actual_add_stamina)

	# Line 441: Unknown damage type
	return 0

# ==========================================
# PERK CHECK (placeholder for integration)
# ==========================================

func _has_perk(_perk_id: StringName) -> bool:
	if _skills_holder and _skills_holder.has_method("has_perk"):
		return _skills_holder.has_perk(_perk_id)
	return false

# ==========================================
# PASS OUT (BaseCharacter)
# ==========================================

func _pass_out() -> void:
	EventBus.sex_event_triggered.emit(&"passed_out", [entity], &"any")

func is_conscious() -> bool:
	return current_pain < get_pain_threshold()

# ==========================================
# LEVEL (BaseCharacter line 705-706)
# ==========================================

func get_level() -> int:
	if _skills_holder and _skills_holder.has_method("get_level"):
		return _skills_holder.get_level()
	return 1
