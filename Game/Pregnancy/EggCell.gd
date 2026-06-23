extends RefCounted
class_name EggCell

## MIGRATED to Godot 4 (GDScript 2.0).
## Single egg cell with lifespan, impregnation, and gestation.

var life_span: int
var orifice_type: int = OrificeType.Vagina
var is_impregnated: bool = false
var mother_id: String = ""
var father_id: String = ""
var cause_id: String = ""
var progress: float = 0.0
var mother_species: Array = []
var result_species: Array = []
var result_gender: String = NpcGender.Male
var monozygotic: int = 1
var fetus_ready_for_birth: bool = false
var big_egg: bool = false
var big_egg_type: int = BigEggType.Fertilized
var laid_type: int = BigEggType.Fertilized
var laid_color: Color = Color.WHITE
var cycle = null

func _init() -> void:
	var options_lifespan: int = OPTIONS.getEggCellLifespanHours()
	options_lifespan = maxi(options_lifespan, 1)
	var min_range: int = int(options_lifespan / 4)
	var max_range: int = int(options_lifespan / 2)
	life_span = 60 * 60 * options_lifespan + RNG.randi_range(-60 * 60 * min_range, 60 * 60 * max_range)

## Monozygotic splitting (9% chance, lines 35-48)
func setMonozygotic() -> void:
	var chance := RNG.randf_range(0.00, 100.00)
	if chance > 9.00:
		return
	elif chance <= 0.01:
		monozygotic = 6
	elif chance <= 0.1:
		monozygotic = 5
	elif chance <= 0.6:
		monozygotic = 4
	elif chance <= 2.6:
		monozygotic = 3
	else:
		monozygotic = 2

func setMother(new_mother_id: String, new_mother_species: Array) -> void:
	mother_id = new_mother_id
	mother_species = new_mother_species

func getMotherID() -> String:
	return mother_id

func getFatherID() -> String:
	return father_id

func setCauserID(new_cause: String) -> void:
	cause_id = new_cause

func setOrifice(orif: int) -> void:
	orifice_type = orif

func getOrifice() -> int:
	return orifice_type

func getCycle():
	if cycle == null:
		return null
	return cycle.get_ref()

func removeMe() -> void:
	if cycle != null:
		getCycle().removeEgg(self)
		cycle = null

func getGestationTime() -> int:
	return life_span

func getProgress() -> float:
	return progress

func setProgress(new_progress: float) -> void:
	progress = new_progress

func isFetusReadyForBirth() -> bool:
	return fetus_ready_for_birth

func setFetusReadyForBirth(ready: bool) -> void:
	fetus_ready_for_birth = ready

func getResultSpecies() -> Array:
	return result_species

func setResultSpecies(species: Array) -> void:
	result_species = species

func getResultGender() -> String:
	return result_gender

func setResultGender(gender: String) -> void:
	result_gender = gender

func getMonozygotic() -> int:
	return monozygotic

func isImpregnated() -> bool:
	return is_impregnated

func setImpregnated(impregnated: bool) -> void:
	is_impregnated = impregnated

func isBigEgg() -> bool:
	return big_egg

func setBigEgg(is_big: bool) -> void:
	big_egg = is_big

func getBigEggType() -> int:
	return big_egg_type

func setBigEggType(egg_type: int) -> void:
	big_egg_type = egg_type

func getLaidType() -> int:
	return laid_type

func setLaidType(laid: int) -> void:
	laid_type = laid

func getLaidColor() -> Color:
	return laid_color

func setLaidColor(color: Color) -> void:
	laid_color = color

func saveData() -> Dictionary:
	return {}

func loadData(_data: Dictionary) -> void:
	pass
