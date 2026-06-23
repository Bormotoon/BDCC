# Core/RegistryManager.gd
class_name RegistryManager extends Node

## Generic type-safe registry. Replaces GlobalRegistry's 3000+ lines of
## duplicated register/create/get methods with a single data-driven system.

# Each type gets its own storage: type_name -> { id -> resource_or_script }
var _registries: Dictionary = {} # StringName -> Dictionary

func _ready() -> void:
	ServiceLocator.register_service(&"RegistryManager", self)

# --- Core API ---

## Registers a single resource/script under a type
func register(type_name: StringName, id: StringName, data: Variant) -> void:
	if not _registries.has(type_name):
		_registries[type_name] = {}
	_registries[type_name][id] = data

## Gets a registered resource by type and ID
func get_entry(type_name: StringName, id: StringName) -> Variant:
	if _registries.has(type_name) and _registries[type_name].has(id):
		return _registries[type_name][id]
	push_error("RegistryManager: %s with id '%s' not found!" % [type_name, id])
	return null

## Checks if a resource is registered
func has_entry(type_name: StringName, id: StringName) -> bool:
	return _registries.has(type_name) and _registries[type_name].has(id)

## Returns all entries of a given type
func get_all(type_name: StringName) -> Dictionary:
	if _registries.has(type_name):
		return _registries[type_name]
	return {}

## Creates a new instance from a registered script (stored as script path)
func create(type_name: StringName, id: StringName) -> Variant:
	var script_path = get_entry(type_name, id)
	if script_path is String or script_path is StringName:
		var loaded = load(str(script_path))
		if loaded:
			return loaded.new()
		push_error("RegistryManager: Failed to load script for %s '%s'" % [type_name, id])
		return null
	push_error("RegistryManager: %s '%s' is not a script path" % [type_name, id])
	return null

# --- Folder scanning ---

## Scans a folder and registers all .gd scripts or .tres resources
func register_folder(type_name: StringName, folder: String, extension: String = "gd") -> int:
	var count := 0
	var dir = DirAccess.open(folder)
	if not dir:
		push_error("RegistryManager: Cannot open folder %s" % folder)
		return 0

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with("." + extension):
			var full_path = folder.path_join(file_name)
			var loaded = load(full_path)
			if loaded:
				if extension == "tres":
					# .tres resources: store directly, use resource id if available
					var res = loaded
					var id = res.get("id") if res.has_method("get") else file_name.get_basename()
					if not id:
						id = StringName(file_name.get_basename())
					register(type_name, id, res)
					count += 1
				else:
					# .gd scripts: store path for lazy instantiation
					var id = file_name.get_basename()
					register(type_name, StringName(id), full_path)
					count += 1
		file_name = dir.get_next()

	return count

# --- Convenience methods for common types (replaces GlobalRegistry boilerplate) ---

func register_scene(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"scenes", StringName(id), path)

func get_scene(id: StringName) -> Variant:
	return get_entry(&"scenes", id)

func register_character(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"characters", StringName(id), path)

func get_character(id: StringName) -> Variant:
	return get_entry(&"characters", id)

func register_item(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"items", StringName(id), path)

func get_item(id: StringName) -> Variant:
	return get_entry(&"items", id)

func register_bodypart(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"bodyparts", StringName(id), path)

func get_bodypart(id: StringName) -> Variant:
	return get_entry(&"bodyparts", id)

func register_skill(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"skills", StringName(id), path)

func get_skill(id: StringName) -> Variant:
	return get_entry(&"skills", id)

func register_perk(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"perks", StringName(id), path)

func get_perk(id: StringName) -> Variant:
	return get_entry(&"perks", id)

func register_sex_activity(path: String) -> void:
	var loaded = load(path)
	if loaded:
		var id = path.get_file().get_basename()
		register(&"sex_activities", StringName(id), path)

func get_sex_activity(id: StringName) -> Variant:
	return get_entry(&"sex_activities", id)
