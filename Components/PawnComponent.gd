# Components/PawnComponent.gd
class_name PawnComponent extends Component

## Migrated from CharacterPawn.gd (714 lines).
## ECS component for NPC pawn needs, scoring, and interaction state.

@export var pawn_type_id: StringName = &""

# Needs (migrated from CharacterPawn.gd lines 12-24)
var hunger: float = 0.0
var social: float = 0.0
var anger: float = 0.0
var tiredness: float = 0.0
var fight_exhaustion: float = 0.0
var time_since_last_work: int = 0

const HUNGER_PER_HOUR: float = 0.2
const SOCIAL_PER_HOUR: float = 0.5
const ANGER_PER_HOUR: float = 0.1
const TIREDNESS_PER_HOUR: float = 0.05
const FIGHT_EXHAUSTION_PER_HOUR: float = 2.0

# Current interaction state
var current_interaction: Node = null

func _ready() -> void:
	super._ready()

# --- Needs accessors ---

func get_hunger() -> float:
	return hunger

func get_social() -> float:
	return social

func get_social_clamped() -> float:
	return clampf(social, 0.0, 1.0)

func get_anger() -> float:
	return anger

func get_anger_clamped() -> float:
	return clampf(anger, 0.0, 1.0)

func get_tiredness() -> float:
	return tiredness

func get_exhaustion() -> float:
	return fight_exhaustion

# --- Needs modification ---

func satisfy_social() -> void:
	social = 0.0

func add_social(how_much: float) -> void:
	social = maxf(0.0, social + how_much)

func after_social_interaction() -> void:
	if social <= 1.0:
		social -= RNG.randf_range(0.2, 0.4)
		social = maxf(0.0, social)
	else:
		social *= 0.5

func after_failed_social_interaction() -> void:
	after_social_interaction()
	add_anger(RNG.randf_range(0.2, 0.4))

func add_anger(new_ang: float) -> void:
	anger = maxf(0.0, anger + new_ang)

func affect_anger(how_much: float) -> void:
	var meanness: float = _get_personality_stat(&"mean")
	add_anger(how_much * (1.0 + 0.5 * meanness))

func satisfy_anger() -> void:
	anger = 0.0

func recover_exhaustion(how_much: float = 0.1) -> void:
	fight_exhaustion = maxf(0.0, fight_exhaustion - how_much)

func make_exhausted() -> void:
	if entity.entity_id == &"pc":
		return
	fight_exhaustion = 1.0

# --- Fight outcomes (migrated from CharacterPawn.gd lines 473-500) ---

func after_lost_fight() -> void:
	if anger > 0.5:
		satisfy_anger()
	else:
		add_anger(1.0)
	if entity.entity_id != &"pc":
		fight_exhaustion = 1.0

func after_won_fight() -> void:
	satisfy_anger()

func after_sex(is_dom: bool = false) -> void:
	satisfy_social()
	satisfy_anger()

# --- Interaction state ---

func set_interaction(new_interaction: Node) -> void:
	current_interaction = new_interaction

func get_interaction() -> Node:
	return current_interaction

func has_interaction() -> bool:
	return current_interaction != null

# --- Scoring helpers ---

func score_personality(stat: StringName, only_positive: bool = false) -> float:
	return _get_personality_stat(stat)

func score_like(other_entity: Node) -> float:
	return maxf(0.0, _get_affection(other_entity))

func score_hate(other_entity: Node) -> float:
	return maxf(0.0, -_get_affection(other_entity))

func score_lust(other_entity: Node) -> float:
	return maxf(0.0, _get_lust(other_entity))

func score_exposed() -> float:
	if entity.has_method("get_exposure"):
		return entity.get_exposure()
	return 0.0

# --- Internal lookups ---

func _get_personality_stat(stat: StringName) -> float:
	if entity.has_method("get_component"):
		var personality = entity.get_component(&"PersonalityComponent")
		if personality and personality.has_method("get_stat"):
			return personality.get_stat(stat)
	return 0.0

func _get_affection(other_entity: Node) -> float:
	# Will be connected to RelationshipSystem via EventBus
	return 0.0

func _get_lust(other_entity: Node) -> float:
	# Will be connected to RelationshipSystem via EventBus
	return 0.0

# --- Type checks (migrated from CharacterPawn.gd lines 394-422) ---

func get_char_type() -> StringName:
	if entity.has_method("get_character_type"):
		return entity.get_character_type()
	return &"generic"

func is_inmate() -> bool:
	return get_char_type() == &"inmate"

func is_guard() -> bool:
	return get_char_type() == &"guard"

func is_nurse() -> bool:
	return get_char_type() == &"nurse"

func is_engineer() -> bool:
	return get_char_type() == &"engineer"

func is_staff() -> bool:
	return is_guard() or is_nurse() or is_engineer()

func is_player() -> bool:
	return entity.entity_id == &"pc"

# --- Pawn type delegation ---

func get_pawn_type_id() -> StringName:
	if pawn_type_id == &"" and entity.has_method("get_character_type"):
		return entity.get_character_type()
	return pawn_type_id
