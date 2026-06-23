@tool
extends Sprite
class_name GameRoom

## MIGRATED to Godot 4 (GDScript 2.0).
## Room node with export vars, colors, sprites, location tags.

@export var room_name: String = ""
@export var room_id: String = ""
@export_multiline var room_description: String = ""
@export_multiline var blind_room_description: String = ""

@export var can_west: bool = true
@export var can_north: bool = true
@export var can_east: bool = true
@export var can_south: bool = true

@export var room_sprite: RoomStuff.RoomSprite = RoomStuff.RoomSprite.NONE:
	set(value):
		room_sprite = value
		_update_sprite()

@export var room_color: RoomStuff.RoomColor = RoomStuff.RoomColor.White:
	set(value):
		room_color = value
		if Engine.is_editor_hint:
			_update_color()

@export var grid_color: RoomStuff.RoomColor = RoomStuff.RoomColor.White:
	set(value):
		grid_color = value
		if Engine.is_editor_hint:
			_update_grid_color()

const ROOM_COLOR_TO_COLOR: Dictionary = {
	RoomStuff.RoomColor.White: Color.WHITE,
	RoomStuff.RoomColor.Green: Color(0.7, 1.0, 0.7),
	RoomStuff.RoomColor.Red: Color(1.0, 0.6, 0.6),
	RoomStuff.RoomColor.Blue: Color(0.7, 0.7, 1.0),
	RoomStuff.RoomColor.Pink: Color(1.0, 0.6, 0.8),
	RoomStuff.RoomColor.Orange: Color(1.0, 0.8, 0.6),
	RoomStuff.RoomColor.Yellow: Color(1.0, 1.0, 0.7),
	RoomStuff.RoomColor.Grey: Color(0.5, 0.5, 0.5),
	RoomStuff.RoomColor.LightGrey: Color(0.7, 0.7, 0.7),
}

const SPRITES: Dictionary = {
	RoomStuff.RoomSprite.PERSON: preload("res://Images/World/person.png"),
	RoomStuff.RoomSprite.CANTEEN: preload("res://Images/World/canteen.png"),
	RoomStuff.RoomSprite.STAIRS: preload("res://Images/World/stairs.png"),
	RoomStuff.RoomSprite.IMPORTANT: preload("res://Images/World/important.png"),
	RoomStuff.RoomSprite.COMPUTER: preload("res://Images/World/computer.png"),
	RoomStuff.RoomSprite.VENDOMAT: preload("res://Images/World/vendomat.png"),
	RoomStuff.RoomSprite.SHOWER: preload("res://Images/World/shower.png"),
	RoomStuff.RoomSprite.WC: preload("res://Images/World/wc.png"),
	RoomStuff.RoomSprite.LAUNDRY: preload("res://Images/World/laundry.png"),
	RoomStuff.RoomSprite.BED: preload("res://Images/World/bed.png"),
	RoomStuff.RoomSprite.BOSS: preload("res://Images/World/boss.png"),
}

@onready var room_sprite_object: Sprite = $Sprite
@onready var grid_sprite: Sprite = $Grid

signal on_enter(room)
signal on_pre_enter(room)
signal on_react(room, key)

# Location tags
@export var loctag_greenhouses: bool = false
@export var loctag_mental_ward: bool = false
@export var loctag_guards_encounter: bool = false
@export var loctag_engineers_encounter: bool = false
@export var loctag_offlimits: bool = false
@export var loctag_old_guards_encounter: bool = false
@export var loctag_no_walls_near: bool = false

@export_flags("Inmates", "Guards") var population: int = 0

@export var lootable: bool = false
@export var loot_table_id: String = ""
@export var loot_around_message: String = ""
@export var loot_item_ids: PackedStringArray = PackedStringArray()
@export var loot_credits: int = 0
@export var loot_every_x_days: int = 0

var astar_id
@export var astar_connected_to: PackedStringArray = PackedStringArray()
var astar_connections: Array = []
var floor_id: String = ""

func _ready() -> void:
	if Engine.is_editor_hint:
		return
	if not room_id:
		room_id = name
	if not room_name:
		room_name = room_id
	if ROOM_COLOR_TO_COLOR.has(room_color):
		self_modulate = ROOM_COLOR_TO_COLOR[room_color]
	if SPRITES.has(room_sprite):
		room_sprite_object.texture = SPRITES[room_sprite]

func get_population() -> Array:
	var result: Array = []
	if Util.isBitEnabled(population, 0):
		result.append(WorldPopulation.Inmates)
	if Util.isBitEnabled(population, 1):
		result.append(WorldPopulation.Guards)
	return result

func _update_sprite() -> void:
	if room_sprite == RoomStuff.RoomSprite.NONE:
		$Sprite.texture = null
	elif SPRITES.has(room_sprite):
		$Sprite.texture = SPRITES[room_sprite]

func _update_color() -> void:
	if ROOM_COLOR_TO_COLOR.has(room_color):
		self_modulate = ROOM_COLOR_TO_COLOR[room_color]

func _update_grid_color() -> void:
	if grid_color == RoomStuff.RoomColor.White:
		$Grid.visible = false
	else:
		$Grid.visible = true
	$Grid.self_modulate = ROOM_COLOR_TO_COLOR.get(grid_color, Color.WHITE)

func get_floor_id() -> String:
	var my_parent = get_parent()
	while not my_parent.has_method("getRooms"):
		my_parent = my_parent.get_parent()
	return my_parent.id

func get_cell() -> Vector2:
	return Vector2(roundf(global_position.x / GameWorld.GRID_SIZE), roundf(global_position.y / GameWorld.GRID_SIZE))

func get_description() -> String:
	return room_description

func get_blind_description() -> String:
	return blind_room_description if blind_room_description != "" else "You don't understand where you are"

func get_name() -> String:
	return room_name

func say(text: String) -> void:
	if GM.ui:
		GM.ui.say(text)

func add_button(text: String, tooltip: String = "", arg: String = "") -> void:
	GM.ui.addButton(text, tooltip, "roomCallback", [room_id, arg])

func add_disabled_button(text: String, tooltip: String = "") -> void:
	GM.ui.addDisabledButton(text, tooltip)

func add_actions() -> void:
	for action in get_children():
		if action is RoomAction:
			if action._shouldShow():
				if action._canRun():
					GM.ui.addButton(action.ActionName, action.ActionTooltip, "actionCallback", [action.ActionScene])
				else:
					GM.ui.addDisabledButton(action.ActionName, action.ActionTooltip)

func _on_pre_enter() -> void:
	on_pre_enter.emit(self)

func _on_enter() -> void:
	add_actions()
	on_enter.emit(self)

func set_highlighted(high: bool) -> void:
	if high:
		self_modulate = Color.PURPLE
	else:
		self_modulate = ROOM_COLOR_TO_COLOR.get(room_color, Color.WHITE)

func is_offlimits_for_inmates() -> bool:
	return loctag_guards_encounter or loctag_greenhouses or loctag_engineers_encounter or loctag_mental_ward or loctag_offlimits

func get_cached_floor_id() -> String:
	return floor_id
