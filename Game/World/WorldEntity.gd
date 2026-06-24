extends Node2D

## MIGRATED to Godot 4 (GDScript 2.0).
## Simple map entity with tween movement.

var id: String
var loc
var floor_id

@onready var icon: Sprite2D = $Icon

func move_to_pos(target_pos: Vector2, custom_offset: bool = false, the_offset: Vector2 = Vector2.ZERO) -> void:
	var offset := Vector2(randi_range(-16, 16), randi_range(-16, 16)) if not custom_offset else the_offset
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos + offset, 0.5)

func set_texture(texture: Texture2D) -> void:
	icon.texture = texture

func set_color(color: Color) -> void:
	icon.self_modulate = color
