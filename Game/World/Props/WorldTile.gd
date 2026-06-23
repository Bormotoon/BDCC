@tool
extends Node2D

## MIGRATED to Godot 4 (GDScript 2.0).
## Editor tool for floor tile props.

enum TileType {Floor1, Floor2, Floor3, WideStairs}

const propData: Dictionary = {
	TileType.Floor1: {texture = preload("res://Images/WorldTiles/old/floor1.png")},
	TileType.Floor2: {texture = preload("res://Images/WorldTiles/old/floor2.png")},
	TileType.Floor3: {texture = preload("res://Images/WorldTiles/old/floor3.png")},
	TileType.WideStairs: {texture = preload("res://Images/WorldTiles/old/widestairs.png")},
}

@export var tile_type: TileType = TileType.Floor1:
	set(value):
		tile_type = value
		_update_prop()

func _update_prop() -> void:
	if not propData.has(tile_type):
		return
	$WorldTileSprite.texture = propData[tile_type]["texture"]
