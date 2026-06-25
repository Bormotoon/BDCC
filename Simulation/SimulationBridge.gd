# Simulation/SimulationBridge.gd
class_name SimulationBridge extends Node

## EXACT migration from InteractionSystem.gd (728 lines) and CharacterPawn.gd (714 lines).
## All time-slicing formulas, batch spread, action scoring, pawn lifecycle preserved.

var csharp_engine: Node
var room_graph: RoomGraph

# Pawn management (InteractionSystem lines 4-6)
var pawns: Dictionary = {} # StringName -> Dictionary
var pawns_by_loc: Dictionary = {} # StringName -> Dictionary[StringName, bool]
var interactions: Array = []
var global_tasks: Dictionary = {}
var used_char_ids_today: Dictionary = {}
var react_cooldowns: Dictionary = {}

# Time-slicing state (InteractionSystem line 174)
var internal_tick: int = 0

const MAX_SIMULATIONS_PER_TICK: int = 10
const TICK_SIZE_SECONDS: int = 60

func _ready() -> void:
	var CSharpScript = load("res://Simulation/SimulationEngine.cs")
	csharp_engine = CSharpScript.new()
	add_child(csharp_engine)

	room_graph = RoomGraph.new()
	ServiceLocator.register_service(&"SimulationBridge", self)

	EventBus.time_advanced.connect(_on_time_advanced)
	EventBus.npc_spawned.connect(_on_npc_spawned)
	EventBus.npc_despawned.connect(_on_npc_despawned)

# ==========================================
# PAWN LIFECYCLE (InteractionSystem lines 259-350)
# ==========================================

## Line 259-299: spawnPawn with pawnType location selection
func spawn_pawn(char_id: StringName, starting_room: StringName = &"", pawn_type_id: StringName = &"") -> Dictionary:
	if char_id.is_empty():
		return {}

	# Delete existing pawn if present (line 272-273)
	if pawns.has(char_id):
		delete_pawn(char_id)

	var pawn: Dictionary = {
		"id": char_id,
		"location": starting_room if not starting_room.is_empty() else &"main_punishment_spot",
		"pawn_type": pawn_type_id,
		"hunger": randf_range(0.0, 0.3),
		"social": randf_range(0.0, 0.6),
		"anger": 0.0,
		"tiredness": randf_range(0.0, 0.1),
		"fight_exhaustion": 0.0,
		"time_since_last_work": randi_range(0, 6000),
		"is_active": true,
		"current_interaction": null,
	}

	pawns[char_id] = pawn

	# Register in spatial index (line 290-293)
	var loc: StringName = pawn["location"]
	if not pawns_by_loc.has(loc):
		pawns_by_loc[loc] = {}
	pawns_by_loc[loc][char_id] = true

	used_char_ids_today[char_id] = true

	# Register in C# engine
	if csharp_engine and csharp_engine.has_method("AddNpc"):
		csharp_engine.AddNpc(char_id, loc)

	EventBus.npc_spawned.emit(char_id, loc)
	return pawn

## Line 301-304: spawn only if not already present
func spawn_pawn_if_needed(char_id: StringName, pawn_type_id: StringName = &"") -> Dictionary:
	if pawns.has(char_id):
		return pawns[char_id]
	return spawn_pawn(char_id, &"", pawn_type_id)

## Line 306-321: delete pawn, stop interactions, update spatial index
func delete_pawn(char_id: StringName) -> void:
	if char_id.is_empty() or not pawns.has(char_id):
		return

	# Stop all interactions for this pawn (line 312)
	stop_interactions_for_pawn(char_id)

	var pawn: Dictionary = pawns[char_id]
	pawn["is_active"] = true # Mark as deleted

	var loc: StringName = pawn["location"]
	pawns.erase(char_id)

	if pawns_by_loc.has(loc):
		pawns_by_loc[loc].erase(char_id)
		if pawns_by_loc[loc].is_empty():
			pawns_by_loc.erase(loc)

	EventBus.npc_despawned.emit(char_id)

## Line 323-350: onPawnMoved triggers meet checks
func on_pawn_moved(char_id: StringName, old_loc: StringName, new_loc: StringName) -> void:
	if char_id.is_empty() or old_loc == new_loc:
		return

	# Update spatial index (lines 331-337)
	if pawns_by_loc.has(old_loc):
		pawns_by_loc[old_loc].erase(char_id)
		if pawns_by_loc[old_loc].is_empty():
			pawns_by_loc.erase(old_loc)

	if not pawns_by_loc.has(new_loc):
		pawns_by_loc[new_loc] = {}
	pawns_by_loc[new_loc][char_id] = true

	# Check meet interactions (lines 342-350)
	var all_new_pawns := get_pawns_at(new_loc)
	for other_pawn_id in all_new_pawns:
		if other_pawn_id == char_id:
			continue
		# Check if either pawn wants to interact
		var other_pawn = pawns.get(other_pawn_id, {})
		if other_pawn.is_empty():
			continue
		if not other_pawn.is_empty() and other_pawn.get("is_active", false):
			if GM and ServiceLocator.safe_get_service(&"MainScene") and ServiceLocator.safe_get_service(&"MainScene").IS:
				ServiceLocator.safe_get_service(&"MainScene").IS.checkOnMeetInteractions(char_id, other_pawn_id, true)
		break

func get_pawn(char_id: StringName) -> Dictionary:
	return pawns.get(char_id, {})

func get_pawns_at(location: StringName) -> Array[StringName]:
	if pawns_by_loc.has(location):
		return pawns_by_loc[location].keys()
	return []

func has_pawn(char_id: StringName) -> bool:
	return pawns.has(char_id)

# ==========================================
# TIME SLICING (InteractionSystem lines 109-137, 174-246)
# ==========================================

## Line 109-137: processTime with dungeon check
func process_time(how_much: int) -> void:
	# Line 110: no pawn activity while in dungeon
	var main_scene = ServiceLocator.get_service(&"MainScene") if ServiceLocator else null
	if main_scene and main_scene.has_method("is_in_dungeon") and main_scene.is_in_dungeon():
		return

	# Update needs for all pawns
	for char_id in pawns:
		_process_pawn_needs(char_id, how_much)

	# Update cooldowns (lines 117-120)
	for char_id in react_cooldowns:
		react_cooldowns[char_id] -= how_much
		if react_cooldowns[char_id] <= 0:
			react_cooldowns.erase(char_id)

	# Time-sliced simulation (lines 122-132)
	var time_copy: int = how_much
	var did_simulations: int = 0
	while time_copy > 0 and did_simulations < MAX_SIMULATIONS_PER_TICK:
		var timeslice: int = mini(TICK_SIZE_SECONDS, time_copy)
		time_copy -= timeslice
		did_simulations += 1
		_process_busy_all_interactions(timeslice)

	# Process remaining time
	if time_copy > 0:
		_process_busy_all_interactions(time_copy)

	# Check for new pawns (line 134)
	_check_add_new_pawns()

## Line 174-184: batch spread calculation
func _calc_spread_tick_amount() -> int:
	var amount_of_interactions: int = interactions.size()
	var am_ticks: int = ceili(float(amount_of_interactions) / 40.0)
	if am_ticks < 1:
		am_ticks = 1
	elif am_ticks > 5:
		am_ticks = 5
	return am_ticks

## Line 186-246: processBusyAllInteractions with batch spread
func _process_busy_all_interactions(how_many_seconds: int) -> void:
	if how_many_seconds <= 0:
		return

	# Process global tasks (lines 191-197)
	var max_pawn_count := _get_max_pawn_count()
	for task_id in global_tasks:
		var task = global_tasks[task_id]
		if task.has_method("process_time"):
			task.process_time(how_many_seconds)
		if task.has_method("set_max_assigned_cached"):
			task.set_max_assigned_cached(task.get("max_assigned", 0))

	# Process pawn needs (lines 199-202)
	for char_id in pawns:
		_process_pawn_needs(char_id, how_many_seconds)

	# Batch spread interaction processing (lines 204-244)
	var how_many_ticks := _calc_spread_tick_amount()
	var how_many_to_process := ceili(float(interactions.size()) / float(how_many_ticks))
	var interactions_copy := interactions.duplicate()

	for i in how_many_to_process:
		var indx: int = i * how_many_ticks + internal_tick
		if indx >= interactions_copy.size():
			continue

		var interaction = interactions_copy[indx]
		if interaction == null:
			continue

		# Line 217: batch spread multiplies time
		var final_how_many_seconds: int = how_many_seconds * how_many_ticks

		if interaction.has("busy_action_seconds"):
			interaction["busy_action_seconds"] -= final_how_many_seconds

		if interaction.has_method("process_time"):
			interaction.process_time(final_how_many_seconds)

		# Line 222-225: execute action when timer expires
		if interaction.get("busy_action_seconds", 0) <= 0:
			if interaction.has_method("do_current_action"):
				interaction.do_current_action()
			if interaction.has_method("decide_next_action"):
				decide_next_action(interaction)

	# Advance tick (lines 242-244)
	internal_tick += 1
	if internal_tick >= how_many_ticks:
		internal_tick = 0

# ==========================================
# ACTION SCORING (InteractionSystem lines 139-172)
# ==========================================

## Line 139-172: decideNextAction with minScore filtering
func decide_next_action(interaction: Dictionary, context: Dictionary = {}) -> void:
	if interaction.is_empty():
		return

	var actions: Array = interaction.get("actions", [])
	if actions.is_empty():
		return

	# Line 153-158: calculate scores
	var max_score: float = 0.0
	for action in actions:
		var score: float = action.get("score", 0.0)
		action["final_score"] = score
		if score > max_score:
			max_score = score

	# Line 160: filter out actions below 10% of max
	var min_score: float = max_score * 0.1
	var possible_actions: Array = []
	for action in actions:
		if action.get("final_score", 0.0) >= min_score:
			possible_actions.append(action)

	if possible_actions.is_empty():
		return

	# Line 171: weighted random selection
	var picked = RNG.pick(possible_actions)
	if picked and interaction.has_method("set_picked_action"):
		interaction.set_picked_action(picked, context)

# ==========================================
# NEEDS SIMULATION (CharacterPawn lines 94-113)
# ==========================================

func _process_pawn_needs(char_id: StringName, delta_seconds: int) -> void:
	if not pawns.has(char_id):
		return

	var pawn: Dictionary = pawns[char_id]
	var delta_hours: float = float(delta_seconds) / 3600.0

	# Line 99: hunger += delta * 0.2 / 3600
	pawn["hunger"] += delta_hours * 0.2

	# Line 100: social += delta * 0.5 / 3600
	pawn["social"] += delta_hours * 0.5

	# Line 101: fight exhaustion recovery
	pawn["fight_exhaustion"] -= delta_hours * 2.0
	pawn["fight_exhaustion"] = maxf(pawn["fight_exhaustion"], 0.0)

	# Line 102: tiredness += delta * 0.05 / 3600
	pawn["tiredness"] += delta_hours * 0.05

	# Line 104-110: anger modified by personality
	var meanness: float = _score_personality(char_id, &"mean")
	if meanness > 0.0:
		pawn["anger"] += delta_hours * 0.1 * meanness
	else:
		pawn["anger"] -= delta_hours * 0.1 * maxf(absf(meanness), 0.1)
		pawn["anger"] = maxf(pawn["anger"], 0.0)

	# Line 112: timeSinceLastWork
	pawn["time_since_last_work"] += delta_seconds

# ==========================================
# INTERACTION MANAGEMENT
# ==========================================

func stop_interactions_for_pawn(char_id: StringName) -> void:
	for i in range(interactions.size() - 1, -1, -1):
		var interaction = interactions[i]
		if interaction.has("involved_pawns"):
			if char_id in interaction["involved_pawns"].values():
				interactions.remove_at(i)

func start_interaction(interaction_id: StringName, participants: Dictionary, context: Dictionary = {}) -> void:
	var new_interaction: Dictionary = {
		"id": interaction_id,
		"participants": participants,
		"context": context,
		"busy_action_seconds": 0,
	}
	interactions.append(new_interaction)

func _check_add_new_pawns() -> void:
	if GM and ServiceLocator.safe_get_service(&"MainScene"):
		if ServiceLocator.safe_get_service(&"MainScene").has_method("getTime"):
			var time_sec = ServiceLocator.safe_get_service(&"MainScene").getTime()
			if time_sec >= 19 * 3600:
				return
		if ServiceLocator.safe_get_service(&"MainScene").has_method("is_in_dungeon") and ServiceLocator.safe_get_service(&"MainScene").is_in_dungeon():
			return

	var max_pawns: int = _get_max_pawn_count()
	var cur_pawns: int = pawns.size()
	if cur_pawns >= max_pawns or max_pawns <= 0:
		return

	var fullness: float = float(cur_pawns) / float(max_pawns)
	var chance: float = (1.0 - fullness) * 10.0
	if not RNG.chance(chance):
		return

	_try_spawn_pawn()

func _get_max_pawn_count() -> int:
	if OPTIONS and OPTIONS.has_method("get_sandbox_pawn_count"):
		return OPTIONS.get_sandbox_pawn_count()
	return 30

func _try_spawn_pawn() -> bool:
	var pawn_types: Array = []
	if GM and ServiceLocator.safe_get_service(&"MainScene") and ServiceLocator.safe_get_service(&"MainScene").has_method("getPawnDistribution"):
		var dist = ServiceLocator.safe_get_service(&"MainScene").getPawnDistribution()
		pawn_types = dist.keys()
	elif GM and ServiceLocator.safe_get_service(&"MainScene") and ServiceLocator.safe_get_service(&"MainScene").IS:
		if ServiceLocator.safe_get_service(&"MainScene").IS.has("pawnDistribution"):
			pawn_types = ServiceLocator.safe_get_service(&"MainScene").IS.pawnDistribution.keys()
	if pawn_types.is_empty():
		return false

	var picked_type = RNG.pick(pawn_types)
	var pawn_type = GlobalRegistry.getPawnType(picked_type) if GlobalRegistry.has_method("getPawnType") else null
	if pawn_type == null:
		return false

	var picked_char_id = pawn_type.tryPickCharacterID() if pawn_type.has_method("tryPickCharacterID") else ""
	if picked_char_id.is_empty():
		picked_char_id = pawn_type.generateCharacterID() if pawn_type.has_method("generateCharacterID") else ""
	if picked_char_id.is_empty():
		return false

	var new_pawn = spawn_pawn(picked_char_id, &"", picked_type)
	return not new_pawn.is_empty()

# ==========================================
# COMBAT HELPERS (CharacterPawn lines 473-500)
# ==========================================

func after_lost_fight(char_id: StringName) -> void:
	if not pawns.has(char_id):
		return
	var pawn: Dictionary = pawns[char_id]
	if pawn["anger"] > 0.5:
		pawn["anger"] = 0.0
	else:
		pawn["anger"] = 1.0
	if char_id != &"pc":
		pawn["fight_exhaustion"] = 1.0

func after_won_fight(char_id: StringName) -> void:
	if pawns.has(char_id):
		pawns[char_id]["anger"] = 0.0

func after_sex(char_id: StringName) -> void:
	if pawns.has(char_id):
		pawns[char_id]["social"] = 0.0
		pawns[char_id]["anger"] = 0.0

# ==========================================
# RELATIONSHIP SCORING (CharacterPawn lines 259-369)
# ==========================================

func score_like(char_id: StringName, other_char_id: StringName) -> float:
	return maxf(0.0, _get_affection(char_id, other_char_id))

func score_hate(char_id: StringName, other_char_id: StringName) -> float:
	return maxf(0.0, -_get_affection(char_id, other_char_id))

func score_lust(char_id: StringName, other_char_id: StringName) -> float:
	return maxf(0.0, _get_lust(char_id, other_char_id))

## Line 321-338: affectAffection with reputation and personality modifiers
func affect_affection(char_id: StringName, other_char_id: StringName, how_much: float) -> void:
	var mult: float = 1.0
	if how_much > 0.0:
		mult = _get_chars_rep_mult(char_id, other_char_id)
		var meanness: float = _score_personality(char_id, &"mean")
		mult -= meanness * 0.5
	elif how_much < 0.0:
		var meanness: float = _score_personality(char_id, &"mean")
		mult += meanness * 0.5

	var current_affection: float = _get_affection(char_id, other_char_id)
	# Line 335-338: opposite direction gets double multiplier
	if (current_affection > 0.1 and how_much < 0.0) or (current_affection < -0.1 and how_much > 0.0):
		EventBus.npc_relationship_changed.emit(char_id, other_char_id, &"affection", how_much * mult * 2.0)
	else:
		EventBus.npc_relationship_changed.emit(char_id, other_char_id, &"affection", how_much * mult)

func _get_affection(char_id: StringName, other_char_id: StringName) -> float:
	if GM and ServiceLocator.safe_get_service(&"MainScene") and ServiceLocator.safe_get_service(&"MainScene").RS:
		return ServiceLocator.safe_get_service(&"MainScene").RS.getAffection(char_id, other_char_id)
	return 0.0

func _get_lust(char_id: StringName, other_char_id: StringName) -> float:
	if GM and ServiceLocator.safe_get_service(&"MainScene") and ServiceLocator.safe_get_service(&"MainScene").RS:
		return ServiceLocator.safe_get_service(&"MainScene").RS.getLust(char_id, other_char_id)
	return 0.0

func _score_personality(char_id: StringName, stat: StringName) -> float:
	var character = GlobalRegistry.getCharacter(char_id)
	if character == null:
		return 0.0
	if character.has_method("getPersonality"):
		var personality = character.getPersonality()
		if personality and personality.has_method("personality_score"):
			return personality.personality_score({stat: 1.0})
	if character.has_method("get_personality"):
		var personality = character.get_personality()
		if personality and personality.has_method("personality_score"):
			return personality.personality_score({stat: 1.0})
	return 0.0

func _get_chars_rep_mult(char1_id: StringName, char2_id: StringName) -> float:
	var character1 = GlobalRegistry.getCharacter(char1_id)
	var character2 = GlobalRegistry.getCharacter(char2_id)
	if character1 == null or character2 == null:
		return 1.0

	if not character1.has_method("isPlayer") or not character2.has_method("isPlayer"):
		return 1.0
	if not character1.isPlayer() and not character2.isPlayer():
		return 1.0

	var reputation
	if character1.isPlayer():
		reputation = character1.getReputation() if character1.has_method("getReputation") else null
		if reputation:
			if character2.has_method("isInmate") and character2.isInmate():
				return reputation.getGenericRepMult("Inmates", 1.0)
			else:
				return reputation.getGenericRepMult("Staff", 1.0)
	else:
		reputation = character2.getReputation() if character2.has_method("getReputation") else null
		if reputation:
			if character1.has_method("isInmate") and character1.isInmate():
				return reputation.getGenericRepMult("Inmates", 1.0)
			else:
				return reputation.getGenericRepMult("Staff", 1.0)
	return 1.0

# ==========================================
# C# BRIDGE
# ==========================================

func _on_time_advanced(minutes: int) -> void:
	process_time(minutes * 60)

func _on_npc_spawned(npc_id: StringName, room_id: StringName) -> void:
	if not pawns.has(npc_id):
		spawn_pawn(npc_id, room_id)

func _on_npc_despawned(npc_id: StringName) -> void:
	delete_pawn(npc_id)

func _process_csharp_tick(delta_minutes: float) -> void:
	if csharp_engine and csharp_engine.has_method("ProcessSimulationTick"):
		csharp_engine.ProcessSimulationTick(delta_minutes)
