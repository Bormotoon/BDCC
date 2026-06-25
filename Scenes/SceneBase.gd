extends Node
class_name SceneBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for ALL game scenes. Heavy GM.* usage preserved for backward compat.

signal scene_ended(result)

var state: String = ""
var scene_id: String = "UNREGISTERED_SCENE"
var current_characters_variants: Dictionary = {}
var scene_tag: String = ""
var scene_ended_flag: bool = false
var scene_ended_args
var show_fight_ui: bool = false
var scene_saved_items_inv: LightInventory = LightInventory.new()
var unique_scene_id: int = -1
var parent_scene_unique_id: int = -1
var showed_developer_commentary: bool = false

# Backward aliases
var sceneID: String:
	get: return scene_id
var uniqueSceneID: int:
	get: return unique_scene_id
	set(value): unique_scene_id = value
var parentSceneUniqueID: int:
	get: return parent_scene_unique_id
	set(value): parent_scene_unique_id = value

# ==========================================
# LIFECYCLE
# ==========================================

func _run() -> void:
	pass

func _react(_action: String, _args) -> void:
	pass

func _react_scene_end(_tag, _result) -> void:
	pass

func _init_scene(_args: Array = []) -> void:
	pass

func _react_init() -> void:
	pass

func init_scene(args: Array = []) -> void:
	clear_character()
	_init_scene(args)
	_react_init()

## Line 55-82: run() — main scene execution
func run() -> void:
	ServiceLocator.safe_get_service(&"Player").update_non_battle_effects()
	for id in current_characters_variants:
		var character = GlobalRegistry.get_character(id)
		if not character:
			continue
		character.update_non_battle_effects()

	ServiceLocator.safe_get_service(&"UI").clear_scene_artwork()
	ServiceLocator.safe_get_service(&"UI").clear_text()
	ServiceLocator.safe_get_service(&"UI").clear_buttons()
	ServiceLocator.safe_get_service(&"UI").clear_u_i_textboxes()
	_run()
	ServiceLocator.safe_get_service(&"EventSystem").trigger_run(Trigger.SceneAndStateHook, [scene_id, state])

	if show_fight_ui:
		ServiceLocator.safe_get_service(&"UI").get_characters_panel().switch_to_fight_mode()
	else:
		ServiceLocator.safe_get_service(&"UI").get_characters_panel().switch_to_normal_mode()

	ServiceLocator.safe_get_service(&"Player").update_effect_panel(ServiceLocator.safe_get_service(&"UI").get_player_status_effects_panel())
	ServiceLocator.safe_get_service(&"UI").update_characters_in_panel()
	ServiceLocator.safe_get_service(&"UI").set_scene_creator(get_scene_creator(), should_show_dev_commentary_icon())
	ServiceLocator.safe_get_service(&"UI").set_scene_art_work(Images.get_scene_art(self))
	ServiceLocator.safe_get_service(&"UI").set_big_answers_mode(should_display_big_buttons())

	check_scene_ended()

## Line 84-101
func check_scene_ended() -> void:
	if scene_ended_flag:
		_on_scene_end()
		ServiceLocator.safe_get_service(&"MainScene").remove_scene(self, scene_ended_args)
		scene_ended.emit(scene_ended_args)
		if not scene_saved_items_inv.is_empty():
			var new_items: Array = []
			while not scene_saved_items_inv.is_empty():
				var the_item = scene_saved_items_inv.items.front()
				scene_saved_items_inv.remove_item(the_item)
				new_items.append(the_item)
			run_scene("LootingScene", [{"items": new_items}])
			scene_saved_items_inv.items.clear()
		queue_free()

func end_scene(result = []) -> void:
	scene_ended_flag = true
	scene_ended_args = result
	check_scene_ended()

func run_scene(id: String, args: Array = [], tag: String = ""):
	var scene = ServiceLocator.safe_get_service(&"MainScene").run_scene(id, args, unique_scene_id)
	scene.scene_tag = tag
	return scene

# ==========================================
# UI HELPERS (lines 119-265)
# ==========================================

func say(text: String) -> void:
	if ServiceLocator.safe_get_service(&"UI"):
		ServiceLocator.safe_get_service(&"UI").say(text)

func sayn(text: String) -> void:
	say(text + "\n")

func saynn(text: String) -> void:
	say(text + "\n\n")

func add_button(text: String, tooltip: String = "", method: String = "", args: Array = []) -> void:
	ServiceLocator.safe_get_service(&"UI").add_button(text, tooltip, method, args)

func add_disabled_button(text: String, tooltip: String = "") -> void:
	ServiceLocator.safe_get_service(&"UI").add_disabled_button(text, tooltip)

func add_continue(method: String = "", args: Array = []) -> void:
	add_button("Continue", "See what happens next", method, args)

func add_next_button(method: String, args: Array = []) -> void:
	if ServiceLocator.safe_get_service(&"UI"):
		ServiceLocator.safe_get_service(&"UI").add_button("Next", "", method, args)

func add_button_with_checks(text: String, tooltip: String, method: String, args, checks: Array) -> void:
	var bad_check = ButtonChecks.check(checks)
	if bad_check == null:
		add_button(text, ButtonChecks.get_prefix(checks) + tooltip, method, args)
	else:
		var reason_text = ButtonChecks.get_reason_text(bad_check)
		if reason_text != "":
			reason_text = "[" + reason_text + "] "
		add_disabled_button(text, ButtonChecks.get_prefix(checks) + reason_text + tooltip)

func add_message(text: String) -> void:
	ServiceLocator.safe_get_service(&"MainScene").add_message(text)

func add_experience_to_player(ex: int, show_message: bool = true) -> void:
	if show_message:
		add_message("You received " + str(ex) + " experience")
	ServiceLocator.safe_get_service(&"Player").add_experience(ex)

# ==========================================
# CHARACTER MANAGEMENT (lines 140-185)
# ==========================================

func add_character(id: String, variant: Array = []) -> void:
	if id.is_empty():
		return
	current_characters_variants[id] = variant
	ServiceLocator.safe_get_service(&"MainScene").start_updating_character(id)
	if ServiceLocator.safe_get_service(&"MainScene").get_current_scene() == self:
		ServiceLocator.safe_get_service(&"UI").add_character_to_panel(id, variant)

func remove_character(id: String) -> void:
	current_characters_variants.erase(id)
	if ServiceLocator.safe_get_service(&"MainScene").get_current_scene() == self:
		ServiceLocator.safe_get_service(&"UI").remove_character_from_panel(id)

func has_character(id: String) -> bool:
	return current_characters_variants.has(id)

func clear_character() -> void:
	if ServiceLocator.safe_get_service(&"MainScene").get_current_scene() == self:
		ServiceLocator.safe_get_service(&"UI").clear_characters_panel()
	if current_characters_variants.is_empty():
		return
	current_characters_variants.clear()

func set_characters_easy_list(new_chars: Array) -> void:
	for char_id in current_characters_variants.keys():
		if char_id == "pc":
			continue
		if not new_chars.has(char_id):
			remove_character(char_id)
	for char_id in new_chars:
		if char_id == "pc":
			continue
		if not current_characters_variants.has(char_id):
			add_character(char_id)

# ==========================================
# FLAG DELEGATION (lines 293-309)
# ==========================================

func set_flag(flag_id, value) -> void:
	ServiceLocator.safe_get_service(&"MainScene").set_flag(flag_id, value)

func get_flag(flag_id, default_value = null):
	return ServiceLocator.safe_get_service(&"MainScene").get_flag(flag_id, default_value)

func increase_flag(flag_id, add_value = 1) -> void:
	ServiceLocator.safe_get_service(&"MainScene").increase_flag(flag_id, add_value)

func set_module_flag(module_id, flag_id, value) -> void:
	ServiceLocator.safe_get_service(&"MainScene").set_module_flag(module_id, flag_id, value)

func get_module_flag(module_id, flag_id, default_value = null):
	return ServiceLocator.safe_get_service(&"MainScene").get_module_flag(module_id, flag_id, default_value)

# ==========================================
# TIME & SCENE (lines 287-328)
# ==========================================

func process_time(seconds: int) -> void:
	ServiceLocator.safe_get_service(&"MainScene").process_time(seconds)

func start_new_day() -> int:
	return ServiceLocator.safe_get_service(&"MainScene").start_new_day()

func set_location_name(location_name: String) -> void:
	ServiceLocator.safe_get_service(&"MainScene").set_location_name(location_name)

func aim_camera(room_id: String) -> void:
	ServiceLocator.safe_get_service(&"MainScene").aim_camera(room_id)

func get_character_by_id(char_id: String) -> BaseCharacter:
	return GlobalRegistry.get_character(char_id)

func play_animation(the_scene_id, the_action_id, args: Dictionary = {}) -> void:
	if ServiceLocator.safe_get_service(&"MainScene") != null:
		ServiceLocator.safe_get_service(&"MainScene").play_animation(the_scene_id, the_action_id, args)

# ==========================================
# ITEM HELPERS (lines 388-420)
# ==========================================

func put_on(char_id: String, item_id: String):
	var the_character := get_character_by_id(char_id)
	if not the_character:
		return null
	var the_item = GlobalRegistry.create_item(item_id)
	if not the_item:
		return null
	the_character.get_inventory().force_equip_store_other_unless_restraint(the_item)
	return the_item

func put_off(char_id: String, item_id: String):
	var the_character := get_character_by_id(char_id)
	if not the_character:
		return null
	var the_cur_item: ItemBase = the_character.get_inventory().get_equipped_item_by_id(item_id)
	if not the_cur_item:
		return null
	the_character.get_inventory().remove_equipped_item(the_cur_item)
	return the_cur_item

func remove_item_id(item_id: String, amount: int = 1) -> void:
	ServiceLocator.safe_get_service(&"Player").get_inventory().remove_x_of_or_destroy(item_id, amount)

func has_item_id(item_id: String) -> bool:
	return ServiceLocator.safe_get_service(&"Player").get_inventory().has_item_id(item_id)

# ==========================================
# SAVE/LOAD (lines 422-444)
# ==========================================

func save_data() -> Dictionary:
	return {
		"state": state,
		"currentCharactersVariants": current_characters_variants,
		"sceneTag": scene_tag,
		"sceneEndedFlag": scene_ended_flag,
		"sceneEndedArgs": scene_ended_args,
		"sceneSavedItemsInv": scene_saved_items_inv.save_data(),
		"uniqueSceneID": unique_scene_id,
		"parentSceneUniqueID": parent_scene_unique_id,
	}

func load_data(data: Dictionary) -> void:
	state = SAVE.load_var(data, "state", "")
	current_characters_variants = SAVE.load_var(data, "currentCharactersVariants", {})
	scene_tag = SAVE.load_var(data, "sceneTag", "")
	scene_ended_flag = SAVE.load_var(data, "sceneEndedFlag", false)
	scene_ended_args = SAVE.load_var(data, "sceneEndedArgs", null)
	update_character()
	scene_saved_items_inv.load_data(SAVE.load_var(data, "sceneSavedItemsInv", {}))
	unique_scene_id = SAVE.load_var(data, "uniqueSceneID", -1)
	parent_scene_unique_id = SAVE.load_var(data, "parentSceneUniqueID", -1)

func update_character() -> void:
	if ServiceLocator.safe_get_service(&"MainScene").get_current_scene() == self:
		ServiceLocator.safe_get_service(&"UI").clear_characters_panel()
		for id in current_characters_variants:
			var character = GlobalRegistry.get_character(id)
			if not character:
				continue
			ServiceLocator.safe_get_service(&"UI").add_character_to_panel(id, current_characters_variants[id])

func _on_scene_end() -> void:
	pass

func get_scene_creator() -> String:
	var registry_creator = GlobalRegistry.get_scene_creator(scene_id)
	if registry_creator != null and registry_creator != "":
		return str(registry_creator)
	return ""

func supports_battle_turns() -> bool:
	return false

func supports_sex_engine() -> bool:
	return false

func should_display_big_buttons() -> bool:
	return false

func get_dev_commentary():
	return null

func should_show_dev_commentary_icon() -> bool:
	if not OPTIONS.developer_commentary_enabled():
		return false
	if showed_developer_commentary:
		return false
	return get_dev_commentary() != null and get_dev_commentary() != ""
