# Visuals/SkeletonModifiers/JiggleModifier3D.gd
@tool
class_name JiggleModifier3D extends SkeletonModifier3D

## Verlet integration for soft body physics (tails, breasts).
## Must be a child node of Skeleton3D.

@export var bone_name: StringName
@export var stiffness: float = 0.1
@export var damping: float = 0.7
@export var gravity: Vector3 = Vector3(0, -0.05, 0)

var _bone_idx: int = -1
var _current_pos: Vector3
var _previous_pos: Vector3

func _ready() -> void:
	var skel = get_skeleton()
	if skel and bone_name:
		_bone_idx = skel.find_bone(String(bone_name))
		if _bone_idx != -1:
			var global_pose = skel.get_bone_global_pose(_bone_idx)
			_current_pos = global_pose.origin
			_previous_pos = _current_pos

func _process_modification() -> void:
	var skel: Skeleton3D = get_skeleton()
	if not skel or _bone_idx == -1:
		return

	var velocity: Vector3 = (_current_pos - _previous_pos) * damping
	_previous_pos = _current_pos

	var target_pose = skel.get_bone_pose(_bone_idx).origin
	var force: Vector3 = gravity + (target_pose - _current_pos) * stiffness

	_current_pos += velocity + force

	var pose: Transform3D = skel.get_bone_pose(_bone_idx)
	pose.origin = _current_pos
	skel.set_bone_pose(_bone_idx, pose)
