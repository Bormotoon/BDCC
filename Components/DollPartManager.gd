# Components/DollPartManager.gd
class_name DollPartManager extends Component

## Manages attached models (body slots, armor) on a 3D doll.
## Must be attached to an Entity.

@export var target_skeleton: Skeleton3D

var active_parts: Dictionary = {} # SlotName (StringName) -> Node3D

## Equips a new body part/clothing. Replaces existing part in the same slot.
func equip_part(slot: StringName, part_scene_path: String) -> void:
	assert(target_skeleton != null, "DollPartManager: Skeleton3D not assigned!")

	if active_parts.has(slot):
		var old_part: Node = active_parts[slot]
		target_skeleton.remove_child(old_part)
		old_part.queue_free()

	var packed_scene := load(part_scene_path) as PackedScene
	if not packed_scene:
		push_error("DollPartManager: Failed to load scene %s" % part_scene_path)
		return

	var instance = packed_scene.instantiate() as Node3D
	target_skeleton.add_child(instance)
	active_parts[slot] = instance

	EventBus.item_added.emit(entity, slot, 1)

## Clears a slot
func unequip_part(slot: StringName) -> void:
	if active_parts.has(slot):
		var part: Node = active_parts[slot]
		target_skeleton.remove_child(part)
		part.queue_free()
		active_parts.erase(slot)
