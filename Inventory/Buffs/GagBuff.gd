extends BuffBase

func _init():
	id = Buff.GagBuff

func getVisibleDescription():
	return "Gags the wearer"

func apply(_buffHolder):
	_buffHolder.gagged = true

func getBuffColor():
	return Color.PURPLE
