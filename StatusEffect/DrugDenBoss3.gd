extends DrugDenBoss1

func _init():
	id = "DrugDenBoss3"

func getBuffs():
	return [
		buff(Buff.PhysicalDamageBuff, [50.0]),
		buff(Buff.ReceivedPhysicalDamageBuff, [20.0]),
	]
