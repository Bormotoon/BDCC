extends DrugDenBoss1

func _init():
	id = "DrugDenBoss2"

func getBuffs():
	return [
		buff(Buff.DodgeChanceBuff, [30.0]),
	]
