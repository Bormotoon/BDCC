extends Node
class_name Inventory

## MIGRATED to Godot 4 (GDScript 2.0).
## Full inventory system with equip/unequip, stacking, save/load.

var items: Array = []
var equipped_items: Dictionary = {}

signal equipped_items_changed

func _ready() -> void:
	name = "Inventory"

# ==========================================
# ADD ITEMS (lines 12-61)
# ==========================================

func add_item(item: RefCounted) -> void:
	if item.current_inventory != null:
		assert(false)
	if item.can_combine():
		for my_item in items:
			if my_item.id == item.id:
				if my_item.try_combine(item):
					return
	items.append(item)
	item.current_inventory = self

func add_item_id(item_id: String) -> bool:
	var new_item = GlobalRegistry.create_item(item_id)
	if new_item == null:
		return false
	add_item(new_item)
	return true

func force_equip_item_id(item_id: String) -> bool:
	var new_item = GlobalRegistry.create_item(item_id)
	if new_item == null:
		return false
	if new_item.get_clothing_slot() == null:
		return false
	return force_equip_store_other_unless_restraint(new_item)

func add_x_of_item_id(item_id: String, amount: int) -> bool:
	var the_ref = GlobalRegistry.get_item_ref(item_id)
	if the_ref == null:
		return false
	var can_stack: bool = the_ref.can_combine()
	if can_stack:
		var new_item = GlobalRegistry.create_item(item_id)
		new_item.set_amount(Util.maxi(0, amount))
		if new_item == null:
			return false
		add_item(new_item)
		return true
	else:
		for _i in range(amount):
			var new_item = GlobalRegistry.create_item(item_id)
			if new_item == null:
				return false
			add_item(new_item)
		return true

# ==========================================
# QUERY ITEMS (lines 63-258)
# ==========================================

func has_item(item) -> bool:
	return items.has(item)

func has_item_id(item_id: String) -> bool:
	for item in items:
		if item.id == item_id:
			return true
	return false

func get_items() -> Array:
	return items

func get_all_items() -> Array:
	return items

func get_equipped_items() -> Dictionary:
	return equipped_items

func get_all_equipped_items() -> Dictionary:
	return equipped_items

func get_all_of(item_id: String) -> Array:
	var result: Array = []
	for item in items:
		if item.id == item_id:
			result.append(item)
	return result

func get_first_of(item_id: String):
	for item in items:
		if item.id == item_id:
			return item
	return null

func get_amount_of(item_id: String) -> int:
	var item = get_first_of(item_id)
	if item == null:
		return 0
	return item.amount

func has_x_of(item_id: String, amount: int) -> bool:
	var item = get_first_of(item_id)
	if item == null:
		return false
	return item.amount >= amount

func get_x_of_total(item_id: String) -> int:
	var result := 0
	for item in items:
		if item.id == item_id:
			result += item.amount
	return result

func has_x_of_total(item_id: String, amount: int) -> bool:
	return get_x_of_total(item_id) >= amount

func get_all_combat_usable_items() -> Array:
	var result: Array = []
	for item in items:
		if item.can_use_in_combat():
			result.append(item)
	return result

func get_all_combat_usable_restraints() -> Array:
	var result: Array = []
	for item in items:
		if item.can_force_onto_npc():
			result.append(item)
	return result

func get_items_with_tag(tag_id: StringName) -> Array:
	var result: Array = []
	for item in items:
		if item.has_tag(tag_id):
			result.append(item)
	return result

func get_equipped_items_with_tag(tag_id: StringName) -> Array:
	var result: Array = []
	for slot in equipped_items:
		var item = equipped_items[slot]
		if item.has_tag(tag_id):
			result.append(item)
	return result

func get_all_items_can_dye() -> Array:
	var result: Array = []
	for item in items:
		if item.can_dye():
			result.append(item)
	for slot in equipped_items:
		if equipped_items[slot].can_dye():
			result.append(equipped_items[slot])
	return result

func get_all_sellable_items() -> Array:
	var result: Array = []
	for item in items:
		if item.can_sell():
			result.append(item)
	return result

func get_items_and_equipped_together() -> Array:
	var result: Array = []
	result.append_array(equipped_items.values())
	result.append_array(items)
	return result

func get_items_and_equipped_grouped() -> Dictionary:
	var result: Dictionary = {}
	for item in equipped_items.values():
		result["%$%" + item.id] = [item]
	for item in items:
		var group_id: String = item.get_inventory_group_id()
		if not result.has(group_id):
			result[group_id] = [item]
		else:
			result[group_id].append(item)
	return result

func get_offspring_eggs() -> Array:
	var result: Array = []
	for item in items:
		if item.id == "EggGeneric" and item.is_offspring_egg():
			result.append(item)
	return result

# ==========================================
# REMOVE ITEMS (lines 171-231)
# ==========================================

func remove_item(item) -> Variant:
	if items.has(item):
		items.erase(item)
		item.current_inventory = null
		return item
	return null

func remove_first_of(item_id: String) -> bool:
	var the_item = get_first_of(item_id)
	if the_item != null:
		remove_item(the_item)
		return true
	return false

func remove_x_from_item_or_delete(item, amount: int) -> void:
	assert(items.has(item))
	item.remove_x_or_destroy(amount)

func remove_x_of_or_destroy(item_id: String, amount: int) -> void:
	var item = get_first_of(item_id)
	if item == null:
		return
	item.remove_x_or_destroy(amount)

func remove_items_list(items_to_delete: Array) -> void:
	for item in items_to_delete:
		remove_item(item)

func clear() -> void:
	for item in items:
		item.current_inventory = null
	items.clear()
	for slot in equipped_items:
		equipped_items[slot].current_inventory = null
	equipped_items.clear()
	equipped_items_changed.emit()

# ==========================================
# EQUIP/UNEQUIP (lines 260-480)
# ==========================================

func can_equip_slot(slot) -> bool:
	if get_parent() != null and get_parent().has_method("invCanEquipSlot"):
		return get_parent().invCanEquipSlot(slot)
	return true

func equip_item(item) -> bool:
	if has_item(item):
		remove_item(item)
	var slot: String = item.get_clothing_slot()
	if equipped_items.has(slot):
		Log.err("Trying to equip to slot " + str(slot) + " when already occupied")
		return false
	if not can_equip_slot(slot):
		return false
	equipped_items[slot] = item
	item.current_inventory = self
	equipped_items_changed.emit()
	if SexToyManager.enabled and item.is_restraint():
		var the_char = get_character()
		if the_char and the_char.is_player():
			SexToyManager.send_trigger(SexToyTrigger.OnBondageLocked)
	return true

func unequip_item(item) -> bool:
	var the_item = remove_equipped_item(item)
	if the_item != null:
		add_item(the_item)
		return true
	return false

func force_equip_remove_other(item) -> bool:
	var slot: String = item.get_clothing_slot()
	if has_slot_equipped(slot):
		remove_item_from_slot(slot)
	return equip_item(item)

func force_equip_store_other(item) -> bool:
	var slot: String = item.get_clothing_slot()
	if has_slot_equipped(slot):
		var stored_item = remove_item_from_slot(slot)
		add_item(stored_item)
	return equip_item(item)

func force_equip_store_other_unless_restraint(item) -> bool:
	var slot: String = item.get_clothing_slot()
	if has_slot_equipped(slot):
		var stored_item = remove_item_from_slot(slot)
		if not stored_item.is_restraint() or stored_item.is_important() or stored_item.is_restraint_should_keep():
			add_item(stored_item)
	return equip_item(item)

func equip_item_by(item, equipper) -> void:
	var success = equip_item(item)
	if success:
		item.on_equipped_by(equipper, false)

func force_equip_by_remove_other(item, forcer, can_smart_lock: bool = true) -> void:
	var success = force_equip_remove_other(item)
	if success:
		item.on_equipped_by(forcer, true)
		if can_smart_lock:
			item.try_add_smart_lock(forcer)

func has_slot_equipped(slot) -> bool:
	return equipped_items.has(slot) and equipped_items[slot] != null

func get_equipped_item(slot):
	return equipped_items.get(slot)

func get_equipped_item_by_id(the_id: String):
	for slot in equipped_items:
		var item = equipped_items[slot]
		if item.id == the_id:
			return item
	return null

func has_item_id_equipped(item_id: String) -> bool:
	for slot in equipped_items:
		if equipped_items[slot].id == item_id:
			return true
	return false

func remove_item_from_slot(slot):
	if equipped_items.has(slot):
		var item = equipped_items[slot]
		item.on_unequipped()
		equipped_items.erase(slot)
		item.current_inventory = null
		equipped_items_changed.emit()
		return item
	return null

func remove_equipped_item(item):
	for slot in equipped_items.keys():
		if equipped_items[slot] == item:
			item.on_unequipped()
			equipped_items.erase(slot)
			item.current_inventory = null
			equipped_items_changed.emit()
			return item
	return null

func clear_slot(slot) -> bool:
	var the_item = remove_item_from_slot(slot)
	return the_item != null

func clear_equipped_items() -> void:
	for slot in equipped_items.keys():
		equipped_items[slot].current_inventory = null
	equipped_items.clear()
	equipped_items_changed.emit()

func clear_equipped_items_keep_persistent() -> void:
	var persistent: Dictionary = {}
	for slot in equipped_items.keys():
		if equipped_items[slot].is_persistent():
			persistent[slot] = equipped_items[slot]
		else:
			equipped_items[slot].current_inventory = null
	equipped_items.clear()
	equipped_items = persistent
	equipped_items_changed.emit()

func get_smart_locked_items_amount() -> int:
	var result := 0
	for slot in equipped_items:
		var item = equipped_items[slot]
		if item.restraint_data != null and item.restraint_data.has_smart_lock():
			result += 1
	return result

func get_all_smart_locks() -> Array:
	var result: Array = []
	for slot in equipped_items:
		var item = equipped_items[slot]
		if item.restraint_data != null and item.restraint_data.has_smart_lock():
			result.append(item.restraint_data.get_smart_lock())
	return result

func get_equipped_items_with_buff(buff_id: StringName) -> Array:
	var result: Array = []
	for slot in equipped_items:
		var item = equipped_items[slot]
		for buff in item.get_buffs():
			if buff.id == buff_id:
				result.append(item)
				break
	return result

func get_character():
	if get_parent() != null:
		return get_parent()
	return null

# ==========================================
# SAVE/LOAD (lines 810-935)
# ==========================================

func save_data() -> Dictionary:
	var data := {}
	data["items"] = []
	for item in items:
		var item_data := {"id": item.id, "uniqueID": item.unique_id}
		item_data["data"] = item.save_data()
		data["items"].append(item_data)
	data["equipped_items"] = {}
	for slot in equipped_items:
		var item = equipped_items[slot]
		var item_data := {"id": item.id, "uniqueID": item.unique_id}
		item_data["data"] = item.save_data()
		data["equipped_items"][slot] = item_data
	return data

func load_data(data: Dictionary) -> void:
	clear()
	var loaded_items = SAVE.load_var(data, "items", [])
	for loaded_item in loaded_items:
		var item_id = SAVE.load_var(loaded_item, "id", "")
		var uid = SAVE.load_var(loaded_item, "uniqueID", "")
		if uid != null and uid is int:
			uid = str(uid)
		var item_data = SAVE.load_var(loaded_item, "data", {})
		var new_item: ItemBase = GlobalRegistry.create_item(item_id, false)
		if not new_item:
			Log.err("ITEM WITH ID " + str(item_id) + " NOT FOUND IN REGISTRY")
			continue
		if uid == null or uid == "":
			uid = "item" + str(GlobalRegistry.generate_unique_id())
		new_item.unique_id = uid
		new_item.load_data(item_data)
		add_item(new_item)
	var loaded_equipped = SAVE.load_var(data, "equipped_items", {})
	for loaded_slot in loaded_equipped:
		var loaded_item = loaded_equipped[loaded_slot]
		var item_id = SAVE.load_var(loaded_item, "id", "")
		var uid = SAVE.load_var(loaded_item, "uniqueID", null)
		if uid != null and uid is int:
			uid = str(uid)
		var item_data = SAVE.load_var(loaded_item, "data", {})
		var new_item: ItemBase = GlobalRegistry.create_item(item_id, false)
		if not new_item:
			Log.err("ITEM WITH ID " + str(item_id) + " NOT FOUND IN REGISTRY")
			continue
		if uid == null or uid == "":
			uid = "item" + str(GlobalRegistry.generate_unique_id())
		new_item.unique_id = uid
		new_item.load_data(item_data)
		equip_item(new_item)

func load_data_npc(data: Dictionary, npc) -> void:
	var has_any_inv_data = data.has("equipped_items")
	load_data(data)
	if not has_any_inv_data:
		npc.reset_equipment_hard()
