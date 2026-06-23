# Visuals/SkeletonModifiers/DeformModifier3D.gd
@tool
class_name DeformModifier3D extends SkeletonModifier3D

## Modifier for bone size and offset changes (Pregnancy, breast/penis size).
## Must be a child node of Skeleton3D.

@export var bone_name: StringName
@export var scale_factor: Vector3 = Vector3.ONE
@export var position_offset: Vector3 = Vector3.ZERO

var _bone_idx: int = -1

func _process_modification() -> void:
	var skel: Skeleton3D = get_skeleton()
	if not skel:
		return

	if _bone_idx == -1:
		_bone_idx = skel.find_bone(String(bone_name))

	if _bone_idx == -1:
		return

	var pose: Transform3D = skel.get_bone_pose(_bone_idx)
	var custom_transform := Transform3D(Basis().scaled(scale_factor), position_offset)

	skel.set_bone_pose(_bone_idx, pose * custom_transform)
