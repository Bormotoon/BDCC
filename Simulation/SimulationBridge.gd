# Simulation/SimulationBridge.gd
class_name SimulationBridge extends Node

## Migrated from InteractionSystem.gd (728 lines) and CharacterPawn.gd (714 lines).
## Bridges GDScript events and C# simulation engine.
## Manages pawn lifecycle, time-slicing, and needs simulation.

var csharp_engine: Node
var room_graph: RoomGraph

# Pawn management (migrated from InteractionSystem.gd lines 4-6)
var pawns: Dictionary = {} # StringName -> PawnData
var pawns_by_loc: Dictionary = {} # StringName -> Dictionary[StringName, bool]
var used_char_ids_today: Dictionary = {}
var react_cooldowns: Dictionary = {}

# Time-slicing constants (migrated from InteractionSystem.gd lines 122-132)
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

# --- Pawn lifecycle (migrated from InteractionSystem.gd spawn/despawn) ---

func spawn_pawn(char_id: StringName, starting_room: StringName, pawn_type_id: StringName = &"") -> void:
	var pawn: Dictionary = {
		"id": char_id,
		"location": starting_room,
		"pawn_type": pawn_type_id,
		"hunger": RNG.randf_range(0.0, 0.3),
		"social": RNG.randf_range(0.0, 0.6),
		"anger": 0.0,
		"tiredness": RNG.randf_range(0.0, 0.1),
		"fight_exhaustion": 0.0,
		"time_since_last_work": RNG.randi_range(0, 6000),
		"is_active": true,
	}

	pawns[char_id] = pawn

	if not pawns_by_loc.has(starting_room):
		pawns_by_loc[starting_room] = {}
	pawns_by_loc[starting_room][char_id] = true

	# Register in C# engine
	if csharp_engine and csharp_engine.has_method("AddNpc"):
		csharp_engine.AddNpc(char_id, starting_room)

	used_char_ids_today[char_id] = true

	EventBus.npc_spawned.emit(char_id, starting_room)

func despawn_pawn(char_id: StringName) -> void:
	if not pawns.has(char_id):
		return

	var pawn: Dictionary = pawns[char_id]
	var loc: StringName = pawn["location"]

	if pawns_by_loc.has(loc) and pawns_by_loc[loc].has(char_id):
		pawns_by_loc[loc].erase(char_id)

	pawns.erase(char_id)
	EventBus.npc_despawned.emit(char_id)

func get_pawn(char_id: StringName) -> Dictionary:
	return pawns.get(char_id, {})

func get_pawns_at_location(location: StringName) -> Array[StringName]:
	if pawns_by_loc.has(location):
		return pawns_by_loc[location].keys()
	return []

# --- Time-slicing (migrated from InteractionSystem.gd lines 109-137) ---

func process_time(how_much: int) -> void:
	# Update needs for all pawns
	for char_id in pawns:
		_process_pawn_needs(char_id, how_much)

	# Update cooldowns
	for char_id in react_cooldowns:
		react_cooldowns[char_id] -= how_much
		if react_cooldowns[char_id] <= 0:
			react_cooldowns.erase(char_id)

	# Time-sliced simulation (max 10 ticks of 60s each)
	var time_copy: int = how_much
	var did_simulations: int = 0
	while time_copy > 0 and did_simulations < MAX_SIMULATIONS_PER_TICK:
		var timeslice: int = mini(TICK_SIZE_SECONDS, time_copy)
		time_copy -= timeslice
		did_simulations += 1
		_process_csharp_tick(timeslice)

	# Process remaining time
	if time_copy > 0:
		_process_csharp_tick(time_copy)

# --- Needs simulation (migrated from CharacterPawn.gd lines 94-113) ---

func _process_pawn_needs(char_id: StringName, delta_seconds: int) -> void:
	if not pawns.has(char_id):
		return

	var pawn: Dictionary = pawns[char_id]
	var delta_hours: float = float(delta_seconds) / 3600.0

	# Hunger (0.2 per hour)
	pawn["hunger"] += delta_hours * 0.2

	# Social (0.5 per hour)
	pawn["social"] += delta_hours * 0.5

	# Anger (0.1 per hour, modified by personality)
	var meanness: float = _score_personality(char_id, &"mean")
	if meanness > 0.0:
		pawn["anger"] += delta_hours * 0.1 * meanness
	else:
		pawn["anger"] -= delta_hours * 0.1 * maxf(absf(meanness), 0.1)
		pawn["anger"] = maxf(pawn["anger"], 0.0)

	# Tiredness (0.05 per hour)
	pawn["tiredness"] += delta_hours * 0.05

	# Fight exhaustion recovery (2.0 per hour)
	pawn["fight_exhaustion"] -= delta_hours * 2.0
	pawn["fight_exhaustion"] = maxf(pawn["fight_exhaustion"], 0.0)

	pawn["time_since_last_work"] += delta_seconds

# --- Relationship scoring (migrated from CharacterPawn.gd lines 259-369) ---

func score_like(char_id: StringName, other_char_id: StringName) -> float:
	var affection: float = _get_affection(char_id, other_char_id)
	return maxf(0.0, affection)

func score_hate(char_id: StringName, other_char_id: StringName) -> float:
	var affection: float = _get_affection(char_id, other_char_id)
	return maxf(0.0, -affection)

func score_lust(char_id: StringName, other_char_id: StringName) -> float:
	var lust_val: float = _get_lust(char_id, other_char_id)
	return maxf(0.0, lust_val)

func affect_affection(char_id: StringName, other_char_id: StringName, how_much: float) -> void:
	var mult: float = 1.0
	if how_much > 0.0:
		var meanness: float = _score_personality(char_id, &"mean")
		mult -= meanness * 0.5
	elif how_much < 0.0:
		var meanness: float = _score_personality(char_id, &"mean")
		mult += meanness * 0.5

	# Emit relationship change event
	EventBus.npc_relationship_changed.emit(char_id, other_char_id, &"affection", how_much * mult)

func _get_affection(char_id: StringName, other_char_id: StringName) -> float:
	# Placeholder - will be connected to RelationshipSystem
	return 0.0

func _get_lust(char_id: StringName, other_char_id: StringName) -> float:
	# Placeholder - will be connected to RelationshipSystem
	return 0.0

func _score_personality(char_id: StringName, stat: StringName) -> float:
	# Placeholder - will be connected to Personality component
	return 0.0

# --- Combat helpers (migrated from CharacterPawn.gd lines 473-500) ---

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

# --- C# bridge ---

func _on_time_advanced(minutes: int) -> void:
	process_time(minutes * 60)

func _on_npc_spawned(npc_id: StringName, room_id: StringName) -> void:
	if not pawns.has(npc_id):
		spawn_pawn(npc_id, room_id)

func _on_npc_despawned(npc_id: StringName) -> void:
	despawn_pawn(npc_id)

func _process_csharp_tick(delta_minutes: float) -> void:
	if csharp_engine and csharp_engine.has_method("ProcessSimulationTick"):
		csharp_engine.ProcessSimulationTick(delta_minutes)
