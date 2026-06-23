@tool
extends Node2D

## MIGRATED to Godot 4 (GDScript 2.0).
## Editor tool for furniture props.

enum PropType {Bench, Bed, BedRed, BedLilac, CoolChair}

const propData: Dictionary = {
	PropType.Bench: {texture = preload("res://Images/WorldProps/bench.png")},
	PropType.Bed: {texture = preload("res://Images/WorldProps/bed.png")},
	PropType.BedRed: {texture = preload("res://Images/WorldProps/bedRed.png")},
	PropType.BedLilac: {texture = preload("res://Images/WorldProps/bedLilac.png")},
	PropType.CoolChair: {texture = preload("res://Images/WorldProps/coolchair.png")},
}

@export var prop_type: PropType = PropType.Bench:
	set(value):
		prop_type = value
		_update_prop()

@export var show_shadow: bool = true:
	set(value):
		show_shadow = value
		if $WorldPropSpriteShadow:
			$WorldPropSpriteShadow.visible = value

func _update_prop() -> void:
	if not propData.has(prop_type):
		return
	if $WorldPropSprite == null:
		return
	var prop_info: Dictionary = propData[prop_type]
	$WorldPropSprite.texture = prop_info["texture"]
	$WorldPropSpriteShadow.texture = prop_info["texture"]
