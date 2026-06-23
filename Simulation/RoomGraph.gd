# Simulation/RoomGraph.gd
class_name RoomGraph extends RefCounted

## Logical graph of the prison for fast NPC movement off-screen.
## Stores connections: from -> where you can go.

var _connections: Dictionary = {} # StringName -> Array[StringName]

## Adds a bidirectional connection between rooms
func add_connection(room_a: StringName, room_b: StringName) -> void:
	if not _connections.has(room_a):
		_connections[room_a] = [] as Array[StringName]
	if not _connections.has(room_b):
		_connections[room_b] = [] as Array[StringName]

	if not _connections[room_a].has(room_b):
		_connections[room_a].append(room_b)
	if not _connections[room_b].has(room_a):
		_connections[room_b].append(room_a)

## Checks if direct travel is possible
func are_connected(room_a: StringName, room_b: StringName) -> bool:
	if _connections.has(room_a):
		return _connections[room_a].has(room_b)
	return false
