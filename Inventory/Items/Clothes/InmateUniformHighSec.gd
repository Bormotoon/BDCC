extends InmateUniformGeneral

func _init():
	id = "inmateuniformHighsec"
	inmateType = InmateType.HighSec

func getTags():
	return [
		ItemTag.HighSecurityInmateUniform,
		]
