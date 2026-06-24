extends RefCounted
class_name PartTrait

enum {
	PenisKnot,
	PenisBarbs,
	PenisRidges,
	PenisFlare,
	HornsGraspable,
	HornsSingle,
	TailFlexible,
	LegsDigi,
	LegsPlanti,
	LegsHoofs,
	ArmsBuff,
	HairBald,
	HairPonytail,
	HairOvereye,
	HairShort,
	HairLong,
	HairVeryShort,
	BreastsMale,
	BreastsFemale,
	AnusWomb,
	LaysEggs,
	Ovipositor,
	TRAITCOUNT,
}

const traitNames: Array = [
	"PenisKnot",
	"PenisBarbs",
	"PenisRidges",
	"PenisFlare",
	"HornsGraspable",
	"HornsSingle",
	"TailFlexible",
	"LegsDigi",
	"LegsPlanti",
	"LegsHoofs",
	"ArmsBuff",
	"HairBald",
	"HairPonytail",
	"HairOvereye",
	"HairShort",
	"HairLong",
	"HairVeryShort",
	"BreastsMale",
	"BreastsFemale",
	"AnusWomb",
	"LaysEggs",
	"Ovipositor",
]

static func textToTrait(traitName: String) -> int:
	return traitNames.find(traitName)
