extends Node2D
class_name GameWorld

## MIGRATED to Godot 4 (GDScript 2.0).
## 2D grid world with AStar2D pathfinding, rooms, pawns, camera.

enum Direction {WEST, NORTH, EAST, SOUTH}

@onready var camera: Camera2D = $Camera2D

var cells: Dictionary = {}
var room_dict: Dictionary = {}
var floor_dict: Dictionary = {}
const GRID_SIZE: int = 64
var highlighted_room: Node2D
var last_aimed_room_id = null
var pawns: Dictionary = {}
var entities: Dictionary = {}

var room_connection_scene = preload("res://Game/World/RoomConnection.tscn")
@onready var world_floor_scene = load("res://Game/World/WorldFloor.tscn")
var world_pawn_scene = preload("res://Game/World/WorldPawn.tscn")
var world_entity_scene = preload("res://Game/World/WorldEntity.tscn")

var astar: AStar2D
var astar_id_to_room_id_map: Dictionary = {}

# Backward aliases
var roomDict: Dictionary:
	get: return room_dict
var floorDict: Dictionary:
	get: return floor_dict
var lastAimedRoomID:
	get: return last_aimed_room_id

func _ready() -> void:
	ServiceLocator.safe_get_service(&"World") = self
	astar = AStar2D.new()
	var map_floors = GlobalRegistry.getMapFloors()
	for map_id in map_floors:
		var map_path = map_floors[map_id]
		var map_object = load(map_path).instantiate()
		var new_world_floor = world_floor_scene.instantiate()
		new_world_floor.id = map_id
		add_child(new_world_floor)
		new_world_floor.add_child(map_object)
		if map_object.get("canMeetNPCs"):
			new_world_floor.canMeetNPCs = map_object.canMeetNPCs

	for f in get_children():
		if f.has_method("getRooms"):
			if floor_dict.has(f.id):
				assert(false)
			floor_dict[f.id] = f
			if not cells.has(f.id):
				cells[f.id] = {}
			var room_cells = f.getRooms()
			for cell in room_cells:
				cell.global_position.x = roundf(cell.global_position.x / GRID_SIZE) * GRID_SIZE
				cell.global_position.y = roundf(cell.global_position.y / GRID_SIZE) * GRID_SIZE
				_register_room(f.id, cell)

# ==========================================
# PATHFINDING (lines 39-53)
# ==========================================

func calculate_path(start_room_id: String, end_room_id: String) -> Array:
	if not has_room_id(start_room_id) or not has_room_id(end_room_id):
		return []
	var start_room = get_room_by_id(start_room_id)
	var end_room = get_room_by_id(end_room_id)
	var result = astar.get_id_path(start_room.astarID, end_room.astarID)
	var result_rooms: Array = []
	for astar_id in result:
		if astar_id_to_room_id_map.has(astar_id):
			result_rooms.append(astar_id_to_room_id_map[astar_id])
	return result_rooms

# ==========================================
# DIRECTION HELPERS (lines 6-122)
# ==========================================

static func get_all_directions() -> Array:
	return [Direction.WEST, Direction.NORTH, Direction.EAST, Direction.SOUTH]

func opposite(dir: int) -> int:
	match dir:
		Direction.WEST: return Direction.EAST
		Direction.EAST: return Direction.WEST
		Direction.NORTH: return Direction.SOUTH
		Direction.SOUTH: return Direction.NORTH
	return -1

func apply_direction(pos: Vector2, dir: int) -> Vector2:
	var new_pos := pos
	match dir:
		Direction.WEST: new_pos.x -= 1
		Direction.NORTH: new_pos.y -= 1
		Direction.EAST: new_pos.x += 1
		Direction.SOUTH: new_pos.y += 1
	return new_pos

func apply_direction_id(room_id: String, dir: int) -> String:
	var room = get_room_by_id(room_id)
	if not room:
		return ""
	var new_pos = apply_direction(room.getCell(), dir)
	if has_room(room.getFloorID(), new_pos):
		return cells[room.getFloorID()][new_pos].roomID
	return ""

func can_go_id(room_id: String, dir: int) -> bool:
	var room = get_room_by_id(room_id)
	if not room:
		return false
	return can_go(room.getFloorID(), room.getCell(), dir)

func can_go(floor_id: String, pos: Vector2, dir: int) -> bool:
	if not has_room(floor_id, pos):
		return false
	var pos2 = apply_direction(pos, dir)
	if not has_room(floor_id, pos2):
		return false
	var room1 = cells[floor_id][pos]
	var room2 = cells[floor_id][pos2]
	match dir:
		Direction.WEST: return room1.canWest and room2.canEast
		Direction.EAST: return room1.canEast and room2.canWest
		Direction.NORTH: return room1.canNorth and room2.canSouth
		Direction.SOUTH: return room1.canSouth and room2.canNorth
	return false

# ==========================================
# ROOM MANAGEMENT (lines 124-279)
# ==========================================

func _register_room(floor_id: String, room) -> void:
	if not cells.has(floor_id):
		cells[floor_id] = {}
	var pos = room.getCell()
	room.astarID = astar.add_point(astar.get_available_point_id(), pos)
	astar_id_to_room_id_map[room.astarID] = room.roomID
	room_dict[room.roomID] = room
	cells[floor_id][pos] = room

func has_room(floor_id: String, pos: Vector2) -> bool:
	return cells.has(floor_id) and cells[floor_id].has(pos)

func has_room_id(id: String) -> bool:
	return room_dict.has(id)

func get_room_by_id(id: String):
	return room_dict.get(id)

func clear_floor(floor_id: String) -> void:
	if not cells.has(floor_id):
		return
	var floor_cells = cells[floor_id]
	for pos in floor_cells.keys():
		var room = floor_cells[pos]
		room_dict.erase(room.roomID)
		for other_id in room.astarConnections:
			if astar.has_point(other_id):
				astar.disconnect_points(room.astarID, other_id)
		astar.remove_point(room.astarID)
		astar_id_to_room_id_map.erase(room.astarID)
		room.queue_free()
		floor_cells.erase(pos)

func add_transitions(floor_ids: Array = []) -> void:
	if floor_ids.is_empty():
		floor_ids = cells.keys()
	for floor_id in floor_ids:
		var floor_cells = cells[floor_id]
		for pos in floor_cells:
			var room = floor_cells[pos]
			# Extra AStar connections
			for extra_id in room.astarConnectedTo:
				var extra_room = get_room_by_id(extra_id)
				if extra_room != null:
					astar.connect_points(room.astarID, extra_room.astarID)
					room.astarConnections.append(extra_room.astarID)
			# East transition
			if can_go(floor_id, pos, Direction.EAST):
				var line = room_connection_scene.instantiate()
				room.add_child(line)
				line.global_position = (pos + Vector2(0.5, 0)) * GRID_SIZE
				var next_id = apply_direction_id(room.roomID, Direction.EAST)
				var next_room = get_room_by_id(next_id)
				if next_room:
					astar.connect_points(room.astarID, next_room.astarID)
					room.astarConnections.append(next_room.astarID)
			# South transition
			if can_go(floor_id, pos, Direction.SOUTH):
				var line = room_connection_scene.instantiate()
				line.rotation_degrees = 90
				room.add_child(line)
				line.global_position = (pos + Vector2(0, 0.5)) * GRID_SIZE
				var next_id = apply_direction_id(room.roomID, Direction.SOUTH)
				var next_room = get_room_by_id(next_id)
				if next_room:
					astar.connect_points(room.astarID, next_room.astarID)
					room.astarConnections.append(next_room.astarID)

func set_room_sprite(id: String, new_sprite) -> void:
	var room = get_room_by_id(id)
	if room:
		room.setRoomSprite(new_sprite)

func set_room_color(id: String, new_color) -> void:
	var room = get_room_by_id(id)
	if room:
		room.setRoomColor(new_color)

# ==========================================
# CAMERA (stubs — full impl in original)
# ==========================================

func aim_camera(room_id: String, instant: bool = false) -> bool:
	if not (room_id is String):
		return false
	var room = get_room_by_id(room_id)
	if not room:
		return false
	switch_to_floor(room.get_floor_id())
	camera.global_position = room.global_position
	if highlighted_room:
		highlighted_room.set_highlighted(false)
	highlighted_room = room
	highlighted_room.set_highlighted(true)
	last_aimed_room_id = room_id
	if instant:
		camera.reset_smoothing()
	return true

func aim_camera_and_set_loc_name(room_id: String) -> void:
	aim_camera(room_id)
	set_location_name(room_id)

func set_location_name(text: String) -> void:
	if ServiceLocator.safe_get_service(&"UI") and ServiceLocator.safe_get_service(&"UI").has_method("set_location_name"):
		ServiceLocator.safe_get_service(&"UI").set_location_name(text)

func get_safe_from_pc_random_room(possible_rooms: Array, pc_location: String) -> String:
	for room_id in possible_rooms:
		if room_id != pc_location:
			return room_id
	return pc_location

# ==========================================
# SAVE/LOAD
# ==========================================

func save_data() -> Dictionary:
	return {
		"last_aimed_room_id": last_aimed_room_id,
		"zoom_x": camera.zoom.x,
		"zoom_y": camera.zoom.y,
	}

func load_data(data: Dictionary) -> void:
	last_aimed_room_id = SAVE.loadVar(data, "last_aimed_room_id", "")
	if data.has("zoom_x") and data.has("zoom_y"):
		camera.zoom = Vector2(SAVE.loadVar(data, "zoom_x", 1.0), SAVE.loadVar(data, "zoom_y", 1.0))

func add_transitions_for_floor(floor_ids: Array) -> void:
	add_transitions(floor_ids)

func update_pawns(interaction_system) -> void:
	if not interaction_system:
		return
	var checked_pawns = pawns.duplicate()
	for char_id in interaction_system.get_pawns():
		var pawn = interaction_system.get_pawn(char_id)
		var loc: String = pawn.get_location()
		var room = get_room_by_id(loc)
		if room == null:
			continue
		if not pawns.has(char_id):
			create_world_pawn(char_id, pawn, loc)
		else:
			checked_pawns.erase(char_id)
			var world_pawn = pawns[char_id]
			update_pawn(world_pawn, pawn)
	for char_id in checked_pawns:
		if pawns.has(char_id):
			var world_pawn = pawns[char_id]
			world_pawn.queue_free()
			pawns.erase(char_id)

func get_pawns_near(room_id: String) -> Array:
	var result: Array = []
	for char_id in pawns:
		var world_pawn = pawns[char_id]
		if world_pawn and world_pawn.get_location() == room_id:
			result.append(char_id)
	return result
