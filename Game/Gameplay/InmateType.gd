extends Object
class_name InmateType

## MIGRATED to Godot 4 (GDScript 2.0).

enum {
	General,
	HighSec,
	SexDeviant,
	Unknown,
}

const names: Array[String] = ["General", "HighSec", "SexDeviant", "Unknown"]

static func getAll() -> Array:
	return [General, HighSec, SexDeviant, Unknown]

static func getAllWithNames() -> Array:
	var result: Array = []
	for i in range(names.size()):
		result.append([i, names[i]])
	return result

static func getOfficialName(type: int) -> String:
	match type:
		General: return "general"
		HighSec: return "high-security"
		SexDeviant: return "sexual-deviant"
	return "Error"

static func getColorName(type: int) -> String:
	match type:
		General: return "orange"
		HighSec: return "red"
		SexDeviant: return "lilac"
		Unknown: return "pink"
	return "Error"
