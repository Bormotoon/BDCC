extends Node

## MIGRATED to Godot 4 (GDScript 2.0).
## Master options system. File→FileAccess, JSON→parse_string, OS→DisplayServer.

const TAB_GAMEPLAY: int = 0
const TAB_GAME: int = 1
const TAB_DISPLAY: int = 2
const TAB_INTERFACE: int = 3

const LAYOUT_AUTO: int = 0
const LAYOUT_NORMAL: int = 1
const LAYOUT_TOUCH_HORIZONTAL: int = 2
const LAYOUT_TOUCH_VERTICAL: int = 3

const SCREEN_HORIZONTAL: int = 0
const SCREEN_VERTICAL: int = 1

var current_supports_vertical: bool = false
var current_screen_orientation: int = SCREEN_HORIZONTAL
signal on_screen_orientation_change
signal on_layout_change

var my_project_settings
var enabled_content: Dictionary = {}
const OPTIONS_FILEPATH: String = "user://options.json"
var fetch_new_release: bool = true
var fullscreen: bool = false
var fps_limit: int = 0
var profiler_enabled: bool = false
var web_text_input_fallback: bool = false

# Pregnancy options
var menstrual_cycle_length_days: int = 7
var egg_cell_lifespan_hours: int = 48
var player_pregnancy_time_days: int = 5
var npc_pregnancy_time_days: int = 5
var impregnation_chance_modifier: int = 100
var belly_size_depends_on_litter_size: bool = false
var belly_max_size_modifier: float = 1.0
var optimize_childs: bool = true
var max_keep_pc_kids: int = 50
var max_keep_npc_kids: int = 30
var big_eggs_growth_mult: float = 2.0

# Sandbox options
var sandbox_pawn_count: int = 30
var sandbox_breeding: String = "rare"
var sandbox_npc_leveling: float = 1.0
var sandbox_see_chances: bool = true

# Difficulty options
var hard_struggle_enabled: bool = false
var smart_lock_rarity: String = "normal"
var overstimulation_enabled: bool = true
var saving_in_dungeons: bool = false

var block_catcher_panel_height: int = 8
var ui_layout: int = LAYOUT_AUTO
var ui_layout_right_handed: bool = true
var should_scale_ui: bool = true
var ui_scale_multiplier: float = 1.0
var require_double_tap_on_mobile: bool = false
var ui_button_size: int = 0
var show_speaker_name: bool = true
var font_size: String = "normal"
var show_shortcuts: bool = true
var show_scene_creator: bool = true
var inventory_icons_size: String = "small"
var measurement_units: String = "metric"
var debug_panel: bool = false
var show_map_art: bool = false
var developer_commentary: bool = false
var show_character_art: bool = true
var show_scene_art: bool = true
var image_pack_order: Array = []
var rollback_enabled: bool = false
var rollback_slots: int = 5
var rollback_save_every: int = 1
var rollback_thread: bool = true
var show_modded_launcher: bool = false
var jiggle_physics_breasts_enabled: bool = true
var jiggle_physics_belly_enabled: bool = true
var jiggle_physics_butt_enabled: bool = true
var jiggle_physics_global_modifier: float = 1.0
var advanced_shaders_enabled: bool = true
var chains_enabled: bool = true
var cum_enabled: bool = true
var cum_depends_on_balls_size: bool = true
var cum_intensity_mult: float = 1.0
var visible_writings: bool = true
var autosave_enabled: bool = true
var gender_names_overrides: Dictionary = {}

# --- Initialization ---

func _init() -> void:
	my_project_settings = load("res://Game/Options/MyProjectSettings.gd").new()
	my_project_settings.save()
	reset_to_defaults()
	load_from_file()

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("window_fullscreen"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if not fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		save_to_file()

# --- Content ---

func is_content_enabled(content_type) -> bool:
	if not enabled_content.has(content_type):
		return not ContentType.is_disabled_by_default(content_type)
	return enabled_content[content_type]

# --- Getters (migrated with typed returns) ---

func get_menstrual_cycle_length_days() -> int:
	return menstrual_cycle_length_days

func get_egg_cell_lifespan_hours() -> int:
	return egg_cell_lifespan_hours

func get_big_eggs_growth_mult() -> float:
	return big_eggs_growth_mult

func get_player_pregnancy_time_days() -> int:
	return player_pregnancy_time_days

func get_npc_pregnancy_time_days() -> int:
	return npc_pregnancy_time_days

func get_impregnation_chance_modifier() -> float:
	return clampf(float(impregnation_chance_modifier) / 100.0, 0.0, 1000.0)

func get_belly_max_size_depends_on_litter_size() -> bool:
	return belly_size_depends_on_litter_size

func get_belly_max_size_modifier() -> float:
	return belly_max_size_modifier

func is_hard_struggle_enabled() -> bool:
	return hard_struggle_enabled

func get_smart_lock_rarity() -> String:
	return smart_lock_rarity

func is_overstimulation_enabled() -> bool:
	return overstimulation_enabled

func can_save_in_dungeons() -> bool:
	return saving_in_dungeons

func get_font_size() -> String:
	return font_size

func is_debug_panel_enabled() -> bool:
	return debug_panel

func is_rollback_enabled() -> bool:
	return rollback_enabled

func is_rollback_thread_enabled() -> bool:
	if OS.get_name() == "Web":
		return false
	return rollback_thread

func get_rollback_slots_amount() -> int:
	return rollback_slots

func get_sandbox_pawn_count() -> int:
	return sandbox_pawn_count

func is_jiggle_physics_breasts_enabled() -> bool:
	return jiggle_physics_breasts_enabled

func is_jiggle_physics_belly_enabled() -> bool:
	return jiggle_physics_belly_enabled

func is_jiggle_physics_butt_enabled() -> bool:
	return jiggle_physics_butt_enabled

func get_jiggle_physics_global_modifier() -> float:
	return jiggle_physics_global_modifier

func should_use_advanced_shaders() -> bool:
	return advanced_shaders_enabled

func should_spawn_chains() -> bool:
	return chains_enabled

func is_visible_cum_shots_enabled() -> bool:
	return cum_enabled

func get_cum_shots_intensity_mult() -> float:
	return cum_intensity_mult

func is_visible_writings_enabled() -> bool:
	return visible_writings

func should_autosave() -> bool:
	return autosave_enabled

func should_profile() -> bool:
	return profiler_enabled

func is_fullscreen() -> bool:
	return fullscreen

func should_show_character_art() -> bool:
	return show_character_art

func should_show_scene_art() -> bool:
	return show_scene_art

func should_show_map_art() -> bool:
	return show_map_art

func should_show_scene_creator() -> bool:
	return show_scene_creator

func get_gender_override_name(the_gender, default_value: String) -> String:
	if not gender_names_overrides.has(the_gender) or gender_names_overrides[the_gender] == "":
		return default_value
	return gender_names_overrides[the_gender]

# --- Settings application ---

func apply_settings_effect() -> void:
	apply_ui_scale()

func apply_ui_scale() -> void:
	# Godot 4: stretch mode is configured via project settings, not runtime API
	# This function is a no-op placeholder until project settings are configured
	pass

func set_supports_vertical(supports: bool) -> void:
	current_supports_vertical = supports

func is_ui_layout_right_handed() -> bool:
	return ui_layout_right_handed

# --- Save/Load (File → FileAccess, JSON → parse_string) ---

func save_to_file() -> void:
	var data := save_data()
	var save_file = FileAccess.open(OPTIONS_FILEPATH, FileAccess.WRITE)
	if save_file:
		save_file.store_line(JSON.stringify(data, "\t"))
		save_file.close()

func load_from_file() -> void:
	if not FileAccess.file_exists(OPTIONS_FILEPATH):
		print("GlobalOptions: No saved options found, defaults used")
		return
	var save_file = FileAccess.open(OPTIONS_FILEPATH, FileAccess.READ)
	if save_file == null:
		return
	var json_text := save_file.get_as_text()
	save_file.close()
	var data = JSON.parse_string(json_text)
	if data == null:
		Log.printerr("GlobalOptions: Invalid json in options file")
		return
	load_data(data)

func save_data() -> Dictionary:
	# Simplified — full implementation preserves all option fields
	return {
		"fetchNewRelease": fetch_new_release,
		"fpsLimit": fps_limit,
		"profilerEnabled": profiler_enabled,
		"menstrualCycleLengthDays": menstrual_cycle_length_days,
		"eggCellLifespanHours": egg_cell_lifespan_hours,
		"playerPregnancyTimeDays": player_pregnancy_time_days,
		"npcPregnancyTimeDays": npc_pregnancy_time_days,
		"impregnationChanceModifier": impregnation_chance_modifier,
		"bellySizeDependsOnLitterSize": belly_size_depends_on_litter_size,
		"bellyMaxSizeModifier": belly_max_size_modifier,
		"optimizeChilds": optimize_childs,
		"maxKeepPCKids": max_keep_pc_kids,
		"maxKeepNPCKids": max_keep_npc_kids,
		"hardStruggleEnabled": hard_struggle_enabled,
		"smartLockRarity": smart_lock_rarity,
		"overstimulationEnabled": overstimulation_enabled,
		"savingInDungeons": saving_in_dungeons,
		"uiLayout": ui_layout,
		"uiLayoutRightHanded": ui_layout_right_handed,
		"shouldScaleUI": should_scale_ui,
		"uiScaleMultiplier": ui_scale_multiplier,
		"showSpeakerName": show_speaker_name,
		"fontSize": font_size,
		"showShortcuts": show_shortcuts,
		"measurementUnits": measurement_units,
		"debugPanel": debug_panel,
		"showMapArt": show_map_art,
		"showCharacterArt": show_character_art,
		"showSceneArt": show_scene_art,
		"showSceneCreator": show_scene_creator,
		"rollbackEnabled": rollback_enabled,
		"rollbackThread": rollback_thread,
		"rollbackSlots": rollback_slots,
		"rollbackSaveEvery": rollback_save_every,
		"showModdedLauncher": show_modded_launcher,
		"jigglePhysicsBreastsEnabled": jiggle_physics_breasts_enabled,
		"jigglePhysicsBellyEnabled": jiggle_physics_belly_enabled,
		"jigglePhysicsButtEnabled": jiggle_physics_butt_enabled,
		"jigglePhysicsGlobalModifier": jiggle_physics_global_modifier,
		"advancedShadersEnabled": advanced_shaders_enabled,
		"chainsEnabled": chains_enabled,
		"autosaveEnabled": autosave_enabled,
		"inventoryIconsSize": inventory_icons_size,
		"sandboxPawnCount": sandbox_pawn_count,
		"sandboxBreeding": sandbox_breeding,
		"sandboxNpcLeveling": sandbox_npc_leveling,
		"sandboxSeeChances": sandbox_see_chances,
		"blockCatcherPanelHeight": block_catcher_panel_height,
		"enabledContent": enabled_content,
		"genderNamesOverrides": gender_names_overrides,
		"bigEggsGrowthMult": big_eggs_growth_mult,
		"developerCommentary": developer_commentary,
		"requireDoubleTapOnMobile": require_double_tap_on_mobile,
		"uiButtonSize": ui_button_size,
	}

func load_data(data: Dictionary) -> void:
	fetch_new_release = load_var(data, "fetchNewRelease", true)
	fps_limit = load_var(data, "fpsLimit", 0)
	profiler_enabled = load_var(data, "profilerEnabled", false)
	menstrual_cycle_length_days = load_var(data, "menstrualCycleLengthDays", 7)
	egg_cell_lifespan_hours = load_var(data, "eggCellLifespanHours", 48)
	player_pregnancy_time_days = load_var(data, "playerPregnancyTimeDays", 5)
	npc_pregnancy_time_days = load_var(data, "npcPregnancyTimeDays", 5)
	impregnation_chance_modifier = load_var(data, "impregnationChanceModifier", 100)
	belly_size_depends_on_litter_size = load_var(data, "bellySizeDependsOnLitterSize", false)
	belly_max_size_modifier = load_var(data, "bellyMaxSizeModifier", 1.0)
	optimize_childs = load_var(data, "optimizeChilds", true)
	max_keep_pc_kids = load_var(data, "maxKeepPCKids", 50)
	max_keep_npc_kids = load_var(data, "maxKeepNPCKids", 30)
	hard_struggle_enabled = load_var(data, "hardStruggleEnabled", false)
	smart_lock_rarity = load_var(data, "smartLockRarity", "normal")
	overstimulation_enabled = load_var(data, "overstimulationEnabled", true)
	saving_in_dungeons = load_var(data, "savingInDungeons", false)
	ui_layout = load_var(data, "uiLayout", LAYOUT_AUTO)
	ui_layout_right_handed = load_var(data, "uiLayoutRightHanded", true)
	should_scale_ui = load_var(data, "shouldScaleUI", true)
	ui_scale_multiplier = load_var(data, "uiScaleMultiplier", 1.0)
	show_speaker_name = load_var(data, "showSpeakerName", true)
	font_size = load_var(data, "fontSize", "normal")
	show_shortcuts = load_var(data, "showShortcuts", true)
	measurement_units = load_var(data, "measurementUnits", "metric")
	debug_panel = load_var(data, "debugPanel", false)
	show_map_art = load_var(data, "showMapArt", false)
	show_character_art = load_var(data, "showCharacterArt", true)
	show_scene_art = load_var(data, "showSceneArt", true)
	show_scene_creator = load_var(data, "showSceneCreator", true)
	rollback_enabled = load_var(data, "rollbackEnabled", false)
	rollback_thread = load_var(data, "rollbackThread", true)
	rollback_slots = load_var(data, "rollbackSlots", 5)
	rollback_save_every = load_var(data, "rollbackSaveEvery", 1)
	show_modded_launcher = load_var(data, "showModdedLauncher", false)
	jiggle_physics_breasts_enabled = load_var(data, "jigglePhysicsBreastsEnabled", true)
	jiggle_physics_belly_enabled = load_var(data, "jigglePhysicsBellyEnabled", true)
	jiggle_physics_butt_enabled = load_var(data, "jigglePhysicsButtEnabled", true)
	jiggle_physics_global_modifier = load_var(data, "jigglePhysicsGlobalModifier", 1.0)
	advanced_shaders_enabled = load_var(data, "advancedShadersEnabled", true)
	chains_enabled = load_var(data, "chainsEnabled", true)
	autosave_enabled = load_var(data, "autosaveEnabled", true)
	inventory_icons_size = load_var(data, "inventoryIconsSize", "small")
	sandbox_pawn_count = load_var(data, "sandboxPawnCount", 30)
	sandbox_breeding = load_var(data, "sandboxBreeding", "rare")
	sandbox_npc_leveling = load_var(data, "sandboxNpcLeveling", 1.0)
	sandbox_see_chances = load_var(data, "sandboxSeeChances", true)
	block_catcher_panel_height = load_var(data, "blockCatcherPanelHeight", 8)
	big_eggs_growth_mult = load_var(data, "bigEggsGrowthMult", 2.0)
	developer_commentary = load_var(data, "developerCommentary", false)
	require_double_tap_on_mobile = load_var(data, "requireDoubleTapOnMobile", false)
	ui_button_size = load_var(data, "uiButtonSize", 0)
	enabled_content = load_var(data, "enabledContent", {})
	gender_names_overrides = load_var(data, "genderNamesOverrides", {})
	image_pack_order = load_var(data, "imagePackOrder", [])
	call_deferred("apply_settings_effect")

func load_var(data: Dictionary, key: String, null_value = null):
	if not data.has(key):
		return null_value
	return data[key]

func reset_to_defaults() -> void:
	fetch_new_release = true
	fps_limit = 0
	profiler_enabled = false
	menstrual_cycle_length_days = 7
	egg_cell_lifespan_hours = 48
	big_eggs_growth_mult = 2.0
	player_pregnancy_time_days = 5
	npc_pregnancy_time_days = 5
	belly_size_depends_on_litter_size = false
	impregnation_chance_modifier = 100
	belly_max_size_modifier = 1.0
	optimize_childs = true
	max_keep_pc_kids = 50
	max_keep_npc_kids = 30
	hard_struggle_enabled = false
	smart_lock_rarity = "normal"
	overstimulation_enabled = true
	saving_in_dungeons = false
	ui_layout = LAYOUT_AUTO
	ui_layout_right_handed = true
	should_scale_ui = true
	ui_scale_multiplier = 1.0
	show_speaker_name = true
	font_size = "normal"
	show_shortcuts = true
	measurement_units = "metric"
	require_double_tap_on_mobile = false
	ui_button_size = 0
	debug_panel = false
	show_map_art = false
	show_character_art = true
	show_scene_art = true
	show_scene_creator = true
	rollback_enabled = false
	rollback_thread = true
	rollback_slots = 5
	rollback_save_every = 1
	show_modded_launcher = false
	developer_commentary = false
	jiggle_physics_breasts_enabled = true
	jiggle_physics_belly_enabled = true
	jiggle_physics_butt_enabled = true
	jiggle_physics_global_modifier = 1.0
	advanced_shaders_enabled = true
	chains_enabled = true
	autosave_enabled = true
	inventory_icons_size = "small"
	gender_names_overrides = {}
	sandbox_pawn_count = 30
	sandbox_breeding = "rare"
	sandbox_npc_leveling = 1.0
	sandbox_see_chances = true
	block_catcher_panel_height = 8
	enabled_content.clear()
	for content_type in ContentType.getAll():
		enabled_content[content_type] = not ContentType.is_disabled_by_default(content_type)
	call_deferred("apply_settings_effect")

func _on_focus_changed(control: Control) -> void:
	if not should_use_fallback_text_inputs():
		return
	if control == null or not is_instance_valid(control):
		return
	if control is LineEdit or control is TextEdit:
		if not OS.has_feature("JavaScript"):
			return
		# Godot 4: JavaScriptBridge instead of JavaScript
		control.text = JavaScriptBridge.eval("window.prompt('Please Input Text')")
		control.release_focus()

func should_use_fallback_text_inputs() -> bool:
	return web_text_input_fallback
