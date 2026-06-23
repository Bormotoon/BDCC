# Resources/ItemData.gd
class_name ItemData extends Resource

@export var id: StringName = &"unknown_item"
@export var display_name: String = "Unknown Item"
@export_multiline var description: String = ""
@export var base_price: int = 0
@export var icon: Texture2D
@export var is_stackable: bool = true
@export var max_stack: int = 99
