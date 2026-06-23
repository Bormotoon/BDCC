extends RefCounted
class_name Species

## MIGRATED to Godot 4 (GDScript 2.0).
## Base species definition with default bodypart assignments.

const Any: String = "any"
const AnyNPC: String = "anynpc"
const Human: String = "human"
const Feline: String = "feline"
const Dragon: String = "dragon"
const Canine: String = "canine"
const Equine: String = "equine"
const Demon: String = "demon"
const Unknown: String = "unknown"

var id: String = "error"

func getVisibleName() -> String:
	return "Error"

func getVisibleDescription() -> String:
	return "Not implemented"

func getDefaultLegs(_gender: int) -> String:
	return "plantilegs"

func getDefaultBreasts(_gender: int) -> String:
	if _gender == Gender.Male:
		return "malebreasts"
	return "humanbreasts"

func getDefaultHair(_gender: int) -> String:
	return "baldhair"

func getDefaultTail(_gender: int):
	return null

func getDefaultBody(_gender: int) -> String:
	return "anthrobody"

func getDefaultHead(_gender: int) -> String:
	return "humanhead"

func getDefaultArms(_gender: int) -> String:
	return "anthroarms"

func getDefaultEars(_gender: int) -> String:
	return "felineears"

func getDefaultHorns(_gender: int):
	return null

func getDefaultPenis(_gender: int):
	if _gender in [Gender.Male, Gender.Androgynous]:
		return "humanpenis"
	return null

func getDefaultVagina(_gender: int):
	if _gender in [Gender.Female, Gender.Androgynous]:
		return "vagina"
	return null

func getDefaultAnus(_gender: int) -> String:
	return "anus"

func getDefaultForSlot(slot: StringName, gender: int):
	match slot:
		BodypartSlot.Legs: return getDefaultLegs(gender)
		BodypartSlot.Breasts: return getDefaultBreasts(gender)
		BodypartSlot.Hair: return getDefaultHair(gender)
		BodypartSlot.Tail: return getDefaultTail(gender)
		BodypartSlot.Body: return getDefaultBody(gender)
		BodypartSlot.Head: return getDefaultHead(gender)
		BodypartSlot.Arms: return getDefaultArms(gender)
		BodypartSlot.Ears: return getDefaultEars(gender)
		BodypartSlot.Horns: return getDefaultHorns(gender)
		BodypartSlot.Penis: return getDefaultPenis(gender)
		BodypartSlot.Vagina: return getDefaultVagina(gender)
		BodypartSlot.Anus: return getDefaultAnus(gender)
	return null

func getCrossSpeciesCompatibility(_other_species_id: String) -> float:
	return 0.0

func getEggType() -> StringName:
	return &"none"

func getOnDynamicNpcCreation(_character) -> void:
	pass

func saveData() -> Dictionary:
	return {}

func loadData(_data: Dictionary) -> void:
	pass
