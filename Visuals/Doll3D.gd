# Visuals/Doll3D.gd
class_name Doll3D extends Node3D

## Root node of the character 3D doll.
## In Godot 4 it is minimal. All the magic happens in SkeletonModifier3D.

@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

var _deform_modifiers: Dictionary = {} # StringName -> DeformModifier3D

func _ready() -> void:
	if skeleton:
		for child in skeleton.get_children():
			if child is DeformModifier3D:
				_deform_modifiers[child.bone_name] = child

## Sets a deformation parameter (e.g. breast size "DeformBreasts")
func set_deformation(bone_name: StringName, scale: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
	if _deform_modifiers.has(bone_name):
		var mod: DeformModifier3D = _deform_modifiers[bone_name]
		mod.scale_factor = scale
		mod.position_offset = offset
	else:
		push_warning("Doll3D: Modifier for bone %s not found!" % bone_name)

## Plays an animation (wraps AnimationPlayer)
func play_animation(anim_name: StringName) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(String(anim_name))
