# Autoloads/EventBus.gd
extends Node

## Global event bus for decoupling systems.
## Scripts should not call each other directly, they should listen to and emit these signals.

# Time and world
signal time_advanced(minutes: int)
signal new_day_started(day_number: int)

# Interactions and NPC
signal npc_relationship_changed(npc_a: StringName, npc_b: StringName, rel_type: StringName, amount: float)
signal npc_spawned(npc_id: StringName, room_id: StringName)

# Sex engine
signal sex_event_triggered(event_type: StringName, participants: Array[Node], location: StringName)

# Inventory and stats
signal item_added(entity: Node, item_id: StringName, amount: int)
signal stat_changed(entity: Node, stat_name: StringName, old_value: float, new_value: float)
