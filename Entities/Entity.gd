# Entities/Entity.gd
class_name Entity extends Node3D

@export var entity_id: StringName = &"npc_unknown"

## Simple component cache for fast access (O(1))
var _components: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is Component:
			_components[child.name] = child

## Gets a component by its node name
func get_component(component_name: StringName) -> Component:
	if _components.has(component_name):
		return _components[component_name]
	return null

## Checks if a component exists
func has_component(component_name: StringName) -> bool:
	return _components.has(component_name)
