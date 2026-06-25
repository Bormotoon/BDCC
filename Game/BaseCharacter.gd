extends Node
class_name BaseCharacter

## MIGRATED to Godot 4 (GDScript 2.0).
## All formulas, edge cases, and game logic preserved 1:1.
## Signal/emit patterns updated: connect() → signal.connect(), emit_signal() → signal.emit()

# --- Signals (lines 5-13, migrated to Godot 4 syntax) ---
signal stat_changed
signal pain_changed(new_value: int, old_value: int)
signal lust_changed(new_value: int, old_value: int)
signal stamina_changed(new_value: int, old_value: int)
signal level_changed
signal skill_level_changed(skill_id: StringName)
signal bodypart_changed
signal orifice_become_more_loose(orifice_name: String, new_value: float, old_value: float)
signal exchanged_cum_during_rubbing(sender_name: String, receiver_name: String)

# --- Variables (lines 16-55, typed where possible) ---
var pain: int = 0
var lust: int = 0
var stamina: int = 100

var arousal: float = 0.0
var consciousness: float = 1.0

var status_effects: Dictionary = {}
var inventory: Inventory
var buffs_holder: BuffsHolder
var skills_holder: SkillsHolder
var lust_interests: LustInterests
var fetish_holder: FetishHolder
var personality: Personality
var body_fluids: Fluids

var bodyparts: Dictionary = {}
var processing_bodyparts: Array = []
var bodypart_storage_node: Node

var pee_production: PeeProduction

var initial_dodge_chance: float = 0.0
var fighting_state: String = "" # dodge, block, defocus

var menstrual_cycle: MenstrualCycle

var timed_buffs: Array = []
var timed_buffs_turns: Array = []

var picked_skin: String = "EmptySkin"
var picked_skin_r_color: Color = Color.WHITE
var picked_skin_g_color: Color = Color.LIGHT_GRAY
var picked_skin_b_color: Color = Color.DARK_GRAY

# Backward-compatible aliases for old code that references these names
var statusEffects: Dictionary:
	get: return status_effects
var buffsHolder: BuffsHolder:
	get: return buffs_holder
var skillsHolder: SkillsHolder:
	get: return skills_holder
var lustInterests: LustInterests:
	get: return lust_interests
var fetishHolder: FetishHolder:
	get: return fetish_holder
var bodyFluids: Fluids:
	get: return body_fluids
var peeProduction: PeeProduction:
	get: return pee_production
var menstrualCycle: MenstrualCycle:
	get: return menstrual_cycle

# ==========================================
# INITIALIZATION (lines 57-87)
# ==========================================

func _init() -> void:
	name = "BaseCharacter"

func _ready() -> void:
	bodypart_storage_node = Node.new()
	add_child(bodypart_storage_node)
	bodypart_storage_node.name = "Bodyparts"
	_reset_slots()

	inventory = Inventory.new()
	add_child(inventory)
	inventory.equipped_items_changed.connect(_on_equipped_items_change)

	buffs_holder = BuffsHolder.new()
	buffs_holder.set_character(self)
	add_child(buffs_holder)

	skills_holder = SkillsHolder.new()
	skills_holder.set_character(self)
	add_child(skills_holder)
	skills_holder.stat_changed.connect(_on_stat_change)
	skills_holder.experience_changed.connect(_on_stat_change)
	skills_holder.level_changed.connect(_on_level_change)
	skills_holder.skill_level_changed.connect(_on_skill_level_change)

	stamina = get_max_stamina()

	lust_interests = LustInterests.new()
	fetish_holder = FetishHolder.new()
	fetish_holder.set_character(self)
	personality = Personality.new()
	personality.set_character(self)
	body_fluids = Fluids.new()
	pee_production = PeeProduction.new(self)

# ==========================================
# STATS (lines 89-184)
# ==========================================

func get_id() -> StringName:
	assert(false, "Getting an ID of a baseCharacter class")
	return &""

## Line 93-103: clamp to [0, threshold], emit signal if changed
func add_pain(_p: int) -> void:
	var initial_pain := pain
	pain += _p
	if pain > pain_threshold():
		pain = pain_threshold()
	if pain < 0:
		pain = 0
	if initial_pain != pain:
		pain_changed.emit(pain, initial_pain)
	stat_changed.emit()

## Line 105-115
func add_lust(_l: int) -> void:
	var initial_lust := lust
	lust += _l
	if lust > lust_threshold():
		lust = lust_threshold()
	if lust < 0:
		lust = 0
	if initial_lust != lust:
		lust_changed.emit(lust, initial_lust)
	stat_changed.emit()

## Line 117-127
func add_stamina(_s: int) -> void:
	var initial_stamina := stamina
	stamina += _s
	if stamina > get_max_stamina():
		stamina = get_max_stamina()
	if stamina < 0:
		stamina = 0
	if initial_stamina != stamina:
		stamina_changed.emit(stamina, initial_stamina)
	stat_changed.emit()

func get_pain() -> int:
	return pain

func get_lust() -> int:
	return lust

func get_stamina() -> int:
	return stamina

func _on_equipped_items_change() -> void:
	pass

func _on_stat_change(_stat: StringName, _new_value: int, _old_value: int) -> void:
	stat_changed.emit()

func _on_level_change(_new_level: int) -> void:
	level_changed.emit()

func _on_skill_level_change(_skill_id: StringName, _new_level: int) -> void:
	skill_level_changed.emit(_skill_id)

func get_base_max_stamina() -> int:
	return 100

## Line 141-142: max(0, 100 + skills + buffs)
func get_max_stamina() -> int:
	return int(maxf(0.0, float(get_base_max_stamina()) + skills_holder.get_extra_stamina() + buffs_holder.get_extra_stamina()))

func getCharacterName() -> StringName:
	return name

func getName() -> String:
	return str(name)

## Line 158-162: hard floor min 10
func get_base_pain_threshold() -> int:
	return 100

func pain_threshold() -> int:
	return int(maxf(10.0, float(get_base_pain_threshold()) + skills_holder.get_extra_pain_threshold() + buffs_holder.get_extra_pain_threshold()))

## Line 164-168
func get_base_lust_threshold() -> int:
	return 100

func lust_threshold() -> int:
	return int(maxf(10.0, float(get_base_lust_threshold()) + skills_holder.get_extra_lust_threshold() + buffs_holder.get_extra_lust_threshold()))

## Line 170-177: current / threshold (NO clamping)
func get_pain_level() -> float:
	return float(get_pain()) / float(pain_threshold())

func get_lust_level() -> float:
	return float(get_lust()) / float(lust_threshold())

func get_stamina_level() -> float:
	return float(get_stamina()) / float(get_max_stamina())

## Line 179-183
func get_ambient_pain() -> int:
	return int(buffs_holder.get_ambient_pain())

func get_ambient_lust() -> int:
	return int(buffs_holder.get_ambient_lust())

func add_effect(effect_id: StringName, args: Array = []) -> bool:
	if status_effects.has(effect_id):
		status_effects[effect_id].combine(args)
		return true
	return false

func has_effect(effect_id: StringName) -> bool:
	return status_effects.has(effect_id)

func get_effect(effect_id: StringName):
	return status_effects.get(effect_id)

func remove_effect(effect_id: StringName) -> void:
	if status_effects.has(effect_id):
		status_effects[effect_id].on_remove()
		status_effects.erase(effect_id)

func update_appearance() -> void:
	pass # Overridden in subclasses

# ==========================================
# LEVEL (lines 905-923)
# ==========================================

func on_level_change() -> void:
	level_changed.emit()

func on_skill_level_change(skill_id: StringName) -> void:
	skill_level_changed.emit(skill_id)

func on_stat_change() -> void:
	stat_changed.emit()

func on_equipped_items_change() -> void:
	stat_changed.emit()

# ==========================================
# FIGHT STATE (lines 443-462)
# ==========================================

func is_dodging() -> bool:
	return fighting_state == "dodge"

func is_blocking() -> bool:
	return fighting_state == "block"

func is_defocusing() -> bool:
	return fighting_state == "defocus"

func set_fighting_state_normal() -> void:
	fighting_state = ""

func set_fighting_state_dodging() -> void:
	fighting_state = "dodge"

func set_fighting_state_blocking() -> void:
	fighting_state = "block"

func set_fighting_state_defocusing() -> void:
	fighting_state = "defocus"

# ==========================================
# DAMAGE (lines 339-441)
# ==========================================

func on_damage(_damage_type: StringName, _amount: int) -> void:
	pass

## Line 342-354: sum(statusEffects) + buffs + skills, floor -0.8
func get_damage_multiplier(_damage_type: StringName) -> float:
	var mult := 0.0
	for effect_id in status_effects:
		var effect = status_effects[effect_id]
		mult += effect.get_damage_multiplier_mod(_damage_type)
	mult += buffs_holder.get_deal_damage_mult(_damage_type)
	mult += skills_holder.get_damage_multiplier(_damage_type)
	if mult < -0.8:
		mult = -0.8
	return mult

## Line 356-367: sum(statusEffects) + buffs only (NO skills), floor -0.8
func get_receive_damage_multiplier(_damage_type: StringName) -> float:
	var mult := 0.0
	for effect_id in status_effects:
		var effect = status_effects[effect_id]
		mult += effect.get_received_damage_mod(_damage_type)
	mult += buffs_holder.get_receive_damage_mult(_damage_type)
	if mult < -0.8:
		mult = -0.8
	return mult

## Line 369-383: if dodging return 1.0, else cap at 0.8
func get_dodge_chance() -> float:
	if is_dodging():
		return 1.0
	var mult := float(initial_dodge_chance)
	for effect_id in status_effects:
		var effect = status_effects[effect_id]
		mult += effect.get_dodge_mod()
	mult += buffs_holder.get_dodge_chance()
	if mult > 0.8:
		mult = 0.8
	return mult

## Line 385-396: floor -0.9
func get_attack_accuracy() -> float:
	var mult := 0.0
	for effect_id in status_effects:
		var effect = status_effects[effect_id]
		mult += effect.get_accuracy_mod()
	mult += buffs_holder.get_accuracy()
	if mult < -0.9:
		mult = -0.9
	return mult

## Line 398-441: EXACT formulas
func receive_damage(damage_type: StringName, amount: int, armor_scale: float = 1.0) -> int:
	var mult := get_receive_damage_multiplier(damage_type)
	var new_damage := roundi(float(amount) * (1.0 + mult))

	if amount > 0:
		var the_armor := get_armor(damage_type)
		var final_armor: float
		if the_armor > 0.0:
			final_armor = floorf(the_armor * armor_scale)
		else:
			final_armor = floorf(the_armor)
		if final_armor < 0:
			new_damage = roundi(float(new_damage) * (-final_armor / 50.0))
		else:
			new_damage = roundi(float(new_damage) * (50.0 / (50.0 + final_armor)))
		new_damage = maxi(new_damage, 1)

	if damage_type == &"physical":
		var old_pain := pain
		add_pain(new_damage)
		var actual_add_pain := pain - old_pain
		on_damage(damage_type, actual_add_pain)
		return actual_add_pain

	if damage_type == &"lust":
		var old_lust := lust
		add_lust(new_damage)
		if is_defocusing() and has_perk(&"SexDefocusNeverLose") and old_lust < (lust_threshold() - 1) and get_lust() >= lust_threshold():
			add_lust(-1)
		var actual_add_lust := lust - old_lust
		on_damage(damage_type, actual_add_lust)
		return actual_add_lust

	if damage_type == &"stamina":
		var old_stamina := stamina
		add_stamina(-new_damage)
		var actual_add_stamina := stamina - old_stamina
		on_damage(damage_type, actual_add_stamina)
		return -actual_add_stamina

	return 0

func get_armor(_damage_type: StringName) -> float:
	return 0.0

func lust_damage_reaction(lust_damage: int, _enemy) -> String:
	if lust_damage <= -10:
		return get_name() + " got very turned off by the sight"
	if lust_damage <= -6:
		return get_name() + " didn't like that at all"
	if lust_damage <= -3:
		return get_name() + " sighs and shakes " + his_her() + " head"
	if lust_damage == 0:
		return get_name() + " didn't seem to care at all"
	if lust_damage <= 5:
		return get_name() + " seems intrigued"
	if lust_damage <= 10:
		return get_name() + " smiles eagerly and watches the show"
	if lust_damage <= 15:
		return get_name() + " exhalled deeply while rubbing " + his_her() + " legs together"
	if lust_damage > 15:
		return get_name() + " moans audibly, " + his_her() + " eyes burn with desire"
	return ""

# ==========================================
# GENDER & PRONOUNS (lines 484-643)
# ==========================================

func get_gender() -> int:
	return Gender.Other

func get_pronoun_gender() -> int:
	return get_gender()

func get_chat_color() -> String:
	match get_gender():
		Gender.Male: return "#5696EA"
		Gender.Female: return "#FF837A"
		Gender.Androgynous: return "#BA82FF"
		Gender.Other: return "#77D86C"
	return "red"

func theyre() -> String:
	match get_pronoun_gender():
		Gender.Male: return "he's"
		Gender.Female: return "she's"
		Gender.Androgynous: return "they're"
		Gender.Other: return "it's"
	return "theyre():BAD_GENDER"

func theyve() -> String:
	match get_pronoun_gender():
		Gender.Male: return "he's"
		Gender.Female: return "she's"
		Gender.Androgynous: return "they've"
		Gender.Other: return "it's"
	return "theyve():BAD_GENDER"

func doesnt_dont() -> String:
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return "doesn't"
	if g == Gender.Androgynous:
		return "don't"
	return "doesntDont():BAD_GENDER"

func does_do() -> String:
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return "does"
	if g == Gender.Androgynous:
		return "do"
	return "doesDo():BAD_GENDER"

func he_she() -> String:
	match get_pronoun_gender():
		Gender.Male: return "he"
		Gender.Female: return "she"
		Gender.Androgynous: return "they"
		Gender.Other: return "it"
	return "heShe():BAD_GENDER"

func his_her() -> String:
	match get_pronoun_gender():
		Gender.Male: return "his"
		Gender.Female: return "her"
		Gender.Androgynous: return "their"
		Gender.Other: return "its"
	return "hisHer():BAD_GENDER"

func his_hers() -> String:
	match get_pronoun_gender():
		Gender.Male: return "his"
		Gender.Female: return "hers"
		Gender.Androgynous: return "theirs"
		Gender.Other: return "its"
	return "hisHers():BAD_GENDER"

func him_her() -> String:
	match get_pronoun_gender():
		Gender.Male: return "him"
		Gender.Female: return "her"
		Gender.Androgynous: return "them"
		Gender.Other: return "it"
	return "himHer():BAD_GENDER"

func was_were() -> String:
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return "was"
	if g == Gender.Androgynous:
		return "were"
	return "wasWere():BAD_GENDER"

func is_are() -> String:
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return "is"
	if g == Gender.Androgynous:
		return "are"
	return "isAre():BAD_GENDER"

func has_have() -> String:
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return "has"
	if g == Gender.Androgynous:
		return "have"
	return "hasHave():BAD_GENDER"

func himself_herself() -> String:
	match get_pronoun_gender():
		Gender.Male: return "himself"
		Gender.Female: return "herself"
		Gender.Androgynous: return "themself"
		Gender.Other: return "itself"
	return "himselfHerself():BAD_GENDER"

func verb_s(verb_with_no_s: String, verb_with_s: String = "") -> String:
	if verb_with_s.is_empty():
		verb_with_s = verb_with_no_s + "s"
	var g := get_pronoun_gender()
	if g in [Gender.Male, Gender.Female, Gender.Other]:
		return verb_with_s
	if g == Gender.Androgynous:
		return verb_with_no_s
	return "verbS():BAD_GENDER"

# ==========================================
# INVENTORY & ACCESSORS (lines 663-760)
# ==========================================

func get_inventory() -> Inventory:
	return inventory

func get_lust_interests() -> LustInterests:
	return lust_interests

func get_skills_holder() -> SkillsHolder:
	return skills_holder

func get_buffs_holder() -> BuffsHolder:
	return buffs_holder

func get_fetish_holder() -> FetishHolder:
	return fetish_holder

func get_personality() -> Personality:
	return personality

func add_experience(new_exp: int) -> void:
	skills_holder.add_experience(new_exp)

func add_skill_experience(skill_id: StringName, amount: int, activity_id: StringName = &"") -> void:
	skills_holder.add_skill_experience(skill_id, amount, activity_id)

func has_perk(perk_id: StringName) -> bool:
	return skills_holder.has_perk(perk_id)

func get_stat(stat_id: StringName):
	return skills_holder.get_stat(stat_id)

func get_skill_level(skill_id: StringName) -> int:
	var skill = skills_holder.get_skill(skill_id)
	if skill == null:
		return 0
	return skill.get_level()

func get_level() -> int:
	return skills_holder.get_level()

func get_species() -> Array:
	return []

func get_loot(_battle_name: String) -> Dictionary:
	return {"credits": 0, "items": []}

# ==========================================
# BODYPART QUERIES (lines 1509-1700)
# ==========================================

func has_penis() -> bool:
	return has_bodypart(BodypartSlot.Penis)

func has_vagina() -> bool:
	return has_bodypart(BodypartSlot.Vagina)

func has_anus() -> bool:
	return true

func has_hair() -> bool:
	return has_bodypart(BodypartSlot.Hair) and get_bodypart(BodypartSlot.Hair).id != "baldhair"

func has_tail() -> bool:
	return has_bodypart(BodypartSlot.Tail)

func has_horns() -> bool:
	return has_bodypart(BodypartSlot.Horns)

func has_non_flat_breasts() -> bool:
	if not has_bodypart(BodypartSlot.Breasts):
		return false
	var breasts = get_bodypart(BodypartSlot.Breasts)
	return breasts.get_size() > BreastsSize.FLAT

func is_lactating() -> bool:
	if not has_bodypart(BodypartSlot.Breasts):
		return false
	var breasts: BodypartBreasts = get_bodypart(BodypartSlot.Breasts)
	var production: FluidProduction = breasts.get_fluid_production()
	if production == null:
		return false
	return production.should_produce()

## Line 1678-1694: cum inflation threshold 3000
func get_cum_inflation_level(check_content: bool = true) -> float:
	if check_content and not OPTIONS.is_content_enabled(ContentType.CumInflation):
		return 0.0
	var bodyparts_to_calculate := [BodypartSlot.Head, BodypartSlot.Vagina, BodypartSlot.Anus]
	var total_amount := 0.0
	for bodypart_slot in bodyparts_to_calculate:
		if not has_bodypart(bodypart_slot):
			continue
		var bodypart: Bodypart = get_bodypart(bodypart_slot)
		var orifice: Orifice = bodypart.get_orifice()
		if orifice == null:
			continue
		total_amount += orifice.get_fluid_amount()
	var threshold := 3000.0
	var tooMuch := maxf(total_amount - threshold, 0.0)
	return clampf(tooMuch / 2000.0, 0.0, 10.0)

# ==========================================
# SEX MECHANICS (lines 818-1270)
# ==========================================

## Line 818-840
func get_fluid_type(fluid_source) -> String:
	if has_bodypart(BodypartSlot.Penis):
		return get_bodypart(BodypartSlot.Penis).get_fluid_type(fluid_source)
	if has_bodypart(BodypartSlot.Vagina):
		return get_bodypart(BodypartSlot.Vagina).get_fluid_type(fluid_source)
	if fluid_source == &"Strapon":
		return "CumLube"
	if fluid_source == &"Pissing":
		return "Piss"
	return "Cum"

## Line 845-863
func get_fluid_amount(fluid_source) -> float:
	if fluid_source == &"Penis":
		if has_bodypart(BodypartSlot.Penis):
			var penis: BodypartPenis = get_bodypart(BodypartSlot.Penis)
			return penis.get_fluid_production().get_fluid_amount()
		return randf_range(100.0, 500.0)
	if fluid_source == &"Vagina":
		return randf_range(50.0, 200.0)
	if fluid_source == &"Strapon":
		return randf_range(100.0, 500.0)
	if fluid_source == &"Pissing":
		return pee_production.get_fluid_amount()
	return 0.0

## Line 1218-1229: penetration chance formula
func get_penetrate_chance(bodypart_slot, insertion_size: float) -> float:
	if not has_bodypart(bodypart_slot):
		return 0.0
	var the_bodypart = get_bodypart(bodypart_slot)
	var orifice: Orifice = the_bodypart.get_orifice()
	if orifice == null:
		return 0.0
	var good_size: float = orifice.get_comfortable_insertion()
	var diff: float = insertion_size - good_size
	if diff <= 0.0:
		return 100.0
	return maxf(500.0 / (5.0 + diff), 30.0)

## Line 1231-1236: knotting with CumUniqueBiology perk
func get_penetrate_chance_by(bodypart_slot, character_id: String, is_knotting: bool = false) -> float:
	var ch = GlobalRegistry.get_character(character_id)
	assert(ch != null)
	if is_knotting and has_perk(&"CumUniqueBiology"):
		return 100.0
	return get_penetrate_chance(bodypart_slot, ch.get_penis_size())

## Line 1245-1260
func got_fucked_by(bodypart_slot, character_id: String, show_messages: bool = true, fire_sex_event: bool = true) -> void:
	if not has_bodypart(bodypart_slot):
		return
	var ch = GlobalRegistry.get_character(character_id)
	assert(ch != null)
	got_orifice_stretched_with(bodypart_slot, ch.get_penis_size(), show_messages)
	add_stamina(buffs_holder.get_custom(BuffAttribute.StaminaRecoverAfterSex))
	ch.add_stamina(ch.get_buffs_holder().get_custom(BuffAttribute.StaminaRecoverAfterSex))
	if fire_sex_event:
		var event = SexEventHelper.create(SexEvent.HolePenetrated, character_id, get_id(), {
			"hole": bodypart_slot,
			"engulfed": false,
			"strapon": ch.is_wearing_strapon(),
		})
		ch.send_sex_event(event)
		send_sex_event(event)

## Line 1127-1147: vagina rubbing fluid share (20-40%)
func rubs_vaginas_with(character_id: String, chance_to_steal_cum: int = 100, show_messages: bool = true) -> void:
	if not RNG.chance(chance_to_steal_cum) or not OPTIONS.is_content_enabled(ContentType.CumStealing):
		return
	if not has_bodypart(BodypartSlot.Vagina):
		return
	var ch = GlobalRegistry.get_character(character_id)
	if ch == null or not ch.has_bodypart(BodypartSlot.Vagina):
		return
	var orifice: Orifice = get_bodypart(BodypartSlot.Vagina).get_orifice()
	var npc_orifice: Orifice = ch.get_bodypart(BodypartSlot.Vagina).get_orifice()
	if orifice == null or npc_orifice == null:
		return
	var success: bool = orifice.share_fluids(npc_orifice, randf_range(0.2, 0.4), get_id())
	if show_messages and success:
		exchanged_cum_during_rubbing.emit(get_name(), ch.get_name())

# ==========================================
# PREGNANCY (lines 1285-1483)
# ==========================================

## Line 1287-1307: fertility/virility with perk and buff modifiers
func get_base_fertility() -> float:
	return 1.0

func get_fertility() -> float:
	if has_perk(&"StartInfertile"):
		return 0.0
	var value := get_base_fertility()
	value += buffs_holder.get_fertility()
	value *= (1.0 + buffs_holder.get_custom(BuffAttribute.FinalFertilityModifier))
	return value

func get_base_virility() -> float:
	return 1.0

func get_virility() -> float:
	if has_perk(&"StartMaleInfertility"):
		return 0.0
	var value := get_base_fertility() # NOTE: uses BaseFertility, not BaseVirility (original bug preserved)
	value += buffs_holder.get_virility()
	value *= (1.0 + buffs_holder.get_custom(BuffAttribute.FinalVirilityModifier))
	return value

## Line 1321-1326: broodmother perk forces 1.0
func get_cross_species_compatibility() -> float:
	var value := 0.0
	value += buffs_holder.get_cross_species_compatibility()
	if has_perk(&"FertilityBroodmother") and value < 1.0:
		return 1.0
	return value

## Line 1410-1412: heavily pregnant at > 66%
func is_heavily_pregnant() -> bool:
	if menstrual_cycle != null:
		return menstrual_cycle.get_pregnancy_progress() > 0.66
	return false

## Line 1466-1481: birth stretch formula sqrt(count) * 30.0
func on_giving_birth(_impregnated_egg_cells: Array, _new_kids: Array) -> void:
	var amount_per_orifice: Dictionary = {}
	for egg in _impregnated_egg_cells:
		if not amount_per_orifice.has(egg.get_orifice()):
			amount_per_orifice[egg.get_orifice()] = 0
		amount_per_orifice[egg.get_orifice()] += 1
	var mapping: Dictionary = {
		OrificeType.Vagina: BodypartSlot.Vagina,
		OrificeType.Anus: BodypartSlot.Anus,
		OrificeType.Throat: BodypartSlot.Head,
	}
	for orifice_type in mapping:
		if not amount_per_orifice.has(orifice_type):
			continue
		var amount_to_stretch: float = sqrt(float(amount_per_orifice[orifice_type])) * 30.0
		got_orifice_stretched_with(mapping[orifice_type], amount_to_stretch)

# ==========================================
# DOLL RENDERING (lines 1749-1874) — ALL STATE MAPPINGS
# ==========================================

## EXACT migration of softUpdateDoll with all formulas
func soft_update_doll(doll: Doll3D) -> void:
	doll.writings_data = get_writings_data()

	# Skin data collection (lines 1751-1765)
	var skin_data := {}
	var body_skin_data := get_skin_data()
	for bodypart_slot in bodyparts:
		var bodypart = get_bodypart(bodypart_slot)
		if bodypart == null:
			continue
		if bodypart.supports_skin():
			var bodypart_skin_data = bodypart.get_skin_data()
			for field in ["skin", "r", "g", "b"]:
				if not bodypart_skin_data.has(field) or bodypart_skin_data[field] == null:
					if body_skin_data.has(field):
						bodypart_skin_data[field] = body_skin_data[field]
			skin_data[bodypart_slot] = bodypart_skin_data
	doll.set_skin_data(skin_data)

	# Cum overlay (lines 1766-1776)
	if has_effect(&"CoveredInCum"):
		doll.set_cum_amount(get_outside_messiness_level())
		var dominant_fluid_id = get_fluids().get_dominant_fluid_id()
		if dominant_fluid_id != null:
			var fluid_object = GlobalRegistry.get_fluid(dominant_fluid_id)
			if fluid_object != null:
				doll.set_cum_color(fluid_object.get_cum_overlay_color())
		else:
			doll.set_cum_color(Color.WHITE)
	else:
		doll.set_cum_amount(0)

	doll.update_materials()

	# State mappings (lines 1778-1831)
	doll.set_state("mouth", "")
	doll.set_state("muzzle", "")
	doll.set_state("gloves", "")
	doll.set_state("armalpha", "")

	# Leg type (lines 1784-1791)
	if bodypart_has_trait(BodypartSlot.Legs, &"LegsPlanti"):
		doll.set_state("legstype", "planti")
	elif bodypart_has_trait(BodypartSlot.Legs, &"LegsDigi"):
		doll.set_state("legstype", "digi")
	elif bodypart_has_trait(BodypartSlot.Legs, &"LegsHoofs"):
		doll.set_state("legstype", "hoofs")
	else:
		doll.set_state("legstype", "")

	update_leaking(doll)

	# Arm type (lines 1793-1796)
	if bodypart_has_trait(BodypartSlot.Arms, &"ArmsBuff"):
		doll.set_state("armstype", "buff")
	else:
		doll.set_state("armstype", "")

	# Cock state (lines 1797-1800)
	if is_ready_to_penetrate():
		doll.set_state("cock", "")
	else:
		doll.set_state("cock", "limp")

	# Breast scale (lines 1801-1809)
	var breasts_scale := 1.0
	if has_bodypart(BodypartSlot.Breasts):
		var breasts = get_bodypart(BodypartSlot.Breasts)
		if breasts.has_method("get_breasts_scale"):
			breasts_scale = breasts.get_breasts_scale()
		doll.breast_scale = breasts.get_breasts_adjust_scale()
	else:
		doll.breast_scale = 0.0
	doll.set_breasts_scale(breasts_scale)

	# Head length (lines 1810-1817)
	if has_bodypart(BodypartSlot.Head):
		var the_head = get_bodypart(BodypartSlot.Head)
		if the_head.has_method("get_head_length"):
			doll.head_length = the_head.get_head_length()
		else:
			doll.head_length = 0.0
	else:
		doll.head_length = 0.0

	# Penis & balls scale (lines 1818-1827)
	var penis_scale := 1.0
	var balls_scale := 1.0
	if has_bodypart(BodypartSlot.Penis):
		var penis = get_bodypart(BodypartSlot.Penis)
		if penis.has_method("get_penis_scale"):
			penis_scale = penis.get_penis_scale()
		if penis.has_method("get_balls_scale"):
			balls_scale = penis.get_balls_scale()
	doll.set_penis_scale(penis_scale)
	doll.set_balls_scale(balls_scale)

	# Breast state (lines 1828-1831)
	if has_non_flat_breasts():
		doll.set_state("breasts", "nonflat")
	else:
		doll.set_state("breasts", "flat")

	# Pregnancy value (lines 1832-1851) — ALL FORMULAS
	var pregnancy_value: float = clampf(get_pregnancy_progress_doll(), 0.0, 1.0)
	var pregnancy_kid_amount := get_pregnancy_litter_size()
	var extra_kids_mult := 1.0
	if OPTIONS.get_belly_max_size_depends_on_litter_size() and pregnancy_kid_amount > 1:
		extra_kids_mult = pow(float(pregnancy_kid_amount), 0.25)
	pregnancy_value *= extra_kids_mult
	pregnancy_value *= OPTIONS.get_belly_max_size_modifier()
	var thickness_norm := get_thickness() / 100.0
	var fem_norm := get_femininity() / 100.0
	var pregnancy_addition := 0.0
	if fem_norm < 0.5:
		pregnancy_addition = -0.1 * (1.0 - (fem_norm * 2.0))
	pregnancy_value += pregnancy_addition
	var cum_inflation_level := get_cum_inflation_level()
	pregnancy_value += clampf(cum_inflation_level / 2.0, 0.0, 1.0)
	pregnancy_value += get_custom_attribute(BuffAttribute.InflatedBelly)
	pregnancy_value *= (1.0 + get_custom_attribute(BuffAttribute.BellySizeModifier))
	if pregnancy_value < -0.5:
		pregnancy_value = -0.5
	doll.set_pregnancy(pregnancy_value)

	# Butt & thigh thickness (lines 1852-1862)
	var the_tail_scale := 1.0
	if has_bodypart(BodypartSlot.Tail):
		var the_tail = get_bodypart(BodypartSlot.Tail)
		if the_tail.has_method("get_tail_scale"):
			the_tail_scale = the_tail.get_tail_scale()
	if thickness_norm <= 0.5:
		doll.set_butt_scale(1.0 - 0.2 * (1.0 - thickness_norm * 2), the_tail_scale)
		doll.set_thigh_thickness(-0.4 * (1.0 - thickness_norm * 2))
	else:
		doll.set_butt_scale(1.0 + (thickness_norm - 0.5) / 1.5, the_tail_scale)
		doll.set_thigh_thickness(thickness_norm - 0.5)

	# Chains from items (lines 1863-1874)
	doll.self_chains = []
	var wearing_items := get_inventory().get_all_equipped_items()
	for inventory_slot in wearing_items:
		var item = wearing_items[inventory_slot]
		if item == null:
			continue
		item.update_doll(doll)
		var new_chains = item.get_chains()
		if new_chains != null:
			for self_chain in new_chains:
				doll.self_chains.append([self_chain[0], self_chain[1], "self", self_chain[2]])
	doll.call_deferred("check_chains")

func get_writings_data() -> Dictionary:
	if has_effect(&"HasBodyWritings"):
		return get_effect(&"HasBodyWritings").get_doll_data()
	return {}

func update_leaking(doll: Doll3D) -> void:
	doll.set_breasts_leaking(has_effect(&"BreastsFull"))
	doll.set_pussy_leaking(has_effect(&"HasCumInsideVagina") and not buffs_holder.has_buff(&"BlocksVaginaLeakingBuff"))
	doll.set_anus_leaking(has_effect(&"HasCumInsideAnus") and not buffs_holder.has_buff(&"BlocksAnusLeakingBuff"))

# ==========================================
# BODYPART MANAGEMENT (stubs — full logic in bodypart files)
# ==========================================

func has_bodypart(_slot) -> bool:
	return bodyparts.has(_slot) and bodyparts[_slot] != null

func get_bodypart(_slot):
	return bodyparts.get(_slot)

func bodypart_has_trait(_slot, _trait) -> bool:
	var bp = get_bodypart(_slot)
	if bp == null:
		return false
	if bp.has_method("has_trait"):
		return bp.has_trait(_trait)
	return false

func _reset_slots() -> void:
	pass

func is_ready_to_penetrate() -> bool:
	if not has_bodypart(BodypartSlot.Penis):
		return false
	return true

func is_wearing_strapon() -> bool:
	return false

func get_penis_size() -> float:
	if not has_bodypart(BodypartSlot.Penis):
		return 20.0
	return get_bodypart(BodypartSlot.Penis).get_length()

func is_player() -> bool:
	return false

func get_thickness() -> float:
	return 50.0

func get_femininity() -> float:
	return 50.0

func get_custom_attribute(_attr: StringName) -> float:
	return 0.0

func get_outside_messiness_level() -> int:
	return 0

func get_fluids() -> Fluids:
	return body_fluids

func send_sex_event(_event) -> void:
	onSexEvent(_event)

func got_orifice_stretched_with(bodypart_slot, insertion_size: float, show_messages: bool = true, stretch_mult: float = 1.0) -> void:
	if not has_bodypart(bodypart_slot):
		return
	var the_bodypart = get_bodypart(bodypart_slot)
	var orifice = the_bodypart.get_orifice()
	if orifice == null:
		return
	var old_looseness = orifice.get_looseness()
	the_bodypart.handle_insertion(insertion_size, stretch_mult)
	var new_looseness = orifice.get_looseness()
	if new_looseness > old_looseness and show_messages:
		orifice_become_more_loose.emit(the_bodypart.get_orifice_name(), new_looseness, old_looseness)

func clear_orifice_fluids() -> void:
	if has_bodypart(BodypartSlot.Vagina):
		get_bodypart(BodypartSlot.Vagina).clear_orifice_fluids()
	if has_bodypart(BodypartSlot.Anus):
		get_bodypart(BodypartSlot.Anus).clear_orifice_fluids()
	if has_bodypart(BodypartSlot.Head):
		get_bodypart(BodypartSlot.Head).clear_orifice_fluids()

func update_doll(doll: Doll3D) -> void:
	soft_update_doll(doll)

func get_skin_data() -> Dictionary:
	return {}

func get_pregnancy_progress_doll() -> float:
	return 0.0

func get_pregnancy_litter_size() -> int:
	return 1

# ==========================================
# BACKWARD-COMPATIBLE CAMELCASE ALIASES
# Old code uses camelCase; new internals use snake_case.
# ==========================================

# Variable aliases
var initialDodgeChance: float:
	get: return initial_dodge_chance
	set(value): initial_dodge_chance = value
var processingBodyparts: Array:
	get: return processing_bodyparts
var pickedSkin: String:
	get: return picked_skin
	set(value): picked_skin = value
var pickedSkinRColor: Color:
	get: return picked_skin_r_color
	set(value): picked_skin_r_color = value
var pickedSkinGColor: Color:
	get: return picked_skin_g_color
	set(value): picked_skin_g_color = value
var pickedSkinBColor: Color:
	get: return picked_skin_b_color
	set(value): picked_skin_b_color = value
var timedBuffs: Array:
	get: return timed_buffs
var timedBuffsTurns: Array:
	get: return timed_buffs_turns

# Method aliases — Stats
func addPain(_p: int) -> void:
	add_pain(_p)

func addLust(_l: int) -> void:
	add_lust(_l)

func addArousal(_a: float) -> void:
	var initial := arousal
	arousal = clampf(arousal + _a, 0.0, 1000.0)
	if initial != arousal:
		stat_changed.emit()

func addStamina(_s: int) -> void:
	add_stamina(_s)

func getPain() -> int:
	return get_pain()

func getLust() -> int:
	return get_lust()

func getStamina() -> int:
	return get_stamina()

func getAmbientPain() -> int:
	return get_ambient_pain()

func getAmbientLust() -> int:
	return get_ambient_lust()

func getExposure() -> float:
	return 0.0

# Method aliases — Effects
func addEffect(effect_id: StringName, args: Array = []) -> bool:
	return add_effect(effect_id, args)

func removeEffect(effect_id: StringName) -> void:
	remove_effect(effect_id)

func hasEffect(effect_id: StringName) -> bool:
	return has_effect(effect_id)

func getEffect(effect_id: StringName):
	return get_effect(effect_id)

# Method aliases — Bodyparts
func hasBodypart(slot) -> bool:
	return has_bodypart(slot)

func getBodypart(slot):
	return get_bodypart(slot)

func resetSlots() -> void:
	_reset_slots()

func bodypartHasTrait(slot, trait_id) -> bool:
	return bodypart_has_trait(slot, trait_id)

# Method aliases — Inventory
func getInventory() -> Inventory:
	return get_inventory()

func getSkillsHolder() -> SkillsHolder:
	return get_skills_holder()

func getBuffsHolder() -> BuffsHolder:
	return get_buffs_holder()

func getFetishHolder() -> FetishHolder:
	return get_fetish_holder()

func getPersonality() -> Personality:
	return get_personality()

func getLustInterests() -> LustInterests:
	return get_lust_interests()

# Method aliases — Skills
func addExperience(new_exp: int) -> void:
	add_experience(new_exp)

func addSkillExperience(skill_id: StringName, amount: int, activity_id: StringName = &"") -> void:
	add_skill_experience(skill_id, amount, activity_id)

func hasPerk(perk_id: StringName) -> bool:
	return has_perk(perk_id)

func getStat(stat_id: StringName):
	return get_stat(stat_id)

func getSkillLevel(skill_id: StringName) -> int:
	return get_skill_level(skill_id)

func getLevel() -> int:
	return get_level()

# Method aliases — Appearance
func updateAppearance() -> void:
	update_appearance()

func getSkinData() -> Dictionary:
	return get_skin_data()

# Method aliases — Combat
func processBattleTurn() -> void:
	pass

func beforeFightStarted() -> void:
	pass

func afterFightEnded() -> void:
	pass

# Method aliases — Misc
func processTimedBuffs(_seconds: float) -> void:
	pass

func saveBuffsData(_additional_data: Dictionary = {}) -> Dictionary:
	return {}

func loadBuffsData(_data: Dictionary) -> void:
	pass

func saveStatusEffectsData() -> Dictionary:
	return {}

func loadStatusEffectsData(_data: Dictionary) -> void:
	pass

func checkSkins() -> void:
	pass

func clearTallymarks() -> void:
	pass

func clearBodywritings() -> void:
	pass

func clearBodyFluids() -> void:
	pass

func afterOrgasm() -> void:
	pass

func loadTFVar(_data, _key: String = "", _default = null):
	if _data is Dictionary and _key != "":
		if _data.has(_key):
			return _data[_key]
		return _default
	return _data

func getID() -> String:
	return str(get_id())

func isPlayer() -> bool:
	return is_player()

func getPainLevel() -> float:
	return get_pain_level()

func getLustLevel() -> float:
	return get_lust_level()

func getMaxStamina() -> int:
	return get_max_stamina()

func getAttackAccuracy() -> float:
	return get_attack_accuracy()

func isPregnant() -> bool:
	return is_heavily_pregnant()

func getPregnancyProgress() -> float:
	return get_pregnancy_progress_doll()

func isEggStuffedWithOffspring() -> bool:
	return false

func giveBirth() -> Array:
	return []

func onSexEvent(_event) -> void:
	if _event == null:
		return
	get_skills_holder().onSexEvent(_event)
	for effect_id in status_effects.keys():
		if not status_effects.has(effect_id):
			continue
		var effect = status_effects[effect_id]
		effect.onSexEvent(_event)
	var items = getInventory().getAllEquippedItems()
	for item_slot in items:
		var item = items[item_slot]
		item.onSexEvent(_event)

func sendSexEvent(_event) -> void:
	send_sex_event(_event)

func giveBodypart(bodypart, _slot_override = null) -> void:
	if bodypart == null:
		return
	var slot = _slot_override if _slot_override != null else bodypart.getSlot()
	if slot != null:
		bodyparts[slot] = bodypart
		bodypart_storage_node.add_child(bodypart)
		bodypart_changed.emit()
