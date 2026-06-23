# Visuals/Doll3D.gd
class_name Doll3D extends Node3D

## Migrated from Player/Player3D/Doll3D.gd (963 lines).
## Now a thin orchestrator that delegates to components and modifiers.
## Old methods kept for backward compatibility — they delegate to DollPartManager and DeformModifier3D.

@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

var _deform_modifiers: Dictionary = {} # StringName -> DeformModifier3D
var _part_manager: DollPartManager = null

# State management (migrated from Doll3D.gd lines 4-22)
var state: Dictionary = {}
var temporary_state: Dictionary = {}
var saved_character_id: String = ""

func _ready() -> void:
	# Find all deformation modifiers in skeleton
	if skeleton:
		for child in skeleton.get_children():
			if child is DeformModifier3D:
				_deform_modifiers[child.bone_name] = child

	# Find the DollPartManager component
	_part_manager = get_component(&"DollPartManager") if has_method("get_component") else null

## Gets a component (for backward compatibility with old code)
func get_component(component_name: StringName) -> Component:
	if has_method("get_component"):
		return get_parent().get_component(component_name)
	return null

# --- State management (migrated from Doll3D.gd lines 148-197) ---

func set_state(state_id: String, value: Variant) -> void:
	state[state_id] = value
	if temporary_state.has(state_id):
		return
	if _part_manager:
		for slot in _part_manager.active_parts:
			var part = _part_manager.active_parts[slot]
			if part.has_method("set_state"):
				part.set_state(state_id, value)

func set_temporary_state(state_id: String, value: Variant) -> void:
	temporary_state[state_id] = value
	if _part_manager:
		for slot in _part_manager.active_parts:
			var part = _part_manager.active_parts[slot]
			if part.has_method("set_state"):
				part.set_state(state_id, value)

func get_state(state_id: String) -> Variant:
	return state.get(state_id)

func get_final_state(state_id: String) -> Variant:
	if temporary_state.has(state_id):
		return temporary_state[state_id]
	return state.get(state_id)

func clear_temporary_state() -> void:
	for state_id in temporary_state:
		if state.has(state_id):
			set_state(state_id, state[state_id])
		else:
			set_state(state_id, "")
	temporary_state.clear()

# --- Delegation to DollPartManager (migrated from Doll3D.gd part methods) ---

func add_part(slot: StringName, part: Node3D) -> void:
	if _part_manager:
		_part_manager.add_part(slot, part)

func add_part_object(slot: StringName, part: Node3D) -> void:
	if _part_manager:
		_part_manager.add_part(slot, part)

func set_parts(new_parts: Dictionary) -> void:
	if _part_manager:
		_part_manager.set_parts(new_parts)

func remove_slot(slot: StringName) -> void:
	if _part_manager:
		_part_manager.remove_slot(slot)

func has_slot(slot: StringName) -> bool:
	if _part_manager:
		return _part_manager.has_slot(slot)
	return false

# --- Delegation to DeformModifier3D (migrated from Doll3D.gd bone methods) ---

func set_deformation(bone_name: StringName, scale: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
	if _deform_modifiers.has(bone_name):
		var mod: DeformModifier3D = _deform_modifiers[bone_name]
		mod.scale_factor = scale
		mod.position_offset = offset
	else:
		push_warning("Doll3D: Modifier for bone %s not found!" % bone_name)

func set_pregnancy(progress: float) -> void:
	if _deform_modifiers.has(&"DeformBelly"):
		_deform_modifiers[&"DeformBelly"].apply_pregnancy(progress)

func set_breasts_scale(breasts_scale: float) -> void:
	if _deform_modifiers.has(&"DeformBreasts"):
		_deform_modifiers[&"DeformBreasts"].apply_breasts(breasts_scale)

func set_butt_scale(butt_scale: float, tail_scale: float = 1.0) -> void:
	if _deform_modifiers.has(&"DeformButt"):
		_deform_modifiers[&"DeformButt"].apply_butt(butt_scale, tail_scale)

func set_thigh_thickness(progress: float) -> void:
	for mod_name in [&"DeformThigh.L", &"DeformThigh.R"]:
		if _deform_modifiers.has(mod_name):
			_deform_modifiers[mod_name].apply_thighs(progress)

func set PenisScale(penis_scale: float) -> void:
	if _deform_modifiers.has(&"Penis"):
		_deform_modifiers[&"Penis"].apply_penis(penis_scale)

func set_balls_scale(new_scale: float) -> void:
	if _deform_modifiers.has(&"Balls"):
		_deform_modifiers[&"Balls"].apply_balls(new_scale)

# --- Animation (migrated from Doll3D.gd line 571) ---

func play_animation(anim_name: StringName, blend: float = 0.1, speed: float = 1.0) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(String(anim_name), blend, speed)

func get_anim_player() -> AnimationPlayer:
	return animation_player

# --- Visibility delegation ---

func set_hidden_parts(new_hidden: Dictionary) -> void:
	if _part_manager:
		_part_manager.set_hidden_parts(new_hidden)

func update_alpha() -> void:
	if _part_manager:
		_part_manager.update_visibility()

func force_slot_visible(zone: StringName) -> void:
	if _part_manager:
		_part_manager.force_slot_visible(zone)

# --- Character loading (migrated from Doll3D.gd lines 294-308) ---

func load_character(char_id: String) -> void:
	saved_character_id = char_id

func prepare_character(char_id: String) -> void:
	clear_temporary_state()
	load_character(char_id)

func get_character_id() -> String:
	return saved_character_id
