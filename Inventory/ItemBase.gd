extends RefCounted
class_name ItemBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for ALL items. extends Reference → RefCounted.

var id: String = "baditem"
var unique_id = null
var amount: int = 1
var current_inventory = null
var restraint_data: RestraintData
var item_state: ItemState
var fluids: Fluids
var clothes_color: Color = Color.WHITE

# Backward aliases
var uniqueID:
	get: return unique_id
var restraintData: RestraintData:
	get: return restraint_data
var itemState: ItemState:
	get: return item_state
var currentInventory:
	get: return current_inventory

func _init() -> void:
	generate_restraint_data()
	if restraint_data != null:
		restraint_data.item = weakref(self)
	generate_item_state()
	if item_state != null:
		item_state.item = weakref(self)
	generate_fluids()

func get_visible_name() -> String:
	return "Bad item"

func get_casual_name() -> String:
	if item_state == null:
		return get_visible_name()
	var casual = item_state.get_casual_name()
	if casual == null:
		return get_visible_name()
	return casual

func get_stack_name() -> String:
	if amount > 1:
		return str(amount) + "x" + get_visible_name()
	return get_visible_name()

func get_inventory_name() -> String:
	var the_name := get_stack_name()
	if fluids != null:
		if fluids.is_empty():
			the_name += " (empty)"
		else:
			if fluids.is_capacity_limited():
				the_name += " (" + str(Util.round_f(fluids.get_fluid_amount())) + "/" + str(Util.round_f(fluids.get_capacity(), 1)) + " ml)"
			else:
				the_name += " (" + str(Util.round_f(fluids.get_fluid_amount())) + " ml)"
	elif restraint_data != null:
		if current_inventory != null:
			if not restraint_data.has_smart_lock():
				the_name += " (Level " + restraint_data.get_visible_level(GM.pc.is_blindfolded() and not GM.pc.can_handle_blindness()) + ")"
			else:
				the_name += " (SMART-LOCKED)"
	return the_name

func get_a() -> String:
	var vis_name := get_visible_name()
	if vis_name.ends_with("s"):
		return ""
	if vis_name.length() > 0 and vis_name[0].to_lower() in ["a", "e", "i", "o", "u"]:
		return "an"
	return "a"

func get_a_stack_name() -> String:
	if amount > 1:
		return str(amount) + "x" + get_visible_name()
	return (get_a() + " " + get_visible_name()).trim_prefix(" ")

func get_description() -> String:
	return "No description provided"

func get_visible_description() -> String:
	var text := get_description()
	if not (text is String):
		Log.printerr(id + ".getDescription() RETURNS A BAD VALUE")
		text = ""
	if item_state != null:
		var extra_desc = item_state.get_extra_description()
		if extra_desc != null and extra_desc != "":
			text += "\n" + extra_desc
	if can_dye():
		text += "\n[color=gray]Color: " + str(clothes_color.to_html(false)) + "[/color]"
	if has_tag(&"Illegal"):
		text += "\n[color=red]This item is illegal![/color]"
	return text

# --- Restraint methods ---

func generate_restraint_data() -> void:
	pass

func generate_item_state() -> void:
	pass

func generate_fluids() -> void:
	pass

func can_dye() -> bool:
	return false

func has_tag(_tag: StringName) -> bool:
	return false

func adds_intoxication() -> float:
	return 0.0

func get_amount() -> int:
	return amount

func set_amount(new_amount: int) -> void:
	amount = new_amount

func get_id() -> StringName:
	return StringName(id)

func get_unique_id():
	return unique_id

func is_restraint() -> bool:
	return restraint_data != null

func get_restraint_data() -> RestraintData:
	return restraint_data

func get_item_state() -> ItemState:
	return item_state

func get_fluids() -> Fluids:
	return fluids

func get_clothes_color() -> Color:
	return clothes_color

func set_clothes_color(new_color: Color) -> void:
	clothes_color = new_color

func get_tooltip_info() -> String:
	return ""

func get_chains():
	return null

func get_rigged_parts(_character):
	return null

func get_unrigged_parts(_character):
	return null

func get_hides_parts(_character):
	return null

func get_hides_attachments(_character):
	return null

func should_be_visible_on_doll(_character, _doll) -> bool:
	return true

func covers_bodyparts():
	return null

func always_visible() -> bool:
	return false

func update_doll(_doll) -> void:
	pass

# --- Save/Load ---

func save_data() -> Dictionary:
	return {
		"id": id,
		"amount": amount,
		"uniqueID": unique_id,
		"clothesColor": clothes_color,
	}

func load_data(data: Dictionary) -> void:
	amount = SAVE.load_var(data, "amount", 1)
	unique_id = SAVE.load_var(data, "uniqueID", null)
	clothes_color = SAVE.load_var(data, "clothesColor", Color.WHITE)

func on_removed() -> void:
	pass
