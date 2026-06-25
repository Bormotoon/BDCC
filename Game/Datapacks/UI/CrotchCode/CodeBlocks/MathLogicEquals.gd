extends MathLogicBiggerThan
class_name MathLogicEquals

func getCategories():
	return ["Math", "Logic"]

func thingOnlyNumbers():
	return false

func checkThing(a, b):
	return a == b

func getThingLabel():
	return "=="
