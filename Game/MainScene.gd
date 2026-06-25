extends Control
class_name MainScene

## MIGRATED to Godot 4 (GDScript 2.0).
## Central game orchestrator. All save/load, time, flags, character management.
## GM.* references preserved for backward compatibility.

# --- Node references (onready → @onready) ---
@onready var characters_node: Node = $Characters
@onready var dynamic_characters_node: Node = $DynamicCharacters

# --- Core state ---
var game_ui: GameUI
var scene_stack: Array = []
var messages: Array = []
var log_messages: Array = []
var current_day: int = 0
var time_of_day: int = 6 * 60 * 60 # seconds since 00:00

# --- Flags (3 namespaces) ---
var flags: Dictionary = {}
var flags_cache = null
var module_flags: Dictionary = {}
var datapack_flags: Dictionary = {}

# --- Character management ---
var player_scene = preload("res://Player/Player.gd")
var overridden_player_scene = preload("res://Player/OverriddenPlayer.gd")
var overriden_pc
var original_pc
var static_characters: Dictionary = {}
var characters_to_update: Array = []
var dynamic_characters: Dictionary = {}
var dynamic_characters_pools: Dictionary = {}

# --- Datapacks ---
var loaded_datapacks: Dictionary = {}
var datapack_characters: Dictionary = {}

# --- Subsystems (instantiated inline) ---
var IS: InteractionSystem = InteractionSystem.new()
var RS: RelationshipSystem = RelationshipSystem.new()
var WHS: WorldHistory = WorldHistory.new()
var SAB: SlaveAuctionBidders = SlaveAuctionBidders.new()
var SCI: Science = Science.new()
var DrugDenRun: DrugDen
var PS: PlayerSlaveryBase
var PSH: PlayerSlaveryHolder = PlayerSlaveryHolder.new()
var RCS: RecruitSystem = RecruitSystem.new()

# --- Other state ---
var room_memories: Dictionary = {}
var looted_rooms: Dictionary = {}
var rollbacker: Rollbacker
var encounter_settings: EncounterSettings
var allow_execute_once: bool = false

# --- Signals ---
signal time_passed(seconds_passed: int)
signal save_loading_finished

# Backward-compatible aliases
var currentDay: int:
	get: return current_day
var timeOfDay: int:
	get: return time_of_day
var sceneStack: Array:
	get: return scene_stack
var staticCharacters: Dictionary:
	get: return static_characters
var dynamicCharacters: Dictionary:
	get: return dynamic_characters
var dynamicCharactersPools: Dictionary:
	get: return dynamic_characters_pools
var loadedDatapacks: Dictionary:
	get: return loaded_datapacks
var datapackCharacters: Dictionary:
	get: return datapack_characters
var encounterSettings:
	get: return encounter_settings
var moduleFlags: Dictionary:
	get: return module_flags
var datapackFlags: Dictionary:
	get: return datapack_flags
var roomMemories: Dictionary:
	get: return room_memories
var lootedRooms: Dictionary:
	get: return looted_rooms

# ==========================================
# INITIALIZATION
# ==========================================

func _init() -> void:
	rollbacker = Rollbacker.new()
	flags_cache = Flag.getFlags()
	encounter_settings = EncounterSettings.new()

func _ready() -> void:
	GM.main = self
	GM.register_services()
	create_static_characters()

func _exit_tree() -> void:
	rollbacker.onDestroy()
	GM.main = null

# ==========================================
# PC OVERRIDE (lines 55-86)
# ==========================================

func override_pc() -> void:
	if overriden_pc != null:
		assert(false, "Trying to override player twice!")
		return
	Util.remove_all_signals(original_pc)
	var new_pc = overridden_player_scene.new()
	overriden_pc = new_pc
	GM.pc = new_pc
	_connect_signals_to_pc(new_pc)
	add_child(new_pc)

func clear_override_pc() -> void:
	if overriden_pc == null:
		assert(false, "Player wasn't overridden when we are trying to clear it")
		return
	overriden_pc.queue_free()
	overriden_pc = null
	GM.pc = original_pc
	_connect_signals_to_pc(original_pc)

func get_current_pc():
	return overriden_pc if overriden_pc != null else original_pc

func _connect_signals_to_pc(who) -> void:
	who.level_changed.connect(_on_player_level_changed)
	who.orifice_become_more_loose.connect(_on_player_orifice_become_more_loose)
	who.exchanged_cum_during_rubbing.connect(_on_player_exchanged_cum_during_rubbing)
	who.skill_level_changed.connect(_on_player_skill_level_changed)
	who.stat_changed.connect(game_ui._on_player_stat_changed)

# ==========================================
# CHARACTER MANAGEMENT (lines 101-215)
# ==========================================

func create_static_characters() -> void:
	Util.delete_children(characters_node)
	static_characters.clear()
	for char_id in GlobalRegistry.get_character_classes():
		var character_object = GlobalRegistry.create_static_character(char_id)
		static_characters[character_object.id] = character_object
		characters_node.add_child(character_object)

func get_character(char_id: String):
	if char_id == "pc":
		return GM.pc
	if static_characters.has(char_id):
		return static_characters[char_id]
	if dynamic_characters.has(char_id):
		return dynamic_characters[char_id]
	return null

func add_dynamic_character(character, print_debug: bool = true) -> void:
	if not character.is_dynamic_character():
		assert(false, "addDynamicCharacter() Received a non-dynamic character")
	var new_char_id = character.get_id()
	if new_char_id == null or new_char_id == "" or new_char_id == "errorerror":
		character.id = generate_character_id()
	if dynamic_characters.has(new_char_id):
		remove_dynamic_character(new_char_id)
	dynamic_characters[new_char_id] = character
	dynamic_characters_node.add_child(character)
	if print_debug:
		Log.msg("addDynamicCharacter(): Adding " + str(new_char_id))

func remove_dynamic_character(character_id, print_debug: bool = true) -> void:
	if not (character_id is String):
		character_id = character_id.get_id()
	if not dynamic_characters.has(character_id):
		return
	var character = dynamic_characters[character_id]
	dynamic_characters.erase(character_id)
	if is_instance_valid(character):
		if character.is_in_group("dynamicCharacters"):
			character.remove_from_group("dynamicCharacters")
		character.queue_free()
	# Remove from pools
	for pool_id in dynamic_characters_pools:
		dynamic_characters_pools[pool_id].erase(character_id)

func generate_character_id() -> String:
	return "dyn" + str(randi())

# ==========================================
# SAVE/LOAD (lines 485-615) — EXACT migration
# ==========================================

func save_data() -> Dictionary:
	var data := {}
	data["messages"] = messages
	data["timeOfDay"] = time_of_day
	data["currentDay"] = current_day
	data["flags"] = flags
	data["moduleFlags"] = module_flags
	data["datapackFlags"] = datapack_flags
	data["EventSystem"] = GM.ES.saveData()
	data["ChildSystem"] = GM.CS.saveData()
	data["logMessages"] = log_messages
	data["roomMemories"] = room_memories
	data["lootedRooms"] = looted_rooms
	data["world"] = GM.world.saveData()
	data["dynamicCharactersPools"] = dynamic_characters_pools
	data["encounterSettings"] = encounter_settings.saveData()
	data["gameExtenders"] = GM.GES.saveData()
	data["loadedDatapacks"] = loaded_datapacks
	data["datapackCharacters"] = datapack_characters
	data["interactionSystem"] = IS.saveData()
	data["relationshipSystem"] = RS.saveData()
	data["auctionBidders"] = SAB.saveData()
	data["science"] = SCI.saveData()
	data["playerSlaveryHolder"] = PSH.saveData()
	data["drugDen"] = DrugDenRun.saveData() if DrugDenRun != null else null
	if PS:
		data["playerSlavery"] = {"id": PS.id, "data": PS.saveData()}
	else:
		data["playerSlavery"] = null
	data["scenes"] = []
	for scene in scene_stack:
		data["scenes"].append({"id": scene.sceneID, "sceneData": scene.saveData()})
	return data

func load_data(data: Dictionary) -> void:
	if SAVE.is_updating_from_save_version(1):
		SaveConversion.fix_flags_from_version_1(self, data)
	messages = SAVE.load_var(data, "messages", [])
	time_of_day = SAVE.load_var(data, "timeOfDay", 6 * 60 * 60)
	current_day = SAVE.load_var(data, "currentDay", 0)
	flags = SAVE.load_var(data, "flags", {})
	module_flags = SAVE.load_var(data, "moduleFlags", {})
	datapack_flags = SAVE.load_var(data, "datapackFlags", {})
	GM.ES.loadData(SAVE.load_var(data, "EventSystem", {}))
	GM.CS.loadData(SAVE.load_var(data, "ChildSystem", {}))
	log_messages = SAVE.load_var(data, "logMessages", [])
	room_memories = SAVE.load_var(data, "roomMemories", {})
	looted_rooms = SAVE.load_var(data, "lootedRooms", {})
	dynamic_characters_pools = SAVE.load_var(data, "dynamicCharactersPools", {})
	encounter_settings.loadData(SAVE.load_var(data, "encounterSettings", {}))
	GM.GES.loadData(SAVE.load_var(data, "gameExtenders", {}))
	loaded_datapacks = SAVE.load_var(data, "loadedDatapacks", {})
	IS.loadData(SAVE.load_var(data, "interactionSystem", {}))
	RS.loadData(SAVE.load_var(data, "relationshipSystem", {}))
	SAB.loadData(SAVE.load_var(data, "auctionBidders", {}))
	SCI.loadData(SAVE.load_var(data, "science", {}))
	PSH.loadData(SAVE.load_var(data, "playerSlaveryHolder", {}))
	# Restore scene stack
	for scene in scene_stack:
		scene.queue_free()
	scene_stack = []
	for scene_data in SAVE.load_var(data, "scenes", []):
		var id = SAVE.load_var(scene_data, "id", "error")
		var scene = GlobalRegistry.create_scene(id)
		add_child(scene)
		scene_stack.append(scene)
		scene.loadData(SAVE.load_var(scene_data, "sceneData", {}))
	IS.reset_extra_text()
	# Restore DrugDen
	if data.has("drugDen") and data["drugDen"] is Dictionary:
		DrugDenRun = DrugDen.new()
		DrugDenRun.loadData(SAVE.load_var(data, "drugDen", {}))
	else:
		DrugDenRun = null
	# Restore PlayerSlavery
	if data.has("playerSlavery") and data["playerSlavery"] is Dictionary:
		var the_slavery_id: String = SAVE.load_var(data["playerSlavery"], "id", "")
		var the_slavery_def = GlobalRegistry.get_player_slavery_def(the_slavery_id)
		if the_slavery_def:
			PS = the_slavery_def.create_slavery()
			if PS:
				PS.loadData(SAVE.load_var(data["playerSlavery"], "data", {}))
			else:
				PS = null
		else:
			PS = null
	else:
		PS = null
	GM.world.loadData(SAVE.load_var(data, "world", {}))
	apply_all_world_edits()

# ==========================================
# TIME PROCESSING (lines 719-827) — EXACT formulas
# ==========================================

## Line 719-726
func process_time(seconds: int) -> void:
	seconds = int(roundf(float(seconds)))
	time_of_day += seconds
	_do_time_process(seconds)

## Line 727-772: core time loop with 1-hour chunks
func _do_time_process(seconds: int) -> void:
	if seconds < 0:
		Log.err("doTimeProcess() called with negative seconds: " + str(seconds))
		return

	if not PS:
		IS.process_time(seconds)
		SCI.process_time(seconds)

	# Split long times into 1-hour chunks (line 741-759)
	var copy_seconds := seconds
	while copy_seconds > 0:
		var clipped_seconds := mini(60 * 60, copy_seconds)
		GM.pc.process_time(clipped_seconds)
		for char_id in characters_to_update:
			var character = get_character(char_id)
			if character != null:
				character.process_time(clipped_seconds)
				character.last_updated_second = time_of_day
				character.last_updated_day = current_day
		copy_seconds -= clipped_seconds

	GM.ui.on_time_passed(seconds)

	# Hour boundary detection (lines 764-769)
	var old_hours := int((time_of_day - seconds) / 60.0 / 60.0)
	var new_hours := int(time_of_day / 60.0 / 60.0)
	var hours_passed_count := new_hours - old_hours
	if hours_passed_count > 0:
		_hours_passed(hours_passed_count)

	time_passed.emit(seconds)

## Line 774-788
func _hours_passed(how_much: int) -> void:
	GM.pc.hours_passed(how_much)
	for char_id in characters_to_update:
		var character = get_character(char_id)
		if character != null:
			character.hours_passed(how_much)
	if dynamic_characters_pools.has(CharacterPool.Slaves):
		for slave_id in dynamic_characters_pools[CharacterPool.Slaves]:
			var character = get_character(slave_id)
			if character != null and character.is_slave_to_player():
				character.get_npc_slavery().hours_passed(how_much)
	RS.hours_passed(how_much)

## Line 800-827: startNewDay
func start_new_day() -> int:
	IS.before_new_day()
	GM.CS.optimize()
	if time_of_day > get_time_cap():
		time_of_day = get_time_cap()
	var new_time := 6 * 60 * 60
	var time_diff := 24 * 60 * 60 - time_of_day + new_time
	current_day += 1
	time_of_day = new_time
	Flag.reset_flags_on_new_day()
	_room_memories_process_day()
	_npc_slavery_on_new_day()
	_do_time_process(time_diff)
	WHS.on_new_day()
	IS.after_new_day()
	SCI.on_new_day()
	RS.on_new_day()
	SAVE.trigger_autosave()
	return time_diff

# ==========================================
# FLAG MANAGEMENT (lines 860-1016)
# ==========================================

## Line 860-883: routes "ModuleID.FlagID" and "DatapackID:FlagID"
func set_flag(flag_id: String, value) -> void:
	var split_data := Util.split_on_first(flag_id, ".")
	if split_data.size() > 1:
		set_module_flag(split_data[0], split_data[1], value)
		return
	var split_data2 := Util.split_on_first(flag_id, ":")
	if split_data2.size() > 1:
		set_datapack_flag(split_data2[0], split_data2[1], value)
		return
	if not flags_cache.has(flag_id):
		Log.err("setFlag(): Unknown flag: " + str(flag_id))
		return
	if "type" in flags_cache[flag_id]:
		var flag_type = flags_cache[flag_id]["type"]
		if not FlagType.is_correct_type(flag_type, value):
			Log.err("setFlag(): Wrong type for flag " + str(flag_id))
			return
	flags[flag_id] = value

func get_flag(flag_id: String, default_value = null):
	if flags.has(flag_id):
		return flags[flag_id]
	return default_value

func has_flag(flag_id: String) -> bool:
	return flags.has(flag_id)

func clear_flag(flag_id: String) -> void:
	flags.erase(flag_id)

func increase_flag(flag_id: String, amount = 1) -> void:
	var current = get_flag(flag_id, 0)
	if current is int:
		set_flag(flag_id, current + amount)
	elif current is float:
		set_flag(flag_id, current + float(amount))

func set_module_flag(module_id: String, flag_id: String, value) -> void:
	var modules = GlobalRegistry.get_modules()
	if not modules.has(module_id):
		Log.err("set_module_flag(): Module " + str(module_id) + " doesn't exist")
		return
	var module: Module = modules[module_id]
	var module_flags_cache = module.get_flags_cache()
	if not module_flags_cache.has(flag_id):
		Log.err("set_module_flag(): Unknown flag: " + str(flag_id))
		return
	if "type" in module_flags_cache[flag_id]:
		var flag_type = module_flags_cache[flag_id]["type"]
		if not FlagType.is_correct_type(flag_type, value):
			Log.err("set_module_flag(): Wrong type for flag " + str(flag_id))
			return
	if not module_flags.has(module_id):
		module_flags[module_id] = {}
	module_flags[module_id][flag_id] = value

func get_module_flag(module_id: String, flag_id: String, default_value = null):
	if module_flags.has(module_id) and module_flags[module_id].has(flag_id):
		return module_flags[module_id][flag_id]
	return default_value

func set_datapack_flag(datapack_id: String, flag_id: String, value) -> void:
	if not loaded_datapacks.has(datapack_id):
		Log.err("set_datapack_flag(): Datapack " + str(datapack_id) + " not loaded")
		return
	var datapack: Datapack = GlobalRegistry.get_datapack(datapack_id)
	if datapack == null:
		Log.err("set_datapack_flag(): Datapack " + str(datapack_id) + " not found")
		return
	if not datapack.flags.has(flag_id):
		Log.err("set_datapack_flag(): Unknown flag: " + str(flag_id))
		return
	if not datapack_flags.has(datapack_id):
		datapack_flags[datapack_id] = {}
	datapack_flags[datapack_id][flag_id] = value

# ==========================================
# HELPER METHODS
# ==========================================

func get_time_cap() -> int:
	return 24 * 60 * 60 - 1

func get_visible_time() -> String:
	var text := ""
	if time_of_day >= get_time_cap():
		text = "Night time"
	else:
		text = Util.get_time_string_hhmm(time_of_day)
	text += ", day " + str(current_day)
	return text

func get_time() -> int:
	return time_of_day

func get_days() -> int:
	return current_day

func is_in_dungeon() -> bool:
	return DrugDenRun != null

func add_message(text: String) -> void:
	messages.append(text)

func add_log_message(category: String, text: String) -> void:
	log_messages.append({"category": category, "text": text})

func apply_all_world_edits() -> void:
	var world_edits = GlobalRegistry.get_world_edits()
	for world_edit_id in world_edits:
		var world_edit = world_edits[world_edit_id]
		world_edit.apply(GM.world)

func _room_memories_process_day() -> void:
	for room_id in room_memories.keys():
		var data = room_memories[room_id]
		data["days"] -= 1
		if data["days"] <= 0:
			room_memories.erase(room_id)

func _npc_slavery_on_new_day() -> void:
	for slave_id in get_dynamic_character_ids_from_pool(CharacterPool.Slaves):
		var character = get_character(slave_id)
		if character == null:
			continue
		if character.is_slave_to_player():
			character.get_npc_slavery().on_new_day()

func get_dynamic_character_ids_from_pool(pool_id: StringName) -> Array:
	return dynamic_characters_pools.get(pool_id, [])

func can_show_pawns() -> bool:
	return true

# Signal handlers (placeholders — full logic in original)
func _on_player_level_changed() -> void:
	pass
func _on_player_orifice_become_more_loose(_n, _o, _v) -> void:
	pass
func _on_player_exchanged_cum_during_rubbing(_s, _r) -> void:
	pass
func _on_player_skill_level_changed(_s) -> void:
	pass

var _next_unique_scene_id: int = 0

func run_scene(id: String, args: Array = [], parent_scene_unique_id: int = -1, tag: String = ""):
	var scene = GlobalRegistry.create_scene(id)
	assert(scene != null, "SCENE WITH ID " + str(id) + " IS NOT FOUND.")
	_next_unique_scene_id += 1
	scene.unique_scene_id = _next_unique_scene_id
	scene.scene_tag = tag
	if parent_scene_unique_id >= 0:
		scene.parent_scene_unique_id = parent_scene_unique_id
	add_child(scene)
	scene_stack.append(scene)
	scene.init_scene(args)
	return scene
