extends Node
class_name DamageType

## MIGRATED to Godot 4 (GDScript 2.0).
## Damage type enum with name/color helpers.

enum {
	Physical,
	Lust,
	Stamina
}

static func getAll() -> Array:
	return [Physical, Lust, Stamina]

static func getName(type: int) -> String:
	match type:
		Physical: return "Physical"
		Lust: return "Lust"
		Stamina: return "Stamina"
	return "Error"

static func getBattleName(type: int) -> String:
	match type:
		Physical: return "pain"
		Lust: return "lust"
		Stamina: return "stamina damage"
	return "error bad"

static func getColor(type: int) -> Color:
	match type:
		Physical: return Color("#FF9A8E")
		Lust: return Color.VIOLET
		Stamina: return Color.CORNFLOWER_BLUE
	return Color.FLORAL_WHITE

static func getColorString(type: int) -> String:
	return "#" + getColor(type).to_html(false)

static func getDamageColoredString(damage_type: int, amount: int) -> String:
	return "[color=" + getColorString(damage_type) + "]" + str(amount) + " " + getBattleName(damage_type) + "[/color]"
