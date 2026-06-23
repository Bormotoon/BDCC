# Components/DollPartManager.gd
class_name DollPartManager extends Component

## Migrated from Doll3D.gd lines 199-528.
## Manages body part slots, visibility, and attachment zones.

@export var target_skeleton: Skeleton3D

var active_parts: Dictionary = {} # StringName -> Node3D
var hidden_part_zones: Dictionary = {}
var hidden_attachment_zones: Dictionary = {}
var overriden_part_hidden: Dictionary = {}

# --- Part management (migrated from addPartObject, line 217) ---

## Adds a part to a slot, replacing any existing part
func add_part(slot: StringName, part: Node3D) -> void:
	assert(target_skeleton != null, "DollPartManager: Skeleton3D not assigned!")

	if active_parts.has(slot):
		var old_part: Node = active_parts[slot]
		if old_part.has_method("on_removed"):
			old_part.on_removed()
		target_skeleton.remove_child(old_part)
		old_part.queue_free()
		active_parts.erase(slot)

	if part.has_method("set_doll3d"):
		part.set_doll3d(entity)

	active_parts[slot] = part
	target_skeleton.add_child(part)

	if part.has_method("init_part"):
		part.init_part(entity)

	EventBus.item_added.emit(entity, slot, 1)

## Adds part only if the slot doesn't already have the same scene
func add_part_unless_same(slot: StringName, part_scene_path: String) -> void:
	if active_parts.has(slot):
		var old_part = active_parts[slot]
		if old_part.scene_file_path == part_scene_path:
			return

	var packed_scene := load(part_scene_path) as PackedScene
	if not packed_scene:
		push_error("DollPartManager: Failed to load scene %s" % part_scene_path)
		return

	var instance = packed_scene.instantiate() as Node3D
	add_part(slot, instance)

## Removes a part from a slot (migrated from removeSlot, line 255)
func remove_slot(slot: StringName) -> void:
	if active_parts.has(slot):
		var part = active_parts[slot]
		if part.has_method("on_removed"):
			part.on_removed()
		target_skeleton.remove_child(part)
		part.queue_free()
		active_parts.erase(slot)

## Checks if a slot has a part
func has_slot(slot: StringName) -> bool:
	return active_parts.has(slot)

## Equips a new body part, replacing existing
func equip_part(slot: StringName, part_scene_path: String) -> void:
	add_part_unless_same(slot, part_scene_path)

## Unequips a part
func unequip_part(slot: StringName) -> void:
	remove_slot(slot)

# --- Bulk part management (migrated from setParts, line 512) ---

## Sets all parts at once, only recreating changed ones (dirty flag approach)
func set_parts(new_parts: Dictionary) -> void:
	var dirty_flags: Dictionary = {}
	for slot in active_parts:
		dirty_flags[slot] = false

	for new_slot in new_parts:
		add_part_unless_same(new_slot, new_parts[new_slot])
		dirty_flags[new_slot] = true

	for slot in active_parts.keys():
		if not dirty_flags[slot]:
			remove_slot(slot)

	update_visibility()

# --- Visibility (migrated from updateAlpha, lines 472-528) ---

func set_hidden_parts(new_hidden: Dictionary) -> void:
	hidden_part_zones = new_hidden

func set_hidden_attachment_zones(new_hidden: Dictionary) -> void:
	hidden_attachment_zones = new_hidden

func force_slot_visible(zone: StringName) -> void:
	overriden_part_hidden[zone] = true
	if active_parts.has(zone):
		(active_parts[zone] as Node3D).visible = true

func clear_override_alpha() -> void:
	for slot in overriden_part_hidden:
		if hidden_part_zones.has(slot) and active_parts.has(slot):
			(active_parts[slot] as Node3D).visible = false
		elif active_parts.has(slot):
			(active_parts[slot] as Node3D).visible = true
	overriden_part_hidden.clear()

## Updates visibility of all parts based on hidden zones
func update_visibility() -> void:
	for slot in active_parts:
		if hidden_part_zones.has(slot) and not overriden_part_hidden.has(slot):
			(active_parts[slot] as Node3D).visible = false
		else:
			(active_parts[slot] as Node3D).visible = true

# --- Unrigged parts (migrated from setUnriggedParts, line 549) ---

func set_unrigged_parts(scenes: Dictionary) -> void:
	for zone in active_parts:
		var part = active_parts[zone]
		if part.has_method("set_scenes"):
			if scenes.has(zone):
				part.set_scenes(scenes[zone])
			else:
				part.set_scenes([])

func attach_temporary_unrigged_part(zone: StringName, scene: PackedScene) -> void:
	if active_parts.has(zone):
		var part = active_parts[zone]
		if part.has_method("add_temporary_scene"):
			part.add_temporary_scene(scene)

# --- Shape keys (migrated from setShapeKeyValue, line 266) ---

func set_shape_key_value(shape_key: String, value: float) -> void:
	for slot in active_parts:
		var part = active_parts[slot]
		if part.has_method("set_shape_key_value"):
			part.set_shape_key_value(shape_key, value)
