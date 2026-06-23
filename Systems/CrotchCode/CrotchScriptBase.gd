# Systems/CrotchCode/CrotchScriptBase.gd
class_name CrotchScriptBase extends RefCounted

## Migrated from CodeContex.gd (727 lines).
## Base class for all generated CrotchCode scripts (mods).
## Provides safe API for modders with error handling and variable management.

signal on_print(text: String)
signal on_error(block: Variant, text: String)
signal on_generic_error(text: String)

var _is_cancelled: bool = false

# Variable system (migrated from CodeContex.gd lines 12-42)
var _vars: Dictionary = {}
var _vars_definition: Dictionary = {}

# Flag system (migrated from CodeContex.gd lines 47-87)
var _flags: Dictionary = {}
var _flags_definition: Dictionary = {}

func execute() -> void:
	pass

func cancel() -> void:
	_is_cancelled = true

# --- Variable management (migrated from CodeContex.gd) ---

func has_var(var_id: String) -> bool:
	return _vars.has(var_id)

func get_var(var_id: String, default_value: Variant = null) -> Variant:
	if not _vars.has(var_id):
		if _vars_definition.has(var_id):
			return _vars_definition[var_id]["default"]
		return default_value
	return _vars[var_id]

func set_var(var_id: String, new_value: Variant) -> void:
	if _vars_definition.has(var_id):
		var expected_type: int = _vars_definition[var_id].get("type", -1)
		match expected_type:
			0: # BOOL
				if not new_value is bool:
					throw_error(null, "Trying to assign '%s' to BOOL variable %s" % [str(new_value), var_id])
					return
			1: # STRING
				if not new_value is String:
					throw_error(null, "Trying to assign '%s' to STRING variable %s" % [str(new_value), var_id])
					return
			2: # NUMBER
				if not (new_value is int or new_value is float):
					throw_error(null, "Trying to assign '%s' to NUMBER variable %s" % [str(new_value), var_id])
					return
	_vars[var_id] = new_value

func clear_vars() -> void:
	_vars.clear()

# --- Flag management (migrated from CodeContex.gd lines 47-87) ---

func has_flag(flag_id: String) -> bool:
	return _flags_definition.has(flag_id)

func get_flag(flag_id: String, default_value: Variant = null) -> Variant:
	if not _flags.has(flag_id):
		if _flags_definition.has(flag_id):
			return _flags_definition[flag_id]["default"]
		return default_value
	return _flags[flag_id]

func set_flag(flag_id: String, new_value: Variant) -> void:
	if _flags_definition.has(flag_id):
		var expected_type: int = _flags_definition[flag_id].get("type", -1)
		match expected_type:
			0: # BOOL
				if not new_value is bool:
					throw_error(null, "Trying to assign '%s' to BOOL flag %s" % [str(new_value), flag_id])
					return
			1: # STRING
				if not new_value is String:
					throw_error(null, "Trying to assign '%s' to STRING flag %s" % [str(new_value), flag_id])
					return
			2: # NUMBER
				if not (new_value is int or new_value is float):
					throw_error(null, "Trying to assign '%s' to NUMBER flag %s" % [str(new_value), flag_id])
					return
	_flags[flag_id] = new_value

## Global flag access via ServiceLocator (replaces GM.main.getFlag)
func get_flag_raw(flag_id: String, default_value: Variant = null) -> Variant:
	var main_scene = ServiceLocator.get_service(&"MainScene") if ServiceLocator else null
	if main_scene and main_scene.has_method("get_flag"):
		return main_scene.get_flag(flag_id, default_value)
	return get_flag(flag_id, default_value)

func set_flag_raw(flag_id: String, new_value: Variant) -> void:
	var main_scene = ServiceLocator.get_service(&"MainScene") if ServiceLocator else null
	if main_scene and main_scene.has_method("set_flag"):
		main_scene.set_flag(flag_id, new_value)
	else:
		set_flag(flag_id, new_value)

# --- Error handling (migrated from CodeContex.gd lines 96-119) ---

var _errored: bool = false
var _returning: bool = false

func had_error() -> bool:
	return _errored

func reset_errored() -> void:
	_errored = false

func should_return() -> bool:
	return _returning

func throw_error(block: Variant, error_text: String) -> void:
	_errored = true
	if block == null:
		on_generic_error.emit(str(error_text))
		push_error("[CrotchScript Error] %s" % error_text)
	else:
		on_error.emit(block, str(error_text))
		push_error("[CrotchScript Error] %s" % error_text)

# --- Safe API for modders (migrated from CodeContex.gd lines 137-300) ---

func cc_print(message: String) -> void:
	on_print.emit(message)
	print("[CrotchCode]: ", message)

func say(text: String) -> void:
	if text.length() > 80:
		text = text.substr(0, 78) + "..."
	cc_print(text)

func saynn(text: String) -> void:
	say(text)

func say_as_character(char_id: String, say_text: String) -> void:
	saynn("[say=%s]%s[/say]" % [char_id, say_text])

func add_message(text: String) -> void:
	cc_print("Adding message: " + str(text))

func add_button(name_text: String, desc_text: String, state: Variant, code_slot: Variant, button_checks: Variant) -> void:
	cc_print("BUTTON ADDED: " + str(name_text))

func add_disabled_button(name_text: String, desc_text: String) -> void:
	cc_print("DISABLED BUTTON ADDED: " + str(name_text))

# --- Character methods (migrated from CodeContex.gd lines 213-292) ---

func get_character(char_id: String) -> Variant:
	var registry = ServiceLocator.get_service(&"RegistryManager") if ServiceLocator else null
	if registry:
		return registry.get_character(StringName(char_id))
	return null

func add_pain(char_id: String, amount: int) -> void:
	var character = get_character(char_id)
	if character and character.has_method("add_pain"):
		character.add_pain(amount)

func add_lust(char_id: String, amount: int) -> void:
	var character = get_character(char_id)
	if character and character.has_method("add_lust"):
		character.add_lust(amount)

func add_stamina(char_id: String, amount: int) -> void:
	var character = get_character(char_id)
	if character and character.has_method("add_stamina"):
		character.add_stamina(amount)

func get_pain(char_id: String) -> int:
	var character = get_character(char_id)
	if character and character.has_method("get_pain"):
		return character.get_pain()
	return 0

func get_lust(char_id: String) -> int:
	var character = get_character(char_id)
	if character and character.has_method("get_lust"):
		return character.get_lust()
	return 0

func get_stamina(char_id: String) -> int:
	var character = get_character(char_id)
	if character and character.has_method("get_stamina"):
		return character.get_stamina()
	return 0

func char_method(char_id: String, method_name: String, args: Array = [], default_value: Variant = null) -> Variant:
	var character = get_character(char_id)
	if character == null:
		return default_value
	if not character.has_method(method_name):
		throw_error(null, "No method found: %s for character: %s" % [method_name, char_id])
		return default_value
	return character.callv(method_name, args)

# --- Inventory methods (migrated from CodeContex.gd inventory section) ---

func inv_add_item(char_id: String, item_id: String, amount: int = 1) -> void:
	var character = get_character(char_id)
	if character and character.has_method("getInventory"):
		var inventory = character.getInventory()
		if inventory and inventory.has_method("addItem"):
			inventory.addItem(item_id, amount)

func inv_remove_item(char_id: String, item_id: String, amount: int = 1) -> void:
	var character = get_character(char_id)
	if character and character.has_method("getInventory"):
		var inventory = character.getInventory()
		if inventory and inventory.has_method("removeItem"):
			inventory.removeItem(item_id, amount)

func inv_has_item(char_id: String, item_id: String) -> bool:
	var character = get_character(char_id)
	if character and character.has_method("getInventory"):
		var inventory = character.getInventory()
		if inventory and inventory.has_method("hasItem"):
			return inventory.hasItem(item_id)
	return false

# --- Scene methods (migrated from CodeContex.gd scene section) ---

func play_anim(anim_id: String, anim_data: Variant = null) -> void:
	cc_print("PLAYING ANIMATION: " + str(anim_id))

func aim_camera(new_loc: String) -> void:
	cc_print("AIMING CAMERA AT " + str(new_loc))

func set_loc_name(new_text: String) -> void:
	cc_print("Setting loc name to " + str(new_text))

func do_run_event() -> void:
	cc_print("EVENT WILL HAPPEN")
	_returning = true

# --- Wait (safe async replacement for loops) ---

func cc_wait_seconds(tree: SceneTree, seconds: float) -> void:
	if _is_cancelled:
		return
	await tree.create_timer(seconds).timeout

# --- Type helpers ---

func is_number(val: Variant) -> bool:
	return val is float or val is int

func is_string(val: Variant) -> bool:
	return val is String

func to_string_val(val: Variant) -> String:
	return str(val)

func to_int_val(val: Variant) -> int:
	return int(val)

func to_float_val(val: Variant) -> float:
	return float(val)
