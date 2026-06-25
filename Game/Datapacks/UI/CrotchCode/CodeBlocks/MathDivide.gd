extends MathPlus

func doThing(a, b):
	if(b == 0):
		return INF
	return a / b

func getThingLabel():
	return "/"
