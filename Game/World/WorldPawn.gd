extends Node2D

## MIGRATED to Godot 4 (GDScript 2.0).
## Visual representation of an NPC pawn on the map.
## Tween → create_tween() (Godot 4 node-less tweens).

var pawn
var id
var loc
var floor_id

@onready var icon: Sprite2D = $Icon
@onready var icon_2: Sprite2D = $Icon2
@onready var icon_3: Sprite2D = $Icon/Icon3
@onready var relationship_label: Label = $RelationshipLabel

func move_to_pos(target_pos: Vector2) -> void:
	# Godot 4: create_tween() instead of node-based Tween
	var tween := create_tween()
	tween.tween_property(self, "global_position",
		target_pos + Vector2(randi_range(-16, 16), randi_range(-16, 16)), 0.5)

func set_pawn_texture(pawn_texture) -> void:
	match pawn_texture:
		RoomStuff.PawnTexture.Fem:
			icon.texture = preload("res://Images/WorldPawns/fem.png")
		RoomStuff.PawnTexture.Masc:
			icon.texture = preload("res://Images/WorldPawns/masc.png")
		_:
			icon.texture = null

func set_pawn_activity_icon(activity_icon) -> void:
	var texture_map := {
		RoomStuff.PawnActivity.Chat: "res://Images/WorldPawnActivity/chat.png",
		RoomStuff.PawnActivity.Fight: "res://Images/WorldPawnActivity/fight.png",
		RoomStuff.PawnActivity.Sex: "res://Images/WorldPawnActivity/sex.png",
		RoomStuff.PawnActivity.Eat: "res://Images/WorldPawnActivity/eating.png",
		RoomStuff.PawnActivity.Shower: "res://Images/WorldPawnActivity/showering.png",
		RoomStuff.PawnActivity.Stocks: "res://Images/WorldPawnActivity/stocks.png",
		RoomStuff.PawnActivity.Unconscious: "res://Images/WorldPawnActivity/unconscious.png",
		RoomStuff.PawnActivity.Work: "res://Images/WorldPawnActivity/working.png",
		RoomStuff.PawnActivity.Help: "res://Images/WorldPawnActivity/help.png",
		RoomStuff.PawnActivity.Down: "res://Images/WorldPawnActivity/down.png",
		RoomStuff.PawnActivity.Prostitution: "res://Images/WorldPawnActivity/prostitution.png",
		RoomStuff.PawnActivity.Struggle: "res://Images/WorldPawnActivity/struggle.png",
		RoomStuff.PawnActivity.GiveBirth: "res://Images/WorldPawnActivity/givebirth.png",
		RoomStuff.PawnActivity.LayEggs: "res://Images/WorldPawnActivity/layeggs.png",
	}
	if texture_map.has(activity_icon):
		icon_2.texture = load(texture_map[activity_icon])
	else:
		icon_2.texture = null

func set_pawn_color(color: Color) -> void:
	icon.self_modulate = color

func set_show_collar(show: bool) -> void:
	icon_3.visible = show

func set_relationship_text(text: String, color: Color = Color.WHITE) -> void:
	if text.is_empty():
		relationship_label.visible = false
		return
	relationship_label.visible = true
	relationship_label.text = text
	relationship_label["custom_colors/font_color"] = color
