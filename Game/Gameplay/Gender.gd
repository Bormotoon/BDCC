extends Object
class_name Gender

## MIGRATED to Godot 4 (GDScript 2.0).
## Gender enum with string/pronoun helpers.

enum {
	Male,
	Female,
	Androgynous,
	Other,
}

static func genderToString(thegender: int) -> String:
	match thegender:
		Male: return "male"
		Female: return "female"
		Androgynous: return "androgynous"
		Other: return "other"
	return "error?"

static func genderToPronouns(thegender: int) -> String:
	match thegender:
		Male: return "He/his"
		Female: return "She/her"
		Androgynous: return "They/their"
		Other: return "It/its"
	return "error?"
