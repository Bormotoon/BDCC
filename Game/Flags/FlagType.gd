extends Object
class_name FlagType

## MIGRATED to Godot 4 (GDScript 2.0).
## Flag type enum and validation utilities.

enum {
	Bool,
	Number,
	Text,
	Dict,
	Anything,
}

static func getDefaultValue(flag_type: int):
	match flag_type:
		Bool: return false
		Number: return 0
		Text: return ""
		Dict: return {}
	return false

static func isCorrectType(flag_type: int, value) -> bool:
	match flag_type:
		Bool: return value is bool
		Number: return value is float or value is int
		Text: return value is String
		Dict: return value is Dictionary
		Anything: return true
	return false

static func getVisibleName(flag_type: int) -> String:
	match flag_type:
		Bool: return "Bool"
		Number: return "Number"
		Text: return "Text"
		Dict: return "Dict"
		Anything: return "Anything"
	return "Error?"

static func is_correct_type(flag_type: int, value) -> bool:
	return isCorrectType(flag_type, value)
