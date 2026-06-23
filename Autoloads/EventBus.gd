# Autoloads/EventBus.gd
extends Node

## Global event bus for decoupling systems.
## Replaces the 8369 direct GM.* access sites across 904 files.
## Scripts should not call each other directly, they should listen to and emit these signals.

# --- Time and world ---
signal time_advanced(minutes: int)
signal new_day_started(day_number: int)
signal hour_passed(hour: int)
signal room_entered(room_id: StringName, character_id: StringName)
signal room_exited(room_id: StringName, character_id: StringName)

# --- NPC lifecycle ---
signal npc_spawned(npc_id: StringName, room_id: StringName)
signal npc_despawned(npc_id: StringName)
signal npc_level_up(npc_id: StringName, new_level: int)

# --- Relationships ---
signal npc_relationship_changed(npc_a: StringName, npc_b: StringName, rel_type: StringName, amount: float)
signal npc_affection_changed(npc_a: StringName, npc_b: StringName, old_value: float, new_value: float)
signal npc_lust_changed(npc_a: StringName, npc_b: StringName, old_value: float, new_value: float)

# --- Sex engine ---
signal sex_event_triggered(event_type: StringName, participants: Array[Node], location: StringName)
signal sex_scene_started(participants: Array[Node], location: StringName)
signal sex_scene_ended(participants: Array[Node], location: StringName)
signal orgasm_triggered(entity: Node, bodypart_id: StringName)

# --- Character stats (migrated from BaseCharacter signals) ---
signal pain_changed(entity: Node, new_value: float, old_value: float)
signal lust_changed(entity: Node, new_value: float, old_value: float)
signal stamina_changed(entity: Node, new_value: float, old_value: float)
signal stat_changed(entity: Node, stat_name: StringName, old_value: float, new_value: float)
signal health_changed(entity: Node, old_value: float, new_value: float)
signal consciousness_changed(entity: Node, is_conscious: bool)

# --- Leveling and skills ---
signal level_changed(entity: Node, old_level: int, new_level: int)
signal skill_level_changed(entity: Node, skill_id: StringName, old_level: int, new_level: int)
signal perk_unlocked(entity: Node, perk_id: StringName)
signal stat_point_spent(entity: Node, stat_name: StringName, new_value: float)

# --- Inventory ---
signal item_added(entity: Node, item_id: StringName, amount: int)
signal item_removed(entity: Node, item_id: StringName, amount: int)
signal item_equipped(entity: Node, item_id: StringName, slot: StringName)
signal item_unequipped(entity: Node, item_id: StringName, slot: StringName)
signal credits_changed(entity: Node, old_amount: int, new_amount: int)

# --- Scene management ---
signal scene_started(scene_id: StringName)
signal scene_ended(scene_id: StringName)
signal scene_option_chosen(scene_id: StringName, option_index: int)

# --- Save/Load ---
signal save_started(save_name: String)
signal save_finished(save_name: String)
signal load_started(save_name: String)
signal load_finished(save_name: String)

# --- Status effects ---
signal status_effect_added(entity: Node, effect_id: StringName)
signal status_effect_removed(entity: Node, effect_id: StringName)

# --- Pregnancy ---
signal pregnancy_started(entity: Node, mother_id: StringName)
signal birth_started(entity: Node, mother_id: StringName)
signal birth_completed(entity: Node, mother_id: StringName, child_count: int)

# --- Transformation ---
signal transformation_started(entity: Node, tf_id: StringName)
signal transformation_completed(entity: Node, tf_id: StringName)
signal bodypart_changed(entity: Node, slot: StringName, old_part: StringName, new_part: StringName)

# --- Combat ---
signal fight_started(attacker: Node, defender: Node)
signal fight_ended(winner: Node, loser: Node)
signal damage_dealt(attacker: Node, defender: Node, damage_type: StringName, amount: float)
