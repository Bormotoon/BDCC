# Components/Component.gd
class_name Component extends Node

## Reference to the parent entity
var entity: Node

func _ready() -> void:
	entity = get_parent()
	assert(entity != null and entity.has_method("get_component"), "Component must be a child of an Entity!")
