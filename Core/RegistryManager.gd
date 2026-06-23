# Core/RegistryManager.gd
class_name RegistryManager extends Node

var items: Dictionary = {} # StringName -> ItemData

func _ready() -> void:
	ServiceLocator.register_service(&"RegistryManager", self)
	_load_all_items("res://Resources/Items/")

func get_item(item_id: StringName) -> ItemData:
	if items.has(item_id):
		return items[item_id]
	push_error("RegistryManager: Item %s not found!" % item_id)
	return null

func _load_all_items(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load(path + file_name) as ItemData
				if res:
					items[res.id] = res
			file_name = dir.get_next()
