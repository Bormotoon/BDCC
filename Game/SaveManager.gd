extends Node

## MIGRATED to Godot 4 (GDScript 2.0).
## Save/load system. File→FileAccess, DirAccess→DirAccess, JSON→JSON.parse_string.

var current_savefile_version: int = 2
var max_backup_quicksaves: int = 3
var loaded_savefile_version: int = -1
var save_info_cache: Dictionary = {}
var is_saving_cache: bool = false
var is_auto_saving: bool = false

const SAVE_INFO_CACHE_PATH: String = "user://saveInfoCache.json"

func _ready() -> void:
	_load_save_info_cache_from_file()

# ==========================================
# SAVE/LOAD DATA (lines 13-66)
# ==========================================

func save_data() -> Dictionary:
	var data := {
		"savefile_version": current_savefile_version,
		"currentUniqueID_DONT_TOUCH": GlobalRegistry.currentUniqueID,
		"currentChildUniqueID_DONT_TOUCH": GlobalRegistry.currentChildUniqueID,
		"currentNPCUniqueID_DONT_TOUCH": GlobalRegistry.currentNPCUniqueID,
		"currentTFID_DONT_TOUCH": GlobalRegistry.currentTFID,
		"currentSave": GlobalRegistry.currentSave,
	}
	data["player"] = GM.main.get_original_pc().saveData()
	if GM.main.get_overridden_pc() != null:
		data["player_override"] = GM.main.get_overridden_pc().saveData()
	data["characters"] = GM.main.save_characters_data()
	data["dynamicCharacters"] = GM.main.save_dynamic_characters_data()
	data["main"] = GM.main.save_data()
	return data

func load_data(data: Dictionary) -> void:
	if not data.has("savefile_version"):
		Log.err("Save file doesn't have a version")
		return
	if data["savefile_version"] > current_savefile_version:
		Log.err("Savefile not supported. Version: " + str(data["savefile_version"]))
		return
	loaded_savefile_version = data["savefile_version"]
	GlobalRegistry.currentUniqueID = SAVE.load_var(data, "currentUniqueID_DONT_TOUCH", 0)
	GlobalRegistry.currentChildUniqueID = SAVE.load_var(data, "currentChildUniqueID_DONT_TOUCH", 0)
	GlobalRegistry.currentNPCUniqueID = SAVE.load_var(data, "currentNPCUniqueID_DONT_TOUCH", 0)
	GlobalRegistry.currentTFID = SAVE.load_var(data, "currentTFID_DONT_TOUCH", 0)
	GlobalRegistry.currentSave = SAVE.load_var(data, "currentSave", 1)
	GM.main.get_original_pc().loadData(data["player"])
	if GM.main.get_overridden_pc() != null:
		GM.main.clear_override_pc()
	if data.has("player_override") and data["player_override"] != null:
		GM.main.override_pc()
		GM.main.get_overridden_pc().loadData(data["player_override"])
	GM.main.load_dynamic_characters_data(SAVE.load_var(data, "dynamicCharacters", {}))
	GM.main.load_data(SAVE.load_var(data, "main", {}))
	GM.main.update_static_characters()
	GM.main.load_characters_data(SAVE.load_var(data, "characters", {}))
	GM.main.loading_savefile_finished()
	GM.ui.loading_savefile_finished()

func can_save() -> bool:
	return GM.main.can_save()

# ==========================================
# FILE OPERATIONS (File → FileAccess, DirAccess → DirAccess)
# ==========================================

## Line 71-84: saveGame with FileAccess
func save_game(path: String) -> void:
	if not can_save():
		Log.err("Can't save")
		return
	var save_data_dict := save_data()
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	if save_file == null:
		Log.err("Failed to open save file: " + path)
		return
	save_file.store_line(JSON.stringify(save_data_dict, "\t"))
	save_file.close()
	_invalidate_cached_save_info_by_path(path)

## Line 131-137
func save_game_from_text(filepath: String, save_data_string) -> void:
	var save_file = FileAccess.open("user://saves/" + filepath.get_file().get_basename() + ".save", FileAccess.WRITE)
	if save_file:
		save_file.store_line(save_data_string)
		save_file.close()
	_invalidate_cached_save_info_by_path(filepath)

## Line 146-162: loadGame with FileAccess + JSON.parse_string
func load_game(path: String) -> void:
	if not FileAccess.file_exists(path):
		Log.error("Save file not found: " + str(path))
		return
	var save_file = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		return
	var json_text := save_file.get_as_text()
	save_file.close()
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		assert(false, "Bad save file " + str(path))
		return
	load_data(json_result)

## Line 164-175: switchToGameAndLoad with await
func switch_to_game_and_load(path: String) -> void:
	get_tree().change_scene_to_file("res://Game/MainScene.tscn")
	await get_tree().process_frame
	call_deferred("load_game", path)

func switch_to_game_and_resume_latest_save() -> void:
	var saves: Array = get_saves_sorted_by_date()
	if saves.is_empty():
		return
	get_tree().change_scene_to_file("res://Game/MainScene.tscn")
	await get_tree().process_frame
	call_deferred("load_game", saves[0])

## Line 212-216: canQuickLoad
func can_quick_load() -> bool:
	return FileAccess.file_exists("user://saves/quicksave.save")

## Line 218-239: recursiveQuickSaveMakeBackup with DirAccess
func _recursive_quick_save_make_backup(current_i: int = 1) -> void:
	var quick_save_name := "quicksave"
	if current_i > 1:
		quick_save_name += " backup" + str(current_i)
	var quick_save_fullname := "user://saves/" + quick_save_name + ".save"
	var dir := DirAccess.open("user://saves/")
	if dir == null:
		return
	if dir.file_exists(quick_save_fullname):
		_recursive_quick_save_make_backup(current_i + 1)
		if current_i >= max_backup_quicksaves:
			dir.remove_file(quick_save_fullname)
			_invalidate_cached_save_info_by_path(quick_save_fullname)
			return
		var new_name := "quicksave backup" + str(current_i + 1)
		var new_fullname := "user://saves/" + new_name + ".save"
		dir.rename(quick_save_fullname, new_fullname)
		_invalidate_cached_save_info_by_path(quick_save_fullname)

func make_quick_save() -> void:
	_recursive_quick_save_make_backup()
	save_game("user://saves/quicksave.save")

func load_quick_save() -> void:
	load_game("user://saves/quicksave.save")

## Line 249-265: triggerAutosave with await
func trigger_autosave() -> void:
	if is_auto_saving:
		return
	if not OPTIONS.should_autosave():
		return
	is_auto_saving = true
	await get_tree().create_timer(0.1).timeout
	if GM.main == null or GM.pc == null:
		is_auto_saving = false
		return
	save_game("user://saves/autosave_" + Util.strip_bad_filename_characters(GM.pc.getName()) + ".save")
	if GM.ui != null:
		GM.ui.say("\n\n[center][i]Autosave completed[/i][/center]\n")
	is_auto_saving = false

## Line 267-286: getAllSavePathsInFolder with DirAccess
func get_all_save_paths_in_folder(path: String = "user://saves/") -> Array:
	var saves: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		return []
	dir.list_dir_begin()
	var subpath := dir.get_next()
	while not subpath.is_empty():
		if dir.current_is_dir():
			subpath = dir.get_next()
			continue
		if subpath.get_extension() == "save":
			saves.append(path.path_join(subpath))
		subpath = dir.get_next()
	return saves

func get_all_save_paths() -> Array:
	var saves := get_all_save_paths_in_folder("user://saves/")
	if OS.get_name() == "Android":
		var external_dir: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		var android_saves_dir := external_dir.path_join("BDCCSaves")
		saves.append_array(get_all_save_paths_in_folder(android_saves_dir))
	return saves

## Line 305-317: getSavesSortedByDate with callable
func get_saves_sorted_by_date() -> Array:
	var saves_paths := get_all_save_paths()
	var sorted_save_paths: Array = []
	for path in saves_paths:
		var file_mod_time = Util.get_file_modified_time(path)
		sorted_save_paths.append([path, file_mod_time])
	sorted_save_paths.sort_custom(func(a, b): return a[1] > b[1])
	var result: Array = []
	for sorted_data in sorted_save_paths:
		result.append(sorted_data[0])
	return result

## Line 319-364: loadGameInformationFromSaveRaw
func _load_game_information_from_save_raw(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var save_file = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		return {}
	var json_text := save_file.get_as_text()
	save_file.close()
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		return {}
	var data = json_result
	if not data.has("savefile_version"):
		return {}
	if data["savefile_version"] > current_savefile_version:
		return {}
	return {
		"gamename": data["player"]["gamename"],
		"credits": data["player"]["credits"],
		"location": data["player"]["location"],
		"currentDay": data["main"]["currentDay"],
		"timeOfDay": data["main"]["timeOfDay"],
	}

func load_game_information_from_save(path: String) -> Dictionary:
	if save_info_cache.has(path):
		return save_info_cache[path]
	var info := _load_game_information_from_save_raw(path)
	if not info.is_empty():
		save_info_cache[path] = info
		_trigger_save_cache_save()
	return info

## Line 88-106: loadSaveInfoCacheFromFile
func _load_save_info_cache_from_file() -> void:
	if not FileAccess.file_exists(SAVE_INFO_CACHE_PATH):
		return
	var save_file = FileAccess.open(SAVE_INFO_CACHE_PATH, FileAccess.READ)
	if save_file == null:
		return
	var json_text := save_file.get_as_text()
	save_file.close()
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		Log.err("Save info cache is not valid json")
		return
	var cache_data: Dictionary = json_result
	if not cache_data.has("version") or not cache_data.has("saves"):
		Log.err("Save info cache is not valid")
		return
	if cache_data["version"] != 1:
		Log.err("Unsupported save info cache version")
		return
	save_info_cache = cache_data["saves"]

## Line 108-115
func _save_info_cache_to_file() -> void:
	var save_file = FileAccess.open(SAVE_INFO_CACHE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_line(JSON.stringify({"version": 1, "saves": save_info_cache}, "\t"))
		save_file.close()
	is_saving_cache = false

func _trigger_save_cache_save() -> void:
	if is_saving_cache:
		return
	is_saving_cache = true
	call_deferred("_save_info_cache_to_file")

func _invalidate_cached_save_info_by_path(path: String) -> void:
	if save_info_cache.has(path):
		save_info_cache.erase(path)
	_trigger_save_cache_save()

## Line 195-210: loadVar — safe dictionary access
func load_var(data, key: String, null_value = null):
	if not (data is Dictionary):
		Log.err("Warning: Loaded key " + key + " is not a dictionary")
		return null_value
	if not data.has(key):
		return null_value
	return data[key]

## Line 366-369: deleteSave
func delete_save(path: String) -> void:
	var dir := DirAccess.open("user://saves/")
	if dir:
		dir.remove_file(path)
	_invalidate_cached_save_info_by_path(path)

func load_var_method(data, key: String, null_value = null):
	return load_var(data, key, null_value)
