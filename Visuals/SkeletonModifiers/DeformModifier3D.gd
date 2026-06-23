# Visuals/SkeletonModifiers/DeformModifier3D.gd
@tool
class_name DeformModifier3D extends SkeletonModifier3D

## Migrated from Doll3D.gd lines 348-446.
## Handles bone deformation for pregnancy, breasts, penis, balls, thighs, butt.
## Replaces Godot 3's set_bone_custom_pose with SkeletonModifier3D pipeline.

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

# --- Migrated deformation presets from Doll3D.gd ---

## Set uniform scale on a bone (migrated from setBoneScale, line 358)
func set_uniform_scale(bone: StringName, scale_val: float) -> void:
	scale_factor = Vector3(scale_val, scale_val, scale_val)
	bone_name = bone

## Set scale + offset (migrated from setBoneScaleAndOffset, line 368)
func set_scale_and_offset(bone: StringName, scale_val: float, offset: Vector3, scale_on_z: bool = false) -> void:
	scale_factor = Vector3(scale_val, scale_val, scale_val if scale_on_z else 1.0)
	position_offset = offset
	bone_name = bone

## Set 3-axis scale + offset (migrated from setBoneScale3AndOffset, line 379)
func set_scale3_and_offset(bone: StringName, scale_vec: Vector3, offset: Vector3) -> void:
	scale_factor = scale_vec
	position_offset = offset
	bone_name = bone

## Set offset only (migrated from setBoneOffset, line 390)
func set_offset_only(bone: StringName, offset: Vector3) -> void:
	scale_factor = Vector3.ONE
	position_offset = offset
	bone_name = bone

# --- High-level deformation presets (migrated from Doll3D.gd) ---

## Pregnancy deformation (migrated from setPregnancy, line 415)
func apply_pregnancy(progress: float) -> void:
	progress = minf(5.0, progress)
	var horizontal_belly_scale := 1.0 + maxf(0.0, progress - 1.0)
	var vertical_belly_scale := clampf(1.0 + maxf(0.0, progress - 1.0), 0.0, 2.0)
	scale_factor = Vector3(vertical_belly_scale, horizontal_belly_scale, horizontal_belly_scale)
	position_offset = Vector3(0.0, 0.706324, 0.0) * clampf(progress, -0.1, 1.0)

## Breast scale (migrated from setBreastsScale, line 405)
func apply_breasts(breasts_scale: float) -> void:
	var mul := 0.0
	if breasts_scale <= 1.2:
		mul = maxf(1.2 - breasts_scale, 0.0)
	if mul < 1.0:
		set_scale_and_offset(&"DeformBreasts", breasts_scale, Vector3(0.18713, 0.399727, 0.0) * mul)
	else:
		set_scale_and_offset(&"DeformBreasts", breasts_scale, Vector3(0.18713, 0.199727, 0.0) * mul)

## Butt scale (migrated from setButtScale, line 400)
func apply_butt(butt_scale: float, tail_scale: float = 1.0) -> void:
	var butt_scale_mod := 1.0 + clampf(butt_scale - 1.0, 0.0, 0.2)
	set_scale_and_offset(&"DeformButt", butt_scale * butt_scale_mod,
		Vector3(-0.109556, -0.109556, 0.0) * clampf((butt_scale - 1.0) * 3.0, 0.0, 1.0))

## Thigh thickness (migrated from setThighThickness, line 424)
func apply_thighs(progress: float) -> void:
	set_offset_only(&"DeformThigh.L", Vector3(-0.008168, 0.386037, 0.0) * progress)
	set_offset_only(&"DeformThigh.R", Vector3(-0.008168, 0.386037, 0.0) * progress)

## Penis scale (migrated from setPenisScale, line 428)
func apply_penis(penis_scale: float) -> void:
	set_uniform_scale(&"Penis", penis_scale)

## Balls scale (migrated from setBallsScale, line 436)
func apply_balls(new_scale: float) -> void:
	var offset_scale := 0.0
	if new_scale <= 1.0:
		offset_scale = 0.0
	elif new_scale <= 3.0:
		offset_scale = new_scale / 3.0
	else:
		offset_scale = 1.0
	set_scale_and_offset(&"Balls", new_scale, Vector3(0.0, 0.156431, 0.0) * offset_scale)
