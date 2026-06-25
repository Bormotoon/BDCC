extends RefCounted
class_name Module

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for all 22 game modules. Registration loop preserved.

var scenes: Array = []
var characters: Array = []
var items: Array = []
var events: Array = []
var quests: Array = []
var attacks: Array = []
var bodyparts: Array = []
var species: Array = []
var skills: Array = []
var perks: Array = []
var lust_actions: Array = []
var buffs: Array = []
var status_effects: Array = []
var world_edits: Array = []
var game_extenders: Array = []
var computers: Array = []
var part_skins: Array = []
var stage_scenes: Array = []
var loot_tables: Array = []
var loot_lists: Array = []
var fetishes: Array = []
var sex_goals: Array = []
var sex_activities: Array = []
var sex_types: Array = []
var fluids: Array = []
var speech_modifiers: Array = []
var slave_break_tasks: Array = []
var slave_types: Array = []
var slave_actions: Array = []
var slave_events: Array = []
var slave_activities: Array = []
var sex_reaction_handlers: Array = []

var id: String = "badmodule"
var author: String = "no author"
var flags_cache = null

func _init() -> void:
	flags_cache = get_flags()

func get_register_name() -> String:
	if str(author) != "Rahi":
		return id + " module by " + str(author)
	return id + " module"

func get_author_name() -> String:
	var the_author: String = str(author)
	if the_author == "Rahi" or the_author == "no author":
		return ""
	return the_author

func pre_init() -> void:
	pass

func post_init() -> void:
	pass

## Registration loop — registers all content arrays into GlobalRegistry
func register() -> void:
	var the_author_name: String = get_author_name()

	for scene in scenes:
		GlobalRegistry.register_scene(scene, author)
	for character in characters:
		GlobalRegistry.register_character(character)
	for item in items:
		GlobalRegistry.register_item(item)
	for event in events:
		GlobalRegistry.register_event(event)
	for quest in quests:
		GlobalRegistry.register_quest(quest)
	for attack in attacks:
		GlobalRegistry.register_attack(attack)
	for bodypart in bodyparts:
		GlobalRegistry.register_bodypart(bodypart, the_author_name)
	for specie in species:
		GlobalRegistry.register_species(specie)
	for skill in skills:
		GlobalRegistry.register_skill(skill)
	for perk in perks:
		GlobalRegistry.register_perk(perk)
	for lust_action in lust_actions:
		GlobalRegistry.register_lust_action(lust_action)
	for buff in buffs:
		GlobalRegistry.register_buff(buff)
	for status_effect in status_effects:
		GlobalRegistry.register_status_effect(status_effect)
	for world_edit in world_edits:
		GlobalRegistry.register_world_edit(world_edit)
	for game_extender in game_extenders:
		GlobalRegistry.register_game_extender(game_extender)
	for computer in computers:
		GlobalRegistry.register_computer(computer)
	for part_skin in part_skins:
		GlobalRegistry.register_part_skin(part_skin)
	for stage_scene in stage_scenes:
		GlobalRegistry.register_stage_scene(stage_scene)
	for loot_table in loot_tables:
		GlobalRegistry.register_loot_table(loot_table)
	for loot_list in loot_lists:
		GlobalRegistry.register_loot_list(loot_list)
	for fetish in fetishes:
		GlobalRegistry.register_fetish(fetish)
	for sex_goal in sex_goals:
		GlobalRegistry.register_sex_goal(sex_goal)
	for sex_activity in sex_activities:
		GlobalRegistry.register_sex_activity(sex_activity)
	for sex_type in sex_types:
		GlobalRegistry.register_sex_type(sex_type)
	for fluid in fluids:
		GlobalRegistry.register_fluid(fluid)
	for speech_modifier in speech_modifiers:
		GlobalRegistry.register_speech_modifier(speech_modifier)
	for slave_break_task in slave_break_tasks:
		GlobalRegistry.register_slave_break_task(slave_break_task)
	for slave_type in slave_types:
		GlobalRegistry.register_slave_type(slave_type)
	for slave_action in slave_actions:
		GlobalRegistry.register_slave_action(slave_action)
	for slave_event in slave_events:
		GlobalRegistry.register_slave_event(slave_event)
	for slave_activity in slave_activities:
		GlobalRegistry.register_slave_activity(slave_activity)
	for sex_reaction_handler in sex_reaction_handlers:
		GlobalRegistry.register_sex_reaction_handler(sex_reaction_handler)

func register_event_triggers() -> void:
	pass

func reset_flags_on_new_day() -> void:
	pass

func set_flag(flag_id, value) -> void:
	ServiceLocator.safe_get_service(&"MainScene").set_flag(flag_id, value)

func get_flag(flag_id, default_value = null):
	return ServiceLocator.safe_get_service(&"MainScene").get_flag(flag_id, default_value)

func increase_flag(flag_id, add_value = 1) -> void:
	ServiceLocator.safe_get_service(&"MainScene").increase_flag(flag_id, add_value)

func get_random_scene_for(_scene_type) -> Array:
	return []

func is_science_upgrade_visible(_upgrade_id: String) -> bool:
	return true

func get_flags() -> Dictionary:
	return {}

func get_flags_cache():
	return flags_cache

func flag(type) -> Dictionary:
	return {"type": type}
