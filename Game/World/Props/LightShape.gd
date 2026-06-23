@tool
extends Node2D

## MIGRATED to Godot 4 (GDScript 2.0).
## Editor tool for light shape props.

enum LightType {Default, Big, BigGlow}

const propData: Dictionary = {
	LightType.Default: {
		texture = preload("res://Images/WorldProps/LightShapes/default.png"),
		offset = [0, 4],
	},
	LightType.Big: {
		texture = preload("res://Images/WorldProps/LightShapes/big.png"),
		offset = [0, 4],
	},
	LightType.BigGlow: {
		texture = preload("res://Images/WorldProps/LightShapes/bigglow.png"),
		offset = [0, 4],
	},
}

@export var light_type: LightType = LightType.Default:
	set(value):
		light_type = value
		_update_prop()

@export var above_walls: bool = true:
	set(value):
		above_walls = value
		if value:
			z_index = 2
		else:
			z_index = -6

func _update_prop() -> void:
	if not propData.has(light_type):
		return
	var prop_info: Dictionary = propData[light_type]
	$WorldPropSprite.texture = prop_info["texture"]
	if "offset" in prop_info:
		$WorldPropSprite.offset.x = prop_info["offset"][0]
		$WorldPropSprite.offset.y = prop_info["offset"][1]
	else:
		$WorldPropSprite.offset = Vector2.ZERO
